package com.trickplay.gameservice.dao.impl;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.GamePlayStateDAO;
import com.trickplay.gameservice.domain.GamePlayState;

@Repository
@SuppressWarnings("unchecked")
public class GamePlayStateDAOImpl extends GenericDAOWithJPA<GamePlayState, Long> implements GamePlayStateDAO {

}
