package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PostFilter;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.access.prepost.PreFilter;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Device;
import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.domain.Vendor;

@PreAuthorize("hasRole('ROLE_ANONYMOUS') or hasRole('ROLE_USER') or hasRole('ROLE_ADMIN')")
public interface UserService {

	@PostFilter("filterObject.username == principal.username or hasRole('ROLE_ADMIN')")
	public List<User> findAll();

//	@PreAuthorize("principal.username == #username or hasRole('ROLE_ADMIN')")
	public User findByName(String username, boolean detached);
	
	public User findByName(String username);

	//TODO: role anonymous should not be allowed to create users maybe ????

	@PreFilter("filterObject.username == principal.username")
	@Transactional
	public void update(User entity);

	public User find(Long id);
	
	@PreAuthorize("hasRole('ROLE_ADMIN')")
	public Role createRole(String roleName);
	
	public Role findRole(String rolename);
	
	public Device registerDevice(Device device);
	
	
	@Transactional
	public Vendor createVendor(String vendorName);
	
	@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_ANONYMOUS')")
	@Transactional
	public void create(User u);
}
