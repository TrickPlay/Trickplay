package com.trickplay.gameservice.service;

import com.trickplay.gameservice.domain.User;


/**
 * A simple data seeder for domain objects.
 * 
 * 
 */
public class DataSeeder {


	public static User generateUser() {
		User person = new User();
		person.setUsername("homer");
		person.setEmail("homer@simpsons.com");
		person.setPassword("homer");
		return person;
	}
	
}
