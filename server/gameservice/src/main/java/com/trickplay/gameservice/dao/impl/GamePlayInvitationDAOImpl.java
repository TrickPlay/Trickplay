package com.trickplay.gameservice.dao.impl;

import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GamePlayInvitationDAO;
import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;

@Repository
@SuppressWarnings("unchecked")
public class GamePlayInvitationDAOImpl extends
        GenericDAOWithJPA<GamePlayInvitation, Long> implements
        GamePlayInvitationDAO {

    public static final String invitationForUserQuery = "select I from GamePlayInvitation I join I.gameSession GS join GS.game G"
            + " WHERE G.id = :gameId"
            + " AND GS.open = true"
            + " AND I.recipient.id = :userId"
            + " AND I.status=:pendingStatus"
            + " ORDER BY I.created";
    
    public static final String wildCardInvitationQuery = 
            "select I from GamePlayInvitation I join I.gameSession GS join GS.game G"
            + " WHERE G.id = :gameId"
            + " AND GS.open = true"
            + " AND I.recipient is null"
            + " AND I.status=:status"
            + " AND (I.reservedUntil is null OR I.reservedUntil < :currentTime) "
            + " ORDER BY GS.id, I.created";

    
    public List<GamePlayInvitation> getPendingWildCardInvitations(Long gameId) {
        return entityManager.createQuery(wildCardInvitationQuery)
                .setParameter("gameId", gameId)
                .setParameter("status", InvitationStatus.PENDING)
                .setParameter("currentTime", new Date()).getResultList();
    }
    
    public List<GamePlayInvitation> getPendingInvitationsForUser(Long gameId, Long userId, int max) {
            return entityManager
            .createQuery(invitationForUserQuery)
            .setParameter("gameId", gameId)
            .setParameter("userId", userId)
            .setParameter("pendingStatus", InvitationStatus.PENDING)
            .setMaxResults(max)
            .getResultList();
    }
}
