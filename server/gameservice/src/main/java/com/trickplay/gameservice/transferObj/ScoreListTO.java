package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.RecordedScore;

public class ScoreListTO {

	private List<ScoreTO> scoreList = new ArrayList<ScoreTO>();
	
	public ScoreListTO() {
		
	}
	
	public ScoreListTO(List<RecordedScore> scoreList) {
		if (scoreList == null)
			return;
		for(RecordedScore s: scoreList) 
			this.scoreList.add(new ScoreTO(s));
	}

	public List<ScoreTO> getScoreList() {
		return scoreList;
	}

	public void setScoreList(List<ScoreTO> scoreList) {
		this.scoreList = scoreList;
	}
	
}
