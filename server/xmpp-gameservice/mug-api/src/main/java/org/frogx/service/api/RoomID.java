package org.frogx.service.api;

import java.util.ArrayList;
import java.util.List;

public class RoomID {
	public static final long INVALID_ROOM_ID = -1L;

	private final GameID gameID;
	private long id;
	private String name;
	private int hash;
	
	public RoomID(long id, GameID gameID, String name) {
		this.name = name;
		this.gameID = gameID;
		this.id = id;
		
		List<Object> l = new ArrayList<Object>();
		l.add(gameID);
		l.add(name);
		hash = l.hashCode();
	}
	
	public RoomID(GameID gameID, String name) {
		this(INVALID_ROOM_ID, gameID, name);
	}
	
	public boolean equals(Object obj) {
		if (obj == null)
			return false;
		else if (obj == this)
			return true;
		MUGRoom other = (MUGRoom)obj;
		
		return other.getGame().equals(gameID) && other.getName().equals(name);
	}

	public int hashCode() {
		return hash;
	}
	
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public GameID getGameID() {
		return gameID;
	}

	public String getName() {
		return name;
	}
}

