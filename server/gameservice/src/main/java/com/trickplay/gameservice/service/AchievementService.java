package com.trickplay.gameservice.service;

import java.util.List;

import com.trickplay.gameservice.domain.Achievement;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedAchievement;
import com.trickplay.gameservice.domain.User;

public interface AchievementService {

	public List<RecordedAchievement> findBuddyRecordedAchievement(Game game, User user);
	
	public List<RecordedAchievement> findRecordedAchievement(Game game, User user);
	
	public void persist(RecordedAchievement score);
	
	public RecordedAchievement findRecordedAchievement(Long id);
	
	public List<Achievement> find(Game game);
	
	public Achievement find(Long id);
	
	public void merge(Achievement entity);
	
	public void persist(Achievement entity);
}
