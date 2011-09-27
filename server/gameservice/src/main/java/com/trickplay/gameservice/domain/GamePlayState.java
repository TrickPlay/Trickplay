package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@XmlRootElement
public class GamePlayState extends BaseEntity implements Serializable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
//	private Long id;
	@NotNull
	private User creator;
	@NotNull
	private GameSession gameSession;
	@NotNull
	private String state;
	
	private User turn;
	private GameStepId stepId;
	
	public GamePlayState() {
		
	}

	public GamePlayState(User createdBy, User turn, GameSession gameSession, String state, GameStepId stepId) {
		super();
		this.creator = createdBy;
		this.turn = turn;
		this.gameSession = gameSession;
		this.state = state;
		this.stepId = stepId;
	}

//	@Id
//	@GeneratedValue
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}

	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="creator_id", updatable=false, nullable=false)
	public User getCreatedBy() {
		return creator;
	}

	public void setCreatedBy(User creator) {
		this.creator = creator;
	}

	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="game_session_id", updatable=false, nullable=false)
	public GameSession getGameSession() {
		return gameSession;
	}

	public void setGameSession(GameSession gameSession) {
		this.gameSession = gameSession;
	}

	@Lob @Basic(fetch=FetchType.LAZY)
	@Column(updatable=false)
	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
	
	@Embedded
	public GameStepId getGameStepId() {
		return stepId;
	}
	
	public void setGameStepId(GameStepId stepId) {
		this.stepId = stepId;
	}
	
	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="turn_id", updatable=false)
	public User getTurn() {
		return turn;
	}

	public void setTurn(User turn) {
		this.turn = turn;
	}

}
