package com.trickplay.gameservice.service;

import static org.junit.Assert.assertTrue;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Achievement;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedAchievement;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.UserAdapter;

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
public class AchievementServiceTest {

	@Autowired
	private UserService userService;
	
	@Autowired
	private GameService gameService;
	
	@Autowired
	private AchievementService achievementService;

	@Before
	public void setup() {
        
	}

	private User createUser(String username, String password, String email) {
        Authentication authRequest = new UsernamePasswordAuthenticationToken("anonymous", "anonymous", AuthorityUtils.createAuthorityList("ROLE_ANONYMOUS"));
        SecurityContextHolder.getContext().setAuthentication(authRequest);

        final User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password);
        userService.create(newUser);
        
        UserAdapter ua = new UserAdapter(newUser.getId(),
                new org.springframework.security.core.userdetails.User(
                        newUser.getUsername(), 
                        newUser.getPassword(),
                        true, 
                        true, 
                        true, 
                        true, 
                        AuthorityUtils.createAuthorityList("ROLE_USER")));
        
        authRequest = new UsernamePasswordAuthenticationToken(ua, newUser.getPassword(), AuthorityUtils.createAuthorityList("ROLE_USER"));
        SecurityContextHolder.getContext().setAuthentication(authRequest);
        return newUser;
	}
	
	/* seed some data */
	private Game createHangman() {
	    final User gameOwner = createUser("developer", "developer", "developer@trickplay.com");
        
        // create a vendor
        Vendor v = userService.createVendor("Trickplay");
        
        // create a game
        Game hangman = new Game(null, "Hangman", "com.trickplay.games.hangman", 2, 2, true, true, true, true);
        gameService.create(v.getId(), hangman);
        return hangman;
	}
	
	@Test
	public void testCreateAchievement() {
	    Game hangman = createHangman();
	    Achievement a = new Achievement(hangman, "A1", "A1", 100);
	    
		achievementService.create(a);
		assertTrue(a.getId() != null);
	//	assert
	}

	@Test
    public void testCreateAchievementEntityExistsException() {
	    Game hangman = createHangman();
        Achievement a = new Achievement(hangman, "A1", "A1", 100);
        
        achievementService.create(a);
        try {
            Achievement copy_a = new Achievement(hangman, "A1", "A1", 100);
            achievementService.create(copy_a);
            assertTrue(false);
        } catch (GameServiceException e) {
            assertTrue(e.getReason()==Reason.ENTITY_EXISTS_EXCEPTION);
        }
    //  assert
    }
	
	@Test
    public void testCreateRecordedAchievement() {
        Game hangman = createHangman();
        Achievement a = new Achievement(hangman, "A1", "A1", 100);
        achievementService.create(a);
        
        User gamePlayer = createUser("player", "player", "player@trickplay.com");
        RecordedAchievement ra = new RecordedAchievement(hangman, gamePlayer, a);
        achievementService.create(ra);
        assertTrue(ra.getId()!=null);
    }
	
	@Test
    public void testRecordedAchievementEntityExistsException() {
        Game hangman = createHangman();
        Achievement a = new Achievement(hangman, "A1", "A1", 100);
        achievementService.create(a);
        
        User gamePlayer = createUser("player", "player", "player@trickplay.com");
        RecordedAchievement ra = new RecordedAchievement(hangman, gamePlayer, a);
        achievementService.create(ra);
        
        try {
            RecordedAchievement ra_copy = new RecordedAchievement(hangman, gamePlayer, a);
            achievementService.create(ra_copy);
            assertTrue(false);
        } catch (GameServiceException e) {
            assertTrue(e.getReason()==Reason.ENTITY_EXISTS_EXCEPTION);
        } 
    }
	
	
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
