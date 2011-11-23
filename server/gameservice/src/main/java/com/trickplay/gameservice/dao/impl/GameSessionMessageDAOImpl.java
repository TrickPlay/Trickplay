package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GameSessionMessageDAO;
import com.trickplay.gameservice.domain.GameSessionMessage;

@Repository
@SuppressWarnings("unchecked")
public class GameSessionMessageDAOImpl extends GenericDAOWithJPA<GameSessionMessage, Long> implements GameSessionMessageDAO {

    private static final String getMessagesQuery = 
            "select M from GameSessionMessage M where M.session.id = :gameSessionId "
            + " AND id > :lastMessageId order by M.id";
    public List<GameSessionMessage> getMessages(Long gameSessionId, Long lastMessageId) {
        return entityManager
                .createQuery(getMessagesQuery)
                .setParameter("gameSessionId", gameSessionId)
                .setParameter("lastMessageId", lastMessageId)
                .getResultList();
    }
    
}
