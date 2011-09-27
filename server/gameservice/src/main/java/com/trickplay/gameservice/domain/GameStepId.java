package com.trickplay.gameservice.domain;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import org.hibernate.validator.constraints.NotBlank;

@Embeddable
public class GameStepId {

	@NotBlank
	private String key;

	@Column(unique=true,nullable=false,updatable=false)
	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public GameStepId(String key) {
		super();
		this.key = key;
	}

	public GameStepId() {
		super();

	}
	
	
}
