package com.trickplay.gameservice.xmpp.client;

import java.util.Random;

public class XmppGuessGamePlayer2 extends XmppGameSession {
		
	GuessGameState state;

	public XmppGuessGamePlayer2() throws Exception {
		super();
	}
	
	public XmppGuessGamePlayer2(String domain, String host, int port) throws Exception {
		super(domain, host, port);
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
	
	public String findAndJoin(String gameId) throws Exception {
		System.out.println(getUserName() + " finding match for game " + gameId);
		// create a match
		String matchId = xmppManager.findMatch(gameId);
		System.out.println(getUserName() + " found match to join. matchId " + matchId);

		System.out.println(getUserName() + " joining match " + matchId );
	
		// join the match
		join(gameId, matchId); // obtains a free role also 
		
		return matchId;		
	}
	
	public void join(String gameId, String matchId) throws Exception {
		if (!matchInfoMap.containsKey(matchId))
			matchInfoMap.put(matchId, new MatchInfo(gameId, matchId));
		joinMatch(matchId);
		/*
		xmppManager.joinMatch(matchId);
		
		// wait till join match finishes successfully
		int attempts = 0;
		int max_attempts = 10;
		while(!isJoined(matchId) && attempts < max_attempts) {
			attempts++;
			Thread.sleep(2000);
		}
		if (attempts >= max_attempts) {
			System.out.println("failed to join match. aborting");
			throw new RuntimeException("Join match did not complete successfully in 20 seconds. aborting");
		}
		System.out.println(getUserName() + " joined match successfully");	
		*/
	}

	public void play(String matchId) throws Exception {
		
		int range = state.getHigh() - state.getLow() + 1;
		Random r = new Random();
		state.setGuess(state.getLow() + r.nextInt(range));
	    // 
		System.out.println(getUserName() + " guess:"+state.getGuess());
		xmppManager.sendTurn(matchId, state.toJSON(), false);
	}


	private static void printUsageAndExit() {
		System.out.println("usage is java XmppGuessGamePlayer2 [use_localhost] [correspondence [roomToJoin] | online]");
		System.exit(0);
	}

	public static void main(String[] args) throws Exception {

		boolean automode = false;
		boolean correspondenceMode = false;
		XmppGuessGamePlayer2 p2 = null;
		String roomToJoin = "";
		
		String domain = "gameservice.trickplay.com";
		String host = "gameservice.gameservice.trickplay.com";
		int port = 5222;
		for (int i=0; i<args.length; i++) {
			if ("use_localhost".equals(args[i])) {
				domain = "internal.trickplay.com";
				host = "localhost";
				port = 5222;
			} else if ("online".equals(args[i])) {
				correspondenceMode = false;
			} else if ("correspondence".equals(args[i])) {
				correspondenceMode = true;
				
				if (i+1 < args.length) {
					roomToJoin = args[i+1];
					i += 1;
				}
			}
		}
		
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
			p2 = new XmppGuessGamePlayer2(domain, host, port);
			String appname = "tpapps";
			int appversion = 1;
			String appId = "urn:xmpp:mug:tp:"+appname+":"+appversion;
			p2.openApp(appId);
			String gamename = "guessgame";
			String gameId = appId+":"+gamename;
			
			if (!correspondenceMode) {
				String matchId = p2.findAndJoin(gameId);
				// obtain the list of matches player is currently participating in
				p2.getMatchdata(gameId);
				while(!p2.isMatchOver(matchId)) {
					Command cmd = p2.getCommand();
					if (!matchId.equals(cmd.getMatchId()))
						continue;
					switch(cmd.getCommandType()) {
					case PLAY:
						PlayCommand pcmd = (PlayCommand)cmd;
						if (pcmd.getRole().equals(p2.getRole(matchId)))
							p2.play(matchId);
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
					matchId = p2.findAndJoin(gameId);
					System.out.println("Joining match:" + matchId);
				} else {
					matchId = roomToJoin;
					p2.join(gameId, matchId);
				}

				// obtain the list of matches player is currently participating in
				p2.getMatchdata(gameId);
				do {
					Command cmd = p2.getCommand();
					switch (cmd.getCommandType()) {
					case PLAY:
						PlayCommand pcmd = (PlayCommand) cmd;
						if (pcmd.getRole().equals(p2.getRole(matchId)))
							p2.play(matchId);
						break;
					case MATCH_COMPLETED:						
						break;
					}

					if (!p2.isMatchOver(matchId)) {
						p2.destroy();
						p2 = new XmppGuessGamePlayer2();
						p2.join(gameId, matchId);
					} 
				} while (!p2.isMatchOver(matchId) && automode);
				
				GuessGameState state = p2.getState();
				System.out.println("match state:" + state.toJSON());

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
