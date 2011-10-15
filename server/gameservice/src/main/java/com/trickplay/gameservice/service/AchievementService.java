package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;

import com.trickplay.gameservice.domain.Achievement;
import com.trickplay.gameservice.domain.RecordedAchievement;

public interface AchievementService {

	public List<RecordedAchievement> findBuddyRecordedAchievement(Long gameId, Long buddyId);

	public List<RecordedAchievement> findAllRecordedAchievementsByGameId(Long id);
	
	@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
	public void create(RecordedAchievement score);
	
	public RecordedAchievement findRecordedAchievement(Long id);
	
	public List<Achievement> findAchievementsByGameId(Long gameId);
	
	public Achievement find(Long id);
	
	@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
	public void create(Achievement entity);
}
