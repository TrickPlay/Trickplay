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
public class VendorServiceTest {

	@Autowired
	private UserService userService;
	
	@Autowired
	private VendorService vendorService;

	@Autowired
	private TestUtil testUtil;
	
	@Before
	public void setup() {
	    createUser("u1", "u1", "u1@tp.com");
	    createUser("u2", "u2", "u2@tp.com");
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
	
	
	@Test
	public void testCreateVendor() {
        testUtil.setSecurityContext("u1", "u1");
        
        // create a vendor
	    Vendor entity = vendorService.create("Trickplay");
		
        assertTrue(
                entity.getId() != null
                && entity.getPrimaryContact().getUsername().equals("u1")
                );
	//	assert
	}

    @Test
    public void testCreateVendorDuplicate() {
        testUtil.setSecurityContext("u1", "u1");

        // create a vendor
        Vendor entity = vendorService.create("Trickplay");

        assertTrue(entity.getId() != null
                && entity.getPrimaryContact().getUsername().equals("u1"));
        // assert
        try {
            vendorService.create("Trickplay");
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.ENTITY_EXISTS_EXCEPTION);
        }
    }
    
    @Test
    public void testVendorExists() {
        testUtil.setSecurityContext("u1", "u1");

        // look up for vendor
        Vendor entity = vendorService.findByName("Trickplay");
        assertTrue(entity == null);

        // look up for vendor
        entity = vendorService.create("Trickplay");
        assertTrue(entity.getId() != null
                && entity.getPrimaryContact().getUsername().equals("u1"));
        
     // look up for vendor
        entity = vendorService.findByName("Trickplay");
        assertTrue(entity != null && entity.getName().equals("Trickplay"));
    }
	
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
