package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.GameSession;

public interface GameSessionDAO extends GenericDAO<GameSession, Long> {
    
    public List<GameSession> findAllGameSessions(Long gameId, Long participantId);
    
    public List<GameSession> findAllSessions(Long participantId);
}
