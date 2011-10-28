package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;

public interface BuddyListInvitationDAO extends GenericDAO<BuddyListInvitation, Long> {

    public List<BuddyListInvitation> getInvitations(Long requestorId, Long recipientId);
    
    public List<BuddyListInvitation> getInvitations(Long requestorId, Long recipientId, InvitationStatus status);

    public boolean hasPendingInvitations(Long requestorId, Long recipientId);
    
    public List<BuddyListInvitation> getPendingInvitations(Long recipientId);
}
