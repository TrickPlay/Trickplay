package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.GameSession;
import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.domain.InvitationStatus;

public interface GamePlayService {

	@Transactional
	public GameSession createGameSession(Long gameId);
	
	public List<GameSession> findAllSessions(Long gameId, Long participantId);
	
	public List<GameSession> findAllSessions(Long participantId);
	
	public List<GameSession> findAllSessions();
	
	public GameSession find(Long sessionId);
	
	@Transactional
	public GamePlayInvitation sendGamePlayInvitation(Long gameId, Long recipientId);
	
	@Transactional
	public GamePlayInvitation updateGamePlayInvitation(Long invitationId, InvitationStatus status);
	
	public GamePlayInvitation findGamePlayInvitation(Long gamePlayInvitationId);
	
	@Transactional
	public GameStepId startGamePlay(Long gameSessionId, String gameState, Long nextTurnId);
	
	@Transactional
	public GameStepId updateGamePlay(Long gameSessionId, String gameState, Long nextTurnId);
	
	@Transactional
	public GameStepId endGamePlay(Long gameSessionId, String gameState);

	@Transactional
	public void postMessage(Long gameSessionId, String msg);
		
}
