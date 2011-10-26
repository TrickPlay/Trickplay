package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.BuddyListInvitationDAO;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;

@Repository
@SuppressWarnings("unchecked")
public class BuddyListInvitationDAOImpl extends GenericDAOWithJPA<BuddyListInvitation, Long> implements BuddyListInvitationDAO {

    private static final String getInvitationsQuery = 
            "select I from BuddyListInvitation I join I.requestor R1 join I.recipient R2"
            + " where R1.id=:requestorId AND R2.id=:recipientId";
    
    private static final String getInvitationsMatchingStatusQuery =
            "select I from BuddyListInvitation I join I.requestor R1 join I.recipient R2"
                    + " where R1.id=:requestorId AND R2.id=:recipientId"
                    + " AND I.status=:status";
    
    private static final String hasPendingInvitationsQuery =
            "select count(*) from BuddyListInvitation I join I.requestor R1 join I.recipient R2"
                    + " where R1.id=:requestorId AND R2.id=:recipientId"
                    + " AND I.status=:status";
    
    private static final String getPendingInvitations =
            "select I from BuddyListInvitation I join I.recipient R"
                    + " where R.id=:recipientId"
                    + " AND I.status=:status";
    
    public List<BuddyListInvitation> getInvitations(Long requestorId, Long recipientId) {
        return super.entityManager
        .createQuery(getInvitationsQuery)
        .setParameter("requestorId", requestorId)
        .setParameter("recipientId", recipientId)
        .getResultList();
    }

    public List<BuddyListInvitation> getInvitations(Long requestorId, Long recipientId,
            InvitationStatus status) {
        return super.entityManager
                .createQuery(getInvitationsMatchingStatusQuery)
                .setParameter("requestorId", requestorId)
                .setParameter("recipientId", recipientId)
                .setParameter("status", status)
                .getResultList();
    }
    
    public boolean hasPendingInvitations(Long requestorId, Long recipientId) {
        return ((Number)super.entityManager
                .createQuery(hasPendingInvitationsQuery)
                .setParameter("requestorId", requestorId)
                .setParameter("recipientId", recipientId)
                .setParameter("status", InvitationStatus.PENDING)
                .getSingleResult()).intValue() > 0;
    }
    
    public List<BuddyListInvitation> getPendingInvitations(Long recipientId) {
        return super.entityManager
                .createQuery(getPendingInvitations)
                .setParameter("recipientId", recipientId)
                .setParameter("status", InvitationStatus.PENDING)
                .getResultList();
    }

}
