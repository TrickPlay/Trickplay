package com.trickplay.gameservice.service;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

@PreAuthorize("hasRole('ROLE_ADMIN')")
public interface DBPurgeService {
	
    @Transactional
	public void resetDB();
	
}
