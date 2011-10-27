package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.GameSessionMessage;

public interface GameSessionMessageDAO extends GenericDAO<GameSessionMessage, Long> {

    public List<GameSessionMessage> getMessages(Long gameSessionId, Long lastMessageId);

}
