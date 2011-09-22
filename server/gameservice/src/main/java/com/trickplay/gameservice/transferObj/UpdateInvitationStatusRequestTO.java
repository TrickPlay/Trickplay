package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

import com.trickplay.gameservice.domain.InvitationStatus;

public class UpdateInvitationStatusRequestTO {

	@NotNull
	private InvitationStatus status;

	public UpdateInvitationStatusRequestTO() {

	}

	public UpdateInvitationStatusRequestTO(InvitationStatus status) {
		this.status = status;
	}

	public void setStatus(InvitationStatus status) {
		this.status = status;
	}

	public InvitationStatus getStatus() {
		return status;
	}
}
