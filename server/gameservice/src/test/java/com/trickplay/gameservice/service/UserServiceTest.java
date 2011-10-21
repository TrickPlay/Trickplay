package com.trickplay.gameservice.service;

import static org.junit.Assert.assertEquals;
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

import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
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
public class UserServiceTest {

    @Autowired
    TestUtil testUtil;
    
	@Autowired
	private UserService userService;
	
	@Before
	public void setup(){
	    testUtil.setAnonymousSecurityContext();
	}

	@Test
	public void testRoleCreate() {
	    testUtil.setAdminSecurityContext();
		Role r = userService.createRole("dummyRole");
		assertTrue(r.getId()!=null);
		assertTrue(r.getName().equals("dummyRole"));
	}

	
	@Test
	public void testCreate() {
		User homer = DataSeeder.generateUser();
		userService.create(homer);
		assertTrue(homer.getId()!=null);
	}

    @Test
    public void testCreateNullArgumentException() {
        try {
            userService.create(null);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.ILLEGAL_ARGUMENT);
        }
    }
    
    @Test
    public void testCreateNullPasswordException() {
        try {
            User home = new User("homer", null, "homer@yahoo.com", false, false);
            userService.create(home);
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.ILLEGAL_ARGUMENT);
        }
    }
    
    @Test
    public void testCreateInvalidEmailException() {
        try {
            User home = new User("homer", "homer", "home@r@yahoo.com", false, false);
            userService.create(home);
            assertTrue(false);
        } catch (GameServiceException ex) {
            ex.printStackTrace();
            assertTrue(ex.getReason()==Reason.ILLEGAL_ARGUMENT);
        }
    }
    

	   
	@Test
	public void testUpdate() {
		User person = new User("homer", "homer", "homer@yahoo.com", false, false);
		userService.create(person);
		
		User homer = userService.find(person.getId());
		testUtil.setSecurityContext(person.getUsername(), person.getPassword(), false);
		User person2 = new User();
		person2.setUsername(person.getUsername());
		person2.setEmail("homer@blah.com");
		userService.update(person2);
		
		person = userService.findByName(person2.getUsername());
		assertEquals("homer@blah.com", userService.find(person.getId()).getEmail());
	}


	@Test
	public void testFind() {
		User person = new User("homer", "homer", "homer@yahoo.com", false, false);
		userService.create(person);
		
		testUtil.setSecurityContext(person.getUsername(), person.getPassword(), false);
		
		User result = userService.find(person.getId());
		assertTrue("homer".equals(result.getUsername()));
		assertTrue("homer@yahoo.com".equals(result.getEmail()));
	}

	@Test
	public void testFindByUsername() {
		userService.create(new User("homer", "homer", "homer@yahoo.com", false, false));
		assertEquals("homer", userService.findByName("homer").getUsername());
	}
	
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
