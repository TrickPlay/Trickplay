package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.GameService;


@Service("gameService")
public class GameServiceImpl implements GameService {

    private static final Logger logger = LoggerFactory.getLogger(GameServiceImpl.class);
	@Autowired
	VendorDAO vendorDAO;

	@Autowired
    GameDAO gameDAO;
	
	public Game findByName(String name) {
		return gameDAO.findByName(name);
	}

	private void validate(Game g) {
	    if (g.getMinPlayers()<=0) {
            throw ExceptionUtil.newIllegalArgumentException("minPlayers", g.getMinPlayers(), "> 0");
        }
        if (g.getMaxPlayers() < g.getMinPlayers()) {
            throw ExceptionUtil.newIllegalArgumentException("maxPlayers", g.getMaxPlayers(), ">= minPlayers. minPlayers = "+g.getMinPlayers());
        }
	}
	
	/*
	 * TODO: ensure only authorized users are allowed to create a Game
	 */
	@Transactional
	public Game create(Long vendorId, Game g) {
	    Long userId = SecurityUtil.getCurrentUserId();
	    if (userId == null) {
	        throw ExceptionUtil.newUnauthorizedException();
	    }
	    if (vendorId == null) {
	        throw ExceptionUtil.newIllegalArgumentException("Vendor", null, "!= null");
	    } else if (g == null) {
	        throw ExceptionUtil.newIllegalArgumentException("Game", null, "!= null");
	    }
		Vendor v = vendorDAO.find(vendorId);
		if (v == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Vendor.class, "id", vendorId);
		} 
		validate(g);
		g.setVendor(v);
		try {
		    gameDAO.persist(g);
		} catch (DataIntegrityViolationException ex) {
		    logger.error("Failed to create Game.", ex);
		    throw ExceptionUtil.newEntityExistsException(Game.class, 
		            "name", g.getName(),
		            "appId", g.getAppId());
		} catch (RuntimeException ex) {
		    logger.error("Failed to create Game.", ex);
		    throw ExceptionUtil.convertToSupportedException(ex);
		}
		return g;
	}

    /*
     * TODO: ensure only authorized users are allowed to update a Game
     */
	@Transactional
	public Game update(Long vendorId, Game g) {
	    Long userId = SecurityUtil.getCurrentUserId();
	    if (userId == null) {
	        throw ExceptionUtil.newUnauthorizedException();
	    }
	    validate(g);
		Game existing = find(g.getId());
		if (existing == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Game.class, "id", g.getId());
		}
		Vendor v = vendorDAO.find(vendorId);
		if (v == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Vendor.class, "id", vendorId);
		}
		existing.setLeaderboardFlag(g.isLeaderboardFlag());
		existing.setAchievementsFlag(g.isAchievementsFlag());
		existing.setAllowWildCardInvitation(g.isAllowWildCardInvitation());
		existing.setTurnBasedFlag(g.isTurnBasedFlag());
		existing.setAppId(g.getAppId());
		existing.setName(g.getName());
		existing.setMaxPlayers(g.getMaxPlayers());
		existing.setMinPlayers(g.getMinPlayers());
		existing.setVendor(v);
		
		return existing;
	}

	@Transactional
    public void remove(Long id) {
	    Long userId = SecurityUtil.getCurrentUserId();
        if (userId == null) {
            throw ExceptionUtil.newUnauthorizedException();
        }
        Game existing = find(id);
        if (existing == null) {
            throw ExceptionUtil.newEntityNotFoundException(Game.class, "id", id);
        }
        gameDAO.remove(existing);        
    }

    public List<Game> findAll() {
        return gameDAO.findAll();
    }

    public Game find(Long id) {
        return gameDAO.find(id);
    }

}
