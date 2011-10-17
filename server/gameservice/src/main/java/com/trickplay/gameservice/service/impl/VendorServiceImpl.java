package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.security.UserAdapter;
import com.trickplay.gameservice.service.VendorService;


@Service("vendorService")
public class VendorServiceImpl implements VendorService {

    private static Logger logger = LoggerFactory.getLogger(VendorServiceImpl.class);
    @Autowired
    VendorDAO vendorDAO;
    
    public List<Vendor> findAll() {
        return vendorDAO.findAll();
    }
    
    public Vendor find(Long id) {
        return vendorDAO.find(id);
    }
    
	public Vendor findByName(String name) {
		return vendorDAO.findByName(name);
	}

	public List<Vendor> findByContactName(String contactName) {
		return vendorDAO.findByContactName(contactName);
	}

	
	public void authorizeCreateVendor(User u) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (principal == null || u == null || !principal.getId().equals(u.getId())) {
			throw ExceptionUtil.newUnauthorizedException();
		}
	}


    public void remove(Long vendorId) {
        throw new UnsupportedOperationException("Vendor.remove not yet implemented");
    }

    @Transactional
    public void create(Vendor entity) {
        if (entity == null) {
            throw ExceptionUtil.newIllegalArgumentException("Vendor", null, "!= null");
        }
        authorizeCreateVendor(entity.getPrimaryContact());
        try {
            vendorDAO.persist(entity);
        } catch (DataIntegrityViolationException ex) {
            logger.error("Failed to create Vendor.", ex);
            throw ExceptionUtil.newEntityExistsException(Vendor.class, "name", entity.getName());
        } catch (RuntimeException ex) {
            logger.error("Failed to create Vendor.", ex);
            throw ExceptionUtil.newUnknownException(ex.getMessage());
        }
    }

}
