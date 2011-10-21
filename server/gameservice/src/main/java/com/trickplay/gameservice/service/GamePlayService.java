package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.GamePlaySummary;
import com.trickplay.gameservice.domain.GameSession;
import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.domain.InvitationStatus;

@PreAuthorize("isAuthenticated()")
public interface GamePlayService {

    public static final int RESERVATION_VALID_INTERVAL_IN_SECONDS = 120;
    
	@Transactional
	public GameSession createGameSession(Long gameId);
	
	public List<GameSession> findAllGameSessions(Long gameId);
	
	public List<GameSession> findAllSessions();
	
	public GameSession find(Long sessionId);
	
	@Transactional
	public GamePlayInvitation sendGamePlayInvitation(Long gameSessionId, Long recipientId);
	
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
	
	@Transactional
	public List<GamePlayInvitation> getInvitations(Long gameId, int max);
	
    public GamePlaySummary getGamePlaySummary(Long gameId, Long userId);
    
    public GamePlaySummary getGamePlaySummary(Long gameId);
    
    @Transactional
    public GamePlaySummary saveGamePlaySummary(Long gameId, String summaryDetail);
		
}
