package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.GamePlayInvitation;

public class GamePlayInvitationListTO {
	List<GamePlayInvitationTO> invitationList = new ArrayList<GamePlayInvitationTO>();
	
	public GamePlayInvitationListTO() {
		
	}
	
	public GamePlayInvitationListTO(List<GamePlayInvitation> listGS) {
		if (listGS==null)
			return;
		for(GamePlayInvitation gs: listGS)
		    invitationList.add(new GamePlayInvitationTO(gs));
	}
	
	public List<GamePlayInvitationTO> getInvitations() {
		return invitationList;
	}
	
	public void setInvitations(List<GamePlayInvitationTO> listGS) {
	    invitationList.clear();
		if (listGS != null && listGS.size()>0)
		    invitationList.addAll(listGS);
	}
}
