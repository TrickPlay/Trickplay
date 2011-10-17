package com.trickplay.gameservice.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.DeviceDAO;
import com.trickplay.gameservice.dao.RoleDAO;
import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.dao.VendorDAO;
import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.UserService;

@Service("userService")
public class UserServiceImpl implements UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);
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
	    if (rolename == null) {
	        throw ExceptionUtil.newIllegalArgumentException("rolename", null, "!= null");
	    }
	    rolename = rolename.trim();
	    if (rolename.isEmpty()) {
	        throw ExceptionUtil.newIllegalArgumentException("rolename", "", "length(rolename) > 0");
	    }
	        
		Role r = new Role(rolename);
		
		try {
		    roleDAO.persist(r);
		} catch (DataIntegrityViolationException ex) {
		    logger.error("Failed to create Role.", ex);
		    throw ExceptionUtil.newEntityExistsException(Role.class, "rolename", rolename);
		}
		return r;
	}

	public Role findRole(String rolename) {
		return roleDAO.findRole(rolename);
	}
	
	@Transactional
	public void create(User entity) {
	    if (entity == null) {
	        throw ExceptionUtil.newIllegalArgumentException("User", null, "!= null");
	    } else if (entity.getUsername() == null || entity.getUsername().trim().isEmpty()) {
	        throw ExceptionUtil.newIllegalArgumentException("User.username", "", "length(username) > 0");
	    } else if (entity.getPassword() == null || entity.getPassword().trim().isEmpty()) {
	        throw ExceptionUtil.newIllegalArgumentException("User.password", "", "length(password) > 0");
	    }
		entity.addAuthority(findRole(Role.ROLE_USER));
		entity.setPassword(passwordEncoder.encodePassword(entity.getPassword(), null));
		try {
		    userDAO.persist(entity);
		} catch (DataIntegrityViolationException ex) {
		    logger.error("Failed to create User", ex);
		    throw ExceptionUtil.newEntityExistsException(User.class, 
		            "username", entity.getUsername());
		} catch (RuntimeException ex) {
		    logger.error("Failed to create User", ex);
            throw ExceptionUtil.newUnknownException(ex.getMessage());
		}
	}

	@Transactional
	public Device registerDevice(Device device) {
		Long userId = SecurityUtil.getPrincipal().getId();
		if (userId == null) {
		    throw ExceptionUtil.newUnauthorizedException();
		}
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
	    if (vendorName == null || vendorName.trim().isEmpty()) {
	        throw ExceptionUtil.newIllegalArgumentException("vendorName", "", "length(vendorName) != null");
	    }
		Long userId = SecurityUtil.getPrincipal().getId();
		User u = find(userId);
		if (u == null) 
		    throw ExceptionUtil.newEntityNotFoundException(User.class, "id", userId); 
		
		Vendor v = new Vendor();
		v.setName(vendorName);
		v.setPrimaryContact(u);
		try {
		    vendorDAO.persist(v);
		} catch (DataIntegrityViolationException ex) {
		    logger.error("Failed to create Vendor.", ex);
		    throw ExceptionUtil.newEntityExistsException(Vendor.class,
		            "vendorName", vendorName);
		} catch (RuntimeException ex) {
		    logger.error("Failed to create Vendor.", ex);
            throw ExceptionUtil.newUnknownException(ex.getMessage());
		}
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
                throw ExceptionUtil.newEntityNotFoundException(User.class, "id", entity.getId());
            }
        } else {
            existing = findByName(entity.getUsername());
            if (existing == null) {
                throw ExceptionUtil.newEntityNotFoundException(User.class, "username", entity.getUsername()); 
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
