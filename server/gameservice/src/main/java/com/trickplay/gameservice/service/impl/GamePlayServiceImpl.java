package com.trickplay.gameservice.service.impl;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
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
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.GamePlayService;
import com.trickplay.gameservice.service.GameService;
import com.trickplay.gameservice.service.UserService;

@Service("gamePlayService")
@Repository
public class GamePlayServiceImpl extends GenericDAOWithJPA<GameSession, Long> implements GamePlayService {

	@Autowired
	GameService gameService;
	@Autowired
	UserService userService;
	
	@Transactional
	public GameSession createGameSession(Long gameId) {
		Game g = gameService.find(gameId);
		
		if (g == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Game.id", gameId));
		
		Long initiatorId = SecurityUtil.getPrincipal().getId();
		User initiator = userService.find(initiatorId);
		
		if (initiator == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.initiatorId", initiatorId));
		
		ServiceUtil.checkAuthority(initiator);
		
		GameSession gs = new GameSession(g, initiator);
		gs.getPlayers().add(initiator);
		super.entityManager.persist(gs);
		
		return gs;
	}

	@SuppressWarnings("unchecked")
	public List<GameSession> findAllSessions(Long gameId, Long participantId) {
		return entityManager.createQuery
		(
				"select GS from GameSession as GS join G.game as G join GS.players as where G.id=:gid and P.id=:pid"
				)
				.setParameter("gid", gameId)
				.setParameter("pid", participantId)
				.getResultList();
	}

	@SuppressWarnings("unchecked")
	public List<GameSession> findAllSessions() {
		return findAllSessions(SecurityUtil.getPrincipal().getId());
	}

	
	@SuppressWarnings("unchecked")
	public List<GameSession> findAllSessions(Long participantId) {
		return entityManager.createQuery
		(
				"select G from GameSession as G join G.players as where P.id=:pid"
				)
				.setParameter("pid", participantId)
				.getResultList();
	}

	@Transactional
	public GamePlayInvitation sendGamePlayInvitation(Long gameSessionId, Long recipientId) throws GameServiceException {
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userService.find(SecurityUtil.getPrincipal().getId());
		
		if (requestor == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.requestorId", requestorId));
		ServiceUtil.checkAuthority(requestor);
		
		if (recipientId == requestorId) {
			throw new GameServiceException(Reason.GP_RECIPIENT_SAME_AS_REQUESTOR, null, 
					ExceptionContext.make("User.recipientId", recipientId),
					ExceptionContext.make("User.requestorId", requestorId)
					);
			
		}
		User recipient = userService.find(recipientId);
		
		if (recipient == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.recipientId", recipientId));
		
		GameSession gs = super.find(gameSessionId);
		if (gs==null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GameSession.sessionId", gameSessionId));

		if (gs.getGame().getMaxPlayers() <= gs.getPlayers().size())
			throw new GameServiceException(Reason.GP_EXCEEDS_MAX_PLAYERS_ALLOWED, null, 
					ExceptionContext.make("maxPlayersAllowed", gs.getGame().getMaxPlayers()));
		
		for(GamePlayInvitation gpi : gs.getInvitations()) {
			if (gpi.getRecipient().getId() == recipient.getId()) {
				throw new GameServiceException(Reason.INVITATION_PREVIOUSLY_SENT);
			}
		}
		GamePlayInvitation gpi = new GamePlayInvitation(gs, requestor, recipient, InvitationStatus.PENDING);
		gs.addInvitation(gpi);
		entityManager.persist(gpi);

		entityManager.persist(new Event(EventType.GAME_PLAY_INVITATION, requestor, recipientId, "Game play request from "+requestor.getUsername(), gpi));
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
		throw new GameServiceException(Reason.UNSUPPORTED_OPERATION_EXCEPTION, null,
				ExceptionContext.make("status", status));
	}

	private GamePlayInvitation declineGamePlayInvitation(Long invitationId,
			Long recipientId) {
		GamePlayInvitation gpi = entityManager.find(GamePlayInvitation.class, invitationId);
		if (gpi == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GamePlayInvitation.invitationId", invitationId));
		
		User recipient = userService.find(recipientId);
		if (recipient == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.recipientId", recipientId));
		
		ServiceUtil.checkAuthority(recipient);
		
		if (gpi.getStatus()!=InvitationStatus.PENDING)
			throw new GameServiceException(Reason.INVITATION_INVALID_STATUS);
		gpi.setStatus(InvitationStatus.REJECTED);
		entityManager.persist(new Event(EventType.GAME_PLAY_INVITATION, recipient, gpi.getRequestor().getId(), "Game play request declined by "+recipient.getUsername(), gpi));
		return gpi;
	}

	private GamePlayInvitation acceptGamePlayInvitation(Long invitationId,
			Long recipientId) throws GameServiceException {

		User recipient = userService.find(recipientId);
		if (recipient == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.recipientId", recipientId));

		ServiceUtil.checkAuthority(recipient);
		
		GamePlayInvitation gpi = entityManager.find(GamePlayInvitation.class, invitationId);
		if (gpi == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GamePlayInvitation.invitationId", invitationId));

		GameSession gs = gpi.getGameSession();
		if (gs.getGame().getMaxPlayers() <= gs.getPlayers().size())
			throw new GameServiceException(Reason.GP_EXCEEDS_MAX_PLAYERS_ALLOWED, null, 
					ExceptionContext.make("maxPlayersAllowed", gs.getGame().getMaxPlayers()));
		
		if (gpi.getStatus()!=InvitationStatus.PENDING)
			throw new GameServiceException(Reason.INVITATION_INVALID_STATUS);
		gpi.setStatus(InvitationStatus.ACCEPTED);
		gs.getPlayers().add(recipient);
		
		entityManager.persist(new Event(EventType.GAME_PLAY_INVITATION, recipient, gpi.getRequestor().getId(), "Game play request accepted by "+recipient.getUsername(), gpi));
		
		return gpi;
	}

	private GamePlayInvitation cancelGamePlayInvitation(Long invitationId,
			Long requestorId) {
		GamePlayInvitation gpi = entityManager.find(GamePlayInvitation.class, invitationId);
		if (gpi == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GamePlayInvitation.invitationId", invitationId));
		
		User requestor = userService.find(requestorId);
		if (requestor == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.requestorId", requestorId));

		ServiceUtil.checkAuthority(requestor);
		
		if (gpi.getStatus()!=InvitationStatus.PENDING)
			throw new GameServiceException(Reason.INVITATION_INVALID_STATUS);
		gpi.setStatus(InvitationStatus.CANCELLED);
		entityManager.persist(new Event(EventType.GAME_PLAY_INVITATION, requestor, gpi.getRecipient().getId(), "Game play request withdrawn", gpi));
		return gpi;
	}

	@Transactional
	public GameStepId startGamePlay(Long sessionId, String state, Long nextTurnId) {
		
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userService.find(requestorId);
		if (requestor == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.requestor", requestorId));
		ServiceUtil.checkAuthority(requestor);
		
		GameSession attached_gs = super.find(sessionId);
		if (attached_gs == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GameSession.sessionId", sessionId));
		
		if (state == null) 
			throw new GameServiceException(Reason.ILLEGAL_ARGUMENT, null, ExceptionContext.make("state", null));
			
		User nextTurn = null;
		if (nextTurnId != null) {
			nextTurn = userService.find(nextTurnId);
			if (nextTurn == null)
				throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, 
						ExceptionContext.make("User.nextTurnId", nextTurnId)
						);
		}
		
		
		if (attached_gs.getStartTime()!=null)
			throw new GameServiceException(Reason.GAME_ALREADY_STARTED);
		
		if (attached_gs.getPlayers().size() < attached_gs.getGame().getMinPlayers())
			throw new GameServiceException(Reason.GP_BELOW_MIN_PLAYERS_REQUIRED, null,
					new ExceptionContext("minPlayersRequired", attached_gs.getGame().getMinPlayers())
			);
		
		attached_gs.setStartTime(new Date());
		for(GamePlayInvitation gpi: attached_gs.getInvitations()) {
			if (gpi.getStatus()==InvitationStatus.PENDING)
				gpi.setStatus(InvitationStatus.EXPIRED);
		}
		
		GamePlayState gps = new GamePlayState(requestor, nextTurn, attached_gs, state, generateGameStepId());
		
		entityManager.persist(gps);
		attached_gs.setState(gps);	
		entityManager.persist(new Event(EventType.GAME_SESSION_START, requestor, attached_gs.getId(), "Game started by "+requestor.getUsername(), gps));
		return gps.getGameStepId();
	}

	public GameStepId updateGamePlay(Long sessionId, String state, Long nextTurnId) {
		GameSession attached_gs = super.find(sessionId);
		if (attached_gs == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GameSession.sessionId", sessionId));
		
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userService.find(requestorId);
		if (requestor == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.requestorId", requestorId));
		
		if (state == null) 
			throw new GameServiceException(Reason.ILLEGAL_ARGUMENT, null, ExceptionContext.make("state", null));
			
		User nextTurn = null;
		if (nextTurnId != null) {
			nextTurn = userService.find(nextTurnId);
			if (nextTurn == null)
				throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.nextTurnId", nextTurnId));
		}
		ServiceUtil.checkAuthority(requestor);
		
		
		if (attached_gs.getStartTime()==null)
			throw new GameServiceException(Reason.GAME_NOT_STARTED);
		
		if (attached_gs.getEndTime()!=null)
			throw new GameServiceException(Reason.GAME_ALREADY_ENDED);
		
		
		GamePlayState gps = new GamePlayState(requestor, nextTurn, attached_gs, state, generateGameStepId());
		
		entityManager.persist(gps);
		attached_gs.setState(gps);
		entityManager.persist(new Event(EventType.GAME_SESSION_STATE_CHANGE, requestor, attached_gs.getId(), "Game state updated by "+requestor.getUsername(), gps));
		return gps.getGameStepId();
	}

	public GameStepId endGamePlay(Long sessionId, String state) {
		GameSession attached_gs = super.find(sessionId);
		if (attached_gs == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GameSession.sessionId", sessionId));
		
		Long requestorId = SecurityUtil.getPrincipal().getId();
		User requestor = userService.find(requestorId);
		if (requestor == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.requestorId", requestorId));
		
		if (state == null) 
			throw new GameServiceException(Reason.ILLEGAL_ARGUMENT, null, ExceptionContext.make("state", null));
			
		ServiceUtil.checkAuthority(requestor);
		
		
		if (attached_gs.getStartTime()==null)
			throw new GameServiceException(Reason.GAME_NOT_STARTED);
		
		if (attached_gs.getEndTime()!=null)
			throw new GameServiceException(Reason.GAME_ALREADY_ENDED);
		attached_gs.setEndTime(new Date());
		
		
		GamePlayState gps = new GamePlayState(requestor, null, attached_gs, state, generateGameStepId());
		
		entityManager.persist(gps);
		attached_gs.setState(gps);
		entityManager.persist(new Event(EventType.GAME_SESSION_END, requestor, attached_gs.getId(), "Game play ended.", gps));
		return gps.getGameStepId();
	}

	public void postMessage(Long sessionId, String msg) {
		GameSession gs = super.find(sessionId);
		if (gs == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("GameSession.sessionId", sessionId));
		Long senderId = SecurityUtil.getPrincipal().getId();
		User sender = userService.find(senderId);
		if (sender == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.senderId", senderId));
		
		ChatMessage chatMsg = new ChatMessage(sender, gs, msg);
		super.entityManager.persist(chatMsg);
		entityManager.persist(new Event(EventType.GAME_SESSION_MESSAGE, sender, gs.getId(), "In game message sent by "+sender.getUsername(), chatMsg));
	}
	
	public GamePlayInvitation findGamePlayInvitation(Long gamePlayInvitationId) {
		return super.entityManager.find(GamePlayInvitation.class, gamePlayInvitationId);
	}
	
	private GameStepId generateGameStepId() {
	//	MessageDigest md = MessageDigest.getInstance("SHA-1");
		return new GameStepId(SessionServiceImpl.generateToken());
	}
	
	
}
