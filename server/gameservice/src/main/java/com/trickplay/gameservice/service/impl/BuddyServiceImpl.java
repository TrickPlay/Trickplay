package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.BuddyStatus;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.security.UserAdapter;
import com.trickplay.gameservice.service.BuddyService;
import com.trickplay.gameservice.service.UserService;

@Service("buddyService")
@Repository
public class BuddyServiceImpl extends GenericDAOWithJPA<Buddy, Long> implements
		BuddyService {

	@Autowired
	UserService userService;
	
	public void authorizeSendInvitation(User requestor) {
		UserAdapter principal = (UserAdapter)SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		if (requestor == null || !principal.getId().equals(requestor.getId())) {
			throw new GameServiceException(Reason.FORBIDDEN);
		}
	}
	
	@Transactional
	public BuddyListInvitation sendInvitation(Long requestorId, String recipientName)
			throws GameServiceException {

		// check if recipient is already a buddy
		try {
			User requestor = userService.find(requestorId);
			authorizeSendInvitation(requestor);
			
			User recipient = userService.findByName(recipientName);
			if (recipient == null) {
				throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.recipientName", recipientName));
			}
			
			List<Buddy> requestBuddy = findByOwnerIdTargetId(requestor.getId(),
					recipient.getId());
			List<Buddy> recipientBuddy = findByOwnerIdTargetId(
					recipient.getId(), requestor.getId());

			if (recipientBuddy == null || recipientBuddy.size() == 0) {
				// if recipient's buddyList doesn't include requestor
				BuddyListInvitation bli = new BuddyListInvitation(requestor,
						recipient, InvitationStatus.PENDING);
				entityManager.persist(bli);
				entityManager.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, requestor, recipient.getId(), "Buddy Invitation from "+requestor.getUsername(), bli));
				return bli;
			} else if (requestBuddy == null || requestBuddy.size() == 0) {
				// if reciever's buddy list doesn't include recipient but
				// reciepient's includes reciever
				recipientBuddy.get(0).setStatus(BuddyStatus.CURRENT);
				Buddy buddy = new Buddy(requestor, recipient,
						BuddyStatus.CURRENT);
				entityManager.persist(buddy);
				BuddyListInvitation bli = new BuddyListInvitation(requestor,
						recipient, InvitationStatus.ACCEPTED);
				entityManager.persist(bli);
/*
				entityManager.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, requestor, recipient.getId(), "Buddy Invitation from "+requestor.getUsername(),bli));
						*/
				entityManager.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, recipient, requestor.getId(), "Buddy Invitation accepted by "+recipient.getUsername(), bli));

				return bli;
			} else {
				// if requestor is recipient's buddy and recipient is
				// requestor's throw an exception
				throw new GameServiceException(Reason.ALREADY_BUDDY);

			}
		} catch (Exception ex) {
			if (ex instanceof GameServiceException)
				throw (GameServiceException)ex;
			else {
				throw new GameServiceException(Reason.SEND_INVITATION_FAILED, ex);
			}
		}

	}

	@Transactional
	public void removeBuddy(Buddy buddy) {
		authorizeRemoveBuddyRequest(buddy);
		List<Buddy> recipientBuddy = findByOwnerIdTargetId(buddy.getOwner().getId(), 
				buddy.getTarget().getId() );
		if (recipientBuddy != null && recipientBuddy.size() != 0) {
			recipientBuddy.get(0).setStatus(BuddyStatus.INACTIVE);
		}
		entityManager.remove(buddy);
	}

	@Transactional
	public BuddyListInvitation updateInvitationStatus(Long userId, Long invitationId,
			InvitationStatus newStatus) {
		if (invitationId == null) {
			throw new IllegalArgumentException(
					"BuddyListInvitation ID is null");
		} else if (newStatus == null) {
			throw new IllegalArgumentException("InvitationStatus is null");
		}

		BuddyListInvitation bli = entityManager.find(BuddyListInvitation.class, invitationId);
		if (bli == null) {
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("BuddyListInvitation.invitationId", invitationId));
		}
		
		authorizeRequest(bli, newStatus);

		if (bli.getStatus() != InvitationStatus.PENDING) {
			throw new GameServiceException(Reason.INVITATION_INVALID_STATUS, null,
					ExceptionContext.make("invitationStatus", bli.getStatus()));
		}
		if (bli.getStatus() == newStatus)
			return bli;
		switch (newStatus) {
		case CANCELLED:
			cancelInvitation(bli);
			break;
		case REJECTED:
			declineInvitation(bli);
			break;
		case ACCEPTED:
			acceptInvitation(bli);
		}
		return bli;
	}

	public void authorizeRemoveBuddyRequest(Buddy b) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (principal == null || b == null || b.getOwner() == null || (!principal.getId().equals(b.getOwner().getId()))) {
			throw new GameServiceException(Reason.FORBIDDEN);
		}
	}
	
	public void authorizeRequest(BuddyListInvitation bli, InvitationStatus status) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (principal==null) {
			throw new GameServiceException(Reason.FORBIDDEN);
		} else if (bli==null || bli.getRequestor()==null || bli.getRecipient()==null) {
			throw new GameServiceException(Reason.UNKNOWN);
		}
		if (principal.getId().equals(bli.getRequestor().getId())) {
			if (status != InvitationStatus.CANCELLED) {
				throw new GameServiceException(Reason.INVITATION_INVALID_STATUS, null, ExceptionContext.make("invitationStatus", status));
			}
		} else if (principal.getId().equals(bli.getRecipient().getId())) {
			if (status != InvitationStatus.ACCEPTED && status != InvitationStatus.REJECTED) {
				throw new GameServiceException(Reason.INVITATION_INVALID_STATUS, null, ExceptionContext.make("invitationStatus", status));
			}
		} else {
			throw new GameServiceException(Reason.FORBIDDEN);
		}
	}
	
	public void cancelInvitation(BuddyListInvitation bli) {

		bli.setStatus(InvitationStatus.CANCELLED);
		entityManager.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
				.getRequestor(), bli.getRecipient().getId(), "Buddy invitation withdrawn", bli));
	}

	/*
	 * if (bli.getStatus()==InvitationStatus.ACCEPTED) { List<Buddy>
	 * requestBuddy = findByOwnerIdTargetId(bli.getRequestor().getId(),
	 * bli.getRecipient().getId()); List<Buddy> recipientBuddy =
	 * findByOwnerIdTargetId(bli.getRecipient().getId(),
	 * bli.getRequestor().getId());
	 * 
	 * if (requestBuddy==null||requestBuddy.size()==0) { Buddy b = new
	 * Buddy(bli.getRequestor(), bli.getRecipient(), BuddyStatus.CURRENT);
	 * entityManager.persist(b); } else {
	 * requestBuddy.get(0).setStatus(BuddyStatus.CURRENT); }
	 * 
	 * if (recipientBuddy==null||recipientBuddy.size()==0) { Buddy b = new
	 * Buddy(bli.getRecipient(), bli.getRequestor(), BuddyStatus.CURRENT);
	 * entityManager.persist(b); } else {
	 * recipientBuddy.get(0).setStatus(BuddyStatus.CURRENT); } }
	 * entityManager.persist(new Event(EventType.BUDDY_LIST_INVITATION,
	 * bli.getRecipient(), bli)); }
	 */

	public void declineInvitation(BuddyListInvitation bli) {
		// entityManager.
		bli.setStatus(InvitationStatus.REJECTED);
		entityManager.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
				.getRecipient(), bli.getRequestor().getId(), "Buddy Invitation declined by "+bli.getRecipient().getUsername(), bli));
	}

	public void acceptInvitation(BuddyListInvitation bli) {
		// TODO Auto-generated method stub
		bli.setStatus(InvitationStatus.ACCEPTED);
		List<Buddy> requestBuddy = findByOwnerIdTargetId(bli.getRequestor()
				.getId(), bli.getRecipient().getId());
		List<Buddy> recipientBuddy = findByOwnerIdTargetId(bli.getRecipient()
				.getId(), bli.getRequestor().getId());

		if (requestBuddy == null || requestBuddy.size() == 0) {
			Buddy b = new Buddy(bli.getRequestor(), bli.getRecipient(),
					BuddyStatus.CURRENT);
			entityManager.persist(b);
		} else {
			requestBuddy.get(0).setStatus(BuddyStatus.CURRENT);
		}

		if (recipientBuddy == null || recipientBuddy.size() == 0) {
			Buddy b = new Buddy(bli.getRecipient(), bli.getRequestor(),
					BuddyStatus.CURRENT);
			entityManager.persist(b);
		} else {
			recipientBuddy.get(0).setStatus(BuddyStatus.CURRENT);
		}
		entityManager.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
				.getRecipient(), bli.getRequestor().getId(), "Buddy invitation accepted by "+bli.getRecipient().getUsername(), bli));
	}

	@SuppressWarnings(value = "unchecked")
	public List<Buddy> findAll(Long ownerId) {
		return super.entityManager
				.createQuery(
						"Select b from Buddy as b join b.owner as o where o.id = :ownerId")
				.setParameter("ownerId", ownerId).getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Buddy> findByOwnerName(String ownerName) {
		return super.entityManager
				.createQuery(
						"Select b from Buddy as b join b.owner as o where o.username = :ownerName")
				.setParameter("ownerName", ownerName).getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId) {
		return super.entityManager
				.createQuery(
						"Select b from Buddy as b join b.owner as o join b.target as t where o.id = :ownerId and t.id = :targetId")
				.setParameter("ownerId", ownerId)
				.setParameter("targetId", targetId).getResultList();

	}

}
