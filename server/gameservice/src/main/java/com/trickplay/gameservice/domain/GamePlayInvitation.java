package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Table(name="game_play_invitation")
@XmlRootElement
public class GamePlayInvitation extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

//    private Long id;
    @NotNull
    private User requestor;
    
    // if recipient is null then it is a wild card invitation, meaning any user other than ones who already joined the game can take use this invitation
    private User recipient;
    @NotNull
    private InvitationStatus status;
    @NotNull
    private GameSession gameSession;
    
    private User reservedBy;
    private Date reservedAt;
    private Date reservedUntil;
    
    public GamePlayInvitation() {
        super();
    }


    public GamePlayInvitation(GameSession gameSession, User requestor, User recipient, InvitationStatus status) {
        super();
        this.gameSession = gameSession;
        this.requestor = requestor;
        this.recipient = recipient;
        this.status = status;
    }
    

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="game_session_id", nullable=false, updatable=false)
    public GameSession getGameSession() {
        return gameSession;
    }

    public void setGameSession(GameSession gameSession) {
        this.gameSession = gameSession;
    }

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="requestor_id", nullable=false, updatable=false)
    public User getRequestor() {
        return requestor;
    }

    public void setRequestor(User requestor) {
        this.requestor = requestor;
    }

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="recipient_id")
    public User getRecipient() {
        return recipient;
    }

    public void setRecipient(User recipient) {
        this.recipient = recipient;
    }

    @Enumerated(EnumType.STRING)
    public InvitationStatus getStatus() {
        return status;
    }

    public void setStatus(InvitationStatus status) {
        this.status = status;
    }
    
    @Transient
    public boolean isWildCard() {
        return recipient == null;
    }
    
    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="reserved_by")
    public User getReservedBy() {
        return reservedBy;
    }
    
    public void setReservedBy(User reservedBy) {
        this.reservedBy = reservedBy;
    }
    
    @Temporal(TemporalType.TIMESTAMP)
    public Date getReservedAt() {
        return reservedAt;
    }
    
    public void setReservedAt(Date reservedAt) {
        this.reservedAt = reservedAt;
    }

    @Temporal(TemporalType.TIMESTAMP)
	public void setReservedUntil(Date reservedUntil) {
		this.reservedUntil = reservedUntil;
	}


	public Date getReservedUntil() {
		return reservedUntil;
	}

}
