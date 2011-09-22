package com.trickplay.gameservice.service;

import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Device;

public interface DeviceService {
	
	@Transactional
	public void persist(Device entity);

	@Transactional
	public void merge(Device entity);

	public Device find(Long id);
	
	public Device findByKey(String deviceKey);
	
	@Transactional
	public Device addGame(String deviceKey, String appId);

}
