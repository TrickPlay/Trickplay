package com.trickplay.gameservice.transferObj;

import java.util.Date;

import javax.validation.constraints.NotNull;

import org.hibernate.validator.constraints.NotBlank;

import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;

public class BuddyInvitationTO {
	private Long id;
	private Long requestorId;
	private String requestor;
	private Long recipientId;
	@NotBlank
	private String recipient;
	private InvitationStatus status;
	
    private Date created;
    private Date updated;

	public BuddyInvitationTO(Long requestorId, String requestor, Long recipientId, String recipient, InvitationStatus status) {
		this.requestorId = requestorId;
		this.requestor = requestor;
		this.recipientId = recipientId;
		this.recipient = recipient;
		this.status = status;
	}
	
	public BuddyInvitationTO(BuddyListInvitation bli) {
		if (bli == null)
			throw new IllegalArgumentException("BuddyListInvitation is null");
		this.id = bli.getId();
		this.requestorId = bli.getRequestor().getId();
		this.requestor = bli.getRequestor().getUsername();
		this.recipientId = bli.getRecipient().getId();
		this.recipient = bli.getRecipient().getUsername();
		this.status = bli.getStatus();
		this.created = bli.getCreated();
		this.updated = bli.getUpdated();
	}
	
	public BuddyInvitationTO() {
		
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

	public Long getRequestorId() {
		return requestorId;
	}


	public void setRequestorId(Long requestorId) {
		this.requestorId = requestorId;
	}


	public String getRequestor() {
		return requestor;
	}


	public void setRequestor(String requestor) {
		this.requestor = requestor;
	}


	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getRecipientId() {
		return recipientId;
	}

	public void setRecipientId(Long recipientId) {
		this.recipientId = recipientId;
	}

	public String getRecipient() {
		return recipient;
	}

	public void setRecipient(String recipient) {
		this.recipient = recipient;
	}

	public InvitationStatus getStatus() {
		return status;
	}

	public void setStatus(InvitationStatus status) {
		this.status = status;
	}


}
