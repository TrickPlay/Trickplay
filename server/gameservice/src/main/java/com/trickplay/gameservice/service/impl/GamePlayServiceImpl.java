package com.trickplay.gameservice.service.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.ChatMessageDAO;
import com.trickplay.gameservice.dao.EventDAO;
import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.dao.GamePlayInvitationDAO;
import com.trickplay.gameservice.dao.GamePlayStateDAO;
import com.trickplay.gameservice.dao.GameSessionDAO;
import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.ChatMessage;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.GamePlayState;
import com.trickplay.gameservice.domain.GameSession;
import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.GamePlayService;

@Service("gamePlayService")
public class GamePlayServiceImpl implements GamePlayService {

	@Autowired
	GameDAO gameDAO;
	
	@Autowired
	UserDAO userDAO;
	
	@Autowired
	GameSessionDAO gameSessionDAO;
	
	@Autowired
	EventDAO eventDAO;
	
	@Autowired
	GamePlayStateDAO gamePlayStateDAO;
	
	@Autowired
	GamePlayInvitationDAO gamePlayInvitationDAO;
	
	@Autowired
	ChatMessageDAO chatMessageDAO;
	
	@Transactional
	public GameSession createGameSession(Long gameId) {
		Game g = gameDAO.find(gameId);
		
		if (g == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Game.class, "id", gameId);
		}
		Long initiatorId = SecurityUtil.getPrincipal().getId();
		User initiator = userDAO.find(initiatorId);
		
		if (initiator == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", initiatorId);
		}
		ServiceUtil.checkAuthority(initiator);
		
		GameSession gs = new GameSession(g, initiator);
		gs.getPlayers().add(initiator);
		gameSessionDAO.persist(gs);
		
