package com.trickplay.gameservice.transferObj;

import com.trickplay.gameservice.domain.User;

public class UserTO {

	private Long id;
	private String username;
	private String email;
	private boolean allowHighScoresMessages=false;
	private boolean allowAchievementMessages=false;

	public UserTO() {

	}

	public UserTO(Long id, String username, String email, String password, boolean allowAchievementMessages, boolean allowHighScoresMessages) {
		super();
		this.id = id;
		this.username = username;
		this.email = email;
		this.allowAchievementMessages = allowAchievementMessages;
		this.allowHighScoresMessages = allowHighScoresMessages;
	}

	public UserTO(User user) {
		if (user == null)
			throw new IllegalArgumentException("User is null");
		this.id = user.getId();
		this.username = user.getUsername();
		this.email = user.getEmail();
		this.allowAchievementMessages = user.isAllowAchievementMessages();
		this.allowHighScoresMessages = user.isAllowHighScoreMessages();
	}


	public User toUser() {
		User user = new User();
		user.setId(id);
		user.setUsername(username);
		user.setEmail(email);
		return user;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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
	
	public boolean isAllowHighScoresMessages() {
		return allowHighScoresMessages;
	}

	public void setAllowHighScoresMessages(boolean allowHighScoresMessages) {
		this.allowHighScoresMessages = allowHighScoresMessages;
	}

	public boolean isAllowAchievementMessages() {
		return allowAchievementMessages;
	}

	public void setAllowAchievementMessages(boolean allowAchievementMessages) {
		this.allowAchievementMessages = allowAchievementMessages;
	}


}
