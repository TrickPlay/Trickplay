package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlRootElement;

//@Entity
//@Table(name="LEADERBOARD")
@XmlRootElement(name="leaderboard")
public class Leaderboard implements Serializable {
    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Game game;

    private Long id;
    private List<RecordedScore> scores;

    public Leaderboard() {
        super();
    }

    public Leaderboard(Game game, List<RecordedScore> scores) {
        super();
        this.game = game;
        this.scores = scores;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public List<RecordedScore> getRecordedScores() {
        return scores;
    }

    public void setRecordedScores(List<RecordedScore> scores) {
        this.scores = scores;
    }
    
    @Override
    public String toString() {
        return "Leaderboard [game=" + game + ", scores=" + scores + "]";
    }

    @Id
    @GeneratedValue
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

}
