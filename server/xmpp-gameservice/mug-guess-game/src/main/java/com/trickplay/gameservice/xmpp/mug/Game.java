package com.trickplay.gameservice.xmpp.mug;

import java.util.ArrayList;
import java.util.List;

public class Game {

	public static class RoleConfig {
		private String role;
		private boolean cannotStart;
		private boolean firstRole;
		
		public RoleConfig(String role, boolean cannotStart, boolean firstRole) {
			this.role = role;
			this.cannotStart = cannotStart;
			this.setFirstRole(firstRole);
		}
		
		public RoleConfig(String role) {
			this(role, false, false);
		}

		public String getRole() {
			return role;
		}

		public void setRole(String role) {
			this.role = role;
		}

		public boolean isCannotStart() {
			return cannotStart;
		}

		public void setCannotStart(boolean cannotStart) {
			this.cannotStart = cannotStart;
		}

		public void setFirstRole(boolean firstRole) {
			this.firstRole = firstRole;
		}

		public boolean isFirstRole() {
			return firstRole;
		}
	}
	public enum GameType {
    	correspondence, online;
    }
    
    public enum TurnPolicy {
    	roundrobin, simultaneous, specifiedRole
    }
    
	private String description;
	private String appname;
	private int appversion;

	private String name;
	private String category;
    private List<RoleConfig> roles = new ArrayList<RoleConfig>();
    private boolean joinAfterStart = true;
    private int minPlayersForStart = 1;
    private TurnPolicy turnPolicy = TurnPolicy.roundrobin;
    private GameType gameType = GameType.correspondence;
    private long maxDurationPerTurn=0;
    private boolean abortWhenPlayerLeaves;
    
    
	public String getAppname() {
		return appname;
	}

	public void setAppname(String appname) {
		this.appname = appname;
	}

	public int getAppversion() {
		return appversion;
	}

	public void setAppversion(int appversion) {
		this.appversion = appversion;
	}
	
	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public TurnPolicy getTurnPolicy() {
		return turnPolicy;
	}

	public void setTurnPolicy(TurnPolicy turnPolicy) {
		this.turnPolicy = turnPolicy;
	}

	public GameType getGameType() {
		return gameType;
	}

	public void setGameType(GameType gameType) {
		this.gameType = gameType;
	}

	public List<RoleConfig> getRoles() {
		return roles;
	}
	
	public void setRoles(List<RoleConfig> roles) {
		this.roles = roles;
	}

    public boolean isJoinAfterStart() {
		return joinAfterStart;
	}

	public void setJoinAfterStart(boolean joinAfterStart) {
		this.joinAfterStart = joinAfterStart;
	}

	public int getMinPlayersForStart() {
		return minPlayersForStart;
	}

	public void setMinPlayersForStart(int minPlayersForStart) {
		this.minPlayersForStart = minPlayersForStart;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getCategory() {
		return category;
	}

	public void setMaxDurationPerTurn(long maxDurationPerTurn) {
		this.maxDurationPerTurn = maxDurationPerTurn;
	}

	public long getMaxDurationPerTurn() {
		return maxDurationPerTurn;
	}

	public void setAbortWhenPlayerLeaves(boolean abortWhenPlayerLeaves) {
		this.abortWhenPlayerLeaves = abortWhenPlayerLeaves;
	}

	public boolean isAbortWhenPlayerLeaves() {
		return abortWhenPlayerLeaves;
	}
	
	public String getGameId() {
		return "urn:xmpp:mug:tp:"+appname+":"+appversion+":"+name;
	}

}
