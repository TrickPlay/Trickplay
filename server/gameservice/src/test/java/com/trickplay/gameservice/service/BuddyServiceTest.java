package com.trickplay.gameservice.service;

import static org.junit.Assert.assertEquals;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyStatus;
import com.trickplay.gameservice.domain.User;

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
	@Before
	public void setup(){
		Authentication authRequest = new UsernamePasswordAuthenticationToken("ignored", "ignored", AuthorityUtils.createAuthorityList("ROLE_ADMIN"));
	    SecurityContextHolder.getContext().setAuthentication(authRequest);
		
	    u1 = new User();
	    u1.setUsername("u1");
	    u1.setEmail("u1@tp.com");
	    u1.setPassword("u1");
	    
	    userService.create(u1);

	    u2 = new User();
	    u2.setUsername("u2");
	    u2.setEmail("u1@tp.com");
	    u2.setPassword("u2");
	    userService.create(u2);

	}
	
	/*
	public void persist(Buddy entity);
	@Test
	@Rollback
	public void testPersist() {
		User homer = DataSeeder.generateUser();
		//homer.setEmail(null);
		userService.persist(homer);
		assertEquals("homer", userService.find(homer.getId()).getUsername());
	}

	*/
	@Test
	@Rollback
	public void testPersist()
	{
		Buddy b = new Buddy();
		b.setOwner(u1);
		b.setTarget(u2);
		b.setStatus(BuddyStatus.CURRENT);
		buddyService.persist(b);
		Buddy n = buddyService.find(b.getId());
		Assert.assertTrue(
				b.getId() == n.getId() 
				&& b.getOwner().getId() == n.getOwner().getId()
				&& b.getTarget().getId() == n.getTarget().getId());
	}
	/*
	 * public BuddyListInvitation newBuddyInvitation(User requestor, User recipient);
	public void handleBuddyListInvitation(BuddyListInvitation bli);
	
	public void removeBuddy(Buddy buddy);

	public List<Buddy> findAll(Long ownerId);

	

	public void merge(Buddy entity);

	public Buddy find(Long id);
	
	public List<Buddy> findByOwnerName(String ownerName);
	
	public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId);
	*/
	
	/*
	@Test
	@Rollback
	public void testUpdate() {
		User person = DataSeeder.generateUser();
		userService.persist(person);
		person.setEmail("homer@blah.com");
		userService.merge(person);
		assertEquals("homer@blah.com", userService.find(person.getId()).getEmail());
	}

	/*
	@Test
	@Rollback
	public void testDelete() {
		User homer = DataSeeder.generateUser();
		userService.persist(homer);
		userService.(homer);
		assertEquals(1l, userService.findAll().size());
	}

	@Test
	@Rollback
	public void testRead() {
		User homer = DataSeeder.generateUser();
		userService.persist(homer);
		User result = userService.find(homer.getId());
		assertEquals("homer", result.getUsername());
		assertEquals("homer@simpsons.com", result.getEmail());
		assertEquals("homer", result.getPassword());
	}

	@Test
	@Rollback
	public void testFindByUsername() {
		userService.persist(DataSeeder.generateUser());
		assertEquals("homer", userService.findByName("homer").getUsername());
	}
	*/
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
