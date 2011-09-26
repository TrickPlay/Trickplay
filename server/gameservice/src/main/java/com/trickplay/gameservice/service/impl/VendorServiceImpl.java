package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.security.UserAdapter;
import com.trickplay.gameservice.service.UserService;
import com.trickplay.gameservice.service.VendorService;


@Service("vendorService")
@Repository
public class VendorServiceImpl extends GenericDAOWithJPA<Vendor, Long> implements VendorService {


	@SuppressWarnings("unchecked")
	public Vendor findByName(String name) {
		List<Vendor> list = super.entityManager.createQuery("Select v from Vendor v where v.name = :name").setParameter("name", name).getResultList();
		return SpringUtils.getFirst(list);
	}

	@SuppressWarnings("unchecked")
	public List<Vendor> findByContactName(String contactName) {
		return super.entityManager.createQuery("Select v from Vendor as v join v.primaryContact as u where u.username = :name")
		.setParameter("name", contactName).getResultList();
	}

	
	public void authorizeCreateVendor(User u) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (principal == null || u == null || !principal.getId().equals(u.getId())) {
			throw new GameServiceException(Reason.FORBIDDEN);
		}
	}

}
