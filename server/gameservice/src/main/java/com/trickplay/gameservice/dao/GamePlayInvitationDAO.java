package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.GamePlayInvitation;

public interface GamePlayInvitationDAO extends GenericDAO<GamePlayInvitation, Long> {

    /*
     * returns list of PENDING and unreserved wild card invitations
     */
    public List<GamePlayInvitation> getPendingWildCardInvitations(Long gameId, Long userId);
    
    /*
     * returns list of PENDING invitations for the given User
     */
    public List<GamePlayInvitation> getPendingInvitationsForUser(Long gameId, Long userId, int max);
    
    public boolean isPairInSameGamePlaySession(Long gameId, Long userId1, Long userId2);
}
