package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.BuddyDAO;
import com.trickplay.gameservice.dao.BuddyListInvitationDAO;
import com.trickplay.gameservice.dao.EventDAO;
import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.BuddyStatus;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.security.UserAdapter;
import com.trickplay.gameservice.service.BuddyService;

@Service("buddyService")
public class BuddyServiceImpl implements
		BuddyService {

	@Autowired
	UserDAO userDAO;
	
	@Autowired
	BuddyDAO buddyDAO;
	
	@Autowired
    BuddyListInvitationDAO buddyListInvitationDAO;
	
	@Autowired
    EventDAO eventDAO;
	
	public void authorizeSendInvitation(User requestor) {
		UserAdapter principal = (UserAdapter)SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		if (requestor == null || !principal.getId().equals(requestor.getId())) {
			throw ExceptionUtil.newForbiddenException();
		}
	}
	
	@Transactional
	public BuddyListInvitation sendInvitation(String recipientName)
			throws GameServiceException {

		// check if recipient is already a buddy
		try {
			User requestor = userDAO.find(SecurityUtil.getPrincipal().getId());
			authorizeSendInvitation(requestor);
			
			User recipient = userDAO.findByName(recipientName);
			if (recipient == null) {
				throw ExceptionUtil.newEntityNotFoundException(User.class, "recipientName", recipientName);
			}
			
			List<Buddy> requestBuddy = findByOwnerIdTargetId(requestor.getId(),
					recipient.getId());
			List<Buddy> recipientBuddy = findByOwnerIdTargetId(
					recipient.getId(), requestor.getId());

			if (recipientBuddy == null || recipientBuddy.size() == 0) {
				// if recipient's buddyList doesn't include requestor
				BuddyListInvitation bli = new BuddyListInvitation(requestor,
						recipient, InvitationStatus.PENDING);
				buddyListInvitationDAO.persist(bli);
				eventDAO.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, requestor, recipient.getId(), "Buddy Invitation from "+requestor.getUsername(), bli));
				return bli;
			} else if (requestBuddy == null || requestBuddy.size() == 0) {
				// if reciever's buddy list doesn't include recipient but
				// reciepient's includes reciever
				recipientBuddy.get(0).setStatus(BuddyStatus.CURRENT);
				Buddy buddy = new Buddy(requestor, recipient,
						BuddyStatus.CURRENT);
				buddyDAO.persist(buddy);
				BuddyListInvitation bli = new BuddyListInvitation(requestor,
						recipient, InvitationStatus.ACCEPTED);
				buddyListInvitationDAO.persist(bli);
/*
				entityManager.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, requestor, recipient.getId(), "Buddy Invitation from "+requestor.getUsername(),bli));
						*/
				eventDAO.persist(new Event(
						EventType.BUDDY_LIST_INVITATION, recipient, requestor.getId(), "Buddy Invitation accepted by "+recipient.getUsername(), bli));

				return bli;
			} else {
				throw ExceptionUtil.newAlreadyBuddyException(recipientName);
			}
		} catch (Exception ex) {
			throw ExceptionUtil.newWrapperException(ex);
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
		buddyDAO.remove(buddy);
	}

	@Transactional
	public BuddyListInvitation updateInvitationStatus(Long invitationId,
			InvitationStatus newStatus) {
		if (invitationId == null) {
			throw new IllegalArgumentException(
					"BuddyListInvitation ID is null");
		} else if (newStatus == null) {
			throw new IllegalArgumentException("InvitationStatus is null");
		}

		BuddyListInvitation bli = buddyListInvitationDAO.find(invitationId);
		if (bli == null) {
		    throw ExceptionUtil.newEntityNotFoundException(BuddyListInvitation.class, "invitationId", invitationId); 
        }
		
		authorizeRequest(bli, newStatus);

		if (bli.getStatus() != InvitationStatus.PENDING) {
			throw ExceptionUtil.newUpdateBLInvitationStatusFailedException(bli.getId(), newStatus, bli.getStatus());
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
			throw ExceptionUtil.newForbiddenException();
		}
	}
	
	public void authorizeRequest(BuddyListInvitation bli, InvitationStatus status) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (principal==null) {
		    throw ExceptionUtil.newForbiddenException();
		} 
		if (principal.getId().equals(bli.getRequestor().getId())) {
			if (status != InvitationStatus.CANCELLED) {
				throw ExceptionUtil.newForbiddenException();
			}
		} else if (principal.getId().equals(bli.getRecipient().getId())) {
			if (status != InvitationStatus.ACCEPTED && status != InvitationStatus.REJECTED) {
			    throw ExceptionUtil.newForbiddenException();
			}
		} else {
		    throw ExceptionUtil.newForbiddenException();
		}
	}
	
	public void cancelInvitation(BuddyListInvitation bli) {

		bli.setStatus(InvitationStatus.CANCELLED);
		eventDAO.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
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
		eventDAO.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
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
			buddyDAO.persist(b);
		} else {
			requestBuddy.get(0).setStatus(BuddyStatus.CURRENT);
		}

		if (recipientBuddy == null || recipientBuddy.size() == 0) {
			Buddy b = new Buddy(bli.getRecipient(), bli.getRequestor(),
					BuddyStatus.CURRENT);
			buddyDAO.persist(b);
		} else {
			recipientBuddy.get(0).setStatus(BuddyStatus.CURRENT);
		}
		eventDAO.persist(new Event(EventType.BUDDY_LIST_INVITATION, bli
				.getRecipient(), bli.getRequestor().getId(), "Buddy invitation accepted by "+bli.getRecipient().getUsername(), bli));
	}

	public List<Buddy> findAll(Long ownerId) {
		return buddyDAO.findAll(ownerId);
	}

	public List<Buddy> findByOwnerName(String ownerName) {
		return buddyDAO.findByOwnerName(ownerName);
	}

	public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId) {
		return buddyDAO.findByOwnerIdTargetId(ownerId, targetId);

	}

    public void removeBuddy(Long buddyId) {
        Buddy existing = find(buddyId);
        if (existing == null) {
            throw ExceptionUtil.newEntityNotFoundException(Buddy.class, "id", buddyId);
        }
        buddyDAO.remove(existing);
    }

    @Transactional
    public void create(Buddy entity) {
        buddyDAO.persist(entity);       
    }

    @Transactional
    public Buddy update(Buddy entity) {
        if (entity == null) {
            throw ExceptionUtil.newIllegalArgumentException("Buddy", null, "!= null");
        }
        Buddy existing = find(entity.getId());
        if (existing == null) {
            throw ExceptionUtil.newEntityNotFoundException(Buddy.class, "id", entity.getId());
        }
        existing.setStatus(entity.getStatus());
        return existing;
    }

    public Buddy find(Long id) {
        return buddyDAO.find(id);
    }

}
