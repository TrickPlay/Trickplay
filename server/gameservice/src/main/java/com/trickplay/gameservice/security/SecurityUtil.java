package com.trickplay.gameservice.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;

import com.trickplay.gameservice.domain.Role;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;

public class SecurityUtil {

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
			else
				throw new GameServiceException(Reason.FORBIDDEN);
		}
		return null;
	}
}
