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

    private static final String invitationForUserQuery = "select I from GamePlayInvitation I join I.gameSession GS join GS.game G"
            + " WHERE G.id = :gameId"
            + " AND GS.open = true"
            + " AND I.recipient.id = :userId"
            + " AND I.status=:pendingStatus"
            + " ORDER BY I.created";
    
    private static final String wildCardInvitationQuery = 
            "select I from GamePlayInvitation I join I.gameSession GS join GS.game G"
            + " WHERE G.id = :gameId"
            + " AND GS.open = true"
            + " AND I.recipient is null"
            + " AND I.status=:pendingStatus"
            + " AND :userId NOT IN (select P.id from GS.players P)"
            + " AND (I.reservedUntil is null OR I.reservedUntil < :currentTime OR I.reservedBy.id = :userId) "
            + " ORDER BY GS.id, I.created";

    private static final String pairInSameGamePlaySessionQuery = 
            "select count(I) from GamePlayInvitation I"
            + " where I.gameSession.game.id=:gameId AND I.gameSession.endTime is null"
            + " I.status NOT IN (:expiredStatus, :rejectedStatus, :cancelledStatus)"
            + " AND "
            + " ("
            + "   (I.requestor.id = :userId1 AND I.recipient.id = :userId2)"
            + "   OR "
            + "   (I.requestor.id = :userId2 AND I.recipient.id = :userId1)"
            + " )";
    
    public List<GamePlayInvitation> getPendingWildCardInvitations(Long gameId, Long userId) {
        return entityManager.createQuery(wildCardInvitationQuery)
                .setParameter("gameId", gameId)
                .setParameter("pendingStatus", InvitationStatus.PENDING)
                .setParameter("userId", userId)
                .setParameter("currentTime", new Date())
                .getResultList();
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
    
    public boolean isPairInSameGamePlaySession(Long gameId, Long userId1, Long userId2) {
        return new Long(0).compareTo( 
                (Long)(entityManager.createQuery(pairInSameGamePlaySessionQuery)
                .setParameter("gameId", gameId)
                .setParameter("expiredStatus", InvitationStatus.EXPIRED)
                .setParameter("rejectedStatus", InvitationStatus.REJECTED)
                .setParameter("cancelledStatus", InvitationStatus.CANCELLED)
                .setParameter("userId1", userId1)
                .setParameter("userId2", userId2)
                .getSingleResult())) < 0;             
    }
}
