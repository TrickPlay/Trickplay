package org.frogx.service.api;

import java.util.ArrayList;
import java.util.Date;
import java.util.Map;
import java.util.Set;

import org.frogx.service.api.util.CommonUtils;
import org.xmpp.packet.JID;


/**
 * A MultiUserGame provides information about the implemented
 * game and handles {@see MUGMatch} instances.
 */
public interface MUGApp {
	

	public AppID getAppID();

	/**
	 * Gets the xml namespace of the app.
	 * 
	 * @return the namespace of the app.
	 */
	public String getNamespace(); 
	
	public Map<String, MultiUserGame> getGames();
	
	public MultiUserGame getGame(String gameName);
	
	public JID createdBy();
	
	public Date getCreationDate();
	
	public Date getUpdatedDate();
	
	public Set<JID> getAdmins();
	
}
