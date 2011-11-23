package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.SessionToken;


@PreAuthorize("isAuthenticated()")
public interface SessionService {

	public List<Long> pickPlayersRandom(int count);

	@Transactional
	public void create(SessionToken session);
	
	@Transactional
	public SessionToken touchSession(String token);

	@Transactional
	public void remove(String token);

	public SessionToken findByToken(String token);
}
