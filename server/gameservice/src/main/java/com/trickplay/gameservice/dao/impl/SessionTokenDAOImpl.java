package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.SessionTokenDAO;
import com.trickplay.gameservice.domain.SessionToken;

@Repository
@SuppressWarnings("unchecked")
public class SessionTokenDAOImpl extends GenericDAOWithJPA<SessionToken, Long> implements SessionTokenDAO {
    
    private static final String pickPlayersQuery = "select distinct t.userId from SessionToken t where t.expired=false AND t.userId!=:currentUserId order by t.lastUsed DESC"; 
    
    
    public List<Long> pickPlayersRandom(Long currentUserId, int count) {
        // get distinct users from session table whose sessions have not expired
        return entityManager.createQuery(pickPlayersQuery)
        .setParameter("currentUserId", currentUserId)
        .setMaxResults(count)
        .getResultList();
    }
    
    public SessionToken findByToken(String token) {
        List<SessionToken> list = super.entityManager
                .createQuery(
                        "Select session from SessionToken session where session.token = :token")
                .setParameter("token", token).getResultList();
        return SpringUtils.getFirst(list);
    }

}
