package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class GameSessionMessageRequestTO {

	@NotNull
	private String message;
	
	public GameSessionMessageRequestTO() {
		
	}
	
	public GameSessionMessageRequestTO(String message) {
		this.message = message;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
}
