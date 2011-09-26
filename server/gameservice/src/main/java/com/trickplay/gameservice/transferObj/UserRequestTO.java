package com.trickplay.gameservice.transferObj;

import org.hibernate.validator.constraints.NotBlank;

import com.trickplay.gameservice.domain.User;

public class UserRequestTO {

	@NotBlank
	private String username;
	@NotBlank
	private String email;
	@NotBlank
	private String password;

	public UserRequestTO() {

	}

	public UserRequestTO(String username, String email, String password) {
		super();
		this.username = username;
		this.email = email;
		this.password = password;
	}

	public UserRequestTO(User user) {
		if (user == null)
			throw new IllegalArgumentException("User is null");
		this.username = user.getUsername();
		this.email = user.getEmail();
		this.password = user.getPassword();
	}


	public User toUser() {
		User user = new User();
		user.setUsername(username);
		user.setEmail(email);
		user.setPassword(password);
		return user;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPassword() {
		return password;
	}

}
