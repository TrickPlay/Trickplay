package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.GamePlaySummary;


public interface GamePlaySummaryDAO extends GenericDAO<GamePlaySummary, Long> {

    public GamePlaySummary findByGameAndUser(Long gameId, Long userId);
}
