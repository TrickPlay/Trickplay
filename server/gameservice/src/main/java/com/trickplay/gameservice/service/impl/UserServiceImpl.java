package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.DeviceService;
import com.trickplay.gameservice.service.UserService;
import com.trickplay.gameservice.service.VendorService;

@Service("userService")
@Repository
public class UserServiceImpl extends GenericDAOWithJPA<User, Long>implements UserService {

	@Autowired
	private PasswordEncoder passwordEncoder;
	@Autowired
	private DeviceService deviceService;
	@Autowired VendorService vendorService;
	
	@SuppressWarnings("unchecked")
	public User findByName(String username, boolean detached) {
		List<User> list = super.entityManager.createQuery("Select u from User as u where u.username = :username").setParameter("username", username).getResultList();
		User u = SpringUtils.getFirst(list);
		if (detached) 
			entityManager.detach(u);
		return u;
	}
	
	public User findByName(String username) {
		return findByName(username, false);
	}
	
	@Transactional
	public Role createRole(String rolename) {
		Role r = new Role(rolename);
		entityManager.persist(r);
		return r;
	}

	@SuppressWarnings("unchecked")
	public Role findRole(String rolename) {
		List<Role> list = super.entityManager
		.createQuery("Select r from Role as r where r.name = :name")
		.setParameter("name", rolename).getResultList();
		return SpringUtils.getFirst(list);
	}
	
	@Transactional
	public void create(User entity) {
		entity.addAuthority(findRole(Role.ROLE_USER));
		entity.setPassword(passwordEncoder.encodePassword(entity.getPassword(), null));
		super.persist(entity);
	}

	@Transactional
	public Device registerDevice(Device device) {
		Long userId = SecurityUtil.getPrincipal().getId();
		User u = find(userId);
		if (u == null) {
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.id", userId));
		}

		Device d = deviceService.findByKey(device.getDeviceKey());
		if (d == null) {
			device.setOwner(u);
			device.setId(null);
			deviceService.persist(device);
			d = device;
		} else {
			// implicitly unregistering previous owner
			d.setOwner(u);
		}
		return d;
	}
	
	@Transactional
	public Vendor createVendor(String vendorName) {
		Long userId = SecurityUtil.getPrincipal().getId();
		User u = find(userId);
		if (u == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null, ExceptionContext.make("User.id", userId));
		
		//authorizeCreateVendor(u);
		Vendor v = new Vendor();
		v.setName(vendorName);
		v.setPrimaryContact(u);
		vendorService.persist(v);
		return v;
	}

}
