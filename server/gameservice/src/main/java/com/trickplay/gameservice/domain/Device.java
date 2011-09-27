package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;

import org.hibernate.validator.constraints.NotBlank;

@Entity
public class Device extends BaseEntity implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@NotBlank
	private String deviceKey;
	@NotBlank
	private String deviceType;
	private User owner;
	private List<Game> deployedGames = new ArrayList<Game>();

	public Device() {

	}

	public Device(String deviceKey, String deviceType, User owner) {
		super();
		this.deviceKey = deviceKey;
		this.deviceType = deviceType;
		this.owner = owner;
	}

	@Column(unique=true)
	public String getDeviceKey() {
		return deviceKey;
	}

	public void setDeviceKey(String deviceKey) {
		this.deviceKey = deviceKey;
	}

	public String getDeviceType() {
		return deviceType;
	}

	public void setDeviceType(String deviceType) {
		this.deviceType = deviceType;
	}

	@ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="owner_id", nullable=false)
	public User getOwner() {
		return owner;
	}

	public void setOwner(User owner) {
		this.owner = owner;
	}

	@ManyToMany(targetEntity = Game.class)
	@JoinTable(
			name = "DEVICE_GAME", 
			joinColumns = 
				@JoinColumn(
						name = "device_id"), 
						inverseJoinColumns = @JoinColumn(name = "game_id")
			)
	public List<Game> getDeployedGames() {
		return deployedGames;
	}

	public void setDeployedGames(List<Game> games) {
		this.deployedGames = games;
	}

	public void addGame(Game g) {
		deployedGames.add(g);
	}
}
