package org.frogx.service.openfire;


import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.core.DefaultMUGService;

import org.frogx.service.openfire.util.DBConnector;
import org.frogx.service.openfire.util.OpenfireLocaleUtil;

import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.util.AlreadyExistsException;
import org.jivesoftware.util.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.component.ComponentManager;
import org.xmpp.component.ComponentManagerFactory;
import org.xmpp.packet.JID;
import org.xmpp.packet.Packet;

/**
 * The MUGPlugin provides an implementation of the Openfire
 * {@see Plugin} interface and a centralized management of the
 * configured {@see MUGService} and {@see MultiUserGame}.
 * Game plugins can register and unregister their support within the
 * {@see MUGService}.
 * Multi-User Gaming services can be configured to listen on multiple
 * domains.
 * 
 */
public class MUGPlugin implements Plugin, MUGManager {
	
	private static final Logger log = LoggerFactory.getLogger(MUGPlugin.class);
	
	/**
	 * The name of the plugin for loading the resource bundle.
	 */
	public static final String pluginName = "mug-service";
	
	/**
	 * The fallback description of a MUGService if no description
	 * is configured.
	 */
	private String defaultServiceDescription = null;
	
	/**
	 * All handled Multi-User Gaming components by subdomain.
	 */
	private ConcurrentHashMap<String, MUGService> mugServices = new ConcurrentHashMap<String, MUGService>();
	
	/**
	 * Implements the saving and loading of the configuration.
	 */
	private PersistenceProvider persistenceProvider = null;
	
	/**
	 * Provides logging and other utilities.
	 */
	private ComponentManager componentManager = null;
	
	/**
	 * The utility which provides localized strings.
	 */
	private LocaleUtil locale;
	
	/**
	 * All supported games by their namespace.
	 */
	private Map<String, MultiUserGame> games = new ConcurrentHashMap<String, MultiUserGame>();
	
	
	/**
	 * Called when plugin starts up, to initialize things.
	 * 
	 * @param manager The PluginManager of Openfire handles our plugin.
	 * @param pluginDirectory A java file descriptor of the current
	 *         plugin directory.
	 */
	public void initializePlugin(PluginManager manager, File pluginDirectory) {
		componentManager = ComponentManagerFactory.getComponentManager();
		locale = new OpenfireLocaleUtil();
		log.info("Starting Multi-User Gaming Plugin");
		
		// Create a provider for connection to stored data
		defaultServiceDescription = locale.getLocalizedString("mug.service-name");
		persistenceProvider = new DBConnector(defaultServiceDescription);
		
		// load all persistent services
		try {
			ConcurrentHashMap<String, String> loadServices = persistenceProvider
					.getGameServices();
			for (String subdomain : loadServices.keySet()) {
				registerMultiUserGameService(new DefaultMUGService(subdomain,
						loadServices.get(subdomain), this, null, persistenceProvider));
			}
		}
		catch (Exception e) {
			log.error("Unable to load Multi-User Game Services.", e);
		}
	}
	
	/**
	 * Called when the plugin is stopped, to clean things up.
	 */
	public void destroyPlugin() {
		log.info("Stopping Multi-User Gaming Plugin");
		
		// Unregister the current games
		for (String namespace : games.keySet()) {
			unregisterMultiUserGame(namespace);
		}
		
		// Unregister the managed services
		for (MUGService service : mugServices.values()) {
			unregisterMultiUserGameService(service.getName());
		}
		
		// free local attributes
		mugServices.clear();
		games.clear();
		persistenceProvider = null;
	}
	
	/**
	 * Registers a new {@see MultiUserGame} implementation. This is 
	 * typically used by several game plugins to support their game by
	 * the gaming components.
	 * 
	 * @param namespace The namespace represents the disco feature
	 *     namespace of the game.
	 * @param game Is the implementation of the MultiUserGame interface.
	 */
	public void registerMultiUserGame(String namespace, MultiUserGame game) {
		// TODO: Maybe manage the supported games for each service by the
		//       permanent storage
		for (MUGService service : mugServices.values()) {
			service.registerMultiUserGame(game);
		}
		
		games.put(namespace, game);
	}
	
	/**
	 * Unregisters a registered {@see MultiUserGame} implementation.
	 * This is typically used by several game plugins to stop
	 * supporting the game by the services.
	 * 
	 * @param namespace The namespace represents the disco feature
	 *     namespace of the game.
	 */
	public void unregisterMultiUserGame(String namespace) {
		log.debug("[MUG] Stop supporting: " + namespace);
		
		for (MUGService service : mugServices.values()) {
			service.unregisterMultiUserGame(namespace);
		}
		games.remove(namespace);
	}
	
