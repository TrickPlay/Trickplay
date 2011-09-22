package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.StatelessHttpSession;
import com.trickplay.gameservice.transferObj.SessionTO;


@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
public interface SessionService {

	public List<SessionTO> getActiveSessions();

	@Transactional
	public SessionTO create(String deviceKey);
	
	@Transactional
	public SessionTO touchSession(String token);

	@Transactional
	public void remove(String token);

	public SessionTO findByToken(String token);
}
