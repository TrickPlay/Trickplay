package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import javax.validation.constraints.NotNull;

import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.Vendor;


public class VendorTO {
	private Long id;
	@NotNull
	private String name;
    
    private Long primaryContactId;
    private String primaryContactName;
    private List<GameStruct> games = new ArrayList<VendorTO.GameStruct>();


	public static class GameStruct {
    	private Long id;
    	private String name;
    	private String appId;
    	
    	public GameStruct(Long id, String name, String appId) {
    		this.id = id;
    		this.name = name;
    		this.appId = appId;
    	}

		public Long getId() {
			return id;
		}

		public void setId(Long id) {
			this.id = id;
		}

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public String getAppId() {
			return appId;
		}

		public void setAppId(String appId) {
			this.appId = appId;
		}
    }
    public VendorTO() {
    	
    }
    
    public VendorTO(Long id, String name, Long contactId, String contactName, List<Game> games) {
    	this.id = id;
    	this.name = name;
    	this.primaryContactId = contactId;
    	this.primaryContactName = contactName;
    	if (games!=null) {
    		for(Game g: games) {
    			this.games.add(new GameStruct(g.getId(), g.getName(), g.getAppId()));
    		}
    	}
    }
    
    public VendorTO deepCopy() {
    	VendorTO copy = new VendorTO(id, name, primaryContactId, primaryContactName, null);
    	copy.setGames(deepCopy(games));
    	return copy;
    }
    
    private List<GameStruct> deepCopy(List<GameStruct> gamelist) {
    	if (gamelist==null)
    		return null;
    	List<GameStruct> retval = new ArrayList<GameStruct>();
    	for(GameStruct gs: gamelist) {
    		retval.add(new GameStruct(gs.getId(), gs.getName(), gs.getAppId()));
    	}
    	return retval;
    }
    
    public VendorTO(Vendor v) {
    	if (v==null)
    		throw new IllegalArgumentException("Vendor is null");
    	this.id = v.getId();
    	this.name = v.getName();
    	this.primaryContactId = v.getPrimaryContact()!=null ? v.getPrimaryContact().getId() : null;
    	this.primaryContactName = v.getPrimaryContact()!=null ? v.getPrimaryContact().getUsername() : null;
    	if (v.getGames()!=null) {
    		for(Game g: v.getGames()) {
    			this.games.add(new GameStruct(g.getId(), g.getName(), g.getAppId()));
    		}
    	}
    }
	 
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Long getPrimaryContactId() {
		return primaryContactId;
	}
	public void setPrimaryContactId(Long primaryContactId) {
		this.primaryContactId = primaryContactId;
	}
	public String getPrimaryContactName() {
		return primaryContactName;
	}
	public void setPrimaryContactName(String primaryContactName) {
		this.primaryContactName = primaryContactName;
	}
    public List<GameStruct> getGames() {
		return games;
	}

	public void setGames(List<GameStruct> games) {
		this.games = games;
	}
}
