package com.trickplay.gameservice.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.DeviceDAO;
import com.trickplay.gameservice.dao.GameDAO;
import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.service.DeviceService;

@Service("deviceService")
public class DeviceServiceImpl implements DeviceService {
	@Autowired
	GameDAO gameDAO;
	
	@Autowired
	DeviceDAO deviceDAO;
	
	
	public Device findByKey(String deviceKey) {

		return deviceDAO.findByKey(deviceKey);
	}
	
	@Transactional
	public Device addGame(String deviceKey, String name) {
		Device d = findByKey(deviceKey);
		if (d == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Device.class, "deviceKey", deviceKey);
		}
		Game g = gameDAO.findByName(name);
		if (g == null) {
		    throw ExceptionUtil.newEntityNotFoundException(Game.class, "name", name);
		}
		d.addGame(g);
		return d;
	}

	@Transactional
    public void create(Device entity) {
        deviceDAO.persist(entity);
        
    }

    public Device find(Long id) {
        return deviceDAO.find(id);
    }

	

}
