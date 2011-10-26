package com.trickplay.gameservice.transferObj;

import java.util.Date;

import com.trickplay.gameservice.domain.GamePlaySummary;

public class GamePlaySummaryTO {

	private Long id;
	private String detail;
	private Long userId;
	private Long gameId;
	private Date created;
	private Date updated;

	public GamePlaySummaryTO() {
		
	}
	
	public GamePlaySummaryTO(GamePlaySummary gps) {
		if (gps == null)
			return;
		
		this.id = gps.getId();
		this.userId = gps.getUser().getId();
		this.gameId = gps.getGame().getId();
		this.detail = gps.getDetail();
		this.created = gps.getCreated();
		this.updated = gps.getUpdated();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}


	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	public Date getUpdated() {
		return updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getGameId() {
        return gameId;
    }

    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }
}
