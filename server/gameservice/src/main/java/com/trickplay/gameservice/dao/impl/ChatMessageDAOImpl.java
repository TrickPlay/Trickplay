package com.trickplay.gameservice.dao.impl;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.ChatMessageDAO;
import com.trickplay.gameservice.domain.ChatMessage;

@Repository
@SuppressWarnings("unchecked")
public class ChatMessageDAOImpl extends GenericDAOWithJPA<ChatMessage, Long> implements ChatMessageDAO {
    
}
