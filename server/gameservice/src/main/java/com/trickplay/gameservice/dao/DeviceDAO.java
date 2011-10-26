package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.Device;

public interface DeviceDAO extends GenericDAO<Device, Long> {

    public Device findByKey(String deviceKey);
}
