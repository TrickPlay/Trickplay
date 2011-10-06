package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@Table(uniqueConstraints=@UniqueConstraint(columnNames={"game_id", "name"}))
@XmlRootElement(name="achievement")
public class Achievement extends BaseEntity implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    
 //   private Long id;
    @NotNull
    private Game game;
    @NotNull
    private String name;
    private String description;
    private int value;
    
    public Achievement(Game game, String name, String description, int value) {
        super();
        this.game = game;
        this.name = name;
        this.description = description;
        this.value = value;
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
    @JoinColumn(name="game_id", updatable=false, nullable=false)
    public Game getGame() {
        return game;
    }
    
    public void setGame(Game game) {
        this.game = game;
    }
    
    @Column(name="name", nullable=false)
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getValue() {
        return value;
    }
    
    public void setValue(int value) {
        this.value = value;
    }

    
}
