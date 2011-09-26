package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class GamePlaySessionRequestTO {

	@NotNull
	private Long gameId;

	public GamePlaySessionRequestTO() {
		
	}
	
	public GamePlaySessionRequestTO(Long gameId) {
		this.gameId = gameId;
	}
	
	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}

	public Long getGameId() {
		return gameId;
	}
	
	

}
