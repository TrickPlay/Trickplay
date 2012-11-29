package org.frogx.service.api;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.dom4j.Element;
import org.frogx.service.api.exception.NotAllowedException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.xmpp.component.Component;
import org.xmpp.packet.JID;


/**
 * A Multi-User Gaming service is a XMPP component which 
 * manages game rooms and users.
 *
 */
public interface MUGService extends Component {
	
	/**
	 * The xml namespace of the multi-user game service.
	 */
	public static final String mugNS = "http://jabber.org/protocol/mug";
	
	/**
	 * The Suffix of the owner xml namespace.
	 */
	public static final String mugOwnerNS = "http://jabber.org/protocol/mug#owner";
	
	/**
	 * The Suffix of the user xml namespace.
	 */
	public static final String mugUserNS = "http://jabber.org/protocol/mug#user";
	
	/**
	 * Get the name of the service e.g. gaming for the domain 
	 * gaming.example.com.
	 * 
	 * @return the name of the multi-user game service.
	 */
	public String getName();
	
	/**
	 * Get the domain of the service e.g. gaming.example.com.
	 * 
	 * @return the domain of the multi-user game service.
	 */
	public String getDomain();
	
	/**
	 * Get the JID of the multi-user game service with the full service domain.
	 * 
	 * @return the domain of the service.
	 */
	public JID getAddress();
	
	/**
	 * Get a collection of the administrators JIDs.
	 * 
	 * @return A collection of the administrators JIDs.
	 */
	public Collection<JID> getAdmins();
	
	/**
	 * Get a human readable description of the multi-user game service.
	 * 
	 * @return the description of the service.
	 */
	public String getDescription();
	
	/**
	 * Assign the human readable description of multi-user game service.
	 * This short description of service is used for disco queries and such.
	 * 
	 * @param description Description of the service.
	 */
	public void setDescription(String description);
	
	/**
	 * Get true if the the multi-user game service is started and running.
	 * 
	 * @return true if the service is running, otherwise false.
	 */
	public boolean isServiceEnabled();
	
	/**
	 * Retuns the number of existing Rooms on the server (i.e. active or not, 
	 * in memory or not).
	 *
	 * @return the number of rooms provided by the service.
	 */
	public int getNumberRooms();
	
	/**
	 * Get the number of active multi-user rooms.
	 * 
	 * @return the number of rooms.
	 */
	public int getNumberActiveRooms();
	
	/**
	 * Get the number of saved multi-user rooms.
	 * 
	 * @return the number of rooms.
	 */
	public int getNumberSavedRooms();
	
	/**
	 * Retuns the total number of user sessions on this service.
	 *
	 * @return the number of user sessions on the server.
	 */
	public int getNumberUserSessions();
	
	public AppID registerApp(String appId, int version, JID requestorJID);
	
	public MUGApp getApp(AppID appID);
	
	/**
	 * Registers a new MultiUserGame implementation to the service.
	 * 
	 * @param namespace the MultiUserGame disco feature namespace.
	 * @param gameClass the class which implements the MultiUserGame.
	 */
	public void registerMultiUserGame(MultiUserGame gameClass);
	
	/**
	 * Unregisters a MultiUserGame implementation.
	 * 
	 * @param namespace the MultiUserGame disco feature namespace.
	 */
	public void unregisterMultiUserGame(AppID appID, String gameName);
	public void unregisterMultiUserGame(String gamens);
	
	/**
	 * Get the games supported by the service.
	 * 
	 * @return the namespaces and classes that are supported.
	 */
	public Map<String, MultiUserGame> getSupportedGames();
	
	/**
	 * Obtains a game room.
	 * 
	 * @param roomName the name of the room.
	// * @param gameNamespace the namespace of the game played within the room.
	// * @param userJID the user which wants to get the room.
	 * @return the game room for the given name.
	 * @throws NotAllowedException if the room doesn't exist yet
	// * @throws UnsupportedGameException if the game isn't supported by this service.
	 */
	public MUGRoom getGameRoom(String roomName/*, String gameNamespace, JID userJID*/) 
		throws NotAllowedException/*, UnsupportedGameException*/;
	
	/**
	 * Obtains a game room.
	 * 
	 * @param roomName the name of the room.
	 * @param gameNamespace the namespace of the game played within the room.
	 * @param userJID the user which wants to get the room.
	 * @return a new created game room.
	 * @throws NotAllowedException if there are restrictions on this service to create a new room
	 * @throws UnsupportedGameException if the game isn't supported by this service.
	 */
	public MUGRoom createGameRoom(String gameNamespace, JID userJID) 
		throws NotAllowedException, UnsupportedGameException;

	/**
	 * Get a collection of all game rooms hosted by the service.
	 * 
	 * @return a collection of game rooms.
	 */
	public Collection<MUGRoom> getGameRooms();
	
	/**
	 * If a game room with the specified name exists this method returns true.
	 * 
	 * @param roomName the name of the game room.
	 * @return true if the room already exists otherwise false.
	 */
	public boolean hasRoom(String roomName);
	
	/**
	 * Add an additional service discovery identity to the service.
	 * 
	 * @param name the name of the identity.
	 * @param type the type of the identity (see XMPP Registrar for more details).
	 * @param category the category of the identity (see XMPP Registrar for 
	 * more details).
	 */
	public void addExtraIdentity(String category, String name, String type);
	
	/**
	 * Remove an additional service discovery identity from the service 
	 * (if exists).
	 * 
	 * @param name the name of the identity.
	 */
	public void removeExtraIdentity(String name);
	
	/**
	 * Obtains a collection of additional service discovery identities.
	 * 
	 * @return a collection of additional service discovery identities.
	 */
	public Collection<Element> getExtraIdentities();
	
	/**
	 * Add additional service discovery features for this service.
	 * 
	 * @param feature the namespace of the feature which wants to be added.
	 */
	public void addExtraFeature(String feature);
	
	/**
	 * Remove an additional service discovery feature from the service.
	 * 
	 * @param feature the namespace of the feature which wants to be removed.
	 */
	public void removeExtraFeature(String feature);
	
	/**
	 * Obtains a collection of additional service discovery features.
	 * 
	 * @return a collection of additional service discovery features.
	 */
	public Collection<String> getExtraFeatures();
	
	/**
	 * Remove a game room from this service.
	 * 
	 * @param roomName The name of the room.
	 */
	public void removeGameRoom(String roomName);
	
	public MUGPersistenceProvider getPersistenceProvider();
	
	public List<MUGRoom> getGameRooms(String gameNS, JID jid);
	
	public List<MUGRoom> getGameRooms(AppID appID, JID jid);
	
	public List<MUGRoom> getGameRooms(JID jid);
	
}
