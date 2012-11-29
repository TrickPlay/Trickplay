package org.frogx.service.api;

import java.util.ArrayList;

import org.frogx.service.api.util.CommonUtils;


public class AppID {
	public static final long INVALID_APP_ID = -1L;

	private long id;
	private final String name;
	private final int version;
	private final int hash;
	private final String namespace;
	
	public AppID(long id, String name, int version)  {
		this.id = id;
		this.name = name;
		this.version = version;

		ArrayList<Object> l = new ArrayList<Object>();
		l.add(name);
		l.add(new Integer(version));
		
		hash = l.hashCode(); 
		namespace = CommonUtils.buildAppNS(this);
	}
	
	public AppID(String name, int version)  {
		this(INVALID_APP_ID, name, version);
	}
	
	public void setID(long id) {
		this.id = id;
	}
	
	public long getID() {
		return id;
	}
	
	public String getName() {
		return name;
	}

	public int getVersion() {
		return version;
	}

	public boolean equals(Object obj) {
		if (obj == this)
			return true;
		else if (obj == null)
			return false;
		AppID other = (AppID) obj;
		return name.equals(other.getName()) && version == other.getVersion();
	}
	
	@Override
	public int hashCode() {
		return hash;
	}
	
	public String getNamespace() {
		return namespace;
	}
	
	public static boolean isValidName(String name) {
		if (name == null || name.isEmpty())
			return false;
		return CommonUtils.isValidWord(name);
	}
	
	public String toString() {
		return "AppID { id:"+id+", name:"+name+", version:"+version+" }";
	}
}
