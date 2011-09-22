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
	
	public GameRequestTO() {
		
	}
		
	public GameRequestTO(String name, String appId, Long vendorId,
			int minPlayers, int maxPlayers,
			boolean leaderboardFlag, boolean achievementsFlag) {
		super();
		this.name = name;
		this.appId = appId;
		this.vendorId = vendorId;
		this.minPlayers = minPlayers;
		this.maxPlayers = maxPlayers;
		this.leaderboardFlag = leaderboardFlag;
		this.achievementsFlag = achievementsFlag;
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
	}

	public Game toGame() {
		return new Game(null, name, appId, minPlayers, maxPlayers, leaderboardFlag, achievementsFlag);
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

	
}
