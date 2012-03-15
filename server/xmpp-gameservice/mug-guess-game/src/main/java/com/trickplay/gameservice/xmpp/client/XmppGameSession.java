package com.trickplay.gameservice.xmpp.client;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import com.trickplay.gameservice.xmpp.mug.GameDataExtension;
import com.trickplay.gameservice.xmpp.mug.GamePlayListener;
import com.trickplay.gameservice.xmpp.mug.GamePresenceExtension.Item;
import com.trickplay.gameservice.xmpp.mug.MatchStateExtension;
import com.trickplay.gameservice.xmpp.mug.MatchStateListener;
import com.trickplay.gameservice.xmpp.mug.Participant;
import com.trickplay.gameservice.xmpp.mug.PlayerStatusListener;
import com.trickplay.gameservice.xmpp.mug.TurnMessage;

public abstract class XmppGameSession implements MatchStateListener,
		PlayerStatusListener, GamePlayListener {

	protected GameServiceProxy xmppManager;
	protected String gameId;
	protected String gameName;
	protected AtomicBoolean gameOver = new AtomicBoolean();

	protected String matchId;

	private String matchStatus = "";
	private String role = "";
	private boolean joined = false;
	private boolean turnAck = false;

	public enum CommandType {
		PLAY, MATCH_COMPLETED, LEFT_MATCH
	};

	public static interface Command {
		CommandType getCommandType();
	}

	public static class PlayCommand implements Command {
		private String role;

		public PlayCommand(String role) {
			this.role = role;
		}

		public CommandType getCommandType() {
			return CommandType.PLAY;
		}

		public String getRole() {
			return role;
		}
	}

	public static class MatchCompletedCommand implements Command {
		public MatchCompletedCommand() {
		}

		public CommandType getCommandType() {
			return CommandType.MATCH_COMPLETED;
		}

	}
	
	public static class LeftMatchCommand implements Command {
		private String participant;
		public LeftMatchCommand(String participant) {
			this.participant = participant;
		}

		public String getParticipant() {
			return participant;
		}
		public CommandType getCommandType() {
			return CommandType.LEFT_MATCH;
		}

	}

	private BlockingQueue<Command> commandQueue = new ArrayBlockingQueue<XmppGameSession.Command>(
			1);

	public abstract String getUserName();

	public abstract String getPassword();

	public abstract void updateState(String state);

	protected final GameServiceProxy getXmppManager() {
		return xmppManager;
	}

	public XmppGameSession(String gameName) throws Exception {
		xmppManager = new GameServiceProxy("localhost", 5222);
		xmppManager.init();
		xmppManager.registerGamePlayListener(this);
		xmppManager.registerMatchStateListener(this);
		xmppManager.registerParticipantStatusListener(this);

		xmppManager.performLogin(getUserName(), getPassword());
		xmppManager.setStatus(true, "Hello everyone");

		this.gameName = gameName;
		this.gameId = "http://jabber.org/protocol/mug/" + gameName;

		xmppManager.printRoster();
	}

	public synchronized void destroy() {
		try {
			if (xmppManager != null)
				xmppManager.destroy();
		} finally {
			xmppManager = null;
		}
	}

	public boolean isGameOver() {
		return gameOver.get();
	}

	public String getGameId() {
		return gameId;
	}
	
	public void leaveMatch() throws Exception {
		// start the match
		System.out.println(getUserName() + " leaving match");
		xmppManager.leaveMatch(matchId);
		

		System.out.println("sent request to leave the match");
	}

	public void startMatch(String role) throws Exception {
		System.out.println(getUserName() + " creating new match for game "
				+ gameName);
		// create a match
		matchId = xmppManager.createMatch(gameId);
		System.out.println(getUserName() + " new match created. matchId "
				+ matchId);

		System.out.println(getUserName() + " joining match " + matchId
				+ " with role player1");
		// join the match
		xmppManager.joinMatch(matchId, false, role);

		// wait till join match finishes successfully
		int attempts = 0;
		int max_attempts = 10;
		while (!isJoined() && attempts < max_attempts) {
			attempts++;
			Thread.sleep(2000);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to join match. aborting");
			throw new RuntimeException(
					"Join match did not complete successfully in 20 seconds. aborting");
		}
		System.out.println(getUserName() + " joined match successfully");

		// start the match
		System.out.println(getUserName() + " starting match");
		xmppManager.startMatch(matchId);

		// start match will complete when a presence message arrives with match
		// status = "active"
		attempts = 0;
		while (!isStarted() && attempts < max_attempts) {
			attempts++;
			Thread.sleep(2000);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to start match. aborting");
			throw new RuntimeException(
					"Start match did not complete successfully in 20 seconds. aborting");
		}

		System.out.println("match started successfully");

	}

	public synchronized void setRole(String role) {
		this.role = role;
	}

	public synchronized String getRole() {
		return role;
	}

	public synchronized void setMatchStatus(String newStatus) {
		matchStatus = newStatus != null ? newStatus : "";
	}

	public synchronized String getMatchStatus() {
		return matchStatus;
	}

	public synchronized void setTurnAckReceived(boolean flag) {
		this.turnAck = flag;
	}

	public synchronized boolean isTurnAckReceived() {
		return turnAck;
	}

	public synchronized void setJoined(boolean joined) {
		this.joined = joined;
	}

	public synchronized boolean isJoined() {
		return joined;
	}

	public boolean isStarted() {
		return getMatchStatus().equals("active");
	}

	public boolean isActive() {
		return getMatchStatus().equals("active");
	}

	public void start(Participant from) {
		System.out.println("received state message from:" + from.getNick());
	}

	public Command getCommand() throws InterruptedException {
		return commandQueue.take();
	}

	public void turn(Participant from, TurnMessage turnMessage) {
		try {
			System.out.println("received turn message from:" + from.getNick()
					+ ". message:" + turnMessage.toXML());
			if (getUserName().equals(from.getNick())) {
				setTurnAckReceived(true);
				return;
			}
			updateState(turnMessage.getNewState());
			//if (getRole().equals(turnMessage.getNextTurn())) {
			if (!turnMessage.isTerminate())
				commandQueue.add(new PlayCommand(turnMessage.getNextTurn()));
			else
				commandQueue.add(new MatchCompletedCommand());
			// }
		} catch (Exception ex) {
			System.out.println("failed to process turn event");
			ex.printStackTrace();
		}
	}

	public void joined(Participant from, Item item) {
		System.out.println("received join message from:" + from.getNick() + ". item:"
				+ item.toXML());
		// check whether you successfully joined the match
		if (from.getNick().equals(getUserName()) && item.getRole() != null
				&& !item.getRole().isEmpty()) {
			setJoined(true);
			setRole(item.getRole());
		}
	}

	public void unavailable(Participant participant) {
		
	}
	
	public void left(Participant participant) {
		commandQueue.add(new LeftMatchCommand(participant.getNick()));
	}

	public void nicknameChanged(Participant participant, String newNickname) {
		// TODO Auto-generated method stub

	}

	public void currentMatchState(String status, MatchStateExtension matchState) {
		System.out.println("received current match state. status:" + status
				+ ". matchState:" + matchState.toXML());
		updateState(matchState.getOpaque());
		setMatchStatus(status);
		if (isActive()) {
			// if (getRole().equals(matchState.getNext())) {
			try {
				commandQueue.add(new PlayCommand(matchState.getNext()));
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			// }
		} else if (matchState.isTerminated()) {
			gameOver.set(true);
			commandQueue.add(new MatchCompletedCommand());
		}

	}
	
	protected void updateUserdata(MatchResult result) {
		try {
			String userData = xmppManager.getUserdata(gameId);
			if (userData != null) {
				UserGameData gameData = UserGameData.parseFromJSON(userData);
				gameData.setPlayed(gameData.getPlayed()+1);
				switch (result) {
				case WON:
					gameData.setWins(gameData.getWins()+1);
					break;
				case LOST:
					gameData.setLosses(gameData.getLosses()+1);
					break;
				}
				xmppManager.setUserdata(gameId, gameData.toJSON());
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public GameDataExtension getMatchdata() {
		try {
			return xmppManager.getMatchdata(gameId);

		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return null;
	}
	

}
