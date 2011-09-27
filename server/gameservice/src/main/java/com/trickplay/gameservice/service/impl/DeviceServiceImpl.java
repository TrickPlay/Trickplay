package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.service.DeviceService;
import com.trickplay.gameservice.service.GameService;

@Service("deviceService")
@Repository
public class DeviceServiceImpl extends GenericDAOWithJPA<Device, Long> implements
		DeviceService {
	@Autowired
	GameService gameService;

	@SuppressWarnings("unchecked")
	public Device findByKey(String deviceKey) {

		List<Device> list = super.entityManager.createQuery("Select d from Device as d where d.deviceKey = :key").
		setParameter("key", deviceKey).getResultList();
		Device d = SpringUtils.getFirst(list);
		
		return d;
	}
	
	@Transactional
	public Device addGame(String deviceKey, String name) {
		Device d = findByKey(deviceKey);
		if (d == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Device.deviceKey", deviceKey));
		Game g = gameService.findByName(name);
		if (g == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("Game.name", name));
		
		d.addGame(g);
		return d;
	}
	

}
