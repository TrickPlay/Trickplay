package com.trickplay.gameservice.transferObj;


public class GamePlayInvitationRequestTO {

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
