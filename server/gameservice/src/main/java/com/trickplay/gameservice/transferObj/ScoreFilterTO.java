package com.trickplay.gameservice.transferObj;

import javax.validation.constraints.NotNull;

public class ScoreFilterTO {

	public enum ScoreType { TOP_SCORES, BUDDY_TOP_SCORES, USER_TOP_SCORES }
	
	@NotNull
	private ScoreType scoreType;
	
	public ScoreFilterTO() {
		this(ScoreType.TOP_SCORES);
	}
	
	public ScoreFilterTO(ScoreType st) {
		this.scoreType = st;
	}
	
	public ScoreType getScoreType() {
		return scoreType;
	}
	
	public void setScoreType(ScoreType st) {
		this.scoreType = st;
	}
}
