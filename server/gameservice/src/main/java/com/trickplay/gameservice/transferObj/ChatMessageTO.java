package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class ChatMessageTO {

	@NotNull
	private Long gameSessionId;
	
	@NotNull
	private String message;
	
	public ChatMessageTO() {
		
	}
	
	public ChatMessageTO(Long gameSessionId, String message) {
		this.gameSessionId = gameSessionId;
		this.message = message;
	}

	public Long getGameSessionId() {
		return gameSessionId;
	}

	public void setGameSessionId(Long gameSessionId) {
		this.gameSessionId = gameSessionId;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
}
