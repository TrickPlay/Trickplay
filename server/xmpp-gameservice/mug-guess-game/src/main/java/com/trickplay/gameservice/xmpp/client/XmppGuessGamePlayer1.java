package com.trickplay.gameservice.xmpp.client;

import java.util.List;
import java.util.Random;

import com.trickplay.gameservice.xmpp.mug.Game;
import com.trickplay.gameservice.xmpp.mug.Game.GameType;
import com.trickplay.gameservice.xmpp.mug.Game.TurnPolicy;

public class XmppGuessGamePlayer1 extends XmppGameSession {
	
	private int MAX_ALLOWED_ATTEMPTS = 3;
	private boolean sentFirstTurn;
	private int secret;
	private GuessGameState state = new GuessGameState(0,9);
	
	public int getSecret() {
		return secret;
	}
	
	public GuessGameState getState() {
		return state;
	}

	public XmppGuessGamePlayer1() throws Exception {
		super();
	}
	
	public XmppGuessGamePlayer1(String domain, String host, int port) throws Exception {
		super(domain, host, port);
	}
	
	public String registerGame(String appname, int version, String gamename) throws Exception {
		List<String> allGames = xmppManager.getRegisteredGames();
		
		for (String game : allGames) {
			System.out.println("Game:" + game);
		}
		String gameId = "urn:xmpp:mug:tp:"+appname+":"+version+":"+gamename;
		if (!allGames.contains(gameId)) {
			Game g = new Game();
			g.setAppname(appname);
			g.setAppversion(version);
			g.setName(gamename);
			g.setDescription("guess the number in 3 attempts to win");
			g.setCategory("other");
			g.getRoles().add(new Game.RoleConfig("player1"));
			g.getRoles().add(new Game.RoleConfig("player2"));
			g.setJoinAfterStart(true);
			g.setGameType(GameType.correspondence);
			g.setTurnPolicy(TurnPolicy.roundrobin);
			g.setMaxDurationPerTurn(180000); // 3 minutes
			g.setAbortWhenPlayerLeaves(true);
			xmppManager.registerGame(g);
		}
		return gameId;
	}
	

	public void play(String matchId) throws Exception {
		// keep making moves until the game is over
		// send a turn
		if (!sentFirstTurn) {
			Random r = new Random();
			secret = r.nextInt(state.getHigh()+1);
			System.out.println("sending first turn. secret="+secret);
			setTurnAckReceived(matchId, false);
		    xmppManager.sendTurn(matchId, state.toJSON(), false);
		    
		    int attempts = 0;
		    int max_attempts = 10;
		    while(!isTurnAckReceived(matchId) && attempts < max_attempts) {
				attempts++;
				Thread.sleep(2000);
		    }
		    if (attempts >= max_attempts) {
				System.out.println("failed to receive acknowledgement for the sent turn. aborting");
				throw new RuntimeException("failed to receive acknowledgement for the sent turn. in 20 seconds. aborting");
			}
		    System.out.println("first turn successfully sent");
		    sentFirstTurn = true;
		    return;
		}
		
		if (state.getGuess() == secret) {
			state.setWon(true);
			xmppManager.sendTurn(matchId, state.toJSON(), true);
			updateUserdata(getGameId(matchId), MatchResult.LOST);
		} else {
			if (state.getAttempts() == MAX_ALLOWED_ATTEMPTS) {
				xmppManager.sendTurn(matchId, state.toJSON(), true);
				updateUserdata(getGameId(matchId), MatchResult.WON);
			} else {
				if (secret > state.getGuess())
					state.setLow(state.getGuess() + 1);
				else
					state.setHigh(state.getGuess() - 1);
				xmppManager.sendTurn(matchId, state.toJSON(), false);
			}
		}
	    // 
	}
	

	@Override
	public String getUserName() {
		return "p1";
	}

	@Override
	public String getPassword() {
		return "saywhat";
	}

	@Override
	public synchronized void updateState(String opaqueState) {
		if (opaqueState != null && !opaqueState.isEmpty()) {
			GuessGameState newState = null;
			try {
				newState = GuessGameState.parseGuessGameStateFromJSON(opaqueState);
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			if (newState != null) {
				state.setGuess(newState.getGuess());
				state.setAttempts(state.getAttempts() + 1);
			}
		}		
	}

	public static void main(String[] args) throws Exception {


		XmppGuessGamePlayer1 p1 = null;
		try {
			String domain = "gameservice.trickplay.com";
			String host = "gameservice.gameservice.trickplay.com";
			int port = 5222;
			if (args.length >= 1 && "use_localhost".equals(args[0])) {
				domain = "internal.trickplay.com";
				host = "localhost";
				port = 5222;
			}
			p1 = new XmppGuessGamePlayer1(domain, host, port);
			
			String appId = p1.registerApp("tpapps", 1);
			
			String gameId = p1.registerGame("tpapps", 1, "guessgame");
			
			p1.openApp(appId);
			
			String matchId = p1.startNewMatch(gameId, "player1");
			
			// obtain the list of matches player is currently participating in
			p1.getMatchdata(gameId);
			//
			while(!p1.isMatchOver(matchId)) {
				Command cmd = p1.getCommand();
				if (!matchId.equals(cmd.getMatchId()))
					continue;
				switch(cmd.getCommandType()) {
				case PLAY:
					PlayCommand pcmd = (PlayCommand)cmd;
					if (p1.getRole(matchId).equals(pcmd.getRole()))
					p1.play(matchId);
					break;
				case MATCH_COMPLETED:
					p1.leaveMatch(matchId);
					break;
				}
			}
			System.out.println("match completed. secret is "+p1.getSecret()+". player2 " 
					+ (p1.getState().isWon() ? "guessed correctly" : "failed to guess correctly")
					+ " in " + p1.getState().getAttempts() + " attempts");
			
		} catch (Exception ex) {
			ex.printStackTrace();
		} finally {
			if (p1!=null)
				p1.destroy();
		}
		System.exit(0);

	}

}
