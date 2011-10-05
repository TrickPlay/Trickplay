package com.trickplay.gameservice.transferObj;

import com.trickplay.gameservice.domain.Game;

public class GameTO {
	private Long id;
	private String name;
	private String appId;
	private Long vendorId;
	private String vendorName;
	private int minPlayers=1;
	private int maxPlayers=1;
	private boolean leaderboardFlag=true;
	private boolean achievementsFlag=true;
	private boolean turnBasedFlag = false;
	private boolean enforceTurns=false;
	private boolean allowWildCardInvitation=false;
	
	public GameTO() {
		
	}
		
	public GameTO(Long id, String name, String appId, Long vendorId,
			String vendorName, int minPlayers, int maxPlayers,
			boolean leaderboardFlag, boolean achievementsFlag, 
			boolean turnBasedFlag, boolean allowWildCardInvitation, boolean enforceTurns) {
		super();
		this.id = id;
		this.name = name;
		this.appId = appId;
		this.vendorId = vendorId;
		this.vendorName = vendorName;
		this.minPlayers = minPlayers;
		this.maxPlayers = maxPlayers;
		this.leaderboardFlag = leaderboardFlag;
		this.achievementsFlag = achievementsFlag;
		this.turnBasedFlag = turnBasedFlag;
		this.allowWildCardInvitation = allowWildCardInvitation;
		this.enforceTurns = enforceTurns;
	}

	public GameTO(Game game) {
		if (game==null)
			throw new IllegalArgumentException("Game is null");
		id = game.getId();
		name = game.getName();
		appId = game.getAppId();
		vendorId = game.getVendor()!=null?game.getVendor().getId():null;
		vendorName = game.getVendor()!=null?game.getVendor().getName():null;
		minPlayers = game.getMinPlayers();
		maxPlayers = game.getMaxPlayers();
		leaderboardFlag = game.isLeaderboardFlag();
		achievementsFlag = game.isAchievementsFlag();
		turnBasedFlag = game.isTurnBasedFlag();
		enforceTurns = game.isEnforceTurns();
		allowWildCardInvitation = game.isAllowWildCardInvitation();
	}

	public String getVendorName() {
		return vendorName;
	}

	public void setVendorName(String vendorName) {
		this.vendorName = vendorName;
	}

	public Game toGame() {
		return new Game(null, name, appId, minPlayers, maxPlayers, leaderboardFlag, achievementsFlag, 
				turnBasedFlag, enforceTurns, allowWildCardInvitation);
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

	public void setId(Long id) {
		this.id = id;
	}

	public Long getId() {
		return id;
	}

    public boolean isEnforceTurns() {
        return enforceTurns;
    }

    public void setEnforceTurns(boolean enforceTurns) {
        this.enforceTurns = enforceTurns;
    }

	public boolean isTurnBasedFlag() {
		return turnBasedFlag;
	}

	public void setTurnBasedFlag(boolean turnBasedFlag) {
		this.turnBasedFlag = turnBasedFlag;
	}
	
	public boolean isAllowWildCardInvitation() {
        return allowWildCardInvitation;
    }

    public void setAllowWildCardInvitation(boolean allowWildCardInvitation) {
        this.allowWildCardInvitation = allowWildCardInvitation;
    }

}
