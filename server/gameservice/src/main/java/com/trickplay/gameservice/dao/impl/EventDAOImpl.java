package com.trickplay.gameservice.dao.impl;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.EventDAO;
import com.trickplay.gameservice.domain.Event;

@Repository
@SuppressWarnings("unchecked")
public class EventDAOImpl extends GenericDAOWithJPA<Event, Long> implements EventDAO {

}
