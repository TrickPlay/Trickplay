package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.xml.bind.annotation.XmlRootElement;

import org.hibernate.validator.constraints.Email;
import org.hibernate.validator.constraints.NotBlank;

@Entity
@XmlRootElement(name = "user")
public class User extends BaseEntity implements Serializable {
	private static final long serialVersionUID = 1L;

//	private Long id;
	@NotBlank(message = "username is a required field")
	private String username;
	@NotBlank(message = "password is a required field")
	private String password;
	@NotBlank
	@Email
	private String email;
	private Set<Role> authorities = new HashSet<Role>();
	private boolean allowAchievementMessages;
	private boolean allowHighScoreMessages;
	
	private List<Buddy> buddies = new ArrayList<Buddy>();
	private List<BuddyListInvitation> invitationsSent = new ArrayList<BuddyListInvitation>();
	private List<BuddyListInvitation> invitationsReceived = new ArrayList<BuddyListInvitation>();
	private List<Device> ownedDevices = new ArrayList<Device>();
	private List<Event> events = new ArrayList<Event>();

	public User() {

	}

	public User(String username, String password, String email, boolean allowAchieveMsgs, boolean allowHighscores) {
		this.email = email;
		this.username = username;
		this.password = password;
		this.allowAchievementMessages = allowAchieveMsgs;
		this.allowHighScoreMessages = allowHighscores;
	}

//	@Id
//	@GeneratedValue
//	public Long getId() {
//		return id;
//	}
//
//	public void setId(Long id) {
//		this.id = id;
//	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(unique=true)
	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
	
	@OneToMany(mappedBy="owner", fetch=FetchType.LAZY)
	public List<Buddy> getBuddies() {
		return buddies;
	}
	
	public void setBuddies(List<Buddy> buddies) {
		this.buddies = buddies;
	}


	public void setEvents(List<Event> events) {
		this.events = events;
	}

	@OneToMany(mappedBy="source", fetch=FetchType.LAZY)
	public List<Event> getEvents() {
		return events;
	}
	
	@ManyToMany(
	        targetEntity=Role.class
	    )
	    @JoinTable(
	        name="USER_ROLE",
	        joinColumns=@JoinColumn(name="user_id"),
	        inverseJoinColumns=@JoinColumn(name="role_id")
	    )
	public Set<Role> getAuthorities() {
		return authorities;
	}
	
	public void setAuthorities(Set<Role> authorities) {
		this.authorities = authorities;
	}

	public void addAuthority(Role authority) {
		authorities.add(authority);
	}

	@OneToMany(mappedBy="requestor", fetch=FetchType.LAZY)
	public List<BuddyListInvitation> getInvitationsSent() {
		return invitationsSent;
	}

	public void setInvitationsSent(List<BuddyListInvitation> invitations) {
		this.invitationsSent = invitations;
	}

	@OneToMany(mappedBy="recipient", fetch=FetchType.LAZY)
	public List<BuddyListInvitation> getInvitationsReceived() {
		return invitationsReceived;
	}

	public void setInvitationsReceived(List<BuddyListInvitation> invitations) {
		this.invitationsReceived = invitations;
	}
	
	public void setOwnedDevices(List<Device> ownedDevices) {
		this.ownedDevices = ownedDevices;
	}

	@OneToMany(mappedBy="owner", fetch=FetchType.LAZY)
	public List<Device> getOwnedDevices() {
		return ownedDevices;
	}

	@Column(name="allow_achieve_msgs")
	public boolean isAllowAchievementMessages() {
		return allowAchievementMessages;
	}

	public void setAllowAchievementMessages(
			boolean allowAchievementMessages) {
		this.allowAchievementMessages = allowAchievementMessages;
	}

	@Column(name="allow_high_score_msgs")
	public boolean isAllowHighScoreMessages() {
		return allowHighScoreMessages;
	}

	public void setAllowHighScoreMessages(boolean allowHighScoreMessages) {
		this.allowHighScoreMessages = allowHighScoreMessages;
	}

	@Override
	public String toString() {
		return "User [id=" + getId() + ", username=" + username + ", password="
				+ password + ", email=" + email + "]";
	}


}
