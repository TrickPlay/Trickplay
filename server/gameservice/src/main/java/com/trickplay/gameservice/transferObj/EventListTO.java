package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.Event;

public class EventListTO {
	private List<EventTO> events = new ArrayList<EventTO>();
	
	public EventListTO() {
		
	}
	
	public EventListTO(List<Event> events) {
		if (events==null)
			return;
		for(Event e: events)
			this.events.add(new EventTO(e));
	}
	
	public List<EventTO> getEvents() {
		return events;
	}
	
	public void setEvents(List<EventTO> events) {
		if (events!=null) {
			this.events.clear();
			this.events.addAll(events);
		}
	}
}
