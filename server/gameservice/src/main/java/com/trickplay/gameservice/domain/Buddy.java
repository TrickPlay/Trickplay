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
@XmlRootElement(name = "buddy")
public class Buddy extends BaseEntity implements Serializable {
    private static final long serialVersionUID = 1L;


//    private Long id;
    @NotNull
    private User owner;
    @NotNull
    private User target;   

    @NotNull
    private BuddyStatus status;
    

    public Buddy() {
        // empty constructor required for JAXB
    }

    public Buddy(User owner, User target, BuddyStatus status) {
        this.owner = owner;
        this.target = target;
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

    @Enumerated(EnumType.STRING)
    public BuddyStatus getStatus() {
        return status;
    }
    
    public void setStatus(BuddyStatus s) {
        this.status = s;
    }

    @ManyToOne
    @JoinColumn(name="target_id", nullable=false)
    public User getTarget() {
        return target;
    }

    public void setTarget(User target) {
        this.target = target;
    }

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="owner_id", nullable=false)
    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    @Override
    public String toString() {
        return "Buddy [id=" + getId() + ", owner=" + owner + ", target=" + target + ", status=" + status + "]";
    }

}



