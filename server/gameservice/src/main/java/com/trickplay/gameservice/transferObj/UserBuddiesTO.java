package com.trickplay.gameservice.transferObj;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

import com.trickplay.gameservice.domain.Buddy;
import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.domain.User;

@XmlRootElement
public class UserBuddiesTO {

	private UserTO user;
	private List<UserTO> buddies = new ArrayList<UserTO>();
	private List<BuddyInvitationTO> invitationsSent = new ArrayList<BuddyInvitationTO>();
	private List<BuddyInvitationTO> invitationsReceived = new ArrayList<BuddyInvitationTO>();

	public UserBuddiesTO(User user) {
		if (user == null)
			throw new IllegalArgumentException("User is null");
		this.user = new UserTO(user);
		if (user.getBuddies() != null) {
			for (Buddy buddy : user.getBuddies()) {
				buddies.add(new UserTO(buddy.getTarget()));
			}
		}
		if (user.getInvitationsSent() != null) {
			for (BuddyListInvitation bli : user.getInvitationsSent()) {
				if (bli.getStatus() == InvitationStatus.PENDING)
					invitationsSent.add(new BuddyInvitationTO(bli));
			}
		}
		if (user.getInvitationsReceived() != null) {
			for (BuddyListInvitation bli : user.getInvitationsReceived()) {
				if (bli.getStatus() == InvitationStatus.PENDING)
					invitationsReceived.add(new BuddyInvitationTO(bli));
			}
		}
	}

	public UserBuddiesTO(UserTO user, List<UserTO> buddies,
			List<BuddyInvitationTO> invitations) {
		super();
		this.user = user;
		this.buddies = buddies;
	}

	public UserBuddiesTO() {

	}

	public UserTO getUser() {
		return user;
	}

	public void setUser(UserTO user) {
		this.user = user;
	}

	public List<UserTO> getBuddies() {
		return buddies;
	}

	public void setBuddies(List<UserTO> buddies) {
		this.buddies = buddies;
	}

	public List<BuddyInvitationTO> getInvitationsSent() {
		return invitationsSent;
	}

	public void setInvitationsSent(List<BuddyInvitationTO> invitations) {
		this.invitationsSent = invitations;
	}

	public List<BuddyInvitationTO> getInvitationsReceived() {
		return invitationsReceived;
	}

	public void setInvitationsReceived(List<BuddyInvitationTO> invitations) {
		this.invitationsReceived = invitations;
	}

}
