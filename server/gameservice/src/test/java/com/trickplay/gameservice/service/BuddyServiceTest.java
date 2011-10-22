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

import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;
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
public class BuddyServiceTest {

	@Autowired
	private UserService userService;
	
	@Autowired
	private BuddyService buddyService;
	User u1;
	User u2;
	
	@Autowired
	private TestUtil testUtil;
	
	@Before
	public void setup(){
		testUtil.setAnonymousSecurityContext();
		
	    u1 = new User();
	    u1.setUsername("u1");
	    u1.setEmail("u1@tp.com");
	    u1.setPassword("u1");
	    userService.create(u1);
	    

	    u2 = new User();
	    u2.setUsername("u2");
	    u2.setEmail("u2@tp.com");
	    u2.setPassword("u2");
	    userService.create(u2);

	}
	
	/*
	 *  @Transactional
    public BuddyListInvitation sendInvitation(String recipientName) throws GameServiceException;
    */
	@Test
	public void testSendInvitation() {
	    testUtil.setSecurityContext("u1", "u1");
	    
	    BuddyListInvitation bli = buddyService.sendInvitation("u2");
	    assertTrue(
	            bli!=null 
	            && bli.getId()!=null 
	            && bli.getRequestor().getUsername().equals("u1")
	            && bli.getRecipient().getUsername().equals("u2"));
	}
	
	@Test
    public void testSendInvitationInvalidUser() {
        testUtil.setSecurityContext("u1", "u1");
        try {
            buddyService.sendInvitation("nonExistent");
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.ENTITY_NOT_FOUND);
        }
    }
	
	@Test
    public void testSendInvitationToSelf() {
        testUtil.setSecurityContext("u1", "u1");
        try {
            buddyService.sendInvitation("u1");
            assertTrue(false);
        } catch (GameServiceException ex) {
            assertTrue(ex.getReason()==Reason.INVITATION_TO_SELF);
        }
    }
	
	@Test
    public void testSendInvitationDuplicate() {
        testUtil.setSecurityContext("u1", "u1");
        
        BuddyListInvitation bli_1 = buddyService.sendInvitation("u2");
        BuddyListInvitation bli_2 = buddyService.sendInvitation("u2");
        assertTrue(
                bli_1.getId().equals(bli_2.getId()));
    }
	
	@Test
    public void testAcceptInvitation() {
        testUtil.setSecurityContext("u1", "u1");
        
        BuddyListInvitation bli_1 = buddyService.sendInvitation("u2");
        
        testUtil.setSecurityContext("u2", "u2");
        List<BuddyListInvitation> bliList = buddyService.getPendingInvitations();
        BuddyListInvitation bli_2 = buddyService.updateInvitationStatus(bliList.get(0).getId(), InvitationStatus.ACCEPTED);
        
        assertTrue(
                bli_1.getId().equals(bli_2.getId())
                && bli_2.getStatus() == InvitationStatus.ACCEPTED);
        
        // make sure u2 is in u1's buddylist and vice-versa
        User u1 = userService.findByName("u1");
        User u2 = userService.findByName("u2");
        boolean u1BuddyFound = false;
        for(Buddy b : u2.getBuddies()) {
            if (b.getTarget().getId().equals(u1.getId())) {
                u1BuddyFound = true;
                break;
            }
        }
        assertTrue(u1BuddyFound);
        
        boolean u2BuddyFound = false;
        for(Buddy b : u1.getBuddies()) {
            if (b.getTarget().getId().equals(u2.getId())) {
                u2BuddyFound = true;
                break;
            }
        }
        assertTrue(u2BuddyFound);
    }
	
    /*
    @Transactional
    public BuddyListInvitation updateInvitationStatus(Long invitationId, InvitationStatus newStatus);

    @Transactional
    public void removeBuddy(Long buddyId);

    public List<Buddy> findAll(Long ownerId);

    @Transactional
    public void create(Buddy entity);

    @Transactional
    public Buddy update(Buddy entity);

    public Buddy find(Long id);
    
    public List<Buddy> findByOwnerName(String ownerName);
    
    public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId);
	 */

	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
