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

import com.trickplay.gameservice.domain.Role;
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
public class UserServiceTest {

	@Autowired
	private UserService userService;
	
	@Before
	public void setup(){
		Authentication authRequest = new UsernamePasswordAuthenticationToken("ignored", "ignored", AuthorityUtils.createAuthorityList("ROLE_ADMIN"));
	    SecurityContextHolder.getContext().setAuthentication(authRequest);

	}

	@Test
	@Rollback
	public void testRoleCreate() {
		Role r = userService.createRole("dummyRole");
		Assert.assertTrue(r.getId()!=null);
		Assert.assertTrue(r.getName().equals("dummyRole"));
	}

	
	@Test
	@Rollback
	public void testPersist() {
		User homer = DataSeeder.generateUser();
		//homer.setEmail(null);
		userService.create(homer);
		assertEquals("homer", userService.find(homer.getId()).getUsername());
	}

	@Test
	@Rollback
	public void testUpdate() {
		User person = DataSeeder.generateUser();
		userService.create(person);
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
*/
	@Test
	@Rollback
	public void testRead() {
		User homer = DataSeeder.generateUser();
		userService.create(homer);
		User result = userService.find(homer.getId());
		assertEquals("homer", result.getUsername());
		assertEquals("homer@simpsons.com", result.getEmail());
		assertEquals("homer", result.getPassword());
	}

	@Test
	@Rollback
	public void testFindByUsername() {
		userService.create(DataSeeder.generateUser());
		assertEquals("homer", userService.findByName("homer").getUsername());
	}
	
	@After
	public void tearDown(){
		SecurityContextHolder.clearContext();
	}
}
