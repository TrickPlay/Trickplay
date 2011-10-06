package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.NotNull;

@Entity
@Inheritance(strategy=InheritanceType.JOINED)
public class Session extends BaseEntity implements Serializable {

	public enum SessionType {GAME_SESSION, CHAT_SESSION, HTTP_SESSION}
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

//	private Long id;

	@NotNull
	private User owner;
	
	@NotNull
	private SessionType sessionType;
	
	/**
	 * creates a HTTP_SESSION by default
	 */
	public Session() {
		super();
		this.setSessionType(SessionType.HTTP_SESSION);
	}
	
	public Session(User owner, SessionType sessionType) {
		super();
		this.owner = owner;
		this.setSessionType(sessionType);
	}
	
//	public void setId(Long id) {
//		this.id = id;
//	}
//
//	public Long getId() {
//		return id;
//	}

	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="owner_id", nullable=false, updatable=false)
	public void setOwner(User owner) {
		this.owner = owner;
	}

	public User getOwner() {
		return owner;
	}

	@Enumerated(EnumType.STRING)
	@Column(nullable=false, updatable=false)
	public void setSessionType(SessionType sessionType) {
		this.sessionType = sessionType;
	}

	public SessionType getSessionType() {
		return sessionType;
	}
	
}
