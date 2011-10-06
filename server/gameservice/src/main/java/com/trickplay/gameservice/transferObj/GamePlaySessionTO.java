package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.trickplay.gameservice.domain.GameSession;
import com.trickplay.gameservice.domain.User;

public class GamePlaySessionTO {

	private Long id;
	private Date created;
	private Date updated;
	private Long gameId;
    private String gameName;
    private Date startTime;
    private Date endTime;
    
    private Long ownerId;
    private String ownerName;

    
    public static class UserStruct {
    	private Long userId;
    	private String username;
		public Long getUserId() {
			return userId;
		}
		public void setUserId(Long userId) {
			this.userId = userId;
		}
		public String getUsername() {
			return username;
		}
		public void setUsername(String username) {
			this.username = username;
		}
		public UserStruct(Long userId, String username) {
			super();
			this.userId = userId;
			this.username = username;
		}
    	
    	public UserStruct() {
    		
    	}
    }

    private List<UserStruct> players = new ArrayList<UserStruct>();
	
	public GamePlaySessionTO() {
		
	}
	
	public GamePlaySessionTO(GameSession session) {
		if (session == null)
			throw new IllegalArgumentException("GameSession is null");
		id = session.getId();
		created = session.getCreated();
		updated = session.getUpdated();
		gameId = session.getGame().getId();
		gameName = session.getGame().getName();
		startTime = session.getStartTime();
		endTime = session.getEndTime();
		
		ownerId = session.getOwner() != null ? session.getOwner().getId() : null;
		ownerName = session.getOwner() != null ? session.getOwner().getUsername() : null;
		
		if (session.getPlayers()!=null) {
			for(User u: session.getPlayers())
				this.players.add(new UserStruct(u.getId(), u.getUsername()));
		}
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

	public List<UserStruct> getPlayers() {
		return players;
	}

	public void setPlayers(List<UserStruct> players) {
		this.players = players;
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

	public Long getGameId() {
		return gameId;
	}

	public void setGameId(Long gameId) {
		this.gameId = gameId;
	}

	public String getGameName() {
		return gameName;
	}

	public void setGameName(String gameName) {
		this.gameName = gameName;
	}

	public Date getStartTime() {
		return startTime;
	}

	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	public Date getEndTime() {
		return endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public Long getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(Long ownerId) {
		this.ownerId = ownerId;
	}

	public String getOwnerName() {
		return ownerName;
	}

	public void setOwnerName(String ownerName) {
		this.ownerName = ownerName;
	}

}
