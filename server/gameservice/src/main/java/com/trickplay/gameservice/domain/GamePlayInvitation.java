package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@XmlRootElement
public class GamePlayInvitation extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

//    private Long id;
    @NotNull
    private User requestor;
    @NotNull
    private User recipient;
    @NotNull
    private InvitationStatus status;
    @NotNull
    private GameSession gameSession;
    
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
    
//    @Id
//    @GeneratedValue
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }

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

    public User getRecipient() {
        return recipient;
    }

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="recipient_id", nullable=false, updatable=false)
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

}
