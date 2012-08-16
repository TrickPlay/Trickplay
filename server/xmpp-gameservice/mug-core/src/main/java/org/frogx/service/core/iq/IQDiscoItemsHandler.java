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
package org.frogx.service.core.iq;



import org.dom4j.Element;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.core.DefaultMUGService;
import org.xmpp.packet.IQ;
import org.xmpp.packet.PacketError;


/**
 * This class is implementing a handler for discovering the items associated
 * with the Multi-User Gaming service
 * (<a href="http://xmpp.org/extensions/xep-0030.html#items">XEP-0030</a>).
 * This includes discovering for game rooms and its occupants.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public class IQDiscoItemsHandler {
	
	/**
	 * The Multi-User Gaming Service which can be discovered.
	 */
	DefaultMUGService service;
	
	/**
	 * Create a handler for discovering game rooms and its occupants.
	 * 
	 * @param service The {@see DefaultMUGService} which can be discovered.
	 */
	public IQDiscoItemsHandler(DefaultMUGService service) {
		this.service = service;
	}
	
	/**
	 * Handle a disco#items query and get the resulting IQ packet.
	 * 
	 * @param packet The IQ Query which is handled.
	 * @return The IQ reply resulting from the query.
	 */
	public IQ handleIQ(IQ packet) {
		System.out.println("DiscoItemsHandler");
		
		if (packet.getType() == IQ.Type.result) {
			// TODO: Maybe we want to detect a local MUC service
			return null;
		}
		
		if (packet.getType() == IQ.Type.get) {
			// create an empty reply
			IQ reply = IQ.createResultIQ(packet);
			
			String roomName = packet.getTo().getNode();
			Element iq = packet.getChildElement();
			String node = iq.attributeValue("node");
			reply.setChildElement(iq.createCopy());
			Element queryElement = reply.getChildElement();
			
			if ((roomName == null) && (node == null)) {
				// List all public rooms
				for (MUGRoom room : service.getGameRooms()) {
					if (room.isPublicRoom() && !room.isLocked() ) {
						Element item = queryElement.addElement("item");
						item.addAttribute("jid", room.getJID().toBareJID());
						item.addAttribute("name", room.getNaturalLanguageName());
					}
				}
			}
			else if (roomName != null && node == null) {
				// If it's allowed list all occupants
				MUGRoom room = service.getGameRoom(roomName);
				if (room != null) {
					if (room.canDiscoverOccupants()) {
						for (MUGOccupant occupant : room.getOccupants()) {
							Element item = queryElement.addElement("item");
							item.addAttribute("jid", occupant.getRoomAddress().toString());
						}
					}
				}
				else 
					reply.setError(PacketError.Condition.item_not_found);
			}
			else
				reply.setError(PacketError.Condition.item_not_found);
			return reply;
		}
		else {
			// Ignore packets from Type error or set
			return null;
		}
	}

}
