package com.trickplay.gameservice.security;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import com.trickplay.gameservice.service.impl.UserServiceImpl;

@Component
public class SeedAdminData {
	
    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);
	@Autowired private UserService userService;
	
	@Value("#{adminUser}") private User admin;

	@PostConstruct
	private void seedAdmin() {
	    /* seed Admin only if the admin user doesnt already exist */
	    if (null != userService.findByName(admin.getUsername())) {
	        // admin user already exists;
	        logger.info("Admin user '"+admin.getUsername()+"' already exists. Skipping provisioning of admin user");
	        return;
	    }
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