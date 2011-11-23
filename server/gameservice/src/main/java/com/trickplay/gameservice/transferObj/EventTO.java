package com.trickplay.gameservice.transferObj;

import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;

public class EventTO {

	private Long id;
    private EventType eventType;
    private Long sourceId;
    private String sourceUsername;
    private Long recipientId;
    private String subject;
    private Long targetId;
    
    public EventTO() {
    	
    }
    
    public EventTO(Event e) {
    	this.id = e.getId();
    	this.eventType = e.getEventType();
    	this.sourceId = e.getSource().getId();
    	this.sourceUsername = e.getSource().getUsername();
    	this.recipientId = e.getRecipientId();
    	this.subject = e.getSubject();
    	this.targetId = e.getEventDetailId();
    }
    
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public EventType getEventType() {
		return eventType;
	}
	public void setEventType(EventType eventType) {
		this.eventType = eventType;
	}
	public Long getSourceId() {
		return sourceId;
	}
	public void setSourceId(Long sourceId) {
		this.sourceId = sourceId;
	}
	public String getSourceUsername() {
		return sourceUsername;
	}
	public void setSourceUsername(String sourceUsername) {
		this.sourceUsername = sourceUsername;
	}
	public Long getRecipientId() {
		return recipientId;
	}
	public void setRecipientId(Long recipientId) {
		this.recipientId = recipientId;
	}
	public String getSubject() {
		return subject;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public Long getTargetId() {
		return targetId;
	}
	public void setTargetId(Long targetId) {
		this.targetId = targetId;
	}

}
