package com.trickplay.gameservice.xmpp.client;

import java.util.ArrayList;
import java.util.List;

public class Game {

	private String name;
	private String description;
	private String category;
	private boolean turnbased;
	private List<String> roles = new ArrayList<String>();
	
	public Game() {
		
	}
	
	public Game(String name, String description, String category,
			boolean turnbased) {
		super();
		this.name = name;
		this.description = description;
		this.category = category;
		this.turnbased = turnbased;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public boolean isTurnbased() {
		return turnbased;
	}
	public void setTurnbased(boolean turnbased) {
		this.turnbased = turnbased;
	}
	public List<String> getRoles() {
		return new ArrayList<String>(roles);
	}
	public void setRoles(List<String> roles) {
		this.roles.clear();
		this.roles.addAll(roles);
	}
	
	public void addRole(String role) {
		roles.add(role);
	}
	
	public boolean hasRole(String role) {
		return roles.contains(role);
	}
	
}
