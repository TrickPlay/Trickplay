package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PostFilter;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Game;


@PreAuthorize("isAuthenticated()")
public interface GameService {

    @PostFilter("hasRole('ROLE_ADMIN') or filterObject.primaryContact.username == principal.username")
	public List<Game> findAll();

	@Transactional
	public Game update(Long vendorId, Game entity);

	@Transactional
	public void remove(Long id);

	public Game find(Long id);
	
	public Game findByName(String name);
	
	@Transactional
	public Game create(Long vendorId, Game g);
}
