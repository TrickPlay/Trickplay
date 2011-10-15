package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.EventDAO;
import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.dao.RecordedScoreDAO;
import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedScore;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.LeaderboardService;

@Service("leaderboardService")
public class LeaderboardServiceImpl implements LeaderboardService {

    @Autowired
    RecordedScoreDAO recordedScoreDAO;
    
    @Autowired
    GameDAO gameDAO;
    
    @Autowired
    UserDAO userDAO;
    
    @Autowired
    EventDAO eventDAO;
    
	public List<RecordedScore> findTopScores(Long gameId, int limit) {
		if (limit<=0)
			limit = 100;
		return recordedScoreDAO.findTopScores(gameId, limit);
	}

	public List<RecordedScore> findBuddyScores(Long gameId) {
		return recordedScoreDAO.findBuddyScores(gameId, SecurityUtil.getPrincipal().getId());
	}

	public List<RecordedScore> findScoreByUserId(Long gameId) {
		return recordedScoreDAO.findScoreByUserId(gameId, SecurityUtil.getPrincipal().getId());
	}

	
	@Transactional
	public RecordedScore recordScore(Long gameId, long points) {
	//	findTopScoreBy
	    Long userId = SecurityUtil.getCurrentUserId();
	    if (userId == null) {
	        throw ExceptionUtil.newForbiddenException();
	    }
		User user = userDAO.find(userId);
		if (user == null) {
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", SecurityUtil.getPrincipal().getId());
		}
		Game game = gameDAO.find(gameId);
		if (game == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Game.class, "id", gameId);
		}
		
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
			    recordedScoreDAO.remove(existingScores.get(i));
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
			recordedScoreDAO.persist(newScore);
			
			if (isTopScore) {
				eventDAO.persist(new Event(EventType.HIGH_SCORE_EVENT, user, null, getMessage(newScore), newScore));
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
