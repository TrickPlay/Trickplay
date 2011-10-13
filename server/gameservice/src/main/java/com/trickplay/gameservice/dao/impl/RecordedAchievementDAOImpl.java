package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.RecordedAchievementDAO;
import com.trickplay.gameservice.domain.RecordedAchievement;
import com.trickplay.gameservice.security.SecurityUtil;

@Repository
@SuppressWarnings("unchecked")
public class RecordedAchievementDAOImpl extends GenericDAOWithJPA<RecordedAchievement, Long> implements RecordedAchievementDAO {
    public List<RecordedAchievement> findAllByGameId(Long userId, Long gameId)
    {
        return super.entityManager.createQuery
        (
                "select R from RecordedAchievment as R join R.game as G join R.user as U where G.id=:gId and U.id=:uId"
                )
                .setParameter("gId", gameId)
                .setParameter("uId", userId)
                .getResultList();
    }
}
