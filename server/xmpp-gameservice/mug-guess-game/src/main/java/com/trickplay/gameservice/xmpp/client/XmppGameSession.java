package com.trickplay.gameservice.xmpp.client;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import com.trickplay.gameservice.xmpp.mug.Game;
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

	public static class MatchInfo {
		private String matchStatus = "";
		private String role = "";
		
		private AtomicBoolean matchOver = new AtomicBoolean();
		private boolean joined = false;
		
		private boolean turnAck = false;

		public String getGameId() {
			return gameId;
		}

		public String getMatchId() {
			return matchId;
		}

		private boolean started;
		private final String gameId;
		private final String matchId;
		
		public MatchInfo(String gameId, String matchId) {
			this.gameId = gameId;
			this.matchId = matchId;
		}
		
		public synchronized String getMatchStatus() {
			return matchStatus;
		}

		public synchronized void setMatchStatus(String matchStatus) {
			this.matchStatus = matchStatus;
		}

		public synchronized String getRole() {
			return role;
		}

		public synchronized void setRole(String role) {
			this.role = role;
		}

		public boolean getMatchOver() {
			return matchOver.get();
		}

		public void setMatchOver(boolean val) {
			this.matchOver.set(val);
		}

		public synchronized boolean isJoined() {
			return joined;
		}

		public synchronized void setJoined(boolean joined) {
			this.joined = joined;
		}

		public synchronized boolean isTurnAck() {
			return turnAck;
		}

		public synchronized void setTurnAck(boolean turnAck) {
			this.turnAck = turnAck;
		}

		public synchronized void setStarted(boolean started) {
			this.started = started;
		}

		public synchronized boolean isStarted() {
			return started;
		}
		
		
	}
	
	protected Map<String, MatchInfo> matchInfoMap = Collections.synchronizedMap(new HashMap<String, MatchInfo>());
	private List<JoinListener> joinListeners = Collections.synchronizedList(new ArrayList<JoinListener>());
	private List<StartListener> startListeners = Collections.synchronizedList(new ArrayList<StartListener>());
	
	public interface JoinListener {
		public void joined(String matchId, Participant p, Item item);
	}
	
	public void addJoinListener(JoinListener joinListener) {
		joinListeners.add(joinListener);
	}
	
	public void removeJoinListener(JoinListener joinListener) {
		joinListeners.remove(joinListener);
	}
	

	public interface StartListener {
		public void start(String matchId, Participant from);
	}
	
	public void addStartListener(StartListener startListener) {
		startListeners.add(startListener);
	}
	
	public void removeStartListener(StartListener startListener) {
		startListeners.remove(startListener);
	}

	public enum CommandType {
		PLAY, MATCH_COMPLETED, LEFT_MATCH
	};

	public static interface Command {
		CommandType getCommandType();
		public String getMatchId();
	}

	public static class PlayCommand implements Command {
		private String matchId;
		private String role;

		public PlayCommand(String matchId, String role) {
			this.matchId = matchId;
			this.role = role;
		}

		public CommandType getCommandType() {
			return CommandType.PLAY;
		}

		public String getRole() {
			return role;
		}
		
		public String getMatchId() {
			return matchId;
		}
	}

	public static class MatchCompletedCommand implements Command {
		private String matchId;
		public MatchCompletedCommand(String matchId) {
			this.matchId = matchId;
		}

		public CommandType getCommandType() {
			return CommandType.MATCH_COMPLETED;
		}
		
		public String getMatchId() {
			return matchId;
		}

	}
	
	public static class LeftMatchCommand implements Command {
		private String matchId;
		private String participant;
		public LeftMatchCommand(String matchId, String participant) {
			this.matchId = matchId;
			this.participant = participant;
		}

		public String getParticipant() {
			return participant;
		}
		public CommandType getCommandType() {
			return CommandType.LEFT_MATCH;
		}
		public String getMatchId() {
			return matchId;
		}

	}

	private BlockingQueue<Command> commandQueue = new ArrayBlockingQueue<XmppGameSession.Command>(
			1);

	public abstract String getUserName();

	public abstract String getPassword();

	public abstract void updateState(String state);

	protected GameServiceProxy xmppManager;

	//protected String matchId;
	protected String currentApp;
	
	protected String xmppServerHost;
	protected String xmppDomain;
	protected int xmppPort;

	protected final GameServiceProxy getXmppManager() {
		return xmppManager;
	}

	public XmppGameSession() throws Exception {
		this("internal.trickplay.com", "localhost", 5222);
	}
	
	public XmppGameSession(String domain, String host, int port) throws Exception {
		xmppServerHost = host;
		xmppDomain = domain;
		xmppPort = port;
		
		xmppManager = new GameServiceProxy(domain, host, 5222);
		xmppManager.init();
		xmppManager.registerGamePlayListener(this);
		xmppManager.registerMatchStateListener(this);
		xmppManager.registerParticipantStatusListener(this);

		xmppManager.performLogin(getUserName(), getPassword());
		xmppManager.setStatus(true, "Hello everyone");

		xmppManager.printRoster();
		
	}

	public synchronized void destroy() {
		try {
			if (isAppOpen())
				closeApp();
			if (xmppManager != null)
				xmppManager.destroy();
		} catch (Exception e) {
		} finally {
			xmppManager = null;
		}
	}

	public String registerApp(String appname, int appversion) throws Exception {
		xmppManager.registerApp(appname, appversion);
		return "urn:xmpp:mug:tp:"+appname+":"+appversion;
	}
	
	public void registerGame(Game g) throws Exception {
		xmppManager.registerGame(g);
	}
	
	public void openApp(String appNS) throws Exception {
		// send open app message
		if (isAppOpen()) {
			throw new IllegalStateException("close the currentApp:"+currentApp+" before opening "+appNS );
		}
		xmppManager.openApp(appNS);
		this.currentApp = appNS;
	}
	
	public void closeApp() throws Exception {
		// send close app message
		if (!isAppOpen()) {
			System.out.println("no app currently open. invalid request");
			return;
		}
		xmppManager.closeApp(currentApp);
		this.currentApp = null;
	}
	
	public boolean isAppOpen() {
		return currentApp != null && !currentApp.isEmpty();
	}
	
	public String getCurrentApp() {
		return currentApp;
	}


	public String getAppNamespace() {
		return currentApp;
	}
	
	public void leaveMatch(String matchId) throws Exception {
		// start the match
		System.out.println(getUserName() + " leaving match");
		xmppManager.leaveMatch(matchId);
		

		System.out.println("sent request to leave the match");
	}

	class JoinResponseListener implements JoinListener {
		private final String trackedMatchId;
		JoinResponseListener(String matchId) {
			this.trackedMatchId = matchId;
		}
		
		public synchronized void joined(String matchId, Participant from, Item item) {
			System.out.println("received join message. matchId:"+matchId+", from:" + from.getNick() + ". item:"
					+ item.toXML());
			if (!trackedMatchId.equals(matchId)) {
				return;
			}
			MatchInfo minfo = matchInfoMap.get(matchId);
			// check whether you successfully joined the match
			if (from.getNick().equals(getUserName())) {
				minfo.setJoined(true);
				if (item.getRole() != null && !item.getRole().isEmpty()) {
					minfo.setRole(item.getRole());
				}
				notifyAll();
			}
		}
		
		public synchronized boolean isJoined() {
			MatchInfo minfo = matchInfoMap.get(trackedMatchId);
			return minfo.isJoined();
		}
		
		public synchronized String getRole() {
			MatchInfo minfo = matchInfoMap.get(trackedMatchId);
			return minfo.getRole();
		}
	}
	
	class StartMessageListener implements StartListener {
		private final String trackedMatchId;
		StartMessageListener(String gameId, String matchId) {
			this.trackedMatchId = matchId;
			if (!matchInfoMap.containsKey(matchId))
				matchInfoMap.put(matchId, new MatchInfo(gameId, matchId));
		}
		
		public synchronized void start(String matchId, Participant from) {
			System.out.println("received start message. matchId:"+matchId+", from:" + from.getNick());
			if (!trackedMatchId.equals(matchId)) {
				return;
			}
			MatchInfo minfo = matchInfoMap.get(matchId);
			minfo.setStarted(true);
			notifyAll();
			
		}
		
		public synchronized boolean isStarted() {
			MatchInfo minfo = matchInfoMap.get(trackedMatchId);
			return minfo.isStarted();
		}
		
	}
	
	public void joinMatch(String matchId) throws Exception {
		joinMatch(matchId, true, null);
	}
	
	public void joinMatch(String matchId, String role) throws Exception {
		joinMatch(matchId, false, role);
	}
	
	private void joinMatch(String matchId, boolean freerole, String role) throws Exception {
		int attempts = 0;
		int max_attempts = 10;
		JoinResponseListener joinListener = new JoinResponseListener(matchId);
		joinListeners.add(joinListener);
		try {
			xmppManager.joinMatch(matchId, freerole, role);

			// wait till join match finishes successfully
			synchronized (joinListener) {
				while (!joinListener.isJoined() && attempts < max_attempts) {
					attempts++;
					joinListener.wait(2000);
				}
			}
			
		} finally {
			joinListeners.remove(joinListener);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to join match. aborting");
			throw new RuntimeException(
					"Join match did not complete successfully in 20 seconds. aborting");
		}
		System.out.println(getUserName() + " joined match successfully");
	}
	
	public String startNewMatch(String gameId, String role) throws Exception {
		System.out.println(getUserName() + " creating new match for game "
				+ gameId);
		// create a match
		String matchId = xmppManager.createMatch(gameId);
		System.out.println(getUserName() + " new match created. matchId "
				+ matchId);

		System.out.println(getUserName() + " joining match " + matchId
				+ " with role player1");
		matchInfoMap.put(matchId, new MatchInfo(gameId, matchId));
		// join the match
		
		joinMatch(matchId, role);

		// start the match
		System.out.println(getUserName() + " starting match");
		StartMessageListener startListener = new StartMessageListener(gameId, matchId);
		startListeners.add(startListener);
		
		// start match will complete when a presence message arrives with match
		// status = "active"
		int attempts = 0;
		int max_attempts = 10;
		try {
			xmppManager.startMatch(matchId);
			synchronized (startListener) {
				while (!startListener.isStarted() && attempts < max_attempts) {
					attempts++;
					startListener.wait(2000);
				}
			}
		} finally {
			startListeners.remove(startListener);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to start match. aborting");
			throw new RuntimeException(
					"Start match did not complete successfully in 20 seconds. aborting");
		}

		System.out.println("match started successfully");
		return matchId;
	}


	public boolean isMatchOver(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo != null) {
				return minfo.getMatchOver();
		} else {
			throw new IllegalArgumentException("unknown matchId:"+matchId);
		}
	}
	
	public void setMatchOver(String matchId, boolean flag) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo != null) 
				minfo.setMatchOver(flag);
		
	}
	
	public void setMatchStatus(String matchId, String newStatus) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			minfo.setMatchStatus(newStatus != null ? newStatus : "");
	}

	public String getMatchStatus(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			return minfo.getMatchStatus();
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}

	public void setTurnAckReceived(String matchId, boolean flag) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			minfo.setTurnAck(flag);
	}

	public boolean isTurnAckReceived(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			return minfo.isTurnAck();
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}

	public void setJoined(String matchId, boolean joined) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			minfo.setJoined(joined);
	}

	public boolean isJoined(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			return minfo.isJoined();
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}

	public boolean isStarted(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo!=null)
			return minfo.getMatchStatus().equals("active");
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}

	public boolean isActive(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo != null)
			return minfo.getMatchStatus().equals("active");
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}
	
	public String getRole(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo != null)
			return minfo.getRole();
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}
	
	public String getGameId(String matchId) {
		MatchInfo minfo = matchInfoMap.get(matchId);
		if (minfo != null)
			return minfo.getGameId();
		throw new IllegalArgumentException("unknown matchId:"+matchId);
	}

	public void start(String matchId, Participant from) {
		System.out.println("received state message. matchId:"+matchId+", from:" + from.getNick());
		for (StartListener listener : startListeners) {
			listener.start(matchId, from);
		}
	}

	public Command getCommand() throws InterruptedException {
		return commandQueue.take();
	}

	public void turn(String matchId, Participant from, TurnMessage turnMessage) {
		try {
			System.out.println("received turn message from:" + from.getNick()
					+ ". message:" + turnMessage.toXML());
			if (getUserName().equals(from.getNick())) {
				setTurnAckReceived(matchId, true);
				return;
			}
			updateState(turnMessage.getNewState());
			//if (getRole().equals(turnMessage.getNextTurn())) {
			if (!turnMessage.isTerminate())
				commandQueue.add(new PlayCommand(matchId, turnMessage.getNextTurn()));
			else
				commandQueue.add(new MatchCompletedCommand(matchId));
			// }
		} catch (Exception ex) {
			System.out.println("failed to process turn event");
			ex.printStackTrace();
		}
	}

	public void joined(String matchId, Participant from, Item item) {
		for (JoinListener listener : joinListeners) {
			listener.joined(matchId, from, item);
		}
		/*
		System.out.println("received join message. matchId:"+matchId+", from:" + from.getNick() + ". item:"
				+ item.toXML());
		// check whether you successfully joined the match
		if (from.getNick().equals(getUserName()) && item.getRole() != null
				&& !item.getRole().isEmpty()) {
			setJoined(matchId, true);
			setRole(matchId, item.getRole());
		}
		*/
	}

	public void unavailable(String matchId, Participant participant) {
		
	}
	
	public void left(String matchId, Participant participant) {
		commandQueue.add(new LeftMatchCommand(matchId, participant.getNick()));
	}

	public void nicknameChanged(String matchId, Participant participant, String newNickname) {
		// TODO Auto-generated method stub

	}

	public void currentMatchState(String matchId, String status, MatchStateExtension matchState) {
		System.out.println("received current match state. status:" + status
				+ ". matchState:" + matchState.toXML());
		updateState(matchState.getOpaque());
		setMatchStatus(matchId, status);
		if (isActive(matchId)) {
			// if (getRole().equals(matchState.getNext())) {
			try {
				commandQueue.add(new PlayCommand(matchId, matchState.getNext()));
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			// }
		} else if (matchState.isTerminated()) {
			setMatchOver(matchId, true);
			commandQueue.add(new MatchCompletedCommand(matchId));
		}

	}
	
	protected void updateUserdata(String gameId, MatchResult result) {
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
	
	public GameDataExtension getMatchdata(String gameId) {
		try {
			return xmppManager.getMatchdata(gameId);

		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return null;
	}
	

}
