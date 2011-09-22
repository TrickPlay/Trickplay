package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Table(uniqueConstraints=@UniqueConstraint(columnNames={"user_id", "achievement_id"}))
@XmlRootElement
public class RecordedAchievement extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;


//    private Long id;
    @NotNull
    private User user;
    @NotNull
    private Achievement achievement;
    
    public RecordedAchievement() {
        
    }
    
    public RecordedAchievement(Game game, User user, Achievement achievement) {
        this.user = user;
        this.achievement = achievement;
    }

    @ManyToOne
    @JoinColumn(name="user_id", updatable=false, nullable=false)
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @ManyToOne
    @JoinColumn(name="achievement_id", updatable=false, nullable=false)
    public Achievement getAchievement() {
        return achievement;
    }

    public void setAchievement(Achievement achievement) {
        this.achievement = achievement;
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

    
    
}
