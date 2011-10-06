package com.trickplay.gameservice.transferObj;

import java.util.Date;

import javax.validation.constraints.NotNull;

import com.trickplay.gameservice.domain.StatelessHttpSession;

public class SessionTO {

	@NotNull
	private String token;
	@NotNull
	private Date expires;
	
	public SessionTO(StatelessHttpSession session) {
		super();
		this.token = session.getToken();
		this.expires = session.getExpires();
	}
	
	public SessionTO(String token, Date expires) {
		super();
		this.token = token;
		this.expires = expires;
	}
	
	public SessionTO() {
		super();
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public Date getExpires() {
		return expires;
	}

	public void setExpires(Date expires) {
		this.expires = expires;
	}
	
	
}
