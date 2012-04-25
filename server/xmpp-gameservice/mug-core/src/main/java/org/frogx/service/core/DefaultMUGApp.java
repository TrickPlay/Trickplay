package org.frogx.service.core;

import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.frogx.service.api.AppID;
import org.frogx.service.api.MUGApp;
import org.frogx.service.api.MultiUserGame;
import org.xmpp.packet.JID;

public class DefaultMUGApp implements MUGApp {
	
	private AppID appID;
	private String namespace;
	private JID createdBy;
	private Date creationDate;
	private HashSet<JID> admins;
	private Map<String, MultiUserGame> games;
	private Date updatedDate;

	public DefaultMUGApp(AppID appID, JID createdBy) {
		this(appID, createdBy, new Date(), null, null);
	}
	
	public DefaultMUGApp(AppID appID, JID createdBy, Date creationDate, Map<String, 
			MultiUserGame> games, Collection<JID> admins) {
		this.appID = appID;
		this.createdBy = createdBy;
		this.creationDate = creationDate;
		this.games = new ConcurrentHashMap<String, MultiUserGame>();
		if (games!=null)
			this.games.putAll(games);
		this.admins = new HashSet<JID>();
		if (createdBy!=null)
			this.admins.add(createdBy);
		if (admins != null)
			this.admins.addAll(admins);
		this.namespace = appID.getNamespace();
	}
	
	public String getNamespace() {
		return namespace;
	}

	public Map<String, MultiUserGame> getGames() {
		return games;
	}

	public JID createdBy() {
		return createdBy;
	}

	public Date getCreationDate() {
		return creationDate;
	}

	public Date getUpdatedDate() {
		return updatedDate;
	}

	public Set<JID> getAdmins() {
		return Collections.synchronizedSet(admins);
	}

	public AppID getAppID() {
		return appID;
	}

	public MultiUserGame getGame(String gameName) {
		return games.get(gameName);
	}
}
