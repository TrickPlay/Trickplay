package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.StatelessHttpSession;


@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
public interface SessionService {

	public List<StatelessHttpSession> getActiveSessions();

	@Transactional
	public StatelessHttpSession create(String deviceKey);
	
	@Transactional
	public StatelessHttpSession touchSession(String token);

	@Transactional
	public void remove(String token);

	public StatelessHttpSession findByToken(String token);
}
