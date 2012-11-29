/**
 * Copyright (C) 2008-2009 Guenther Niess. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.frogx.service.core;


import org.xmpp.packet.JID;
import org.xmpp.packet.Packet;

/**
 * A MUGSession provides the user session context of an
 * {@see net.sf.openfire.mug.lib.MUGService} and handles XMPP stanzas
 * which are send to a {@see net.sf.openfire.mug.lib.MUGRoom} or its
 * occupants.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public interface MUGSession {
	
	/**
	 * Get the full {@see JID} of this user session.
	 * The Jabber ID represents the account on which this user is 
	 * signed on.
	 * 
	 * @return The Jabber ID of the user.
	 */
	public JID getAddress();
	
	/**
	 * Get time (in milliseconds from System currentTimeMillis()) since
	 * last packet.
	 *
	 * @return The time when the last packet was sent from this session.
	 */
	public long getLastPacketTime();
	
	/**
	 * This method handles a {@see Packet} send to a
	 * {@see net.sf.openfire.mug.lib.MUGRoom} or
	 * {@see net.sf.openfire.mug.lib.MUGOccupant}.
	 * 
	 * @param packet The XMPP stanza which should be handled.
	 */
	public void process(Packet packet);
	
	/**
	 * Check if the user is participating a game room.
	 * 
	 * @return True if the user is an occupant of any game room.
	 */
	public boolean isParticipant();
}
