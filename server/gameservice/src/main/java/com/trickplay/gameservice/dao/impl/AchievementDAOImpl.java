package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.AchievementDAO;
import com.trickplay.gameservice.domain.Achievement;

@Repository
@SuppressWarnings("unchecked")
public class AchievementDAOImpl extends GenericDAOWithJPA<Achievement, Long> implements AchievementDAO {

    public List<Achievement> findAllByGameId(Long gameId) {
        
        return super.entityManager.createQuery
        (
                "select A from Achievment as A join A.game as G where G.id=:gId"
                )
                .setParameter("gId", gameId)
                .getResultList();
    }
}
