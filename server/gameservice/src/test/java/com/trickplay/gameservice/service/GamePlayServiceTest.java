package com.trickplay.gameservice.service;

import static org.junit.Assert.assertTrue;

import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.GamePlayInvitation;
import com.trickplay.gameservice.domain.GameSession;
import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.test.TestUtil;

/**
 *
 * @since 0.1
 * 
 */
@RunWith(SpringJUnit4ClassRunner.class)
@Transactional
@TransactionConfiguration(transactionManager = "transactionManager")
@ContextConfiguration(locations = { "classpath:gameservice-test.xml" })
public class GamePlayServiceTest {

	@Autowired
	private UserService userService;
	
	@Autowired
	private VendorService vendorService;
	
	@Autowired
    private GameService gameService;
	
	@Autowired
    private GamePlayService gamePlayService;

	@Autowired
	private TestUtil testUtil;
	
	private Vendor vendor;
	private Game turnBasedGame;
	
	@Before
	public void setup() {
	    createUser("u1", "u1", "u1@tp.com");
	    createUser("u2", "u2", "u2@tp.com");
        testUtil.setSecurityContext("u1", "u1");
        createVendor();
        createGame();
	}

	private User createUser(String username, String password, String email) {
        testUtil.setAnonymousSecurityContext();

        final User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password);
        userService.create(newUser);
        
