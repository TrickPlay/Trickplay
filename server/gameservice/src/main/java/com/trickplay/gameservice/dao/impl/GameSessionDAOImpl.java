package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GameSessionDAO;
import com.trickplay.gameservice.domain.GameSession;

@Repository
@SuppressWarnings("unchecked")
public class GameSessionDAOImpl extends GenericDAOWithJPA<GameSession, Long> implements GameSessionDAO {
    
    public List<GameSession> findAllGameSessions(Long gameId, Long participantId) {
        return entityManager.createQuery
        (
                "select GS from GameSession GS join GS.game G join GS.players P"
                + " where GS.endTime is null AND G.id=:gid and P.id=:pid"
                )
                .setParameter("gid", gameId)
                .setParameter("pid", participantId)
                .getResultList();
    }

    
    public List<GameSession> findAllSessions(Long participantId) {
        return entityManager.createQuery
        (
                "select GS from GameSession GS join GS.players P where GS.endTime is null AND P.id=:pid"
                )
                .setParameter("pid", participantId)
                .getResultList();
    }
}
