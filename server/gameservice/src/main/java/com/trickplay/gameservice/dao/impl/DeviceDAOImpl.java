package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.DeviceDAO;
import com.trickplay.gameservice.domain.Device;

@Repository
@SuppressWarnings("unchecked")
public class DeviceDAOImpl extends GenericDAOWithJPA<Device, Long> implements DeviceDAO {
    public Device findByKey(String deviceKey) {

        List<Device> list = super.entityManager.createQuery("Select d from Device as d where d.deviceKey = :key").
        setParameter("key", deviceKey).getResultList();
        Device d = SpringUtils.getFirst(list);
        
        return d;
    }
}
