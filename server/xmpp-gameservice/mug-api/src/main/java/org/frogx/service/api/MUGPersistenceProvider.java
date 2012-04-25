package org.frogx.service.api;

import java.util.Collection;

import org.xmpp.packet.JID;

/**
 * The MUGPersistenceProvider defines the data which must be provided
 * by a storage for Multi-User Gaming services.
 * 
 */
public interface MUGPersistenceProvider {
	
	/**
	 * Get a collection of the bare JIDs of administrators of a
	 * XMPP component.
	 * 
	 * @return A collection of administrators bare JIDs.
	 */
	public Collection<JID> getServiceAdmins(String subdomain) throws Exception;
	
	/**
	 * Get a property value for a specific Multi-User Gaming component
	 * or null if none is present.
	 * 
	 * @param subdomain The subdomain of the Multi-User Gaming component.
	 * @param name The name of the property.
	 * @param value The value of the property.
	 */
	public void setServiceProperty(String subdomain, String name, String value) throws Exception;
	
	/**
	 * Get a property value for a specific Multi-User Gaming component
	 * or null if none is present.
	 * 
	 * @param subdomain The subdomain of the Multi-User Gaming component.
	 * @param name The name of the property.
	 * @return The value of the property or null.
	 */
	public String getServiceProperty(String subdomain, String name) throws Exception;
	
	/**
	 * 
	 * @param username
	 * @param propertyName
	 * @return null if no property is found
	 */
	public MUGProperty getUserProperty(String username, String propertyName) throws Exception;
	
	/**
	 * creates a new property or updates an existing one if one already exists. version is incremented
	 * @param username
	 * @param propertyName
	 * @param value
	 * @return the contents of the persisted mug property
	 */
	public MUGProperty setUserProperty(String username, String propertyName, String value) throws Exception;
	
	/**
	 * either provided version should match or the property shouldn't exist for this to work 
	 * @param username
	 * @param property
	 * @return the contents of the persisted mug property
	 */
	public MUGProperty updateUserProperty(String username, MUGProperty property) throws Exception;
	
	/*
	public MUGApp createMUGApp(String appName, int version, JID requestor);
	
	public AppID getAppID(String appName, int version);
		
	public GameID createGame(AppID appID, String gamename, String gameconfig);
	
	public GameID getGameID(long appID, String gamename);
	
	public GameID getGameID(String appname, int version, String gamename);
	
	public RoomID createRoom(GameID game, JID owner, int status);
	*/
	//public 
}
