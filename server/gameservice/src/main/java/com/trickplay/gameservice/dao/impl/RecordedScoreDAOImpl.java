package com.trickplay.gameservice.dao.impl;

import java.util.List;

import javax.persistence.Query;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.RecordedScoreDAO;
import com.trickplay.gameservice.domain.RecordedScore;

@Repository
@SuppressWarnings("unchecked")
public class RecordedScoreDAOImpl extends GenericDAOWithJPA<RecordedScore, Long> implements RecordedScoreDAO {
    private static final String BUDDY_SCORES_NATIVE_QUERY = 
            "select R.* from recorded_score R join game G on R.game_id = G.id join buddy B ON R.user_id = B.target_id join user U on U.id = B.owner_id"
            + " where U.id=:userId AND G.id=:gameId ORDER BY R.points DESC";
    
    public List<RecordedScore> findTopScores(Long gameId, int limit) {
        return super.entityManager
        .createQuery(
                "Select S from RecordedScore as S join S.game as G  where g.id=:gameId  order by S.points desc")
        .setParameter("gameId", gameId)
        .setMaxResults(limit).getResultList();
    }

    public List<RecordedScore> findBuddyScores(Long gameId, Long userId) {
        Query q = super.entityManager
        .createNativeQuery(BUDDY_SCORES_NATIVE_QUERY, RecordedScore.class);
        
        return q.setParameter("userId", userId)
        .setParameter("gameId", gameId)
        .getResultList();
    }

    public List<RecordedScore> findScoreByUserId(Long gameId, Long userId) {
        return super.entityManager
                .createQuery(
                        "Select S from RecordedScore as S join S.game as G join S.user as U where G.id=:gameId and U.id=:userId ORDER by S.points DESC")
                .setParameter("gameId", gameId)
                .setParameter("userId", userId)
                .getResultList();
    }

}
