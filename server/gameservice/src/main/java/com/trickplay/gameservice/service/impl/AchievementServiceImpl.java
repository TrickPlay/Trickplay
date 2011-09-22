package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.domain.Achievement;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedAchievement;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.service.AchievementService;
import com.trickplay.gameservice.service.EventService;

@Service("achievementService")
@Repository
public class AchievementServiceImpl extends GenericDAOWithJPA<Achievement, Long> implements
		AchievementService {
	@Autowired
	EventService eventService;

	/*
	 * TODO: implement findBuddyRecordedAchievement
	 * (non-Javadoc)
	 * @see com.trickplay.gameservice.service.AchievementService#findBuddyRecordedAchievement(com.trickplay.gameservice.domain.Game, com.trickplay.gameservice.domain.User)
	 */
	public List<RecordedAchievement> findBuddyRecordedAchievement(Game game,
			User user) {
		return null;
	}

	@SuppressWarnings("unchecked")
	public List<RecordedAchievement> findRecordedAchievement(Game game,
			User user) {
		return super.entityManager.createQuery
		(
				"select R from RecordedAchievment as R join R.game as G join R.user as U where G.id=:gId and U.id=:uId"
				)
				.setParameter("gId", game.getId())
				.setParameter("uId", user.getId())
				.getResultList();
	}

	public RecordedAchievement findRecordedAchievement(Long id) {
		return entityManager.find(RecordedAchievement.class, id);
	}

	@SuppressWarnings("unchecked")
	public List<Achievement> find(Game game) {
		return super.entityManager.createQuery
		(
				"select A from Achievment as A join A.game as G where G.id=:gId"
				)
				.setParameter("gId", game.getId())
				.getResultList();
	}

	@Transactional
	public void persist(RecordedAchievement entity) {
		super.entityManager.persist(entity);
		super.entityManager.persist(new Event(EventType.ACHIEVEMENT_EVENT, entity.getUser(), null, getMessage(entity), entity));
	}
	
	public String getMessage(RecordedAchievement ra) {
		return 
		ra.getUser().getUsername() 
		+ " obtained "
		+ ra.getAchievement().getName()
		+ " in "
		+ ra.getAchievement().getGame().getName();		
	}

}
