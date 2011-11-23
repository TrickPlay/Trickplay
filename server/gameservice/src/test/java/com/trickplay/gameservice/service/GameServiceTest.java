package com.trickplay.gameservice.service;

import static org.junit.Assert.assertTrue;

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
public class GameServiceTest {

	@Autowired
	private UserService userService;
	
	@Autowired
	private VendorService vendorService;
	
	@Autowired
    private GameService gameService;

	@Autowired
	private TestUtil testUtil;
	
	private Vendor vendor;
	
	@Before
	public void setup() {
	    createUser("u1", "u1", "u1@tp.com");
	    createUser("u2", "u2", "u2@tp.com");
        testUtil.setSecurityContext("u1", "u1");
        createVendor();
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

    @Test
    public void testCreate() {
        Game g = new Game(
                "g1",
                "g1",
                2,
                2,
                true,
                true,
                true,
                true);
        gameService.create(vendor.getId(), g);

        assertTrue(g.getId() != null
                && g.getVendor().getName().equals(vendor.getName()));
    }
    
    @Test
    public void testCreateDuplicate() {
        Game g = new Game(
                "g1",
                "g1",
                2,
                2,
                true,
                true,
                true,
                true);
        gameService.create(vendor.getId(), g);

        assertTrue(g.getId() != null
                && g.getVendor().getName().equals(vendor.getName()));
        
        try {
            Game g_duplicate = new Game(
                    "g1",
                    "g1",
                    2,
                    2,
                    true,
                    true,
                    true,
                    true);
            gameService.create(vendor.getId(), g_duplicate);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.ENTITY_EXISTS_EXCEPTION);
        }
    }
	
    
    @Test
    public void testUpdate() {
        Game g = new Game(
                "g1",
                "g1",
                2,
                2,
                true,
                true,
                true,
                true);
        gameService.create(vendor.getId(), g);

        assertTrue(g.getId() != null
                && g.getVendor().getName().equals(vendor.getName()));
        
        Game g_updated = new Game(
                "g1",
                "g1",
                2,
                4,
                false,
                false,
                false,
                false);
        g_updated.setId(g.getId());
        gameService.update(vendor.getId(), g_updated);
        
        assertTrue(
                g_updated.getId() != null 
                && g.getId().equals(g_updated.getId())
                && g.getMaxPlayers() == 4
                && g.isAchievementsFlag() == false
                && g.isLeaderboardFlag() == false
                && g.isAllowWildCardInvitation() == false
                && g.isTurnBasedFlag() == false);
    }
    
    @Test
    public void testFindById() {
        Game g = new Game(
                "g1",
                "g1",
                2,
                2,
                true,
                true,
                true,
                true);
        gameService.create(vendor.getId(), g);

        assertTrue(g.getId() != null
                && g.getVendor().getName().equals(vendor.getName()));
        
        Game foundGame = gameService.find(g.getId());
        assertTrue(foundGame != null
                && foundGame.getId().equals(g.getId()));
    }
    
    @Test
    public void testFindByName() {
        Game g = new Game(
                "g1",
                "g1.trickplay.com",
                2,
                2,
                true,
                true,
                true,
                true);
        gameService.create(vendor.getId(), g);

        assertTrue(g.getId() != null
                && g.getVendor().getName().equals(vendor.getName()));
        
        Game foundGame = gameService.findByName(g.getName());
        assertTrue(foundGame != null
                && foundGame.getId().equals(g.getId()));
    }
    
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
