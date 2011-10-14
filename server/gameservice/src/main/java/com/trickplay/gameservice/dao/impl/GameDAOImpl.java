package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.domain.Game;

@Repository
@SuppressWarnings("unchecked")
public class GameDAOImpl extends GenericDAOWithJPA<Game, Long> implements GameDAO {

    public Game findByName(String name) {
        List<Game> list = 
                super.entityManager
                .createQuery("Select g from Game g where g.name = :name")
                .setParameter("name", name).getResultList();
        return SpringUtils.getFirst(list);
    }
    

}
