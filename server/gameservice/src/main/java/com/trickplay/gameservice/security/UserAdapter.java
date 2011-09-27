package com.trickplay.gameservice.security;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public class UserAdapter implements UserDetails {

	private Long id;
	private UserDetails adaptee;
	public UserAdapter(Long id, UserDetails u) {
		this.id = id;
		this.adaptee = u;
	}
	
	public Collection<GrantedAuthority> getAuthorities() {
		return adaptee.getAuthorities();
	}

	public String getPassword() {
		
		return adaptee.getPassword();
	}

	public String getUsername() {
		
		return adaptee.getUsername();
	}

	public boolean isAccountNonExpired() {
		
		return adaptee.isAccountNonExpired();
	}

	public boolean isAccountNonLocked() {
		
		return adaptee.isAccountNonLocked();
	}

	public boolean isCredentialsNonExpired() {
		
		return adaptee.isCredentialsNonExpired();
	}

	public boolean isEnabled() {
		
		return adaptee.isEnabled();
	}
	
	public Long getId() {
		return id;
	}
	
	public void setAdaptee(UserDetails user) {
		this.adaptee = user;
	}

}
