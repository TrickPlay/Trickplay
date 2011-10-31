package com.trickplay.gameservice.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
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
    private static final Logger logger = LoggerFactory.getLogger(DeviceServiceImpl.class);
	@Autowired
	GameDAO gameDAO;
	
	@Autowired
	DeviceDAO deviceDAO;
	
	
	public Device findByKey(String deviceKey) {

		return deviceDAO.findByKey(deviceKey);
	}
	
	/*
	 * TODO: handle the condition of adding the same game more than once to a device.
	 * 
	 * (non-Javadoc)
	 * @see com.trickplay.gameservice.service.DeviceService#addGame(java.lang.String, java.lang.String)
	 */
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
	    if (entity == null) {
	        throw ExceptionUtil.newIllegalArgumentException("Device", null, "!= null");
	    } 
	    try {
	        deviceDAO.persist(entity);
	    }  catch (DataIntegrityViolationException ex) {
	        logger.error("Failed to create Device.", ex);
	        throw ExceptionUtil.newEntityExistsException(Device.class, "deviceKey", entity.getDeviceKey());
	    } catch (RuntimeException ex) {
	        logger.error("Failed to create Device.", ex);
	        throw ExceptionUtil.convertToSupportedException(ex);
	    }
        
    }

    public Device find(Long id) {
        return deviceDAO.find(id);
    }

	

}
