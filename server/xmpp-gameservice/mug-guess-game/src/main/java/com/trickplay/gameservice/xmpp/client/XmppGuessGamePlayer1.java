package com.trickplay.gameservice.xmpp.client;

import java.util.List;
import java.util.Random;

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

	public XmppGuessGamePlayer1(String gameName) throws Exception {
		super(gameName);
	}
	
	public void createGame() throws Exception {
		List<String> allGames = xmppManager.getRegisteredGames();
		
		for (String game : allGames) {
			System.out.println("Game:" + game);
		}
		
		if (!allGames.contains(gameId)) {
			Game g = new Game(gameName, "challenge game", "none", true);
			g.addRole("player1");
			g.addRole("player2");
			xmppManager.createGame(g);
		}
	}
	

	public void play() throws Exception {
		// keep making moves until the game is over
		// send a turn
		if (!sentFirstTurn) {
			Random r = new Random();
			secret = r.nextInt(state.getHigh()+1);
			System.out.println("sending first turn. secret="+secret);
			setTurnAckReceived(false);
		    xmppManager.sendTurn(matchId, state.toJSON(), false);
		    
		    int attempts = 0;
		    int max_attempts = 10;
		    while(!isTurnAckReceived() && attempts < max_attempts) {
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
			updateUserdata(MatchResult.LOST);
		} else {
			if (state.getAttempts() == MAX_ALLOWED_ATTEMPTS) {
				xmppManager.sendTurn(matchId, state.toJSON(), true);
				updateUserdata(MatchResult.WON);
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

			p1 = new XmppGuessGamePlayer1("challenge27");
			
			p1.createGame();
			
			p1.startMatch("player1");
			
			// obtain the list of matches player is currently participating in
			p1.getMatchdata();
			//
			while(!p1.isGameOver()) {
				Command cmd = p1.getCommand();
				switch(cmd.getCommandType()) {
				case PLAY:
					PlayCommand pcmd = (PlayCommand)cmd;
					if (p1.getRole().equals(pcmd.getRole()))
					p1.play();
					break;
				case MATCH_COMPLETED:
					p1.leaveMatch();
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
