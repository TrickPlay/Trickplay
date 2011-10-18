package com.trickplay.gameservice.domain;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@MappedSuperclass
public class BaseEntity {

	private Long id;
	
    private Date created;

    private Date updated;

    public void setId(Long id) {
		this.id = id;
	}

	@Id
	@GeneratedValue
	public Long getId() {
		return id;
	}

	@PrePersist
    protected void onCreate() {
    updated = created = new Date();
    }

    @PreUpdate
    protected void onUpdate() {
    updated = new Date();
    }
    
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created", nullable = false)
    public Date getCreated() {
        return created;
    }
    
    public void setCreated(Date created) {
    	this.created = created;
    }
    
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "updated", nullable = false)
    public Date getUpdated() {
        return updated;
    }
    
    public void setUpdated(Date updated) {
    	this.updated = updated;
    }
}
