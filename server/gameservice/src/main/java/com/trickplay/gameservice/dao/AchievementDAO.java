package com.trickplay.gameservice.dao;

import java.util.List;

import com.trickplay.gameservice.domain.Achievement;

public interface AchievementDAO extends GenericDAO<Achievement, Long> {
    public List<Achievement> findAllByGameId(Long gameId);

}
