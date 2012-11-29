package org.frogx.service.api;

import java.util.ArrayList;
import java.util.List;

import org.frogx.service.api.util.CommonUtils;


public class GameID {
	public static final long INVALID_GAME_ID = -1L;

	private long id;
	private final AppID appID;
	private final String name;
	private final int hash;
	private final String namespace;
	
	public GameID(long id, AppID appID, String name) {
		this.id = id;
		this.appID = appID;
		this.name = name;

		List<Object> l = new ArrayList<Object>();
		l.add(appID);
		l.add(name);
		this.hash = l.hashCode();
		
		this.namespace = CommonUtils.buildGameNS(this);
	}
	
	public GameID(AppID appID, String name) {
		this(INVALID_GAME_ID, appID, name);
	}

	public long getID() {
		return id;
	}
	
	public AppID getAppID() {
		return appID;
	}

	public String getName() {
		return name;
	}
	
	public int hashCode() {
		return hash;
	}
	
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		else if (obj == null)
			return false;
		GameID other = (GameID) obj;
		return other.getAppID().equals(appID) && other.getName().equals(name);			
	}
	
	public String toString() {
		return "GameID { id:"+id+", appID:" + appID + ", name:" + name + " }";
	}
	
	public String getNamespace() {
		return namespace;
	}
	
}

