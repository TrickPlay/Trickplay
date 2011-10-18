package com.trickplay.gameservice.dao.impl;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GamePlaySummaryDAO;
import com.trickplay.gameservice.domain.GamePlaySummary;

@Repository
public class GamePlaySummaryDAOImpl extends GenericDAOWithJPA<GamePlaySummary, Long> implements GamePlaySummaryDAO {
   

    public GamePlaySummary findByGameAndUser(Long gameId, Long userId) {
        return (GamePlaySummary) super.entityManager
                .createQuery(
                        "Select GPS from GamePlaySummary as GPS join GPS.game as G join GPS.user as U"
                        + " where G.id=:gameId and U.id=:userId")
                .setParameter("gameId", gameId)
                .setParameter("userId", userId)
                .getSingleResult();
    }

}
