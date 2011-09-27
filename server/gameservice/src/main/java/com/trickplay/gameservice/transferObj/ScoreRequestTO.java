package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;

public class ScoreRequestTO {

	@Min(0)
	@Max(1000000000)
	private long points;
	
	public ScoreRequestTO(long points) {
		this.points = points;
	}
	
	public ScoreRequestTO() {
		
	}
	
	public long getPoints() {
		return points;
	}
	
	public void setPoints(long points) {
		this.points = points;
	}
	
}
