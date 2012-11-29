package org.frogx.service.api;



/**
 * A MultiUserGame provides information about the implemented
 * game and handles {@see MUGMatch} instances.
 */
public interface MultiUserGame {
	public interface RoleConfig {
		public String getRole();
		public boolean isFirstRole();
		public boolean isNotAllowedToStart();
	}
	public enum GameType {
		correspondence, online;
		
		public static GameType fromString(String gameType) {
			if (correspondence.name().equals(gameType)) {
				return correspondence;
			} else if (online.name().equals(gameType)) {
				return online;
			}
			return null;
		}
	}
	
	public enum TurnPolicy {
		roundrobin, simultaneous, specifiedRole, custom;
		
		public static TurnPolicy fromString(String turnPolicy) {
			if (roundrobin.name().equals(turnPolicy)) {
				return roundrobin;
			} else if (simultaneous.name().equals(turnPolicy)) {
				return simultaneous;
			} else if (specifiedRole.name().equals(turnPolicy)) {
				return specifiedRole;
			} else if (custom.name().equals(turnPolicy)) {
				return custom;
			}
			return custom;
		}
	}
	
	public GameID getGameID();
	
	
	
	/**
	 * Get the human readable description of the game.
	 * 
	 * @return the human readable description of the game.
	 */
	public String getDescription();
	
	/**
	 * Get the category of the game e.g. board, cards, etc.
	 * 
	 * @return the category of the game.
	 */
	public String getCategory();
	
	//public boolean isCorrespondence();
	
	public GameType getGameType();
	
	public TurnPolicy getTurnPolicy();
	
	public boolean allowsJoinAfterStart();
	
	public int getMinPlayersForStart();
	
	public RoleConfig getRoleConfig(String role);
	
	public String[] getRoles();
	
	public String getFirstRole();
	
	public long getMaxAllowedTimeForMove();
	
	public boolean abortWhenPlayerLeaves();
//	public 
	
	/**
	 * Create a match which implements the game logic within a
	 * game room.
	 * 
	 * @param room The MUGRoom which offers the match.
	 * @return The created MUGMatch.
	 */
	public MUGMatch createMatch(MUGRoom room);
	
	/**
	 * Destroy the match in the specified game room.
	 * 
	 * @param room The MUGRoom which hosts the match.
	 */
	public void destroyMatch(MUGRoom room);
}
