package com.trickplay.gameservice.dao.impl;

import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.domain.Vendor;

@Repository
@SuppressWarnings("unchecked")
public class VendorDAOImpl extends GenericEJB3DAO<Vendor, Long> implements VendorDAO {

    public VendorDAOImpl() {
        super();
    }
    
    public Class<Vendor> getEntityBeanType() {
        return Vendor.class;
    }
    
    public Vendor findByName(String name) {
        return SpringUtils.getFirst(findByCriteria(Restrictions.eq("name", name)));
    }

}
