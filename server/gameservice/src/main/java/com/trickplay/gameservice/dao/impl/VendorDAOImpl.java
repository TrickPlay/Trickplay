package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.domain.Vendor;

@Repository
@SuppressWarnings("unchecked")
public class VendorDAOImpl extends GenericDAOWithJPA<Vendor, Long> implements VendorDAO {
    
    public Vendor findByName(String name) {
        List<Vendor> list = super.entityManager.createQuery("Select v from Vendor v where v.name = :name").setParameter("name", name).getResultList();
        return SpringUtils.getFirst(list);
    }

    public List<Vendor> findByContactName(String contactName) {
        return super.entityManager.createQuery("Select v from Vendor as v join v.primaryContact as u where u.username = :name")
        .setParameter("name", contactName).getResultList();
    }
}
