package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.exception.GameServiceException;

@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
public interface BuddyService {
	
    @Transactional
	public BuddyListInvitation sendInvitation(String recipientName) throws GameServiceException;
	
	@Transactional
	public BuddyListInvitation updateInvitationStatus(Long invitationId, InvitationStatus newStatus);

	@Transactional
	public void removeBuddy(Long buddyId);

	public List<Buddy> findAll(Long ownerId);

	@Transactional
	public void create(Buddy entity);

	@Transactional
	public Buddy update(Buddy entity);

	public Buddy find(Long id);
	
	public List<Buddy> findByOwnerName(String ownerName);
	
	public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId);
}
