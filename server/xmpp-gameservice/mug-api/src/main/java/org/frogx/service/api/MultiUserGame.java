package org.frogx.service.api;




/**
 * A MultiUserGame provides information about the implemented
 * game and handles {@see MUGMatch} instances.
 */
public interface MultiUserGame {
	
	/**
	 * Gets the xml namespace of the implemented game which can be discovered.
	 * 
	 * @return the namespace of the game.
	 */
	public String getNamespace(); 
	
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
	
	public boolean isCorrespondence();
	
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
