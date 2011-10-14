package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
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
    Logger logger = LoggerFactory.getLogger(AchievementServiceImpl.class);
    @Autowired
    private EventDAO eventDAO;

    @Autowired
    private AchievementDAO achievementDAO;

    @Autowired
    private RecordedAchievementDAO recordedAchievementDAO;


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
        } 
        else if (entity.getAchievement() == null) {
            throw ExceptionUtil.newIllegalArgumentException("RecordedAchievement.achievement", null, "!= null");
        }
        else if (entity.getUser() == null) {
            throw ExceptionUtil.newIllegalArgumentException("RecordedAchievement.user", null, "!= null");
        }
        else if (entity.getUser().getId() != SecurityUtil.getCurrentUserId()) {
            if (logger.isDebugEnabled()) {
                logger.debug("Create RecordedAchievement failed. Security exception. RecordedAchievement.user[id="
                        + entity.getUser().getId()
                        + "] is different from logged in user[id="
                        + SecurityUtil.getCurrentUserId()
                        + "]");
            }
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
        } catch (DataIntegrityViolationException ex) {
            logger.error("Caught exception in create RecordedAchievement", ex);
            throw ExceptionUtil.newEntityExistsException(RecordedAchievement.class, 
                    "userName", entity.getUser().getUsername(),
                    "game", entity.getAchievement().getGame().getName(),
                    "achievement", entity.getAchievement().getName());
        } catch (RuntimeException ex) {
            logger.error("Caught exception in create RecordedAchievement", ex);
            throw ExceptionUtil.newUnknownException(ex.getMessage());
        }
    }

    public Achievement find(Long id) {
        return achievementDAO.find(id);
    }

    /* 
     * TODO: Security check. make sure an authorized user is requesting this operation
     */
    @Transactional
    public void create(Achievement entity) {
        if (entity == null) {
            throw ExceptionUtil.newIllegalArgumentException("Achievement", null, "!= null");
        } 
        else if (entity.getGame()==null) {
            throw ExceptionUtil.newIllegalArgumentException("Achievement.game", null, "!= null");
        }
        try {
            achievementDAO.persist(entity);
        } catch (DataIntegrityViolationException ex) {
            logger.error("Caught exception in create Achievement", ex);
            throw ExceptionUtil.newEntityExistsException(Achievement.class,
                    "game", entity.getGame().getName(),
                    "achievement", entity.getName());
        } catch (RuntimeException ex) {
            logger.error("Caught exception in create Achievement", ex);
            throw ExceptionUtil.newUnknownException(ex.getMessage());
        }
    }

    public String getMessage(RecordedAchievement ra) {
        return ra.getUser().getUsername() + " obtained "
                + ra.getAchievement().getName() + " in "
                + ra.getAchievement().getGame().getName();
    }

}