		return gs;
	}

	public List<GameSession> findAllGameSessions(Long gameId) {
	    Long participantId = SecurityUtil.getCurrentUserId();
		return gameSessionDAO.findAllGameSessions(gameId, participantId);
	}

	public List<GameSession> findAllSessions() {
		return findAllSessions(SecurityUtil.getPrincipal().getId());
	}

	private List<GameSession> findAllSessions(Long participantId) {
		return gameSessionDAO.findAllSessions(participantId);
	}

	@Transactional
	public GamePlayInvitation sendGamePlayInvitation(Long gameSessionId, Long recipientId) throws GameServiceException {
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userDAO.find(SecurityUtil.getPrincipal().getId());
		
		if (requestor == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", requestorId);
		}
		ServiceUtil.checkAuthority(requestor);
		
		if (recipientId == requestorId) {
			throw ExceptionUtil.newRequestorAndRecipientMatchException(requestorId, recipientId);
		}
		
		GameSession gs = gameSessionDAO.find(gameSessionId);
		if (gs==null) {
		    throw ExceptionUtil.newEntityNotFoundException(GameSession.class, "id", gameSessionId);
		}
		User recipient=null;
        if (recipientId == null) {
            if (!gs.getGame().isAllowWildCardInvitation()) {
                throw ExceptionUtil.newWildcardInvitationNotAllowedException(gs.getGame().getName());
            }
            // this is a valid case for games which allow wild card invitations
        } else {
            recipient = userDAO.find(recipientId);
        
            if (recipient == null) {
                throw ExceptionUtil.newEntityNotFoundException(User.class, "id", recipientId);
            }
        }
        
        if (gs.getStartTime() != null) {
            throw ExceptionUtil.newGameAlreadyStartedException(gs.getGame().getName(), gameSessionId);
        }
        
        if (gs.getGame().getMaxPlayers() <= gs.getPlayers().size()) {
			throw ExceptionUtil.newExceedsMaxPlayersLimitException(gs.getGame().getName(), gs.getGame().getMaxPlayers());
        }
        
		for(GamePlayInvitation gpi : gs.getInvitations()) {
			if (recipient != null && gpi.getRecipient().getId().equals(recipient.getId())) {
				throw ExceptionUtil.newInvitationPreviouslySentException(recipientId);
			}
		}
		GamePlayInvitation gpi = new GamePlayInvitation(gs, requestor, recipient, InvitationStatus.PENDING);
		gs.addInvitation(gpi);
		gamePlayInvitationDAO.persist(gpi);

		if (recipientId != null) {
		    eventDAO.persist(new Event(EventType.GAME_PLAY_INVITATION, requestor, recipientId, "Game play request from "+requestor.getUsername(), gpi));
		}
		return gpi;
	}
	
	@Transactional
	public GamePlayInvitation updateGamePlayInvitation(Long invitationId, InvitationStatus status) {
		switch(status) {
		case CANCELLED:
			return cancelGamePlayInvitation(invitationId, SecurityUtil.getPrincipal().getId());
		case ACCEPTED:
			return acceptGamePlayInvitation(invitationId, SecurityUtil.getPrincipal().getId());
		case REJECTED:
			return declineGamePlayInvitation(invitationId, SecurityUtil.getPrincipal().getId());			
		}
		throw ExceptionUtil.newUnsupportedOperationException("updateGamePlayInvitation(status="+status+")");
	}

	private GamePlayInvitation declineGamePlayInvitation(Long invitationId,
			Long recipientId) {
		GamePlayInvitation gpi = gamePlayInvitationDAO.find(invitationId);
		if (gpi == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GamePlayInvitation.class, "id", invitationId);
		}
		User recipient = userDAO.find(recipientId);
		if (recipient == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", recipientId);
		}
		ServiceUtil.checkAuthority(recipient);

		if (gpi.getStatus()!=InvitationStatus.PENDING) {
			throw ExceptionUtil.newGPInvitationInvalidStatusException(invitationId, InvitationStatus.PENDING, gpi.getStatus());
		}
        if (!gpi.getRecipient().getId().equals(recipientId)) {
            throw ExceptionUtil.newNotInvitationRecipientException(invitationId);
        }
        
		gpi.setStatus(InvitationStatus.REJECTED);
		eventDAO.persist(new Event(EventType.GAME_PLAY_INVITATION, recipient, gpi.getRequestor().getId(), "Game play request declined by "+recipient.getUsername(), gpi));
		return gpi;
	}

	/*
	 * only allow accept invitation if the following is true:
	 * 1. valid recipient
	 * 2. recipient reserved the invitation (in case of wildcard invitation) or recipient is the invitation's recipient.
	 * 3. invitation is in PENDING or RESERVED status
	 * 
	 */
	private GamePlayInvitation acceptGamePlayInvitation(Long invitationId,
			Long recipientId) throws GameServiceException {

		User recipient = userDAO.find(recipientId);
		if (recipient == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", recipientId);
		}

		ServiceUtil.checkAuthority(recipient);
		
		GamePlayInvitation gpi = gamePlayInvitationDAO.find(invitationId);
		if (gpi == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GamePlayInvitation.class, "id", invitationId);
		}
		if (gpi.getStatus()!=InvitationStatus.PENDING)
            throw ExceptionUtil.newGPInvitationInvalidStatusException(invitationId, InvitationStatus.PENDING, gpi.getStatus());


		GameSession gs = gpi.getGameSession();
		if (!gs.isOpen()) {
		    throw ExceptionUtil.newExceedsMaxPlayersLimitException(gs.getGame().getName(), gs.getGame().getMaxPlayers());
		}
		
		
		if (isReservedBySomeoneElse(gpi, recipientId)) {
		    throw ExceptionUtil.newInvitationReservedException(invitationId);
		} else if (!gpi.isWildCard() && !gpi.getRecipient().getId().equals(recipientId)) {
		    throw ExceptionUtil.newNotInvitationRecipientException(invitationId);
		}
		
		gpi.setStatus(InvitationStatus.ACCEPTED);
		if (gpi.isWildCard())
		    gpi.setRecipient(recipient);
		gs.getPlayers().add(recipient);
		
		if (gs.getPlayers().size() >= gs.getGame().getMaxPlayers()) {
            expireGamePlayInvitations(gs);
            gs.setOpen(false);
        }
		
		eventDAO.persist(new Event(EventType.GAME_PLAY_INVITATION, recipient, gpi.getRequestor().getId(), "Game play request accepted by "+recipient.getUsername(), gpi));
		
		if (gs.getGame().isTurnBasedFlag() 
	//			&& gs.getGame().isEnforceTurns()
				&& gs.getStartTime()!=null 
				&& gs.getState() != null
				&& gs.getState().getTurn() == null
				) {
			gs.getState().setTurn(recipient);
		}
		return gpi;
	}
	
	private boolean isReservedBySomeoneElse(GamePlayInvitation gpi, Long recipientId) {
	   return  isValidReservation(gpi)
        && !gpi.getReservedBy().getId().equals(recipientId);
	}

	private boolean isValidReservation(GamePlayInvitation gpi) {
	    return gpi.isWildCard() 
        && gpi.getReservedUntil()!=null 
        && gpi.getReservedUntil().after(new Date());
	}
	/*
	 * TODO: who can cancel an invitation? the owner of the game session ? or the creator of the invitation ???
	 */
	private GamePlayInvitation cancelGamePlayInvitation(Long invitationId,
			Long requestorId) {
		GamePlayInvitation gpi = gamePlayInvitationDAO.find(invitationId);
		if (gpi == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GamePlayInvitation.class, "id", invitationId);
		}
		User requestor = userDAO.find(requestorId);
		if (requestor == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", requestorId);
		}
		ServiceUtil.checkAuthority(requestor);
		//if (!gpi.getRequestor().getId().equals(requestorId))
		  //  throw new GameServiceException()
		if (gpi.getStatus()!=InvitationStatus.PENDING) {
			throw ExceptionUtil.newGPInvitationInvalidStatusException(invitationId, InvitationStatus.PENDING, gpi.getStatus());
		}
		gpi.setStatus(InvitationStatus.CANCELLED);
		eventDAO.persist(new Event(EventType.GAME_PLAY_INVITATION, requestor, gpi.getRecipient().getId(), "Game play request withdrawn", gpi));
		return gpi;
	}

	@Transactional
	public GameStepId startGamePlay(Long sessionId, String state, Long nextTurnId) {
		
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userDAO.find(requestorId);
		if (requestor == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", requestorId);
		}
		ServiceUtil.checkAuthority(requestor);
		
		GameSession attached_gs = gameSessionDAO.find(sessionId);
		if (attached_gs == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GameSession.class, "id", sessionId);
		}
		
		if (state == null) {
		    throw ExceptionUtil.newIllegalArgumentException("gameState", null, " != null");
		}
		
		User nextTurn = null;
		if (nextTurnId != null) {
			nextTurn = userDAO.find(nextTurnId);
			if (nextTurn == null) {
			    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", nextTurnId);
			}
		}
		
		
		if (attached_gs.getStartTime()!=null) {
		    throw ExceptionUtil.newGameAlreadyStartedException(attached_gs.getGame().getName(), sessionId);
		}
		
		attached_gs.setStartTime(new Date());

		if (attached_gs.getPlayers().size() >= attached_gs.getGame().getMaxPlayers()) {
            expireGamePlayInvitations(attached_gs);
		    attached_gs.setOpen(false);
		}
		
		GamePlayState gps = new GamePlayState(requestor, nextTurn, attached_gs, state, generateGameStepId());
		
		gamePlayStateDAO.persist(gps);
		attached_gs.setState(gps);	
		eventDAO.persist(new Event(EventType.GAME_SESSION_START, requestor, attached_gs.getId(), "Game started by "+requestor.getUsername(), gps));
		return gps.getGameStepId();
	}
	
	private void expireGamePlayInvitations(GameSession s) {
		for(GamePlayInvitation gpi: s.getInvitations()) {
			if (gpi.getStatus()==InvitationStatus.PENDING)
				gpi.setStatus(InvitationStatus.EXPIRED);
		}
	}

	@Transactional
	public GameStepId updateGamePlay(Long sessionId, String state, Long nextTurnId) {
		GameSession attached_gs = gameSessionDAO.find(sessionId);
		if (attached_gs == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GameSession.class, "id", sessionId);
		}
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userDAO.find(requestorId);
		if (requestor == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", requestorId);
		}
		if (state == null) {
		    throw ExceptionUtil.newIllegalArgumentException("gameState", null, " != null");
		}
		User nextTurn = null;
		if (nextTurnId != null) {
			nextTurn = userDAO.find(nextTurnId);
			if (nextTurn == null) {
			    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", nextTurnId);
			}
		}
		ServiceUtil.checkAuthority(requestor);
		
		
		if (attached_gs.getStartTime()==null) {
		    throw ExceptionUtil.newGameNotStartedException(attached_gs.getGame().getName(), sessionId);
		}
		if (attached_gs.getEndTime()!=null) {
		    throw ExceptionUtil.newGameAlreadyEndedException(attached_gs.getGame().getName(), sessionId);
		}
		
		GamePlayState gps = new GamePlayState(requestor, nextTurn, attached_gs, state, generateGameStepId());
		
		gamePlayStateDAO.persist(gps);
		attached_gs.setState(gps);
		eventDAO.persist(new Event(EventType.GAME_SESSION_STATE_CHANGE, requestor, attached_gs.getId(), "Game state updated by "+requestor.getUsername(), gps));
		return gps.getGameStepId();
	}

	@Transactional
	public GameStepId endGamePlay(Long sessionId, String state) {
		GameSession attached_gs = gameSessionDAO.find(sessionId);
		if (attached_gs == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GameSession.class, "id", sessionId);
		}
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userDAO.find(requestorId);
		if (requestor == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", requestorId);
		}
		if (state == null) {
			throw ExceptionUtil.newIllegalArgumentException("gameState", null, " != null");
		}
		ServiceUtil.checkAuthority(requestor);
		
		
		if (attached_gs.getStartTime()==null) {
		    throw ExceptionUtil.newGameNotStartedException(attached_gs.getGame().getName(), sessionId);
		}
		if (attached_gs.getEndTime()!=null) {
			throw ExceptionUtil.newGameAlreadyEndedException(attached_gs.getGame().getName(), sessionId);
		}
		attached_gs.setEndTime(new Date());
		
		
		GamePlayState gps = new GamePlayState(requestor, null, attached_gs, state, generateGameStepId());
		
		gamePlayStateDAO.persist(gps);
		attached_gs.setState(gps);
		eventDAO.persist(new Event(EventType.GAME_SESSION_END, requestor, attached_gs.getId(), "Game play ended.", gps));
		return gps.getGameStepId();
	}

	@Transactional
	public void postMessage(Long sessionId, String msg) {
		GameSession gs = gameSessionDAO.find(sessionId);
		if (gs == null) {
		    throw ExceptionUtil.newEntityNotFoundException(GameSession.class, "id", sessionId);
		}
		Long senderId = SecurityUtil.getPrincipal().getId();
		User sender = userDAO.find(senderId);
		if (sender == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", senderId);
		}
		ChatMessage chatMsg = new ChatMessage(sender, gs, msg);
		chatMessageDAO.persist(chatMsg);
		eventDAO.persist(new Event(EventType.GAME_SESSION_MESSAGE, sender, gs.getId(), "In game message sent by "+sender.getUsername(), chatMsg));
	}
	
	public GamePlayInvitation findGamePlayInvitation(Long gamePlayInvitationId) {
		return gamePlayInvitationDAO.find(gamePlayInvitationId);
	}
	
	private GameStepId generateGameStepId() {
	//	MessageDigest md = MessageDigest.getInstance("SHA-1");
		return new GameStepId(SessionServiceImpl.generateToken());
	}
	
	@Transactional
	public List<GamePlayInvitation> getInvitations(Long gameId, int max) {
		if (max<=0 || max>10)
			max=10;
		Long userId = SecurityUtil.getCurrentUserId();
		User user = null;
		if (userId == null || (user=userDAO.find(userId)) == null) {
			throw ExceptionUtil.newForbiddenException();
		}
		
		List<GamePlayInvitation> userInvitations = gamePlayInvitationDAO.getPendingInvitationsForUser(gameId, userId, max);
		
		if (userInvitations!=null && userInvitations.size()>=max)
			return userInvitations;

		List<GamePlayInvitation> resultList;
		resultList = userInvitations != null ? 
				new ArrayList<GamePlayInvitation>(userInvitations) 
				: 
					new ArrayList<GamePlayInvitation>();
		
		max = max - resultList.size();
		
		List<GamePlayInvitation> wildCardInvitations = gamePlayInvitationDAO.getPendingWildCardInvitations(gameId);
		
		if (wildCardInvitations==null)
		    return resultList;

		Long sessionId=null;
		for(GamePlayInvitation invitation: wildCardInvitations) {
		    if (!invitation.getGameSession().getId().equals(sessionId)) {
		        invitation.setReservedBy(user);
		        long now = System.currentTimeMillis();
		        invitation.setReservedAt(new Date(now));
		        invitation.setReservedUntil(new Date(now+RESERVATION_VALID_INTERVAL_IN_SECONDS*1000));
		        resultList.add(invitation);
		        max--;
		        sessionId = invitation.getGameSession().getId();
		    } else {
		        continue;
		    }
		    if (max<1) {
		        break;
		    }
		}
		
		return resultList;
	}

    public GameSession find(Long sessionId) {
        return gameSessionDAO.find(sessionId);
    }
	
}
