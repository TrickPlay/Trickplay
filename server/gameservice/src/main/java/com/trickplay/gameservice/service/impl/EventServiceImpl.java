package com.trickplay.gameservice.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.Query;

import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.Event.EventType;
import com.trickplay.gameservice.domain.EventSelectionCriteria;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.EventCollector;
import com.trickplay.gameservice.service.EventService;

@Service("eventService")
@Repository
public class EventServiceImpl extends GenericDAOWithJPA<Event, Long> implements
		EventService {

	private class BuddyListInvitationEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getBuddyListInvitationEvents(requestorId);
		}
	}

	private class GamePlayInvitationEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getGamePlayInvitationEvents(requestorId);
		}
	}

	private class GamePlayStartEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getGamePlayStartEvents(requestorId);
		}
	}

	private class GamePlayStateChangeEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getGamePlayStateChangeEvents(requestorId);
		}
	}

	private class GamePlayEndEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getGamePlayEndEvents(requestorId);
		}
	}

	private class GamePlayMessageEventsCollector implements EventCollector {
		public List<Event> collect(Long requestorId) {
			return getGamePlayMessageEvents(requestorId);
		}
	}

	private String GS_EVENTS_NATIVE_QUERY = "select E.* from event E join game_session GS ON E.recipient_id = GS.id join game_session_player P on GS.id=P.gs_id"
		+ " where E.source_id != :requestorId and P.player_id = :requestorId and E.event_type=:eventType order by E.created DESC";

	private String GS_SESSION_EVENTS_NATIVE_QUERY = "select E.* from event E join game_session GS ON E.recipient_id = GS.id join game_session_player P on GS.id=P.gs_id"
			+ " where E.source_id != :requestorId and P.player_id = :requestorId and E.event_type=:eventType and GS.id=:gameSessionId order by E.created DESC";

/*
 	private String GS_SESSION_RECENT_EVENTS_NATIVE_QUERY = "select E.* from event E join game_session GS ON E.recipient_id = GS.id join game_session_player P on GS.id=P.gs_id"
 
		+ " where E.source_id != :requestorId and P.player_id = :requestorId and E.event_type=:eventType and GS.id=:gameSessionId order by E.created DESC";

	private String GS_MOST_RECENT_STATE_EVENT_QUERY = "select E.* from event E, game_play_state G"
		+ " where E.event_type IN (:et1, :et2, :et3) AND E.target_id=G.id AND G.key=:stateIdKey AND E.source_id=:requestorId AND E.recipient_id=:gameSessionId";
*/
	
	
	Map<EventType, EventCollector> allEventsCollectors = new HashMap<EventType, EventCollector>();


