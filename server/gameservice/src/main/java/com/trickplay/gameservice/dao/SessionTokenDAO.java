package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.SessionToken;

public interface SessionTokenDAO extends GenericDAO<SessionToken, Long> {

    public List<Long> pickPlayersRandom(Long currentUserId, int count);
    
    public SessionToken findByToken(String token);
}
