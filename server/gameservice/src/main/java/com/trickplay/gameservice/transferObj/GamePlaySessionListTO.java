package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.GameSession;

public class GamePlaySessionListTO {
	List<GamePlaySessionTO> gameSessionList = new ArrayList<GamePlaySessionTO>();
	
	public GamePlaySessionListTO() {
		
	}
	
	public GamePlaySessionListTO(List<GameSession> listGS) {
		if (listGS==null)
			return;
		for(GameSession gs: listGS)
			gameSessionList.add(new GamePlaySessionTO(gs));
	}
	
	public List<GamePlaySessionTO> getGameSessionList() {
		return gameSessionList;
	}
	
	public void setGameSessionList(List<GamePlaySessionTO> listGS) {
		gameSessionList.clear();
		if (listGS != null && listGS.size()>0)
			gameSessionList.addAll(listGS);
	}
}
