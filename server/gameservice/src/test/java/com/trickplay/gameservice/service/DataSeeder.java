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
	
	
/*
	public static Investment generateInvestment() {
		Investment investment = new Investment();
		investment.setInitialUnitPrice(1.7f);
		investment.setUnit(100d);
		investment.setTransactionDate(new Date(System.currentTimeMillis()));
		investment.setProduct(generateProduct());
		return investment;
	}

	public static Product generateProduct() {
		Loan loan = new Loan();
		loan.setName("Home Loan");
		loan.setDescription("Real ripoff");
		loan.setInterest(25f);
		loan.setManagementFee(5d);
		HashSet<Person> lenders = new HashSet<Person>();
		lenders.add(generatePerson());
		lenders.add(generatePerson());
		loan.setLenders(lenders);
		return loan;
	}

	public static Address generateAddress() {
		return new Address("Evergreen Terrace", "99a", "Springfield", "57657", "Ohio", "USA");
	}*/
}
