package com.trickplay.gameservice.domain;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name="persistent_logins")
public class SessionToken extends BaseEntity {
    private long userId;
    private String series;
    private String token;
    private Date lastUsed;

    private boolean expired=false;
    
    public SessionToken(long userId, String series, String token,
            Date lastUsed, boolean expired) {
        super();
        this.userId = userId;
        this.series = series;
        this.token = token;
        this.lastUsed = lastUsed;
        this.expired = expired;
    }

    
    public SessionToken() {
        
    }

    @Column(nullable=false)
    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    @Column(nullable=false)
    public String getSeries() {
        return series;
    }

    public void setSeries(String series) {
        this.series = series;
    }

    @Column(nullable=false, unique=true)
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Date getLastUsed() {
        return lastUsed;
    }

    @Column(nullable=false)
    public void setLastUsed(Date lastUsed) {
        this.lastUsed = lastUsed;
    }

    @Column(nullable=false)
    public boolean isExpired() {
        return expired;
    }

    public void setExpired(boolean expired) {
        this.expired = expired;
    }
}
