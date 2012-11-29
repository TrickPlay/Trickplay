package org.frogx.service.core;

import org.frogx.service.api.MUGMatch.TurnInfo;
import org.frogx.service.api.MUGOccupant;

public class DefaultTurnInfo implements TurnInfo {

	private MUGOccupant target;
	private long startTime;
	private long expirationTime;
	
	public DefaultTurnInfo(MUGOccupant target, long startTime, long expirationTime) {
		this.target = target;
		this.startTime = startTime;
		this.expirationTime = expirationTime;
	}
	
	public MUGOccupant getTarget() {
		return target;
	}

	public long getStartTime() {
		return startTime;
	}

	public long getExpirationTime() {
		return expirationTime;
	}

}
