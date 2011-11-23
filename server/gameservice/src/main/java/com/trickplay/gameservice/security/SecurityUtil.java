package com.trickplay.gameservice.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;

import com.trickplay.gameservice.domain.Role;

public final class SecurityUtil {

	public static boolean isAdmin() {
		UserAdapter principal = getPrincipal();
		if (principal != null) {
			for (GrantedAuthority authority : principal.getAuthorities())
				if (authority.getAuthority().equals(Role.ROLE_ADMIN))
					return true;
		}
		return false;

	}

	public static UserAdapter getPrincipal() {
		if (SecurityContextHolder.getContext() != null
				&& SecurityContextHolder.getContext().getAuthentication() != null) {
			UserDetails user = (UserDetails)SecurityContextHolder.getContext().getAuthentication().getPrincipal();
			if (user instanceof UserAdapter)
				return (UserAdapter)user;
			else if (user != null) {
			    return new UserAdapter(null, user);
			}
		}
		return null;
	}
	
	public static Long getCurrentUserId() {
		return getPrincipal() != null ? getPrincipal().getId() : null;
	}
}
