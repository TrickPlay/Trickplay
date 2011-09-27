package com.trickplay.gameservice.service.impl;

import java.util.List;

import javax.persistence.Query;

import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedScore;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.LeaderboardService;

@Service("leaderboardService")
@Repository
public class LeaderboardServiceImpl extends
		GenericDAOWithJPA<RecordedScore, Long> implements LeaderboardService {
/*
 *
 */
	private static final String BUDDY_SCORES_NATIVE_QUERY = 
		"select R.* from recorded_score R join game G on R.game_id = G.id join buddy B ON R.user_id = B.target_id join User U on U.id = B.owner_id"
		+ " where U.id=:userId AND G.id=:gameId ORDER BY R.points DESC";

	@SuppressWarnings(value = "unchecked")
	public List<RecordedScore> findTopScores(Long gameId, int limit) {
		if (limit<=0)
			limit = 100;
		return super.entityManager
		.createQuery(
				"Select S from RecordedScore as S join S.game as G  where g.id=:gameId  order by S.points desc")
		.setParameter("gameId", gameId)
		.setMaxResults(limit).getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<RecordedScore> findBuddyScores(Long gameId) {
		Query q = super.entityManager
		.createNativeQuery(BUDDY_SCORES_NATIVE_QUERY, RecordedScore.class);
		
		return q.setParameter("userId", SecurityUtil.getPrincipal().getId())
		.setParameter("gameId", gameId)
		.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<RecordedScore> findScoreByUserId(Long gameId) {
		return super.entityManager
				.createQuery(
						"Select S from RecordedScore as S join S.game as G join S.user as U where G.id=:gameId and U.id=:userId ORDER by S.points DESC")
				.setParameter("gameId", gameId)
				.setParameter("userId", SecurityUtil.getPrincipal().getId())
				.getResultList();
	}

	
	@Transactional
	public RecordedScore recordScore(Long gameId, long points) {
	//	findTopScoreBy
		User user = entityManager.find(User.class, SecurityUtil.getPrincipal().getId());
		if (user == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.id", SecurityUtil.getPrincipal().getId()));
		
		Game game = entityManager.find(Game.class, gameId);
		if (game == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Game.id", gameId));
		
		boolean recordingDecision = false;

		List<RecordedScore> existingScores = findScoreByUserId(gameId);
		Integer cutoffScoreLoc = null;
		int numscores=0;
		boolean isTopScore = false;
		if (existingScores==null || (numscores = existingScores.size()) < MAX_TOP_SCORES_PER_GAME) {
			recordingDecision = true;
		} else if (numscores>0 && existingScores.get(numscores-1).getPoints() > points) {		
			recordingDecision = false;
		} else  {
			cutoffScoreLoc = MAX_TOP_SCORES_PER_GAME-1;	
			recordingDecision = true;
		}
		if (cutoffScoreLoc!=null) {
			for(int i=numscores-1; i>=MAX_TOP_SCORES_PER_GAME-1; i--) {
				entityManager.remove(existingScores.get(i));
				existingScores.remove(i);
			}
			numscores = existingScores.size();
		}
		if (recordingDecision==true) {
			if (numscores==0 || (numscores>0 && points > existingScores.get(0).getPoints())) {
				isTopScore = true;
			}
			
			RecordedScore newScore = new RecordedScore();

			newScore.setUser(user);
			newScore.setGame(game);
			newScore.setPoints(points);
			super.entityManager.persist(newScore);
			
			if (isTopScore) {
				entityManager.persist(new Event(EventType.HIGH_SCORE_EVENT, user, null, getMessage(newScore), newScore));
			}
			return newScore;
		}
		return null;
		
	}
	
	public String getMessage(RecordedScore score) {
		return
		score.getUser().getUsername()
		+ " obtained a new high score of "
		+ score.getPoints()
		+ " in "
		+ score.getGame().getName();
	}

}
