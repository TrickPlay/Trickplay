package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@XmlRootElement
public class ChatMessage extends BaseEntity implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
//	private Long id;
	private User sender;
	private GameSession session;
	private String message;
	
	
	public ChatMessage(User sender, GameSession session, String message) {
		super();
		this.sender = sender;
		this.session = session;
		this.message = message;
	}
	
//	public long getId() {
//		return id;
//	}
//	
//	public void setId(long id) {
//		this.id = id;
//	}
	
	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="sender_id", updatable=false, nullable=false)
	public User getSender() {
		return sender;
	}
	
	public void setSender(User sender) {
		this.sender = sender;
	}
	
	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="session_id", updatable=false, nullable=false)
	public GameSession getSession() {
		return session;
	}
	public void setSession(GameSession session) {
		this.session = session;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	
}
