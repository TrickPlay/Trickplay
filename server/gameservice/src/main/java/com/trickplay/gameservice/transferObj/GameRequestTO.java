package com.trickplay.gameservice.transferObj;

import com.trickplay.gameservice.domain.Game;

public class GameRequestTO {
	private String name;
	private String appId;
	private Long vendorId;
	private int minPlayers=1;
	private int maxPlayers=1;
	private boolean leaderboardFlag=true;
	private boolean achievementsFlag=true;
	private boolean enforceTurns=false;
	private boolean allowWildCardInvitation = false;

    public GameRequestTO() {
		
	}
		
	public GameRequestTO(String name, String appId, Long vendorId,
			int minPlayers, int maxPlayers,
			boolean leaderboardFlag, boolean achievementsFlag, boolean allowWildCardInvitation, boolean enforceTurns) {
		super();
		this.name = name;
		this.appId = appId;
		this.vendorId = vendorId;
		this.minPlayers = minPlayers;
		this.maxPlayers = maxPlayers;
		this.leaderboardFlag = leaderboardFlag;
		this.achievementsFlag = achievementsFlag;
		this.enforceTurns = enforceTurns;
		this.allowWildCardInvitation = allowWildCardInvitation;
	}

	public GameRequestTO(Game game) {
		if (game==null)
			throw new IllegalArgumentException("Game is null");
		name = game.getName();
		appId = game.getAppId();
		vendorId = game.getVendor()!=null?game.getVendor().getId():null;
		minPlayers = game.getMinPlayers();
		maxPlayers = game.getMaxPlayers();
		leaderboardFlag = game.isLeaderboardFlag();
		achievementsFlag = game.isAchievementsFlag();
		enforceTurns = game.isEnforceTurns();
		allowWildCardInvitation = game.isAllowWildCardInvitation();
	}

	public Game toGame() {
		return new Game(null, name, appId, minPlayers, maxPlayers, leaderboardFlag, achievementsFlag, enforceTurns, allowWildCardInvitation);
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

	public Long getVendorId() {
		return vendorId;
	}

	public void setVendorId(Long vendorId) {
		this.vendorId = vendorId;
	}

	public int getMinPlayers() {
		return minPlayers;
	}

	public void setMinPlayers(int minPlayers) {
		this.minPlayers = minPlayers;
	}

	public int getMaxPlayers() {
		return maxPlayers;
	}

	public void setMaxPlayers(int maxPlayers) {
		this.maxPlayers = maxPlayers;
	}

	public boolean isLeaderboardFlag() {
		return leaderboardFlag;
	}

	public void setLeaderboardFlag(boolean leaderboardFlag) {
		this.leaderboardFlag = leaderboardFlag;
	}

	public boolean isAchievementsFlag() {
		return achievementsFlag;
	}

	public void setAchievementsFlag(boolean achievementsFlag) {
		this.achievementsFlag = achievementsFlag;
	}

    
    public boolean isEnforceTurns() {
        return enforceTurns;
    }

    public void setEnforceTurns(boolean enforceTurns) {
        this.enforceTurns = enforceTurns;
    }

    public boolean isAllowWildCardInvitation() {
        return allowWildCardInvitation;
    }

    public void setAllowWildCardInvitation(boolean allowWildCardInvitation) {
        this.allowWildCardInvitation = allowWildCardInvitation;
    }
	
}