	/**
	 * Registers a new {@see MUGService} implementation. This is
	 * typically used if you have a custom Multi-User Gaming
	 * implementation which you want to register.
	 * In other words, it may not be stored in the database
	 * and follow special rules, implementing {@see MUGService}.
	 * It is also used internally to register services from the
	 * database. Triggers the service to start up.
	 * 
	 * @param service The {@see MUGService} which is now registered.
	 */
	public void registerMultiUserGameService(MUGService service) {
		log.debug("[MUG]: Register service: " + service.getName());
		try {
			componentManager.addComponent(service.getName(), service);
			mugServices.put(service.getName().toLowerCase(), service);
		} catch (ComponentException e) {
			log.error("[MUG]: Unable to add "
					+ service.getName() + " as component.", e);
		}
	}
	
	/**
	 * Unregisters a {@see MUGService}. It can be used to explicitly
	 * unregister services, and is also used internally to unregister
	 * database stored services. Triggers the service to shut down.
	 * 
	 * @param subdomain The subdomain of the service to be unregistered.
	 */
	public void unregisterMultiUserGameService(String subdomain) {
		log.debug("[MUG]: Unregistering service: " + subdomain);
		MUGService service = getMultiUserGameService(subdomain);
		if (service != null) {
			service.shutdown();
			mugServices.remove(subdomain.toLowerCase());
			try {
				componentManager.removeComponent(subdomain);
			} catch (ComponentException e) {
				log.error("[MUG]: Unable to remove " + subdomain
						+ " from component manager.", e);
			}
		}
	}
	
	/**
	 * Creates a new {@see DefaultMUGService}, registers it and starts
	 * up the component.
	 * 
	 * @param subdomain Subdomain of the MUG service.
	 * @param description Description of the MUG service
	 *     (can be null for default description).
	 * @return {@see MUGService} implementation that was just created.
	 * @throws AlreadyExistsException if the service already exists or
	 * another Exception if we can't save the service.
	 */
	public MUGService createMultiUserGameService(String subdomain,
			String description) throws Exception {
		// do validation
		if (subdomain == null) {
			throw new IllegalArgumentException();
		}
		new JID(null,subdomain,null);
		if (mugServices.containsKey(subdomain.toLowerCase()))
			throw new AlreadyExistsException();
		
		// update persistent storage
		persistenceProvider.insertGameService(subdomain, description);
		if ((description == null) || (description.trim().length() == 0))
			description = defaultServiceDescription;
		
		// create and register the new component
		MUGService mug = new DefaultMUGService(subdomain, description,
				this, null, persistenceProvider);
		registerMultiUserGameService(mug);
		return mug;
	}
	
	/**
	 * Updates the configuration of a MUG service.
	 * This is more involved than it may seem. If the subdomain is
	 * changed, we need to shut down the old service and start up the
	 * new one, registering the new subdomain and cleaning up the old
	 * one.
	 * 
	 * @param curSubdomain The current subdomain assigned to the service.
	 * @param newSubdomain New subdomain to assign to the service.
	 * @param description New description to assign to the service.
	 * @throws NotFoundException if service was not found or another if
	 * something fails with the storage.
	 */
	public void updateMultiUserGameService(String curSubdomain,
			String newSubdomain, String description) throws Exception {
		if (curSubdomain == null) {
			throw new IllegalArgumentException();
		}
		MUGService mug = getMultiUserGameService(curSubdomain);
		if (mug == null)
			throw new NotFoundException();
		
		// A NotFoundException is thrown if the specified service was not found.
		if (mug == null)
			throw new NotFoundException();
		
		if ((newSubdomain == null) ||
				curSubdomain.equalsIgnoreCase(newSubdomain)) {
			// Alright, all we're changing the description. This is easy.
			try {
				persistenceProvider.updateGameService(curSubdomain, newSubdomain,
						description);
			} catch (Exception e) {
				log.error("[MUG] Unable to update service: " + curSubdomain, e);
				throw e;
			}
			// Update the existing service's description.
			if (description == null)
				description = getDefaultServiceDescription();
			mug.setDescription(description);
		}
		else {
			// Changing the subdomain, here's where it gets complex.
			// Unregister existing mug service
			unregisterMultiUserGameService(curSubdomain);
			// Update the information stored about the MUG service
			try {
				persistenceProvider.updateGameService(curSubdomain, newSubdomain,
						description);
			} catch (Exception e) {
				log.error("Unable to update MUGService: " + curSubdomain
						+ " to subdomain: " + newSubdomain, e);
				throw e;
			}
			// Create and register new MUG service with new settings
			if (description == null)
				description = getDefaultServiceDescription();
			mug = new DefaultMUGService(newSubdomain, description,
					this, null, persistenceProvider);
			registerMultiUserGameService(mug);
		}
	}
	
