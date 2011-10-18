package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@XmlRootElement
public class RecordedScore extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;


//    private Long id;
    @NotNull
    private Game game;
    @NotNull
    private User user;
    @Min(0)
    private long points;
    
    public RecordedScore() {
        
    }
    
    public RecordedScore(Game game, User user, long points) {
        this.user = user;
        this.points = points;
    }

    @ManyToOne
    @JoinColumn(name="user_id", updatable=false, nullable=false)
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public long getPoints() {
        return points;
    }

    public void setPoints(long points) {
        this.points = points;
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

    @ManyToOne
    @JoinColumn(name="game_id", updatable=false, nullable=false)
    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }
    
    
}
