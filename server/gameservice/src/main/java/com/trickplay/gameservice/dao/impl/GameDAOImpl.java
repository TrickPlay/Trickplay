package com.trickplay.gameservice.dao.impl;

import static java.lang.String.format;

import java.util.List;

import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.domain.Game;

@Repository
@SuppressWarnings("unchecked")
public class GameDAOImpl extends GenericEJB3DAO<Game, Long> implements GameDAO {

    public GameDAOImpl() {
        super();
    }
    
    public Class<Game> getEntityBeanType() {
        return Game.class;
    }
    
    public Game findByAppIdRelease(String appId, int release) {
        List<Game> validGames = findByCriteria(
                Restrictions.conjunction()
            .add(Restrictions.eq("appId", appId))
            .add(Restrictions.eq("release", release))
            );

        if (validGames.isEmpty())
            throw new RuntimeException(format(
                    "No game found with appId="+appId+" and release="+release));
        return SpringUtils.getFirst(validGames);
    }

}
