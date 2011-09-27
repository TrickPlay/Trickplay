package com.trickplay.gameservice.transferObj;

import org.hibernate.validator.constraints.NotBlank;

import com.trickplay.gameservice.domain.Device;

public class DeviceRequestTO {
	@NotBlank
	private String deviceKey;
	@NotBlank
	private String deviceType;
	
	public DeviceRequestTO() {
		
	}
	
	public DeviceRequestTO(Device device) {
		if (device==null)
			throw new IllegalArgumentException("Device is null");
		this.deviceKey = device.getDeviceKey();
		this.deviceType = device.getDeviceType();
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
	
	public Device toDevice() {
		return new Device(deviceKey, deviceType, null);
	}


}
