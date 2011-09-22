package com.trickplay.gameservice.transferObj;

import java.util.Date;

import javax.validation.constraints.NotNull;

import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;

public class GamePlayInvitationTO {

	private Long id;
	@NotNull
	private Long requestorId;
	@NotNull
	private Long recipientId;
	private Long gameId;
	private Long gameSessionId;
	public Long getGameId() {
		return gameId;
	}

	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}
	private InvitationStatus status;
	private Date created;
	private Date updated;
	
	public GamePlayInvitationTO() {
		
	}
	
	public GamePlayInvitationTO(GamePlayInvitation gpi) {
		if (gpi==null)
			throw new IllegalArgumentException("GamePlayInvitation is null");
		this.id = gpi.getId();
		this.requestorId = gpi.getRequestor().getId();
		this.recipientId = gpi.getRecipient().getId();
		this.gameSessionId = gpi.getGameSession().getId();
		this.status = gpi.getStatus();
		this.created = gpi.getCreated();
		this.updated = gpi.getUpdated();
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getRequestorId() {
		return requestorId;
	}
	public void setRequestorId(Long requestorId) {
		this.requestorId = requestorId;
	}
	public Long getRecipientId() {
		return recipientId;
	}
	public void setRecipientId(Long recipientId) {
		this.recipientId = recipientId;
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

	public InvitationStatus getStatus() {
		return status;
	}
	public void setStatus(InvitationStatus status) {
		this.status = status;
	}
	

}
