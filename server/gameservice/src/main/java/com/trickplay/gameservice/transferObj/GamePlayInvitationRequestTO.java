package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class GamePlayInvitationRequestTO {

	@NotNull
	private Long recipientId;

	public GamePlayInvitationRequestTO() {
		
	}
	
	public GamePlayInvitationRequestTO(Long recipientId) {
		this.recipientId = recipientId;
	}
	
	public Long getRecipientId() {
		return recipientId;
	}
	public void setRecipientId(Long recipientId) {
		this.recipientId = recipientId;
	}
	
	

}
