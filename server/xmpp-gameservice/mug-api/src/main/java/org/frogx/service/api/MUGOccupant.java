
package org.frogx.service.api;


import org.frogx.service.api.MUGRoom;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.JID;
import org.xmpp.packet.Packet;
import org.xmpp.packet.Presence;


public interface MUGOccupant {
	
	/**
	 * The Affiliation represents the authorization of an {@see MUGOccupant}.
	 * 
	 */
	public enum Affiliation {
		
		/**
		 * Owner of the room.
		 */
		owner(10),
		
		/**
		 * A user who is on the "whitelist" for a members-only room.
		 */
		member(20),
		
		/**
		 * A user who doesn't have an affiliation.
		 */
		none(30);
		
		private int value;
		
		Affiliation(int value) {
			this.value = value;
		}
		
		/**
		 * Returns the value for the affiliation.
		 *
		 * @return the value.
		 */
		public int getValue() {
			return value;
		}
		
		/**
		 * Returns the affiliation associated with the specified value.
		 *
		 * @param value the integer value.
		 * @return the associated affiliation.
		 */
		public static Affiliation valueOf(int value) {
			switch (value) {
				case 10: return owner;
				case 20: return member;
				default: return none;
			}
		}
	}
	
	/**
	 * Get the nickname of this occupant.
	 * 
	 * @return The nickname of this occupant.
	 */
	public String getNickname();
	
	/**
	 * Set a new nickname for the occupants attributes.<br>
	 * <b>Note:</b>
	 * A {@see MUGRoom} manage its occupants and therefore
	 * use {@see MUGRoom#changeNickname(String, String, Presence)}
	 * to ensure the room handles the occupant with the new nickname
	 * correctly.
	 * 
	 * @param nickname The new nickname which should be used.
	 */
	void changeNickname(String nickname);
	
	/**
	 * Obtain the {@see JID} representing this occupant in a room.
	 * The Jabber ID has the form: room@service/nickname.
	 *
	 * @return The Jabber ID that represents this occupant in the room.
	 */
	public JID getRoomAddress();
	
	/**
	 * Get the real {@see JID} of this occupant.
	 * The real Jabber ID is the account on which this user is
	 * signed on.
	 * 
	 * @return The Jabber ID of the user.
	 */
	public JID getUserAddress();
	
	/**
	 * Sets a new presence information for the occupant.<br>
	 * <b>Note:</b>
	 * This doesn't include to announce the new presence in the room.
	 * 
	 * @param presence The new presence for the occupant.
	 */
	public void setPresence(Presence presence);
	
	/**
	 * Obtain the actual presence information for this occupant including
	 * information about his affiliation and game role.
	 * 
	 * @return The current presence.
	 */
	public Presence getPresence();
	
	/**
	 * use this version of getPresence to add a (presence acknowledgment) status tag. a status tag with attribute "code" set to 110
	 * will be placed in the presence packet if to_self parameter is true
	 * @param to_self
	 * @return
	 */
	public Presence getPresence(boolean to_self);
	
	/**
	 * Get the {@see Affiliation} of this occupant.
	 * The affiliation represents the authorization.
	 * 
	 * @return The affiliation of this occupant.
	 */
	public Affiliation getAffiliation();
	
	/**
	 * Return true if the occupant has a game role and therefore is
	 * a player in the match.
	 * It returns false if the occupant is a spectator.
	 * 
	 * @return True if the occupant is a player or false otherwise.
	 */
	public boolean hasRole();
	
	/**
	 * Get the name of the role which this occupant is reserved.
	 * 
	 * @return The name of the occupants role.
	 */
	public String getRoleName();
	
	/**
	 * Get the {@see MUGRoom} associated with this occupant.
	 * Each occupant object represents one participant in one 
	 * game room.
	 * 
	 * @return The game room which this occupant is participating.
	 */
	public MUGRoom getGameRoom();
	
	/**
	 * Sends a packet to the occupant.
	 *
	 * @param packet The packet to send.
	 */
	public void send(Packet packet) throws ComponentException;
	
	public boolean isAvailable();
	
	public long getLastPacketTime();
	
	/**
	 * Called when the occupant is leaving the game room,
	 * to clean things up.
	 */
	public void destroy();
	
	public int getInRoomId();
}
