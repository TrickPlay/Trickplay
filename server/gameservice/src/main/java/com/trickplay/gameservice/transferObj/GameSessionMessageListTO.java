package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.GameSessionMessage;

public class GameSessionMessageListTO {
	List<GameSessionMessageTO> gameSessionMessageList = new ArrayList<GameSessionMessageTO>();
	
	public GameSessionMessageListTO() {
		
	}
	
	public GameSessionMessageListTO(List<GameSessionMessage> listGS) {
		if (listGS==null)
			return;
		for(GameSessionMessage gs: listGS)
		    gameSessionMessageList.add(new GameSessionMessageTO(gs));
	}
	
	public List<GameSessionMessageTO> getMessages() {
		return gameSessionMessageList;
	}
	
	public void setMessages(List<GameSessionMessageTO> listGS) {
	    gameSessionMessageList.clear();
		if (listGS != null && listGS.size()>0)
		    gameSessionMessageList.addAll(listGS);
	}
}
