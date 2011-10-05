package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.EventSelectionCriteria;

public interface EventService {

	public List<Event> getEvents();
	
	public List<Event> getGameSessionEvents(Long gameSessionId, EventSelectionCriteria selectionCriteria);
	
	@Transactional
	public void create(Event entity);
}
