package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
//@Table(uniqueConstraints=@UniqueConstraint(columnNames={"requestor_id", "recipient_id"}))
@XmlRootElement
public class BuddyListInvitation extends BaseEntity implements Serializable {

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

    public BuddyListInvitation() {
        super();
    }
    
    public BuddyListInvitation(User requestor, User recipient, InvitationStatus status) {
        super();
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

	@ManyToOne(fetch=FetchType.EAGER)
    @JoinColumn(name="requestor_id", updatable=false, nullable=false)
    public User getRequestor() {
        return requestor;
    }

    
    public void setRequestor(User requestor) {
        this.requestor = requestor;
    }

    @ManyToOne(fetch=FetchType.EAGER)
    @JoinColumn(name="recipient_id", updatable = false, nullable=false)
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

    
}
