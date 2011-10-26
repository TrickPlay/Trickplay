package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Table(uniqueConstraints=@UniqueConstraint(columnNames={"user_id", "game_id"}))
@XmlRootElement
public class GamePlaySummary extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;


//    private Long id;
    @NotNull
    private Game game;
    @NotNull
    private User user;

    @NotNull
    private String detail;
    
    public GamePlaySummary() {
        
    }
    
    public GamePlaySummary(Game game, User user, String detail) {
        this.user = user;
        this.detail = detail;
    }

    @ManyToOne
    @JoinColumn(name="user_id", updatable=false, nullable=false)
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Lob /*@Basic(fetch=FetchType.LAZY)*/
    @Column(updatable=false)
    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
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
