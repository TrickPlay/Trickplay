package com.trickplay.gameservice.service;

import static org.junit.Assert.assertTrue;

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
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.test.TestUtil;

/**
 * A simple integration test for UserService.
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
	private Game game;
	
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
        game = gameService.create(vendor.getId(), g);
    }
    
    @Test
    public void testCreateSession() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
        
        assertTrue( gs != null
                && gs.getId() != null
                && gs.getGame().getId().equals(game.getId()) 
                && gs.getPlayers().get(0).getId().equals(u2.getId()));
    }
	
    @Test
    public void testSendGamePlayInvitation() {
        testUtil.setSecurityContext("u2", "u2");
        User u2 = userService.findByName("u2");
        User u1 = userService.findByName("u1");
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
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
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(game.getId(), 1);
        
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
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(game.getId(), 1);
        
        gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.ACCEPTED);
        
        gpi_recvd = gamePlayService.getInvitations(game.getId(), 1);
        
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
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
        GamePlayInvitation gpi = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        testUtil.setSecurityContext("u1", "u1");
        gamePlayService.getInvitations(game.getId(), 1);
        
        gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.ACCEPTED);
        
        try {
            gamePlayService.updateGamePlayInvitation(gpi.getId(), InvitationStatus.REJECTED);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason() == Reason.GP_INVITATION_INVALID_STATUS);
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
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
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
        
        GameSession gs = gamePlayService.createGameSession(game.getId());
                
        GamePlayInvitation gpi_1 = gamePlayService.sendGamePlayInvitation(gs.getId(), u1.getId());
        
        GamePlayInvitation gpi_2 = gamePlayService.sendGamePlayInvitation(gs.getId(), null);
        
        assertTrue( gpi_1 != null 
                && gpi_2 != null 
                && !gpi_1.getId().equals(gpi_2.getId()));
        
        testUtil.setSecurityContext("u1", "u1");
        List<GamePlayInvitation> gpi_recvd = gamePlayService.getInvitations(game.getId(), 10);
        
        assertTrue(gpi_recvd.size() == 1
                && gpi_recvd.get(0).getRecipient() != null
                && gpi_recvd.get(0).getRecipient().getId().equals(u1.getId()));
    }

    
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
