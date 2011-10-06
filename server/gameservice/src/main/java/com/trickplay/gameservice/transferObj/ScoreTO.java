package com.trickplay.gameservice.transferObj;

import com.trickplay.gameservice.domain.RecordedScore;

public class ScoreTO {
	private Long id;
	private Long userId;
	private String userName;
	private Long gameId;
	private String gameName;
	private long points;
	
	public ScoreTO() {
		
	}

	public ScoreTO(Long id, Long userId, String userName, Long gameId, String gameName,
			long points) {
		super();
		this.id = id;
		this.userId = userId;
		this.userName = userName;
		this.gameId = gameId;
		this.gameName = gameName;
		this.points = points;
	}
	
	public ScoreTO(RecordedScore s) {
		if (s==null)
			return;
			//throw new IllegalArgumentException("RecordedScore is null");
		this.id = s.getId();
		this.userId = s.getUser().getId();
		this.userName = s.getUser().getUsername();
		this.gameId = s.getGame().getId();
		this.gameName = s.getGame().getName();
		this.points = s.getPoints();
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public Long getGameId() {
		return gameId;
	}

	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}

	public String getGameName() {
		return gameName;
	}

	public void setGameName(String gameName) {
		this.gameName = gameName;
	}

	public long getPoints() {
		return points;
	}

	public void setPoints(long points) {
		this.points = points;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getId() {
		return id;
	}
}
