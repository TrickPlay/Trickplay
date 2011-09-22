package com.trickplay.gameservice.transferObj;

import org.hibernate.validator.constraints.NotBlank;

public class SessionRequestTO {

	@NotBlank
	private String deviceKey;

	public SessionRequestTO() {

	}

	public SessionRequestTO(String deviceKey) {
		this.deviceKey = deviceKey;
	}

	public void setDeviceKey(String deviceKey) {
		this.deviceKey = deviceKey;
	}

	public String getDeviceKey() {
		return deviceKey;
	}

}
