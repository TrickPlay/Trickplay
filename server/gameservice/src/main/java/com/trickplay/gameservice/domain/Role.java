package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.validation.constraints.NotNull;

@Entity
public class Role extends BaseEntity implements Serializable {

	public static final String ROLE_ADMIN = "ROLE_ADMIN";
	public static final String ROLE_USER = "ROLE_USER";
	public static final String ROLE_ANONYMOUS = "ROLE_ANONYMOUS";
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@NotNull
	private String name;
	
	public Role() {
		
	}
	
	public Role(String role) {
		this.name = role;
	}


	@Column(unique=true, nullable=false)
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
}
