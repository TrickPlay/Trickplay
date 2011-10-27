package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.BuddyDAO;
import com.trickplay.gameservice.domain.Buddy;

@Repository
@SuppressWarnings("unchecked")
public class BuddyDAOImpl extends GenericDAOWithJPA<Buddy, Long> implements BuddyDAO {

    public List<Buddy> findAll(Long ownerId) {
        return super.entityManager
                .createQuery(
                        "Select b from Buddy as b join b.owner as o where o.id = :ownerId")
                .setParameter("ownerId", ownerId).getResultList();
    }

    public List<Buddy> findByOwnerName(String ownerName) {
        return super.entityManager
                .createQuery(
                        "Select b from Buddy as b join b.owner as o where o.username = :ownerName")
                .setParameter("ownerName", ownerName).getResultList();
    }

    public List<Buddy> findByOwnerIdTargetId(Long ownerId, Long targetId) {
        return super.entityManager
                .createQuery(
                        "Select b from Buddy as b join b.owner as o join b.target as t where o.id = :ownerId and t.id = :targetId")
                .setParameter("ownerId", ownerId)
                .setParameter("targetId", targetId).getResultList();

    }
}