// Map<EventType, EventCollector> gameSession
	public EventServiceImpl() {
		allEventsCollectors.put(EventType.BUDDY_LIST_INVITATION,
				new BuddyListInvitationEventsCollector());
		allEventsCollectors.put(EventType.GAME_PLAY_INVITATION,
				new GamePlayInvitationEventsCollector());
		allEventsCollectors.put(EventType.GAME_SESSION_START,
				new GamePlayStartEventsCollector());
		allEventsCollectors.put(EventType.GAME_SESSION_STATE_CHANGE,
				new GamePlayStateChangeEventsCollector());
		allEventsCollectors.put(EventType.GAME_SESSION_END,
				new GamePlayEndEventsCollector());
		allEventsCollectors.put(EventType.GAME_SESSION_MESSAGE,
				new GamePlayMessageEventsCollector());
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getEvents() {
		Long requestorId = SecurityUtil.getPrincipal().getId();
		List<Event> allEvents = new ArrayList<Event>();
		for (EventType etype : EventType.values()) {
			EventCollector ec = allEventsCollectors.get(etype);
			if (ec != null)
				allEvents.addAll(ec.collect(requestorId));

			/*
			 * entityManager .createQuery(
			 * "select E from User as U join U.buddies as B join B.target.events as E"
			 * +
			 * " where U.id=:requestorId and T.id=U.id and E.eventType=:eventType order by E.created DESC"
			 * ) .setParameter("requestorId", requestorId)
			 * .setParameter("eventType", etype) .getResultList()
			 */
		}
		return allEvents;
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getBuddyListInvitationEvents(Long requestorId) {
		return entityManager
				.createQuery(
						"select E from Event E"
								+ " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC")
				.setParameter("requestorId", requestorId)
				.setParameter("eventType", EventType.BUDDY_LIST_INVITATION)
				.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getGamePlayInvitationEvents(Long requestorId) {
		return entityManager
				.createQuery(
						"select E from Event E"
								+ " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC")
				.setParameter("requestorId", requestorId)
				.setParameter("eventType", EventType.GAME_PLAY_INVITATION)
				.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getGamePlayStartEvents(Long requestorId) {
		Query query = entityManager.createNativeQuery(GS_EVENTS_NATIVE_QUERY,
				Event.class);
		/*
		 * ( "select E from Event E" +
		 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
		 * )
		 */
		return query.setParameter("requestorId", requestorId)
				.setParameter("eventType", EventType.GAME_SESSION_START.name())
				.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getGamePlayStateChangeEvents(Long requestorId) {
		Query query = entityManager.createNativeQuery(GS_EVENTS_NATIVE_QUERY,
				Event.class);
		/*
		 * ( "select E from Event E" +
		 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
		 * )
		 */
		return query
				.setParameter("requestorId", requestorId)
				.setParameter("eventType",
						EventType.GAME_SESSION_STATE_CHANGE.name())
				.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getGamePlayEndEvents(Long requestorId) {
		Query query = entityManager.createNativeQuery(GS_EVENTS_NATIVE_QUERY,
				Event.class);
		/*
		 * ( "select E from Event E" +
		 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
		 * )
		 */
		return query.setParameter("requestorId", requestorId)
				.setParameter("eventType", EventType.GAME_SESSION_END.name())
				.getResultList();
	}

	@SuppressWarnings(value = "unchecked")
	public List<Event> getGamePlayMessageEvents(Long requestorId) {
		Query query = entityManager.createNativeQuery(GS_EVENTS_NATIVE_QUERY,
				Event.class);
		/*
		 * ( "select E from Event E" +
		 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
		 * )
		 */
		return query
				.setParameter("requestorId", requestorId)
				.setParameter("eventType",
						EventType.GAME_SESSION_MESSAGE.name()).getResultList();
	}

	public List<Event> getGameSessionEvents(Long gameSessionId,
			EventSelectionCriteria selectionCriteria) {
		// TODO Auto-generated method stub
		return null;
	}

	private class SessionEventsCollector implements EventCollector {
		private EventSelectionCriteria sc = EventSelectionCriteria.ALL;
		private Long requestorId;
		private Long gsId;
		public SessionEventsCollector(EventSelectionCriteria selectionCriteria, Long gameSessionId, Long requestorId) {
			if (selectionCriteria!=null)
				sc = selectionCriteria;
			this.gsId = gameSessionId;
			this.requestorId = requestorId;
		}
		
		public List<Event> collect(Long requestorId) {
			List<Event> allEvents = new ArrayList<Event>();
		//	if (sc==EventSelectionCriteria.ALL) {
				allEvents.addAll(getGamePlayStartEvents());
				allEvents.addAll(getGamePlayStateChangeEvents());
				allEvents.addAll(getGamePlayEndEvents());
				allEvents.addAll(getGamePlayMessageEvents());
		/*	} else {
				allEvents.addAll(getGamePlayStartEvents());
				allEvents.addAll(getGamePlayStateChangeEvents());
				allEvents.addAll(getGamePlayEndEvents());
				allEvents.addAll(getGamePlayMessageEvents());
			} */
			return allEvents;
		}

		
		@SuppressWarnings(value = "unchecked")
		public List<Event> getGamePlayStartEvents() {
			Query query = entityManager.createNativeQuery(
					GS_SESSION_EVENTS_NATIVE_QUERY, Event.class);
			/*
			 * ( "select E from Event E" +
			 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
			 * )
			 */
			return query
					.setParameter("requestorId", requestorId)
					.setParameter("gameSessionId", gsId)
					.setParameter("eventType",
							EventType.GAME_SESSION_START.name())
					.getResultList();
		}

		@SuppressWarnings(value = "unchecked")
		public List<Event> getGamePlayStateChangeEvents() {
			Query query = entityManager.createNativeQuery(
					GS_SESSION_EVENTS_NATIVE_QUERY, Event.class);
			/*
			 * ( "select E from Event E" +
			 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
			 * )
			 */
			return query
					.setParameter("requestorId", requestorId)
					.setParameter("gameSessionId", gsId)
					.setParameter("eventType",
							EventType.GAME_SESSION_STATE_CHANGE.name())
					.getResultList();
		}

		@SuppressWarnings(value = "unchecked")
		public List<Event> getGamePlayEndEvents() {
			Query query = entityManager.createNativeQuery(
					GS_SESSION_EVENTS_NATIVE_QUERY, Event.class);
			/*
			 * ( "select E from Event E" +
			 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
			 * )
			 */
			return query
					.setParameter("requestorId", requestorId)
					.setParameter("gameSessionId", gsId)
					.setParameter("eventType",
							EventType.GAME_SESSION_END.name()).getResultList();
		}

		@SuppressWarnings(value = "unchecked")
		public List<Event> getGamePlayMessageEvents() {
			Query query = entityManager.createNativeQuery(
					GS_SESSION_EVENTS_NATIVE_QUERY, Event.class);
			/*
			 * ( "select E from Event E" +
			 * " where E.recipientId=:requestorId and E.eventType=:eventType order by E.created DESC"
			 * )
			 */
			return query
					.setParameter("requestorId", requestorId)
					.setParameter("gameSessionId", gsId)
					.setParameter("eventType",
							EventType.GAME_SESSION_MESSAGE.name())
					.getResultList();
		}

	}

}
