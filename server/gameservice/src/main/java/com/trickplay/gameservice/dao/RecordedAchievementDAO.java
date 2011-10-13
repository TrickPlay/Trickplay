package com.trickplay.gameservice.dao;

import java.util.List;

import com.trickplay.gameservice.domain.RecordedAchievement;

public interface RecordedAchievementDAO extends GenericDAO<RecordedAchievement, Long> {

    public List<RecordedAchievement> findAllByGameId(Long userId, Long gameId);
    
}