	/**
	 * Deletes a configured {@see MUGService} by subdomain, and shuts it
	 * down.
	 * 
	 * @param subdomain The subdomain of the service to be deleted.
	 * @throws NotFoundException if the service was not found or another
	 * if something fails with the storage.
	 */
	public void removeMultiUserGameService(String subdomain) throws Exception {
		if (subdomain == null) {
			throw new IllegalArgumentException();
		}
		MUGService mug = getMultiUserGameService(subdomain);
		if (mug == null) {
			throw new NotFoundException();
		}
		unregisterMultiUserGameService(mug.getName());
		persistenceProvider.deleteGameService(subdomain);
	}
	
	/**
	 * Retrieves the default description for a {@see MUGService}. This
	 * description is used if none is specified.
	 * 
	 * @return The {@see MUGService} default description.
	 */
	public String getDefaultServiceDescription() {
		return defaultServiceDescription;
	}
	
	/**
	 * Retrieves a {@see MUGService} instance specified by it's
	 * subdomain of the server's primary domain. In other words, if the
	 * service is games.example.org, and the server is example.org, you
	 * would specify games here.
	 * 
	 * @param subdomain The subdomain of the service you wish to query.
	 * @return The {@see MUGService} instance associated with the 
	 * subdomain, or null if none found.
	 */
	public MUGService getMultiUserGameService(String subdomain) {
		if (mugServices == null)
			return null;
		return mugServices.get(subdomain.toLowerCase());
	}
	
	/**
	 * Retrieves a {@see MUGService} instance specified by any JID that
	 * refers to it. In other words, it can be a hostname for the
	 * service, a match JID, or even the JID of a occupant of the match.
	 * Basically it takes the hostname part of the JID, strips off the
	 * server hostname from the end, leaving only the subdomain, and then
	 * calls the subdomain version of the call.
	 * 
	 * @param jid JID that contains a reference to the gaming service.
	 * @return The {@see MUGService} instance associated with the JID, or
	 * null if none found.
	 */
	public MUGService getMultiUserGameService(JID jid) {
		String subdomain = jid.getDomain().replace(
				"." + XMPPServer.getInstance().getServerInfo().getXMPPDomain(),
				"");
		return getMultiUserGameService(subdomain);
	}
	
	/**
	 * Retrieves all of the Multi-User Game services managed and
	 * configured for this server, sorted by subdomain.
	 * 
	 * @return A list of Multi-User Gaming services configured for this
	 * server.
	 */
	public List<MUGService> getMultiUserGameServices() {
		List<MUGService> services = new ArrayList<MUGService>(mugServices
				.values());
		Collections.sort(services, new ServiceComparator());
		return services;
	}
	
	/**
	 * Retrieves the number of Multi-User Game services that are 
	 * configured for this server.
	 * 
	 * @return The number of registered Multi-User Gaming services.
	 */
	public Integer getServicesCount() {
		if (mugServices == null)
			return 0;
		return mugServices.size();
	}
	
	/**
	 * Returns true if a {@see MUGService} is configured/exists for a 
	 * given subdomain.
	 * 
	 * @param subdomain Subdomain of service to check on.
	 * @return True if the subdomain is registered as a MUG service.
	 */
	public boolean isServiceRegistered(String subdomain) {
		if ((mugServices == null) || (subdomain == null))
			return false;
		return mugServices.containsKey(subdomain);
	}
	
	/**
	 * Returns true if a {@see MultiUserGame} is configured for this
	 * server.
	 * 
	 * @param namespace The namespace of the MultiUserGame
	 *     (disco#info namespace).
	 * @return True if the game is registered for this server.
	 */
	public boolean isGameRegistered(String namespace) {
		if ((games == null) || (namespace == null))
			return false;
		return games.containsKey(namespace);
	}
	
	/**
	 * Retrieve a list of all configured {@see MultiUserGame} instances
	 * which are configured.
	 * 
	 * @return A collection of registered games.
	 */
	public List<MultiUserGame> getRegisteredGames() {
		List<MultiUserGame> mugGames = new ArrayList<MultiUserGame>(games
				.values());
		Collections.sort(mugGames, new GameComparator());
		return mugGames;
	}
	
	private static class ServiceComparator implements Comparator<MUGService> {
		public int compare(MUGService o1, MUGService o2) {
			return o1.getName().compareTo(o2.getName());
		}
	}
	
	private static class GameComparator implements Comparator<MultiUserGame> {
		public int compare(MultiUserGame o1, MultiUserGame o2) {
			return o1.getGameID().getNamespace().compareTo(o2.getGameID().getNamespace());
		}
	}

	public LocaleUtil getLocaleUtil() {
		return locale;
	}

	public String getServerName() {
		return componentManager.getServerName();
	}

	public void sendPacket(MUGService mugService, Packet packet)
			throws ComponentException {
		componentManager.sendPacket(mugService, packet);
	}
}
