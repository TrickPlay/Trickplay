package com.trickplay.gameservice.service.impl;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.support.JdbcDaoSupport;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.service.DBPurgeService;

public class DBPurgeServiceImpl extends JdbcDaoSupport implements DBPurgeService {

    // Event Delete * from Event
    // Device Delete * from Device

    // RecordedAchievement
    // RecordedScore
    // Achievement
    // Leaderboard
    // GamePlayInvitation
    // GameSessionMessage
    // GamePlayState
    // GameSession
    // GamePlaySummary
    // Game
    
    // Buddy
    // BuddyListInvitation

    // SessionToken
    // Vendor
    // User
    //
    private static final String deleteEventQuery = "delete from Event";
    private static final String deleteDeviceQuery = "delete from Device";
    
    private static final String deleteRecordedAchievementQuery = "delete from RecordedAchievement";
    private static final String deleteRecordedScoreQuery = "delete from RecordedScore";
    private static final String deleteAchievementQuery = "delete from Achievement";
 //   private static final String deleteLeaderboardQuery = "delete from Leaderboard";
    
    private static final String deleteGamePlayInvitationQuery = "delete from GamePlayInvitation";
    private static final String deleteGameSessionMessageQuery = "delete from GameSessionMessage";
    private static final String deleteGamePlayStateQuery = "delete from GamePlayState";
    private static final String deleteGameSessionPlayersNativeQuery = "delete from game_session_player";
    private static final String eraseGameSessionStateQuery = "update GameSession set state = null";
    private static final String deleteGameSessionQuery = "delete from GameSession";
    private static final String deleteGamePlaySummaryQuery = "delete from GamePlaySummary";
    private static final String deleteGameQuery = "delete from Game";
    
    private static final String deleteBuddyListInvitationQuery = "delete from BuddyListInvitation";
    private static final String deleteBuddyQuery = "delete from Buddy";
    private static final String deleteSessionTokenQuery = "delete from SessionToken";
    private static final String deleteVendorQuery = "delete from Vendor";
    private static final String deleteUserRoleNativeQuery = "delete from user_role where user_id != ?";
    private static final String deleteUserNativeQuery = "delete from user where id != ?";
    
    @Autowired
    protected UserDAO userDAO;
    
    
    @Value("#{adminUser}") private User admin;
    protected EntityManager entityManager;
    
    @PersistenceContext
    public void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }
    
    @Transactional
    private void executeQuery(String query) {
        entityManager.createQuery(query).executeUpdate();
    }
    
    @Transactional
    private void executeJdbcQuery(String query) {
        getJdbcTemplate().update(query);//.executeUpdate();
    }
    
    @Transactional
    private void deleteUserRoles(Long adminId) {
        getJdbcTemplate().update(deleteUserRoleNativeQuery, new Object[] {adminId});//.executeUpdate();
    }
    
    @Transactional
    private void deleteNonAdminUsers(Long adminId) {
        getJdbcTemplate().update(deleteUserNativeQuery, new Object[] {adminId});
    }
    
    public void resetDB() {
        executeQuery(deleteEventQuery);
        executeQuery(deleteDeviceQuery);
        executeQuery(deleteRecordedAchievementQuery);
        executeQuery(deleteRecordedScoreQuery);
        executeQuery(deleteAchievementQuery);
     //   executeQuery(deleteLeaderboardQuery);
        executeQuery(deleteGamePlayInvitationQuery);
        executeQuery(deleteGameSessionMessageQuery);
        executeJdbcQuery(deleteGameSessionPlayersNativeQuery);
        executeQuery(eraseGameSessionStateQuery);
        executeQuery(deleteGamePlayStateQuery);
        executeQuery(deleteGameSessionQuery);
        executeQuery(deleteGamePlaySummaryQuery);
        executeQuery(deleteGameQuery);
        
        executeQuery(deleteBuddyListInvitationQuery);
        executeQuery(deleteBuddyQuery);
        executeQuery(deleteSessionTokenQuery);
        executeQuery(deleteVendorQuery);
        
        User adminUser = userDAO.findByName(admin.getUsername());
        deleteUserRoles(adminUser.getId());
        deleteNonAdminUsers(adminUser.getId());        
    }
}
