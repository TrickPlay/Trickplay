package org.frogx.service.core.iq;


import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.exception.ForbiddenException;
import org.frogx.service.api.exception.GameConfigurationException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.core.DefaultMUGRoom;
import org.frogx.service.core.DefaultMUGRoom.Anonymity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.IQ;


/**
 * This class is implementing a handler for game room requests
 * within the owner namespace.
 * 
 */
public class IQNonFormOwnerHandler {
	
	private static final Logger log = LoggerFactory.getLogger(IQNonFormOwnerHandler.class);
	
	/**
	 * The hosting multi-user game service component.
	 */
	private MUGService service;
	
	/**
	 * The MUGManager provides sending and routing packages.
	 */
	private MUGManager mugManager;
	
	/**
	 * A utility which provices localized strings.
	 */
	private LocaleUtil locale;
	
	/**
	 * The room which is managed by this IQ handler.
	 */
	private DefaultMUGRoom room;
		
	
	/**
	 * Create a handler for game room requests within the Owner namespace.
	 * 
	 * @param service The {@see MUGService} which hosts the game room.
	 * @param componentManager The ComponentManager provides sending and routing replies.
	 * @param room The IQOwnerHandler process messages only for this room.
	 */
	public IQNonFormOwnerHandler(MUGService service, 
			MUGManager mugManager, DefaultMUGRoom room) {
		this.service = service;
		this.mugManager = mugManager;
		this.locale = mugManager.getLocaleUtil();
		this.room = room;
	}
	
	/**
	 * Handle game room requests within the Owner namespace.
	 * 
	 * @param packet The IQ stanza which should be handled.
	 * @param occupant The Sender of the IQ request.
	 * 
	 * @throws ForbiddenException if the sender don't have the permission for his request.
	 * @throws IllegalArgumentException if we don't understand the request.
	 * @throws GameConfigurationException if the room or match state is not correct.
	 * @throws UnsupportedGameException if the request is unsupported or not implemented.
	 */
	public void handleIQ(IQ packet, MUGOccupant occupant) throws ForbiddenException, 
			IllegalArgumentException, GameConfigurationException, UnsupportedGameException {
		
		// Ignore packets with type error or result
		if (packet.getType() == IQ.Type.error || 
				packet.getType() == IQ.Type.result) {
			return;
		}
		
		IQ reply = IQ.createResultIQ(packet);
		Element query = packet.getChildElement();
		
		// Check if the sender is an owner
		// (Only in non-anonymous rooms we handle member lists for other Occupants)
		if (!room.isNonAnonymous() && (MUGOccupant.Affiliation.owner != occupant.getAffiliation())) {
			throw new ForbiddenException();
		}
		
		if ("query".equals(query.getName())) {
			for (Iterator<Element> it = query.elementIterator(); it.hasNext();) {
				Element element = (Element) it.next();
				
				if ("options".equals(element.getName())) {
					Iterator<Element> optionElementIt = element
							.elementIterator();

					if (MUGOccupant.Affiliation.owner != occupant
							.getAffiliation()) {
						throw new ForbiddenException();
					}

					if (!optionElementIt.hasNext()) {
						// Send a room configuration form
						reply.setChildElement(getConfiguration());
					} else {
						if ((room.getMatch().getStatus() == MUGMatch.Status.created)
								|| (room.getMatch().getStatus() == MUGMatch.Status.inactive)) {
							setConfiguration(element);

							// Inform the occupants that the configuration has
							// changed
							room.broadcastRoomPresence();
						} else {
							// The room can not be changed in an active or
							// paused match status
							throw new GameConfigurationException();
						}
					}
				}
				else if ("state".equals(element.getName())) {
					// The owner requests a constructed match
					if (MUGOccupant.Affiliation.owner != occupant.getAffiliation()) {
						throw new ForbiddenException();
					}
					
					if (element.getNamespaceURI().equals(room.getGame().getGameID().getNamespace())) {
						room.getMatch().setConstructedState(element);
					}
					else {
						throw new IllegalArgumentException();
					}
				}
				else if ("item".equals(element.getName())) {
					//TODO: Implement Member lists, Revoke and Assign Roles, Ownership Transfer
					throw new UnsupportedGameException();
				}
				else if ("delete".equals(element.getName())) {
					//TODO: delete the room
					throw new UnsupportedGameException();
				}
				else {
					throw new UnsupportedGameException();
				}
			}
		}
		else {
			// No valid request, feature not implemented...
			throw new UnsupportedGameException();
		}
		
		// Send a reply only if the sender of the original packet was from a real JID.
		// (i.e. not  a packet generated locally)
		if (reply.getTo() != null) {
			try {
				// TODO: Remove debug output
				log.debug("[MUG]: Sending: " + reply.toXML());
				
				mugManager.sendPacket(service, reply);
			}
			catch (ComponentException e) {
				log.error(locale.getLocalizedString("mug.config.error.response")
						+ room.getName(), e);
			}
		}
	}
	
	/**
	 * Parse the configuration form and set the room configuration.
	 * 
	 * @param completedForm The form with the new configuration of the game room.
	 */
	private void setConfiguration(Element options) {
		Element roomOptions = 
			options != null && options.element("room") != null ? options.element("room") : null;

		if (roomOptions != null)
			room.setOptions(roomOptions);
		
		Element matchOptions = 
			options != null && options.element("match") != null ? options.element("match") : null;
			
		if (matchOptions != null) {
			List<Element> matchOptionsList = new ArrayList<Element>();
			matchOptionsList.add(matchOptions);
			room.getMatch().setConfiguration(matchOptionsList);
		}
	}
	
	/**
	 * Set the current room configuration as default values of the configuration form
	 */
	private Element getConfiguration() {
		Element element = DocumentHelper.createElement(QName.get("query",
				MUGService.mugNS + "#owner"));
		Element gameOptionsElement = element.addElement("options");
		
		gameOptionsElement.add(room.getOptions());
		

		
		Collection<Element> matchConfig = room.getMatch().getConfigurationForm();
		if (matchConfig != null) {
			for (Iterator<Element> it=matchConfig.iterator();it.hasNext();) {
				gameOptionsElement.add(it.next());
			}
		}
		return element;
	}
	
}
