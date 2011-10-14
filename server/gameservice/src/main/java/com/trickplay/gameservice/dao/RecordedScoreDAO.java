package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.RecordedScore;

public interface RecordedScoreDAO extends GenericDAO<RecordedScore, Long> {

    public List<RecordedScore> findTopScores(Long gameId, int limit);

    public List<RecordedScore> findBuddyScores(Long gameId, Long userId);

    public List<RecordedScore> findScoreByUserId(Long gameId, Long userId);
}
