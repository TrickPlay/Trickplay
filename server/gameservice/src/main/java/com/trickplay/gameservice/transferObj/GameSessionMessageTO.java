package com.trickplay.gameservice.transferObj;

import java.util.Date;

import javax.validation.constraints.NotNull;

import com.trickplay.gameservice.domain.GameSessionMessage;

public class GameSessionMessageTO {

    @NotNull
    private Long id;
    
    @NotNull
    private Long senderId;
    
    @NotNull
    private String senderName;
    
	@NotNull
	private Long gameSessionId;
	
	@NotNull
	private String message;
	
	private Date created;
	
	public GameSessionMessageTO() {
		
	}
	
	public GameSessionMessageTO(GameSessionMessage msg) {
	    if (msg == null)
	        throw new IllegalArgumentException("Invalid GameSessionMessage instance. Input is null");
	    this.id = msg.getId();
	    this.senderId = msg.getSender().getId();
	    this.senderName = msg.getSender().getUsername();
		this.gameSessionId = msg.getSession().getId();
		this.message = msg.getMessage();
		this.created = msg.getCreated();
	}

	public Long getSenderId() {
        return senderId;
    }

    public void setSenderId(Long senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
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

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}
