package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PostFilter;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.access.prepost.PreFilter;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.Vendor;


@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
public interface VendorService {

	@PostFilter("hasRole('ROLE_ADMIN') or filterObject.primaryContact.username == principal.username")
	List<Vendor> findAll();


	@PreFilter("filterObject.primaryContact.username == principal.username")
	@Transactional
	void merge(Vendor entity);

	@PreAuthorize("hasRole('ROLE_ADMIN')")
	@Transactional
	void remove(Vendor vendor);

	Vendor find(Long id);
	
	Vendor findByName(String name);
	
	List<Vendor> findByContactName(String contactName);

	
	@Transactional
	public void persist(Vendor entity);
}
