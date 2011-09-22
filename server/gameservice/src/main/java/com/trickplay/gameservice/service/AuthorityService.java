package com.trickplay.gameservice.service;

import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Authority;


//@PreAuthorize("hasRole('ROLE_ANONYMOUS') or hasRole('ROLE_ADMIN')")
public interface AuthorityService {

	@Transactional
	public void persist(Authority entity);
}
