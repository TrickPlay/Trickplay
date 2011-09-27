package com.trickplay.gameservice.service;

import java.util.List;

import com.trickplay.gameservice.domain.Event;

public interface EventCollector {
	List<Event> collect(Long requestorId);
}
