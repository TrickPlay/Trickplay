package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

@Entity
@PrimaryKeyJoinColumn(name="id")
@XmlRootElement
public class StatelessHttpSession extends Session implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	@NotNull
	private String token;
	@NotNull
	private Date expires;
	@NotNull
	private Device device;


	public StatelessHttpSession() {
		super();
	}

	public StatelessHttpSession(User owner, String token, Date expires) {
		super(owner, SessionType.HTTP_SESSION);
		this.token = token;
		this.expires = expires;
	}


	@Column(unique=true)
	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	@Temporal(value=TemporalType.TIMESTAMP)
	public Date getExpires() {
		return expires;
	}

	public void setExpires(Date expires) {
		this.expires = expires;
	}
	
	@ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="device_id", nullable=false, updatable=false)
	public Device getDevice() {
		return device;
	}
	
	public void setDevice(Device d) {
		this.device = d;
	}

	@Transient
	public boolean isExpired() {
		return (expires != null && expires.before(new Date()));
	}

}
