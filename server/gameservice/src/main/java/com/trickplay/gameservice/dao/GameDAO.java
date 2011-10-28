package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.Game;

public interface GameDAO extends GenericDAO<Game, Long>{
    
    public Game findByName(String name);

}
