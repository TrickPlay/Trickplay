package com.trickplay.gameservice.xmpp.client;

import java.util.Random;

public class XmppGuessGamePlayer2 extends XmppGameSession {
		
	GuessGameState state;

	public XmppGuessGamePlayer2(String gameName) throws Exception {
		super(gameName);
	}
	
	

	@Override
	public String getUserName() {
		return "p2";
	}


	@Override
	public String getPassword() {
		return "saywhat";
	}

	public synchronized void setState(GuessGameState state) {
		this.state = state;
	}
	
	public synchronized GuessGameState getState() {
		return state;
	}

	@Override
	public void updateState(String opaqueState) {
		if (opaqueState != null && !opaqueState.isEmpty()) {
			GuessGameState newState = null;
			try {
				newState = GuessGameState.parseGuessGameStateFromJSON(opaqueState);
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			if (newState != null) {
				setState(newState);
			}
		}		
	}
	
	public String findAndJoin() throws Exception {
		System.out.println(getUserName() + " finding match for game " + gameName);
		// create a match
		matchId = xmppManager.findMatch(gameId);
		System.out.println(getUserName() + " found match to join. matchId " + matchId);

		System.out.println(getUserName() + " joining match " + matchId );
		// join the match
		xmppManager.joinMatch(matchId);
		
		
		// wait till join match finishes successfully
		int attempts = 0;
		int max_attempts = 10;
		while(!isJoined() && attempts < max_attempts) {
			attempts++;
			Thread.sleep(2000);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to join match. aborting");
			throw new RuntimeException("Join match did not complete successfully in 20 seconds. aborting");
		}
		System.out.println(getUserName() + " joined match successfully");
		return matchId;		
	}
	
	public void join(String matchId) throws Exception {
		xmppManager.joinMatch(matchId);
		
		this.matchId = matchId;
		// wait till join match finishes successfully
		int attempts = 0;
		int max_attempts = 10;
		while(!isJoined() && attempts < max_attempts) {
			attempts++;
			Thread.sleep(2000);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to join match. aborting");
			throw new RuntimeException("Join match did not complete successfully in 20 seconds. aborting");
		}
		System.out.println(getUserName() + " joined match successfully");	
	}

	public void play() throws Exception {
		
		int range = state.getHigh() - state.getLow() + 1;
		Random r = new Random();
		state.setGuess(state.getLow() + r.nextInt(range));
	    // 
		System.out.println(getUserName() + " guess:"+state.getGuess());
		xmppManager.sendTurn(matchId, state.toJSON(), false);
	}


	private static void printUsageAndExit() {
		System.out.println("usage is java XmppGuessGamePlayer1 [correspondence [roomToJoin] | online]");
		System.exit(0);
	}

	public static void main(String[] args) throws Exception {

		boolean correspondenceMode = false;
		XmppGuessGamePlayer2 p2 = null;
		String roomToJoin = "";
		try {
			if (args.length==0 || args.length>2) {
				correspondenceMode = false;
			} else if ("correspondence".equals(args[0])) {
				correspondenceMode = true;
				if (args.length==2)
					roomToJoin = args[1];
			} else if ("online".equals(args[0])) {
				correspondenceMode = false;
			} else {
				System.out.println("unknown game play mode "+args[0]+". defaulting to online mode");
				correspondenceMode = false;
			}
			p2 = new XmppGuessGamePlayer2("challenge27");
			
			if (!correspondenceMode) {
				while(!p2.isGameOver()) {
					Command cmd = p2.getCommand();
					switch(cmd.getCommandType()) {
					case PLAY:
						PlayCommand pcmd = (PlayCommand)cmd;
						if (pcmd.getRole().equals(p2.getRole()))
							p2.play();
						break;
					case MATCH_COMPLETED:
						GuessGameState state = p2.getState();
						System.out.println("match completed. state:"+state.toJSON());
						break;
					}
					
				}
			} else {
				// disconnect and join match after each move
				String matchId = "";
				if (roomToJoin.isEmpty()) {
					matchId = p2.findAndJoin();
					System.out.println("Joining match:" + matchId);
				} else {
					matchId = roomToJoin;
					p2.join(matchId);
				}

				do {
					Command cmd = p2.getCommand();
					switch (cmd.getCommandType()) {
					case PLAY:
						PlayCommand pcmd = (PlayCommand) cmd;
						if (pcmd.getRole().equals(p2.getRole()))
							p2.play();
						break;
					case MATCH_COMPLETED:						
						break;
					}

					if (!p2.isGameOver()) {
						p2.destroy();
						p2 = new XmppGuessGamePlayer2("challenge27");
						p2.join(matchId);
					} 
				} while (!p2.isGameOver());
				
				GuessGameState state = p2.getState();
				System.out.println("match completed. state:" + state.toJSON());

			}
			
		} catch (Exception ex) {
			ex.printStackTrace();
		} finally {
			if (p2 != null)
				p2.destroy();
		}
		System.exit(0);
	}


}
