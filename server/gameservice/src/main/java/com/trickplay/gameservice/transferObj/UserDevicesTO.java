package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.User;

@XmlRootElement
public class UserDevicesTO {

	public static class DeviceStruct {
		private String deviceKey;
		private String deviceType;
		private Long id;
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
		public Long getId() {
			return id;
		}
		public void setId(Long id) {
			this.id = id;
		}
		public DeviceStruct() {
			
		}
		public DeviceStruct(String key, String dtype, Long id) {
			this.deviceKey = key;
			this.deviceType = dtype;
			this.id = id;
		}
	}
	private UserTO user;
	private List<DeviceStruct> devices = new ArrayList<DeviceStruct>();
	
	
	public UserDevicesTO(User user) {
		if (user == null)
			throw new IllegalArgumentException("User is null");
		this.user = new UserTO(user);
		if (user.getOwnedDevices()==null)
			return;
		for(Device d: user.getOwnedDevices()) {
			devices.add(new DeviceStruct(d.getDeviceKey(), d.getDeviceType(), d.getId()));
		}
		
	}


	public UserTO getUser() {
		return user;
	}


	public void setUser(UserTO user) {
		this.user = user;
	}


	public List<DeviceStruct> getDevices() {
		return devices;
	}


	public void setDevices(List<DeviceStruct> devices) {
		this.devices = devices;
	}
	
	
}
