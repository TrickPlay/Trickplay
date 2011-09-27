package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.service.GameService;
import com.trickplay.gameservice.service.VendorService;


@Service("gameService")
@Repository
public class GameServiceImpl extends GenericDAOWithJPA<Game, Long> implements GameService {

	@Autowired
	VendorService vendorService;
	@SuppressWarnings("unchecked")
	public Game findByName(String name) {
		List<Game> list = super.entityManager.createQuery("Select g from Game g where g.name = :name").setParameter("name", name).getResultList();
		return SpringUtils.getFirst(list);
	}

	@Transactional
	public Game create(Long vendorId, Game g) {
		Vendor v = vendorService.find(vendorId);
		if (v == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Vendor.id", vendorId));
		if (g.getMaxPlayers() < g.getMinPlayers()) {
			throw new GameServiceException(Reason.ILLEGAL_ARGUMENT, null, 
					ExceptionContext.make("minPlayers", g.getMinPlayers()),
					ExceptionContext.make("maxPlayers", g.getMaxPlayers()),
					ExceptionContext.make("message", "minPlayers exceeds maxPlayers"));
		}
		g.setVendor(v);
		super.persist(g);
		return g;
	}

	@Transactional
	public Game update(Long vendorId, Game g) {
		Game existing = find(g.getId());
		if (existing == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Game.id", g.getId()));
		if (g.getMaxPlayers() < g.getMinPlayers()) {
			throw new GameServiceException(Reason.ILLEGAL_ARGUMENT, null, 
					ExceptionContext.make("minPlayers", g.getMinPlayers()),
					ExceptionContext.make("maxPlayers", g.getMaxPlayers()),
					ExceptionContext.make("message", "minPlayers exceeds maxPlayers"));
		}
		Vendor v = vendorService.find(vendorId);
		if (v == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Vendor.id", vendorId));
		existing.setLeaderboardFlag(g.isLeaderboardFlag());
		existing.setAchievementsFlag(g.isAchievementsFlag());
		existing.setAppId(g.getAppId());
		existing.setName(g.getName());
		existing.setMaxPlayers(g.getMaxPlayers());
		existing.setMinPlayers(g.getMinPlayers());
		existing.setVendor(v);
		
		return existing;
	}

}
