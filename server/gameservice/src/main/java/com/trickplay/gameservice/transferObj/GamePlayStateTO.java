package com.trickplay.gameservice.transferObj;

import java.util.Date;

import com.trickplay.gameservice.domain.GamePlayState;
import com.trickplay.gameservice.domain.GameSession;

public class GamePlayStateTO {

	private Long id;
	private String key;
	private String state;
	private Long turnId;
	private String turnUsername;
	private Long gameSessionId;
	private Date created;
	private Date updated;
	private boolean gameEnded;

	public GamePlayStateTO() {
		
	}
	
	public GamePlayStateTO(GameSession gs) {
		if (gs == null)
			throw new IllegalArgumentException("Game Session id null");
		
		GamePlayState gps = gs.getState();
		if (gps==null)
			return;
		
		this.id = gps.getId();
		this.key = gps.getGameStepId().getKey();
		this.state = gps.getState();
		this.turnId = gps.getTurn() != null ? gps.getTurn().getId() : null;
		this.turnUsername = gps.getTurn() != null ? gps.getTurn().getUsername() : null;
		this.gameSessionId = gs.getId();
		this.created = gps.getCreated();
		this.updated = gps.getUpdated();
		this.gameEnded = gs.getEndTime() != null;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public Long getTurnId() {
		return turnId;
	}

	public void setTurnId(Long turnId) {
		this.turnId = turnId;
	}

	public String getTurnUsername() {
		return turnUsername;
	}

	public void setTurnUsername(String turnUsername) {
		this.turnUsername = turnUsername;
	}

	public Long getGameSessionId() {
		return gameSessionId;
	}

	public void setGameSessionId(Long gameSessionId) {
		this.gameSessionId = gameSessionId;
	}

	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	public Date getUpdated() {
		return updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

	public boolean isGameEnded() {
		return gameEnded;
	}

	public void setGameEnded(boolean gameEnded) {
		this.gameEnded = gameEnded;
	}
}
