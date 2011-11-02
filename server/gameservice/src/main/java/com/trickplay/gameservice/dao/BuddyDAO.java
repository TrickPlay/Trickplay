package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.Buddy;

public interface BuddyDAO extends GenericDAO<Buddy, Long> {
    
    public List<Buddy> findAll(Long ownerId);

    public List<Buddy> findByOwnerName(String ownerName);

    public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId);

}
