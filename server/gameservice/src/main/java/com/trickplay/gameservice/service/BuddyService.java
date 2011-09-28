package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;

import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.GameServiceException;

@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
public interface BuddyService {
	
	public BuddyListInvitation sendInvitation(String recipientName) throws GameServiceException;
	
	public BuddyListInvitation updateInvitationStatus(Long invitationId, InvitationStatus newStatus);

	//@PreAuthorize("principal.username == #buddy.owner.username")
	public void removeBuddy(Buddy buddy);

	//@PreAuthorize("hasRole('ROLE_ADMIN') or ")
	public List<Buddy> findAll(Long ownerId);

	//@PreAuthorize("principal.username == #buddy.owner.username")
	public void persist(Buddy entity);

	public void merge(Buddy entity);

	public Buddy find(Long id);
	
	public List<Buddy> findByOwnerName(String ownerName);
	
	public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId);
}
