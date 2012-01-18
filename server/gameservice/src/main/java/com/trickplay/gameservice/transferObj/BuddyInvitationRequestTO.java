package com.trickplay.gameservice.transferObj;

import org.hibernate.validator.constraints.NotBlank;

public class BuddyInvitationRequestTO {
	@NotBlank
	private String recipient;

	public BuddyInvitationRequestTO(String recipient) {
		this.recipient = recipient;
	}
	
	public BuddyInvitationRequestTO() {
		
	}
	

	public String getRecipient() {
		return recipient;
	}

	public void setRecipient(String recipient) {
		this.recipient = recipient;
	}

}
