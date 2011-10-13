package com.trickplay.gameservice.service.impl;

import java.util.List;

import javax.persistence.EntityExistsException;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.AchievementDAO;
import com.trickplay.gameservice.dao.EventDAO;
import com.trickplay.gameservice.dao.RecordedAchievementDAO;
import com.trickplay.gameservice.domain.Achievement;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.RecordedAchievement;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.AchievementService;

@Service("achievementService")
public class AchievementServiceImpl implements AchievementService {
    @Autowired
    private EventDAO eventDAO;

    @Autowired
    private AchievementDAO achievementDAO;

    @Autowired
    private RecordedAchievementDAO recordedAchievementDAO;

    private EntityManager entityManager;

    @PersistenceContext
    public void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    /*
     * TODO: implement findBuddyRecordedAchievement (non-Javadoc)
     * 
     * @see com.trickplay.gameservice.service.AchievementService#
     * findBuddyRecordedAchievement(com.trickplay.gameservice.domain.Game,
     * com.trickplay.gameservice.domain.User)
     */
    public List<RecordedAchievement> findBuddyRecordedAchievement(Long gameId,
            Long buddyId) {
        return null;
    }

    public List<RecordedAchievement> findAllRecordedAchievementsByGameId(
            Long gameId) {
        Long userId = SecurityUtil.getPrincipal().getId();
        return recordedAchievementDAO.findAllByGameId(userId, gameId);
    }

    public RecordedAchievement findRecordedAchievement(Long id) {
        return recordedAchievementDAO.find(id);
    }

    public List<Achievement> findAchievementsByGameId(Long gameId) {
        return achievementDAO.findAllByGameId(gameId);
    }

    @Transactional
    public void create(final RecordedAchievement entity) {
        /*
         * TransactionTemplate transactionTemplate = new TransactionTemplate();
         * transactionTemplate.execute(new TransactionCallback<Void>() { public
         * Void doInTransaction(TransactionStatus status) {
         */
        if (entity == null) {
            throw ExceptionUtil.newIllegalArgumentException("RecordedAchievement", null, "!= null");
        } else if (entity.getUser().getId() != SecurityUtil.getCurrentUserId()) {
            throw ExceptionUtil.newForbiddenException();
        }
        
        try {
            recordedAchievementDAO.persist(entity);
            eventDAO.persist(
                    new Event(EventType.ACHIEVEMENT_EVENT, 
                            entity.getUser(), 
                            null, 
                            getMessage(entity), 
                            entity
                            )
                    );
        } catch (EntityExistsException ex) {
            throw ExceptionUtil.newEntityExistsException(RecordedAchievement.class, 
                    "userName", entity.getUser().getUsername(),
                    "game", entity.getAchievement().getGame().getName(),
                    "achievement", entity.getAchievement().getName());
        } /*catch (PersistenceException ex) {
            throw ExceptionUtil.
        }*/
        /*
         * return null; } });
         */
    }

    public Achievement find(Long id) {
        return achievementDAO.find(id);
    }

    /* 
     * TODO: Security check. make sure an authorized user is requesting this operation
     */
    public void create(Achievement entity) {
        if (entity == null) {
            throw ExceptionUtil.newIllegalArgumentException("Achievement", null, "!= null");
        } 
        achievementDAO.persist(entity);
    }

    public String getMessage(RecordedAchievement ra) {
        return ra.getUser().getUsername() + " obtained "
                + ra.getAchievement().getName() + " in "
                + ra.getAchievement().getGame().getName();
    }

}
