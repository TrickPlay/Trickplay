package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.DeviceDAO;
import com.trickplay.gameservice.dao.RoleDAO;
import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.UserService;

@Service("userService")
public class UserServiceImpl implements UserService {

	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Autowired
	private DeviceDAO deviceDAO;
	
	@Autowired
	private VendorDAO vendorDAO;
	
	@Autowired
    private RoleDAO roleDAO;
	
	@Autowired
    private UserDAO userDAO;	
	
	@Autowired 
	MessageSource messageSource;
	
	public User findByName(String username, boolean detached) {
		return userDAO.findByName(username);
	}
	
	public User findByName(String username) {
		return findByName(username, false);
	}
	
	@Transactional
	public Role createRole(String rolename) {
		Role r = new Role(rolename);
		roleDAO.persist(r);
		return r;
	}

	public Role findRole(String rolename) {
		return roleDAO.findRole(rolename);
	}
	
	@Transactional
	public void create(User entity) {
		entity.addAuthority(findRole(Role.ROLE_USER));
		entity.setPassword(passwordEncoder.encodePassword(entity.getPassword(), null));
		userDAO.persist(entity);
	}

	@Transactional
	public Device registerDevice(Device device) {
		Long userId = SecurityUtil.getPrincipal().getId();
		User u = find(userId);
		if (u == null) {
			throw ExceptionUtil.newEntityNotFoundException(User.class, "id", userId);
		}

		Device d = deviceDAO.findByKey(device.getDeviceKey());
		if (d == null) {
			device.setOwner(u);
			device.setId(null);
			deviceDAO.persist(device);
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
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", userId); 
		
		Vendor v = new Vendor();
		v.setName(vendorName);
		v.setPrimaryContact(u);
		vendorDAO.persist(v);
		return v;
	}

	@Transactional
    public void update(User entity) {
        if (entity==null) {
            throw ExceptionUtil.newIllegalArgumentException("User", null, "!= null");
        }
        User existing;
        if (entity.getId()!=null) {
            existing = find(entity.getId());
            if (existing == null) {
                throw ExceptionUtil.newEntityNotFoundException(User.class,"id", entity.getId());
            }
        } else {
            existing = findByName(entity.getUsername());
            if (existing == null) {
                throw ExceptionUtil.newEntityNotFoundException(User.class,"username", entity.getUsername()); 
            }
               
        }
        
        existing.setAllowHighScoreMessages(entity.isAllowHighScoreMessages());
        existing.setAllowAchievementMessages(entity.isAllowAchievementMessages());
        if (entity.getEmail()!=null && !entity.getEmail().equals(existing.getEmail())) {
            existing.setEmail(entity.getEmail());
        }
    }

    public List<User> findAll() {
        return userDAO.findAll();
    }

    public User find(Long id) {
        return userDAO.find(id);
    }

}