        return newUser;
	}
	
	private void createVendor() {
        vendor = vendorService.create("Trickplay");
	}

    private void createGame() {
        Game g = new Game(
                "g1",
                "g1",
                2,
                2,
                true,
                true,
                true,
                true);
        turnBasedGame = gameService.create(vendor.getId(), g);
    }
    
    @Test
    public void testCreateSession() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        assertTrue( gs != null
                && gs.getId() != null
                && gs.getGame().getId().equals(turnBasedGame.getId()) 
                && gs.getPlayers().get(0).getId().equals(u2.getId())
                && gs.isOpen());
    }
	
    
    @Test
    public void testSendGamePlayInvitation() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        assertTrue( gpi != null
                && gpi.getId() != null
                && gpi.getGameSession().getId().equals(gs.getId()) 
                && gpi.getRequestor().getId().equals(u2.getId())
                && gpi.getRecipient().getId().equals(u1.getId()));
    }
    
    @Test
    public void testAcceptGamePlayInvitation() {
        testUtil.setSecurityContext("u2", "u2");
        userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 1);
        
        assertTrue(gpi_recvd != null
                && gpi_recvd.size() == 1
                && gpi_recvd.get(0).getId().equals(gpi.getId()));
        
        GamePlayInvitation gpi_updated = gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.ACCEPTED);
        assertTrue(gpi_updated != null
                && gpi_updated.getId().equals(gpi.getId())
                && gpi.getStatus() == InvitationStatus.ACCEPTED);
        
        gs = gamePlayService.find(gs.getId());
        
        assertTrue(gs != null
                && gs.isOpen() == false
                && gs.getStartTime() == null
                && gs.getPlayers() != null
                && gs.getPlayers().size() == 2);
    }
    
    /*
     * test to make sure getInvitations() doesn't return already accepted invitations
     */
    @Test
    public void testGetInvitationsAfterAccept() {
        testUtil.setSecurityContext("u2", "u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 1);
        
        gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.ACCEPTED);
        
        gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 1);
        
        assertTrue(gpi_recvd != null 
                && gpi_recvd.size() == 0);
        
    }
    
    /*
     * test to make sure getInvitations() doesn't return already accepted invitations
     */
    @Test
    public void testRejectInvitationAfterAccept() {
        testUtil.setSecurityContext("u2", "u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        gamePlayService.getInvitations(turnBasedGame.getId(), 1);
        
        gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.ACCEPTED);
        
        try {
            gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.REJECTED);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GP_INVITATION_INVALID_STATUS);
        }
        
    }
    
    /*
     * test to make sure that games which have "wildCardInvitationFlag" set to true
     * will allow wild card invitations
     */
    @Test
    public void testAllowWildCardInvitationCriteria() {
        Game g1_wildCardEnabled = new Game(
                "g1-wildcard",
                "g1-wildcard",
                2,
                2,
                true,
                true,
                true,
                true);
        Game wildCardGame = gameService.create(vendor.getId(), g1_wildCardEnabled);
        GameSession gs = gamePlayService.createGameSession(wildCardGame.getId());
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        assertTrue(gpi != null);
    }
    
    /*
     * test to make sure that games which have "wildCardInvitationFlag" set to false
     * will allow wild card invitations
     */
    @Test
    public void testRejectWildCardInvitationCriteria() {
        Game g1_wildCardDisabled = new Game(
                "g1-wildcard",
                "g1-wildcard",
                2,
                2,
                true,
                true,
                true,
                false);
        Game wildCardGame = gameService.create(vendor.getId(), g1_wildCardDisabled);
        GameSession gs = gamePlayService.createGameSession(wildCardGame.getId());
        try {
            GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.WILDCARD_INVITATION_NOT_ALLOWED);
        }
    }
    
    /*
     * test send Wildcard gameplay invitation
     */
    @Test
    public void testSendWildcardInvitation() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        assertTrue( gpi != null
                && gpi.getId() != null
                && gpi.getGameSession().getId().equals(gs.getId()) 
                && gpi.getRequestor().getId().equals(u2.getId())
                && gpi.getRecipient() == null);
    }

    /*
     * test: when a addressed invitation and a wild card invitation is available for a specific game session, 
     * only the addressed invitation should be presented to the user.
     */
    @Test
    public void testInvitationPrecedence() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
                
        GamePlayInvitation gpi_1 = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        GamePlayInvitation gpi_2 = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        assertTrue( gpi_1 != null 
                && gpi_2 != null 
                && !gpi_1.getId().equals(gpi_2.getId()));
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        assertTrue(gpi_recvd.size() == 1
                && gpi_recvd.get(0).getRecipient() != null
                && gpi_recvd.get(0).getRecipient().getId().equals(u1.getId()));
    }


    @Test
    public void testWildCardInvitationAccept() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        GamePlayInvitation gpi_wc = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        assertTrue(gpi_recvd.size() == 1
                && gpi_recvd.get(0).getId().equals(gpi_wc.getId())
                && gpi_recvd.get(0).getRecipient() == null
                && gpi_recvd.get(0).getReservedBy() != null
                && gpi_recvd.get(0).getReservedBy().getId().equals(u1.getId())
                && gpi_recvd.get(0).getReservedUntil() != null
                && gpi_recvd.get(0).getReservedUntil().after(new Date()));
        
        GamePlayInvitation gpi_accepted = gamePlayService.updateGamePlayInvitation(gpi_wc.getId(), InvitationStatus.ACCEPTED);
        
        assertTrue(gpi_accepted != null 
                && gpi_accepted.getId().equals(gpi_wc.getId())
                && gpi_accepted.getStatus() == InvitationStatus.ACCEPTED
                && gpi_accepted.getRecipient() != null
                && gpi_accepted.getRecipient().getId().equals(u1.getId()));
    }

    /*
     * a wild card invitation that is reserved to a user and not yet accepted should still be
     * returned to the same user when the user requests a getInvitations()
     */
    @Test
    public void testRepeatableWildCardInvitationAssignment() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        GamePlayInvitation gpi_wc = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        assertTrue(gpi_recvd.size() == 1
                && gpi_recvd.get(0).getId().equals(gpi_wc.getId())
                && gpi_recvd.get(0).getRecipient() == null
                && gpi_recvd.get(0).getReservedBy() != null
                && gpi_recvd.get(0).getReservedBy().getId().equals(u1.getId())
                && gpi_recvd.get(0).getReservedUntil() != null
                && gpi_recvd.get(0).getReservedUntil().after(new Date()));
        
        
        List<GamePlayInvitation> gpi_recvd2 = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        assertTrue(gpi_recvd2.size() == 1
                && gpi_recvd2.get(0).getId().equals(gpi_wc.getId())
                && gpi_recvd2.get(0).getRecipient() == null
                && gpi_recvd2.get(0).getReservedBy() != null
                && gpi_recvd2.get(0).getReservedBy().getId().equals(u1.getId())
                && gpi_recvd2.get(0).getReservedUntil() != null
                && gpi_recvd2.get(0).getReservedUntil().after(new Date()));
    }
    
    /*
     * a user who already joined the game session will not be allowed to obtain a wild card invitation 
     * from the same game session 
     * create 2 WC invitations.
     * user accepts 1st one after performing getInvitations
     * user should not find any pending invitations from the same gamesession for subsequent getInvitations
     */
    @Test
    public void testNoGameSessionInvitationsAfterAccept() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        GamePlayInvitation gpi_wc_1 = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        GamePlayInvitation gpi_wc_2 = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        assert(gpi_wc_1 != null
                && gpi_wc_2 != null
                && !gpi_wc_1.getId().equals(gpi_wc_2.getId()));
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        assertTrue(gpi_recvd.size() == 1);
        
        gamePlayService.updateGamePlayInvitation(gpi_recvd.get(0).getId(), InvitationStatus.ACCEPTED);
        
        List<GamePlayInvitation> gpi_recvd_2 = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        assertTrue(gpi_recvd_2.size() == 0);             
    }
    
    /*
     * sending an invitation to a user who is already member of the game session should result in a
     * exception
     */
    @Test
    public void testSendInvitationAfterAccept() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        
        gamePlayService.updateGamePlayInvitation(gpi_recvd.get(0).getId(), InvitationStatus.ACCEPTED);
        
        testUtil.setSecurityContext("u2", "u2");
        try {
            gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.INVITATION_PREVIOUSLY_SENT);      
        }
               
    }
    
    /*
     * sending an invitation to self should result in an exception
     */
    @Test
    public void testSendInvitationToSelf() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        try {
            gamePlayService.sendGamePlayInvitation(gs.getId(), u2.getId());
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GP_RECIPIENT_SAME_AS_REQUESTOR);      
        }
              
    }
    
    /*
     * start gameplay with less than minimum players 
     */
    @Test
    public void testStartGamePlayWithLessThanMinPlayers() {
        testUtil.setSecurityContext("u2", "u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        GameStepId stepId = gamePlayService.startGamePlay(gs.getId(), "empty", null);
        assertTrue(stepId != null);
                     
    }
    
    /*
     * starting gameplay multiple times should fail
     */
    @Test
    public void testStartGamePlayMultipleTimes() {
        testUtil.setSecurityContext("u2", "u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        
        GameStepId stepId = gamePlayService.startGamePlay(gs.getId(), "empty", null);
        
        try {
            stepId = gamePlayService.startGamePlay(gs.getId(), "empty", null);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GAME_ALREADY_STARTED);
        }
                     
    }
    
    /*
     * end gameplay without start should fail
     */
    @Test
    public void testEndGamePlayWithoutStart() {
        testUtil.setSecurityContext("u2", "u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());        
        
        try {
            GameStepId stepId = gamePlayService.endGamePlay(gs.getId(), "empty");
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GAME_NOT_STARTED);
        }
                     
    }
    
    /*
     * update gameplay without start should fail
     */
    @Test
    public void testUpdateGamePlayWithoutStart() {
        testUtil.setSecurityContext("u2", "u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());        
        
        try {
            GameStepId stepId = gamePlayService.updateGamePlay(gs.getId(), "empty", null);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GAME_NOT_STARTED);
        }
                     
    }
    
    /*
     * update gameplay after end should fail
     */
    @Test
    public void testUpdateGamePlayAfterEnd() {
        testUtil.setSecurityContext("u2", "u2");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());     
        gamePlayService.startGamePlay(gs.getId(), "{}", null);
        gamePlayService.endGamePlay(gs.getId(), "{}");
        
        try {
            GameStepId stepId = gamePlayService.updateGamePlay(gs.getId(), "empty", null);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GAME_ALREADY_ENDED);
        }
                     
    }
    
    /*
     * test to check if the game session is in closed state after minimum players required
     * join the game and the game has started
     */
    @Test
    public void testGameSessionClosedAfterMaxPlayersLimitReached() {
        testUtil.setSecurityContext("u2", "u2");
        
        assert(turnBasedGame.getMaxPlayers() == 2);
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        assertTrue(gs.isOpen());
        gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        gamePlayService.updateGamePlayInvitation(gpi_recvd.get(0).getId(), InvitationStatus.ACCEPTED);
        
        GameSession newGS = gamePlayService.find(gs.getId());
        
        assert(newGS != null 
                && newGS.isOpen() == false);
                     
    }
    
    /*
     * test to check if the nextTurn is implicitly assigned for a turn-based game which has already
     * started but the turn is not assigned
     */
    @Test
    public void testImplicitTurnAssignment1() {
        testUtil.setSecurityContext("u2", "u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        gamePlayService.startGamePlay(gs.getId(), "{}", null);
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        gamePlayService.updateGamePlayInvitation(gpi_recvd.get(0).getId(), InvitationStatus.ACCEPTED);
        
        GameSession newGS = gamePlayService.find(gs.getId());
        
        assert(newGS != null 
                && newGS.getState() != null
                && newGS.getState().getTurn() != null
                && newGS.getState().getTurn().getId().equals(u1.getId()));
                     
    }
    
    /*
     * test to check if the nextTurn is implicitly assigned for a turn-based game whose turn is not specified
     * but a user accepted invitation exists
     */
    @Test
    public void testImplicitTurnAssignment2() {
        testUtil.setSecurityContext("u2", "u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(turnBasedGame.getId());
        gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(turnBasedGame.getId(), 10);
        
        gamePlayService.updateGamePlayInvitation(gpi_recvd.get(0).getId(), InvitationStatus.ACCEPTED);
        
        testUtil.setSecurityContext("u2", "u2");
        gamePlayService.startGamePlay(gs.getId(), "{}", null);
        
        GameSession newGS = gamePlayService.find(gs.getId());
        
        assert(newGS != null 
                && newGS.getState() != null
                && newGS.getState().getTurn() != null
                && newGS.getState().getTurn().getId().equals(u1.getId()));
                     
    }
    
    
    
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
