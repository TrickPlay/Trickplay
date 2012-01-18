package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.validator.constraints.NotBlank;

import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Game;

public class DeviceTO {
	Long id;
	@NotBlank
	private String deviceKey;
	@NotBlank
	private String deviceType;
	private Long ownerId;
	private String ownerName;
	private List<String> deployedGames = new ArrayList<String>();
	
	public DeviceTO() {
		
	}
	
	public DeviceTO(Device device) {
		if (device==null)
			throw new IllegalArgumentException("Device is null");
		this.id  = device.getId();
		this.deviceKey = device.getDeviceKey();
		this.ownerId = device.getOwner()!=null ? device.getOwner().getId() : null;
		this.ownerName = device.getOwner()!=null ? device.getOwner().getUsername() : null;
		for(Game g:device.getDeployedGames()) {
			deployedGames.add(g.getAppId());
		}
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDeviceKey() {
		return deviceKey;
	}

	public void setDeviceKey(String deviceKey) {
		this.deviceKey = deviceKey;
	}

	public String getDeviceType() {
		return deviceType;
	}

	public void setDeviceType(String deviceType) {
		this.deviceType = deviceType;
	}

	public Long getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(Long ownerId) {
		this.ownerId = ownerId;
	}

	public String getOwnerName() {
		return ownerName;
	}

	public void setOwnerName(String ownerName) {
		this.ownerName = ownerName;
	}

	public List<String> getDeployedGames() {
		return deployedGames;
	}

	public void setDeployedGames(List<String> deployedGames) {
		this.deployedGames = deployedGames;
	}

}
