package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import com.trickplay.gameservice.domain.BuddyListInvitation;

public class BuddyInvitationListTO {
	private List<BuddyInvitationTO> invitations = new ArrayList<BuddyInvitationTO>();
	
	public BuddyInvitationListTO() {
		
	}
	
	public BuddyInvitationListTO(List<BuddyListInvitation> bliList) {
		if (bliList!=null) {
			for(BuddyListInvitation bli: bliList)
				invitations.add(new BuddyInvitationTO(bli));
		}
	}

	public List<BuddyInvitationTO> getInvitations() {
		return invitations;
	}

	public void setInvitations(List<BuddyInvitationTO> invitations) {
		this.invitations = invitations;
	}
}
