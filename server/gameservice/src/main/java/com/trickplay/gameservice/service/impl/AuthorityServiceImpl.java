package com.trickplay.gameservice.service.impl;

import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.domain.Authority;
import com.trickplay.gameservice.service.AuthorityService;


@Service("authorityService")
@Repository
public class AuthorityServiceImpl extends GenericDAOWithJPA<Authority, Long> implements AuthorityService {
/*
	@PostConstruct
	public void initialize() throws Exception {
		Authority authorities = new Authority();
		authorities.setUsername("admin");
		authorities.setAuthority("ROLE_ADMIN");
		super.persist(authorities);		
	}
*/
}
