package com.trickplay.gameservice.security;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.service.UserService;

@Component
public class SeedAdminData {
	
	@Autowired private UserService userService;
	
	@Value("#{adminUser}") private User admin;

	@PostConstruct
	private void seedAdmin() {
        // Set a dummy admin account that will create the actual admin
        Authentication authRequest = new UsernamePasswordAuthenticationToken("ignored", "ignored", AuthorityUtils.createAuthorityList("ROLE_ADMIN"));
        SecurityContextHolder.getContext().setAuthentication(authRequest);

		Role adminRole = userService.createRole(Role.ROLE_ADMIN);
		userService.createRole(Role.ROLE_USER);
		userService.createRole(Role.ROLE_ANONYMOUS);
		admin.addAuthority(adminRole);
        
        userService.create(admin);		
	//	authorityService.persist(adminAuthorities);
		
		SecurityContextHolder.clearContext();
	}
}