package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PostFilter;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Vendor;


@PreAuthorize("isAuthenticated()")
public interface VendorService {

	@PostFilter("hasRole('ROLE_ADMIN') or filterObject.primaryContact.username == principal.username")
	public List<Vendor> findAll();

	@PreAuthorize("hasRole('ROLE_ADMIN')")
	@Transactional
	public void remove(Long vendorId);

	public Vendor find(Long id);
	
	public Vendor findByName(String name);
	
	public List<Vendor> findByContactName(String contactName);

	@Transactional
	public void create(Vendor entity);
}
