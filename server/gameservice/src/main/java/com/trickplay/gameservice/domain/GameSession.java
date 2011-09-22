package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
//@PrimaryKeyJoinColumn(name="id")
@XmlRootElement
public class GameSession extends BaseEntity implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@NotNull
    private Game game;
    private Date startTime;
    private Date endTime;
    private List<User> players = new ArrayList<User>();
    private List<GamePlayInvitation> invitations = new ArrayList<GamePlayInvitation>();

	@NotNull
	private User owner;
	
	private GamePlayState state;
    
    public GameSession() {
    	super();
    }
    
    public GameSession(Game game, User owner) {
    //	super(owner, SessionType.GAME_SESSION);
    	this.owner = owner;
    	this.game = game;
    }

	@ManyToOne(fetch=FetchType.EAGER)
	public Game getGame() {
		return game;
	}

	public void setGame(Game game) {
		this.game = game;
	}

	@Temporal(TemporalType.TIMESTAMP)
	public Date getStartTime() {
		return startTime;
	}

	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	@Temporal(TemporalType.TIMESTAMP)
	public Date getEndTime() {
		return endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public void setOwner(User owner) {
		this.owner = owner;
	}

	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="owner_id", nullable=false, updatable=false)
	public User getOwner() {
		return owner;
	}

	@ManyToMany(
	        targetEntity=User.class,
	        cascade={CascadeType.PERSIST, CascadeType.MERGE}
	    )
	    @JoinTable(
	        name="GAME_SESSION_PLAYER",
	        joinColumns=@JoinColumn(name="gs_id"),
	        inverseJoinColumns=@JoinColumn(name="player_id")
	    )
	public List<User> getPlayers() {
		return players;
	}

	public void setPlayers(List<User> players) {
		this.players = players;
	}

	@OneToMany(mappedBy="gameSession")
	public List<GamePlayInvitation> getInvitations() {
		return invitations;
	}

	public void setInvitations(List<GamePlayInvitation> invitations) {
		this.invitations = invitations;
	}
	
	public void addInvitation(GamePlayInvitation invitation) {
		invitations.add(invitation);
	}

	@OneToOne
	@JoinColumn(name="state_id")
	public GamePlayState getState() {
		return state;
	}
	
	public void setState(GamePlayState state) {
		this.state = state;
	}

}
