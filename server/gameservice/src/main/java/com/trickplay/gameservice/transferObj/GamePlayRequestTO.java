package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class GamePlayRequestTO {

	@NotNull
	private Long gameSessionId;
	@NotNull
	private String gameState;
	private Long turnId;
	
	public GamePlayRequestTO() {
		
	}
	
	public GamePlayRequestTO(Long gameSessionId, String gameState, Long turnId) {
		this.gameSessionId = gameSessionId;
		this.gameState = gameState;
		this.turnId = turnId;
	}

	public Long getGameSessionId() {
		return gameSessionId;
	}

	public void setGameSessionId(Long gameSessionId) {
		this.gameSessionId = gameSessionId;
	}

	public String getGameState() {
		return gameState;
	}

	public void setGameState(String gameState) {
		this.gameState = gameState;
	}

	public Long getTurnId() {
		return turnId;
	}

	public void setTurnId(Long turnId) {
		this.turnId = turnId;
	}
	
	
}
