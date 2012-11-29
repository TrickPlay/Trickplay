package org.frogx.service.api;

import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.util.LocaleUtil;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.Packet;


/**
 * The MUGManager is the interface for {@see MultiUserGame} plugins
 * to register and unregister their support within {@see MUGService}
 * components.
 * 
 */
public interface MUGManager {
	
	/**
	 * Returns true if a {@see MultiUserGame} is configured for this
	 * server.
	 * 
	 * @param namespace The namespace (disco#info) of the MultiUserGame.
	 * @return True if the game is registered for this server.
	 */
	public boolean isGameRegistered(String namespace);
	
	/**
	 * Registers a {@see MultiUserGame} at the multi-user game plugin
	 * which handles the {@see MUGService}.
	 * 
	 * @param namespace The namespace of the MultiUserGame which can be
	 *     discovered via disco#info queries.
	 * @param game The MultiUserGame which should be registered.
	 */
	public void registerMultiUserGame(String namespace, MultiUserGame game);
	
	/**
	 * Unregisters a {@see MultiUserGame} at the multi-user game plugin
	 * which handles the {@see MUGService}. For example if the Plugin is
	 * getting removed or if the game should no longer offered.
	 * 
	 * @param namespace The namespace (disco#info) of the MultiUserGame.
	 */
	public void unregisterMultiUserGame(String namespace);
	
	public String getServerName();
	
	public LocaleUtil getLocaleUtil();
	
	public void sendPacket(MUGService mugService, Packet packet) throws ComponentException;
}
