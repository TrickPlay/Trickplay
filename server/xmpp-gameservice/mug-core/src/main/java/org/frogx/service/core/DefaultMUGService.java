/**
 * Copyright (C) 2008-2009 Guenther Niess. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.frogx.service.core;



import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ConcurrentHashMap;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGPersistenceProvider;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.exception.ForbiddenException;
import org.frogx.service.api.exception.NotAllowedException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.frogx.service.core.iq.IQDiscoInfoHandler;
import org.frogx.service.core.iq.IQDiscoItemsHandler;
import org.frogx.service.core.iq.IQSearchHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.component.ComponentManager;
import org.xmpp.packet.IQ;
import org.xmpp.packet.JID;
import org.xmpp.packet.Packet;

/**
 * The first implementation of a {@see MUGService}.
 * A Multi-User Gaming service is a XMPP component which 
 * manages game rooms and user sessions.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public class DefaultMUGService implements MUGService {
	
	private static final Logger log = LoggerFactory.getLogger(DefaultMUGService.class);
	
	/**
	 * the game service's hostname (subdomain)
	 */
	private String serviceName;
	
	/**
	 * the game service's description
	 */
	private String description;
	
	/**
	 * Flag that indicates if MUG service is enabled.
	 */
	private boolean serviceEnabled;
	
	/**
	 * The Multi-User Gaming manager for sending packets, etc.
	 */
	private MUGManager mugManager = null;
	
	/**
	 * Utility for storing informations
	 */
	private MUGPersistenceProvider storage = null;
	
	/**
	 * Additional identities to be added to the disco response for the service.
	 */
	private List<Element> extraDiscoIdentities = new ArrayList<Element>();
	
	/**
	 * Additional features to be added to the disco response for the service.
	 */
	private List<String> extraDiscoFeatures = new ArrayList<String>();
	
	/**
	 * Handle iq disco info queries.
	 */
	private IQDiscoInfoHandler iqDiscoInfoHandler;
	
	/**
	 * Handle iq disco items queries.
	 */
	private IQDiscoItemsHandler iqDiscoItemsHandler;
	
	/**
	 * Handle iq search queries.
	 */
	private IQSearchHandler iqSearchHandler;
	
	/**
	 * A list of user sessions.
	 */
	private Map<JID, DefaultMUGSession> sessions = new ConcurrentHashMap<JID, DefaultMUGSession>();
	
	/**
	 * Supported games with disco info namespace.
	 */
	private Map<String, MultiUserGame> games = null;
	
	/**
	 * A collection of the categories supported by the games on this service.
	 */
	private List<String> gameCategories = new ArrayList<String>();
	
	/**
	 * The local game rooms.
	 */
	private Map<String, MUGRoom> rooms = null;
	
	/**
	 * local game rooms sorted by game
	 */
	private Map<String, List<MUGRoom>> roomsByGame = new ConcurrentHashMap<String, List<MUGRoom>>();
	
	/**
	 * The local game rooms sorted by the categories.
	 */
	private Map<String, List<MUGRoom>> roomsByCategory = new ConcurrentHashMap<String, List<MUGRoom>>();
	
	/**
	 * Returns the permission policy for creating rooms.
	 */
	private boolean roomCreationRestricted = false;
	
	/**
	 * A list of the administrators bare JIDs, these can create and destroy rooms.
	 */
	private Collection<JID> admins;
	
	/**
	 * The time to elapse (default is 5 minutes) between clearing of idle game sessions.
	 */
	private int timeouttask = 300000;
	
	/**
	 * The number of milliseconds (default is two days) a user session
	 * must be idle before he/she gets kicked from all the rooms.
	 */
	private int sessiontimeout = 172800000;
	
	/**
	 * Timer to monitor game sessions.
	 */
	private Timer timer = new Timer("MUG session cleanup");
	
	/**
	 * Task that cleanup idle sessions and maybe kick users from the rooms.
	 */
	private SessionTimeoutTask sessionTimeoutTask;
	
	
	/**
	 * Create a new multi user game server.
	 *
	 * @param subdomain Subdomain portion of the games services (for example, games for games.example.org)
	 * @param description Short description of service for disco and such.
	 * @param games A map of the supported games with the disco info namespace and implementing class.
	 */
	public DefaultMUGService(String subdomain, String description, MUGManager mugManager,
			Map<String, MultiUserGame> games, MUGPersistenceProvider storage) {
		this.serviceName      = subdomain;     
		this.description      = description;
		this.mugManager       = mugManager;
		this.games            = games;
		this.rooms            = new ConcurrentHashMap<String, MUGRoom>();
		this.serviceEnabled   = false;
		this.storage          = storage;
		
		iqDiscoInfoHandler = new IQDiscoInfoHandler(this, mugManager);
		iqDiscoItemsHandler = new IQDiscoItemsHandler(this);
		iqSearchHandler = new IQSearchHandler(this, mugManager);
		
		// initialize game categories
		for (MultiUserGame game : games.values()) {
			if (!gameCategories.contains(game.getCategory().toLowerCase()))
				gameCategories.add(game.getCategory().toLowerCase());
		}
	}
	
	public void initialize(JID jid, ComponentManager componentManager) throws ComponentException {
		loadPropertys();
	}
	
	public void loadPropertys() {
		try {
			String value = null;
			value = storage.getServiceProperty(serviceName, "enabled");
			if (value != null && 
					(value.toLowerCase().equals("false") || 
							(value.equals("0")))) {
				serviceEnabled = false;
			}
			
			value = storage.getServiceProperty(serviceName, "restricted");
			if (value != null && 
					(value.toLowerCase().equals("true") || 
							(value.equals("1")))) {
				roomCreationRestricted = true;
			}
			
			value = storage.getServiceProperty(serviceName, "timeouttask");
			if (value != null) {
				try {
					timeouttask = Integer.parseInt(value);
				}
				catch (NumberFormatException e) {
					log.error("[MUG] Error while parsing "
							+ serviceName + ".timeouttask.", e);
				}
			}
			
			value = storage.getServiceProperty(serviceName, "sessiontimeout");
			if (value != null) {
				try {
					sessiontimeout = Integer.parseInt(value);
				}
				catch (NumberFormatException e) {
					log.error("[MUG] Error while parsing "
							+ serviceName + ".usertimeout.", e);
				}
			}
			
			admins = storage.getServiceAdmins(serviceName);
		}
		catch (Exception e) {
			if (log != null)
			log.error("[MUG] Error while loading service properties.", e);
		}
	}
	
	public void start() {
		if (sessionTimeoutTask == null) {
			// Run through the users every 5 minutes after a 5 minutes server startup delay (default
			// values)
			sessionTimeoutTask = new SessionTimeoutTask();
			timer.schedule(sessionTimeoutTask, timeouttask, timeouttask);
		}
		
		serviceEnabled = true;
	}
	
	public void shutdown() {
		serviceEnabled = false;
		
		timer.cancel();
		if (sessionTimeoutTask != null) {
			sessionTimeoutTask = null;
		}
	}
	
	/**
	 * Get the subdomain of the multi user gaming service.
	 * 
	 * @return the subdomain of the service.
	 */
	public String getName() {
		return serviceName;
	}
	
	/**
	 * Get the full domain of the multi user gaming service.
	 * 
	 * @return the domain of the service.
	 */
	public String getDomain() {
		if (!serviceEnabled)
			return null;
		return serviceName + "." + mugManager.getServerName();
	}
	
	/**
	 * Get a collection of the administrators JIDs.
	 * 
	 * @return A collection of the administrators JIDs.
	 */
	public Collection<JID> getAdmins() {
		return admins;
	}
	
	/**
	 * Get the JID of the multi user gaming service with the full service domain.
	 * 
	 * @return the subdomain of the service.
	*/
	public JID getAddress() {
		return new JID(null, getDomain(), null, true);
	}
	
	/**
	 * Get a human readable description of the multi user gaming service.
	 * 
	 * @return the description of the service.
	 */
	public String getDescription() {
		return description;
	}
	
	/**
	 * Get a human readable description of the multi user gaming service.
	 * 
	 * @param desc the description of the service.
	 */
	public void setDescription(String desc) {
		this.description = desc;
	}
	
	/**
	 * Get true if the the multi user gaming service is started and running.
	 * 
	 * @return true if the service is running, otherwise false.
	 */
	public boolean isServiceEnabled() {
		return serviceEnabled;
	}
	
	/**
	 * Get the number of active and saved Multi-user Game rooms.
	 * 
	 * @return the number of rooms.
	 */
	public int getNumberRooms() {
		// TODO: Implement this
		return rooms.size();
	}
	
	/**
	 * Get the number of active game rooms.
	 * 
	 * @return the number of rooms.
	 */
	public int getNumberActiveRooms() {
		// TODO: Implement this
		return rooms.size();
	}
	
	/**
	 * Get the number of saved game rooms.
	 * 
	 * @return the number of rooms.
	 */
	public int getNumberSavedRooms() {
		// TODO: Implement this
		return 0;
	}
	
	/**
	 * Retuns the total number of user sessions within the service.
	 *
	 * @return the number of user sessions on the server.
	 */
	public int getNumberUserSessions() {
		return sessions.size();
	}
	
	/**
	 * Processes a packet sent to this Component.
	 *
	 * @param packet the packet.
	 */
	public void processPacket(Packet packet) {
		if (!isServiceEnabled()) {
			return;
		}
		// TODO: Remove debug output
		log.info("[MUG]: Processing: " + packet.toXML());
		System.out.println(packet.toXML());
		
		// The MUG service will receive all the packets whose domain matches the domain of the MUG
		// service. This means that, for instance, a disco request should be responded by the
		// service itself instead of relying on the server to handle the request.
		try {
			// Check if the packet is a disco or jabber search request
			if (packet instanceof IQ) {
				if (process((IQ)packet)) {
					return;
				}
			}
			getGameSession(packet.getFrom()).process(packet);
		}
		catch (Exception e) {
			log.error(mugManager.getLocaleUtil().getLocalizedString("admin.error"), e);
		}
		
	}
	
	private DefaultMUGSession getGameSession(JID realJID) {
		DefaultMUGSession session = sessions.get(realJID);
		if (session == null) {
			session = new DefaultMUGSession(this, mugManager, realJID);
			sessions.put(realJID, session);
		}
		return session;
	}

	/**
	 * Returns true if the IQ packet was processed. This method should only process disco packets
	 * as well as jabber:iq:search packets sent to the MUG service.
	 *
	 * @param iq the IQ packet to process.
	 * @return true if the IQ packet was processed.
	 */
	private boolean process(IQ iq) {		
		Element childElement = iq.getChildElement();
		String namespace = null;
		IQ reply = null;
		// Ignore IQs of type ERROR
		if (IQ.Type.error == iq.getType()) {
			return false;
		}
		if (iq.getTo().getResource() != null) {
			// Ignore here IQ packets sent to room occupants
			// these are handled in MUGRooms
			return false;
		}
		if (childElement != null) {
			namespace = childElement.getNamespaceURI();
		}
		if ("jabber:iq:search".equals(namespace)) {
			reply = iqSearchHandler.handleIQ(iq);
		}
		else if ("http://jabber.org/protocol/disco#info".equals(namespace)) {
			reply = iqDiscoInfoHandler.handleIQ(iq);
		}
		else if ("http://jabber.org/protocol/disco#items".equals(namespace)) {
			reply = iqDiscoItemsHandler.handleIQ(iq);
		}
		else {
			return false;
		}
		try {
			// TODO: Remove debug output
			log.debug("[MUG]: Sending: " + reply.toXML());
			
			mugManager.sendPacket(this, reply);
		}
		catch (Exception e) {
			log.error("[MUG] Error while sending an IQ stanza.",e);
		}
		return true;
	}
	
	/**
	 * Register a Multi-User Game
	 *
	 * @param game is the MultiUserGame which will be registered.
	 */
	public void registerMultiUserGame(String namespace, MultiUserGame game) {
		if (!gameCategories.contains(game.getCategory().toLowerCase()))
			gameCategories.add(game.getCategory().toLowerCase());
		games.put(namespace, game);
	}
	
	/**
	 * Unregister a Multi-User Game
	 *
	 * @param namespace The namespace of the MultiUserGame which will be unregistered.
	 */
	public void unregisterMultiUserGame(String namespace) {
		MultiUserGame game = games.get(namespace);
		for( MUGRoom room : getGameRooms() ) {
			if (room.getGame().getNamespace().equals(namespace))
				try {
					removeGameRoom(room.getName());
				} catch (ForbiddenException e) {
					log.error("[MUG] Can't remove room: ", e);
				}
		}
		games.remove(namespace);
		
		// remove the game category if it isn't supported anymore
		if (game != null) {
			boolean removeCategory = true;
			String category = game.getCategory().toLowerCase();
			for( MultiUserGame g : games.values() ) {
				if (g.getCategory().toLowerCase().equals(category))
					removeCategory = false;
			}
			if (removeCategory)
				gameCategories.remove(category);
		}
	}
	
	/**
	 * Get the supported game classes.
	 * 
	 * @return the namespaces and classes that are supported.
	 */
	public Map<String, MultiUserGame> getSupportedGames() {
		return games;
	}
	
	public MultiUserGame getGame(String gamens) {
		return games.get(gamens);
	}
	
	/**
	 * Get a collection of the supported game categories.
	 * 
	 * @return a collection of the game categories that are supported.
	 */
	public Collection<String> getGameCategories() {
		return gameCategories;
	}
	
	/**
	 * Obtains a game room by name. If the game room does not exists then null will be returned.
	 * 
	 * @param roomName Name of the room to get.
	 * @return The game room for the given name or null if the room does not exists.
	 */
	public MUGRoom getGameRoom(String roomName) {
		if (rooms.containsKey(roomName)) {
			return rooms.get(roomName);
		} else {
			throw new NotAllowedException();
		}
	}
	
	public boolean isRoomCreationRestricted() {
		return roomCreationRestricted;
	}
	
	public MUGRoom createGameRoom(String gameNamespace, JID userJID) 
			throws NotAllowedException, UnsupportedGameException {
		MUGRoom room = null;
		// Check permissions
		if (isRoomCreationRestricted()
				&& !(admins.contains(userJID.toBareJID()))) {
			throw new NotAllowedException();
		}

		// Check Game Support
		MultiUserGame game = games.get(gameNamespace);
		if (game == null)
			throw new UnsupportedGameException();

		
		// Create Room
		room = new DefaultMUGRoom(this, mugManager, game, userJID);

		// Add to the room to the list which is sorted by the game categories
		String category = game.getCategory().toLowerCase();
		if (!roomsByCategory.containsKey(category))
			roomsByCategory.put(category, new ArrayList<MUGRoom>());
		if (!roomsByGame.containsKey(gameNamespace))
			roomsByGame.put(gameNamespace, new ArrayList<MUGRoom>());

		roomsByCategory.get(category).add(room);
		roomsByGame.get(gameNamespace).add(room);
		rooms.put(room.getName(), room);
		return room;
	}
	
	public Collection<MUGRoom> getGameRooms() {
		return rooms.values();
	}
	
	public boolean hasRoom(String roomName) {
		if (rooms == null || roomName == null)
			return false;
		return rooms.containsKey(roomName);
	}
	
	public void addExtraFeature(String feature) {
		if ( !extraDiscoFeatures.contains(feature) )
			extraDiscoFeatures.add(feature);
	}
	
	public void removeExtraFeature(String feature) {
		extraDiscoFeatures.remove(feature);
	}
	
	public List<String> getExtraFeatures() {
		return extraDiscoFeatures;
	}
	
	/**
	 * Adds an extra Disco identity to the list of identities returned for the conference service.
	 * @param category Category for identity.  e.g. conference
	 * @param name Descriptive name for identity.  e.g. Public Chatrooms
	 * @param type Type for identity.  e.g. text 
	 */
	public void addExtraIdentity(String category, String name, String type) {
		Element identity = DocumentHelper.createElement("identity");
		identity.addAttribute("category", category);
		identity.addAttribute("name", name);
		identity.addAttribute("type", type);
		extraDiscoIdentities.add(identity);
	}
	
	/**
	 * Removes an extra Disco identity from the list of identities returned for the conference service.
	 * @param name Name of identity to remove.
	 */
	public void removeExtraIdentity(String name) {
		for (Element elem : extraDiscoIdentities) {
			if (name.equals(elem.attribute("name").getStringValue())) {
				extraDiscoFeatures.remove(elem);
				break;
			}
		}
	}
	
	public List<Element> getExtraIdentities() {
		return extraDiscoIdentities;
	}
	
	public void removeGameRoom(String roomName) {
		MUGRoom room = rooms.get(roomName);
		
		if (room == null) {
			// No room found
			return;
		}
		
		String category = room.getGame().getCategory().toLowerCase();
		room.destroy();
		rooms.remove(roomName);
		if (roomsByCategory.containsKey(category))
			roomsByCategory.get(category).remove(room);
	}
	
	public Collection<MUGRoom> getGameRoomsByCategory(String category) {
		return roomsByCategory.containsKey(category.toLowerCase()) ? 
				roomsByCategory.get(category.toLowerCase()) : 
					new ArrayList<MUGRoom>();
	}
	
	public Collection<MUGRoom> getGameRoomsByGame(String gamens) {
		return gamens != null && roomsByGame.containsKey(gamens) ? 
				roomsByGame.get(gamens) : 
					new ArrayList<MUGRoom>();
	}

	
	/**
	 * Probes the presence of any user who's last packet was sent more than 5 minute ago.
	 */
	private class SessionTimeoutTask extends TimerTask {
		/**
		 * Remove any user session that has been idle for longer than the session timeout.
		 */
		public void run() {
			checkForTimedOutSessions();
		}
	}
	
	private void checkForTimedOutSessions() {
		final long deadline = System.currentTimeMillis() - sessiontimeout;
		for (DefaultMUGSession session : sessions.values()) {
			try {
				// If user is not present in any room then remove the session
				if (!session.isParticipant()) {
					removeSession(session.getAddress());
					continue;
				}
				// Do nothing if this feature is disabled (i.e sessiontimeout equals -1)
				if (sessiontimeout < 1) {
					continue;
				}
				if (session.getLastPacketTime() < deadline) {
					removeSession(session.getAddress());
				}
			}
			catch (Throwable e) {
				log.error(mugManager.getLocaleUtil().getLocalizedString("admin.error"), e);
			}
		}
	}
	
	private void removeSession(JID jabberID) {
		DefaultMUGSession session = sessions.remove(jabberID);
		if (session != null) {
			/*
			for (MUGOccupant occupant : session.getOccupants()) {
				try {
					occupant.getGameRoom().leave(occupant);
				}
				catch (Exception e) {
					log.error("Can't leave game room: " + jabberID, e);
				}
			}
			*/
		}
	}
	
	public MUGPersistenceProvider getPersistenceProvider() {
		return storage;
	}
}
