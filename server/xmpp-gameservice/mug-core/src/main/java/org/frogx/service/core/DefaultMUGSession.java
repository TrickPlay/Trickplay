/**
 * DefaultMUGSession - A user abstraction of a Multi-User Gaming service.
 * Some parts are inspired by the LocalMUCUser of the Openfire XMPP
 * server.
 * 
 * Copyright (C) 2004-2008 Jive Software. All rights reserved.
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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGProperty;
import org.frogx.service.api.MUGOccupant.Affiliation;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.exception.CannotBeInvitedException;
import org.frogx.service.api.exception.ConflictException;
import org.frogx.service.api.exception.ForbiddenException;
import org.frogx.service.api.exception.GameConfigurationException;
import org.frogx.service.api.exception.InvalidTurnException;
import org.frogx.service.api.exception.LeasedException;
import org.frogx.service.api.exception.NotAcceptableException;
import org.frogx.service.api.exception.NotAllowedException;
import org.frogx.service.api.exception.NotFoundException;
import org.frogx.service.api.exception.RequiredPlayerException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.frogx.service.games.common.GenericTurnBasedMUG;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.IQ;
import org.xmpp.packet.JID;
import org.xmpp.packet.Message;
import org.xmpp.packet.Packet;
import org.xmpp.packet.PacketError;
import org.xmpp.packet.PacketError.Condition;
import org.xmpp.packet.PacketError.Type;
import org.xmpp.packet.Presence;

/**
 * The first implementation of an {@see MUGSession}. A {@see MUGSession}
 * provides the user session context of an {@see MUGService} and handles XMPP
 * stanzas which are send to a {@see MUGRoom} or its occupants.
 * 
 */
public class DefaultMUGSession implements MUGSession {

	private static final Logger log = LoggerFactory
			.getLogger(DefaultMUGSession.class);

	/**
	 * The Multi-User Gaming service which this user is associated.
	 */
	protected DefaultMUGService component;

	/**
	 * The MUGManager provides a logging utility and allows to send and route
	 * packages.
	 */
	protected MUGManager mugManager;

	/**
	 * The full Jabber ID represents the session on which this user is signed
	 * on.
	 */
	protected JID jid;

	/**
	 * A active user is associated with maybe several game rooms and therefore
	 * several occupants.
	 */
	protected Map<String, MUGOccupant> occupants = new ConcurrentHashMap<String, MUGOccupant>();

	/**
	 * Time of last packet sent.
	 */
	protected long lastPacketTime;

	/**
	 * Create an user session context of a {@see MUGService}.
	 * 
	 * @param component
	 *            The Multi-User Gaming service.
	 * @param componentManager
	 *            A {@see ComponentManager} utility for logging and sending XMPP
	 *            Stanzas.
	 * @param address
	 *            The Jabber ID represents the session on which this user is
	 *            authenticated.
	 */
	public DefaultMUGSession(DefaultMUGService component,
			MUGManager mugManager, JID address) {
		this.component = component;
		this.mugManager = mugManager;
		this.jid = address;
	}

	/**
	 * Get the full {@see JID} of this user. The Jabber ID represents the
	 * account on which this user is signed on.
	 * 
	 * @return The Jabber ID of the user.
	 */
	public JID getAddress() {
		return jid;
	}

	/**
	 * Get time (in milliseconds from System currentTimeMillis()) since last
	 * packet.
	 * 
	 * @return The time when the last packet was sent from this user
	 */
	public long getLastPacketTime() {
		return lastPacketTime;
	}

	/**
	 * Check if the user is participating a game room.
	 * 
	 * @return True if the user is an occupant of any game room.
	 */
	public boolean isParticipant() {
		return !((occupants == null) || occupants.isEmpty());
	}

	/**
	 * Get a collection of the used {@see MUGOccupant}s.
	 * 
	 * @return A collection of the used occupants.
	 */
	public Collection<MUGOccupant> getOccupants() {
		return occupants.values();
	}

	/**
	 * A helper method for signaling the user that an error occurred.
	 * 
	 * @param packet
	 *            The original packet while the error occurred.
	 * @param error
	 *            The error which should be sent.
	 */
	protected void sendErrorPacket(Packet packet, PacketError error) {
		Packet reply = null;
		if (packet instanceof IQ) {
			reply = IQ.createResultIQ((IQ) packet);
			((IQ) reply).setChildElement(((IQ) packet).getChildElement()
					.createCopy());
			reply.setError(error);
		} else {
			reply = packet.createCopy();
			reply.setError(error);
			reply.setFrom(packet.getTo());
			reply.setTo(packet.getFrom());
		}

		try {
			mugManager.sendPacket(component, reply);
		} catch (ComponentException e) {
			log.error("Can't send packet: " + reply, e);
		}
	}

	/**
	 * A helper method for signaling the user that an error occurred.
	 * 
	 * @param packet
	 *            The original packet while the error occurred.
	 * @param errorCondition
	 *            The error condition which should be sent.
	 */
	protected void sendErrorPacket(Packet packet,
			PacketError.Condition errorCondition) {
		sendErrorPacket(packet, new PacketError(errorCondition));
	}

	/**
	 * This method handles a {@see Packet} send to a {@see MUGRoom} or {@see
	 * MUGOccupant}.
	 * 
	 * @param packet
	 *            The XMPP stanza which should be handled.
	 */
	public void process(Packet packet) {
		lastPacketTime = System.currentTimeMillis();

		try {
			if (packet instanceof Message) {
				process((Message) packet);
			} else if (packet instanceof Presence) {
				process((Presence) packet);
			} else if (packet instanceof IQ) {
				process((IQ) packet);
			}
		} catch (ForbiddenException e) {
			sendErrorPacket(packet, PacketError.Condition.forbidden);
		} catch (RequiredPlayerException e) {
			sendErrorPacket(packet, PacketError.Condition.unexpected_request);
		} catch (GameConfigurationException e) {
			sendErrorPacket(packet, PacketError.Condition.unexpected_request);
		} catch (NotAcceptableException e) {
			sendErrorPacket(packet, PacketError.Condition.not_acceptable);
		} catch (NotFoundException e) {
			sendErrorPacket(packet, PacketError.Condition.recipient_unavailable);
		} catch (ConflictException e) {
			sendErrorPacket(packet, PacketError.Condition.conflict);
		} catch (NotAllowedException e) {
			sendErrorPacket(packet, PacketError.Condition.not_allowed);
		} catch (CannotBeInvitedException e) {
			sendErrorPacket(packet, PacketError.Condition.not_acceptable);
		} catch (IllegalArgumentException e) {
			sendErrorPacket(packet, PacketError.Condition.bad_request);
		} catch (UnsupportedGameException e) {
			sendErrorPacket(packet,
					PacketError.Condition.feature_not_implemented);
		} catch (LeasedException e) {
			sendErrorPacket(packet, PacketError.Condition.conflict);
		} catch (ComponentException e) {
			sendErrorPacket(packet, PacketError.Condition.internal_server_error);
			log.error("Can't process: " + packet.toXML(), e);
		} 
	}

	/**
	 * This method handles invitations, start messages, game moves and private
	 * messages.
	 * 
	 * @param message
	 *            The XMPP stanza which should be handled.
	 * @throws ComponentException
	 */
	protected void process(Message message) throws ComponentException {
		/*
		 * handle messages with child: - <game><invite> -> invitation -
		 * <game><decline> -> decline invitation - <start> -> start - <turn> ->
		 * turn
		 * 
		 * type chat or normal -> private message
		 */

		// Ignore messages of type error
		if (Message.Type.error == message.getType()) {
			return;
		}

		JID recipient = message.getTo();
		String roomName = recipient.getNode();

		// Ignore packets for the game component
		if (roomName == null) {
			return;
		}

		MUGOccupant occupant = occupants.get(roomName);
		MUGRoom room = (occupant != null) ? occupant.getGameRoom() : component
				.getGameRoom(roomName);

		if (room == null) {
			// The sender is not an occupant of a NON-EXISTENT room!!!
			throw new NotFoundException();
		}

		synchronized (room) {
			if (occupant == null /*&& room.getGame().isCorrespondence()*/) {
				occupant = room.getOccupant(jid);
				if (occupant != null)
					occupants.put(roomName, occupant);
			}
			Element childElement = null;

			// An user that is not an occupant could be declining an invitation
			// or he is participating in a correspondence game
			if (occupant == null) {
				boolean declinedInvitation = false;
				if (Message.Type.normal == message.getType()) {
					childElement = message.getChildElement("game",
							MUGService.mugUserNS);
					if (childElement != null
							&& childElement.element("decline") != null) {
						// A user has declined an invitation to a room
						declinedInvitation = true;
					}
				}
				if (declinedInvitation) {
					Element info = childElement.element("decline");
					room.sendInvitationRejection(
							new JID(info.attributeValue("to")),
							info.elementTextTrim("reason"), message.getFrom());
					return;
				} else {
					// The sender is not an occupant of the room
					throw new NotAcceptableException();
				}
			}

			// Check senders address and reject conflicting packets
			if (!occupant.getUserAddress().equals(message.getFrom())) {
				throw new ConflictException();
			}

			// An occupant is trying to send a private message
			String resource = message.getTo().getResource();
			if (resource != null && resource.trim().length() > 0) {
				if (Message.Type.chat == message.getType()
						|| Message.Type.normal == message.getType()) {
					room.sendPrivatePacket(message, occupant);
					return;
				} else {
					throw new UnsupportedGameException();
				}
			}

			// Try to make a turn
			childElement = message
					.getChildElement("turn", MUGService.mugUserNS);
			if (childElement != null) {
				if (!occupant.hasRole())
					throw new ForbiddenException();

				Collection<Element> moves = childElement.elements();
				MUGMatch match = room.getMatch();

				if (moves == null || moves.size() == 0)
					throw new IllegalArgumentException();

				if (match.getStatus() != MUGMatch.Status.active)
					throw new NotAcceptableException();

				try {
					match.processTurn(occupant, moves);
				} catch (InvalidTurnException e) {
					try {
						// Create and send an application specific error
						PacketError error = new PacketError(
								Condition.undefined_condition, Type.cancel);
						error.setApplicationCondition("invalid-turn",
								MUGService.mugNS);
						sendErrorPacket(message, error);

						// Create and broadcast the specific unavailable
						// presence
						Presence presence = new Presence(
								Presence.Type.unavailable);
						presence.addChildElement("invalid-turn",
								MUGService.mugNS);
						occupant.setPresence(presence);
					} finally {
						occupants.remove(roomName);
						room.leave(occupant);
					}
				}
				return;
			}

			// Try to start or continue the match
			childElement = message.getChildElement("start",
					MUGService.mugUserNS);
			if (childElement != null) {
				room.startMatch(occupant);
				return;
			}

			// leave the match
			childElement = message.getChildElement("leave",
					MUGService.mugUserNS);
			if (childElement != null) {
				room.leave(occupant);
				occupants.remove(occupant);
				return;
			}

			// Try to invite or decline an invitation
			childElement = message
					.getChildElement("game", MUGService.mugUserNS);
			if (childElement != null) {
				if (childElement.element("invite") != null) {
					if (!room.canOccupantsInvite()
							&& occupant.getAffiliation() != Affiliation.owner)
						throw new CannotBeInvitedException();

					// Send invitations to invitee
					for (Iterator it = childElement.elementIterator("invite"); it
							.hasNext();) {
						Element invite = (Element) it.next();

						// Add the user as a member of the room if the room is
						// members only
						if (room.isMembersOnly()) {
							room.addMember(
									new JID(invite.attributeValue("to")),
									occupant);
						}

						// Send the invitation to the invitee
						room.invite(new JID(invite.attributeValue("to")),
								invite.elementTextTrim("reason"), occupant);
					}
				}
				if (childElement.element("decline") != null) {
					// Try to reject an invitation
					Element info = childElement.element("decline");
					room.sendInvitationRejection(
							new JID(info.attributeValue("to")),
							info.elementTextTrim("reason"), message.getFrom());
				}
			}
		}
	}

	/**
	 * This method handles an {@see IQ} requests sent to a {@see MUGRoom}
	 * whithin the owner namespace or to a {@see MUGOccupant}.
	 * 
	 * @param iq
	 *            The XMPP stanza which should be handled.
	 * @throws ComponentException
	 */
	protected void process(IQ iq) throws ComponentException {
		/*
		 * Handle IOs whith childs: - <save xmlns='...#owner'> -> save room -
		 * <load xmlns='...#owner'> -> load room - <newMatch xmlns='...#owner'>
		 * -> create room all others (config, memberlist, transfer owner): ->
		 * room iqOwnerhandler
		 */
		JID recipient = iq.getTo();
		String roomName = recipient.getNode();

		Element childElement = iq.getChildElement();

		MUGOccupant occupant = roomName != null ? occupants.get(roomName)
				: null;

		// Try to send a private message
		if (recipient.getResource() != null
				&& recipient.getResource().trim().length() > 0) {
			// Try to send a private message
			if (occupant != null) {
				// Verify occupant
				if (!occupant.getUserAddress().equals(iq.getFrom()))
					throw new ConflictException();

				occupant.getGameRoom().sendPrivatePacket(iq, occupant);
				return;
			} else {
				// The sender is not an occupant of the room
				throw new NotAcceptableException();
			}
		}

		// Ignore IQs of type result or error
		if ((IQ.Type.result == iq.getType()) || (IQ.Type.error == iq.getType())) {
			return;
		}

		// Check child element and namespace
		if (childElement == null
				|| (!MUGService.mugOwnerNS.equals(childElement
						.getNamespaceURI()) && !MUGService.mugNS
						.equals(childElement.getNamespaceURI()))) {
			// No idea what to do with this packet
			throw new UnsupportedGameException();
		}

		boolean foundOwnerNS = MUGService.mugOwnerNS.equals(childElement
				.getNamespaceURI());

		if (!foundOwnerNS 
				&& !("game".equals(childElement.getName())) 
				&& !("gamedata".equals(childElement.getName()))
				&& !("register".equals(childElement.getName()))) {
			throw new NotAllowedException();
		}

		IQ reply = IQ.createResultIQ((IQ) iq);

		if (occupant == null) {
			// assign a game room if the user is requesting for one
			if (!foundOwnerNS) {
				
				if ("game".equals(childElement.getName())) {
					String gameNS = childElement.attributeValue("gameId");
					if (gameNS == null) {
						throw new NotFoundException();
					}
					Element itemElement = null;
					 if (null != (itemElement = childElement.element("item"))) {
						String role = itemElement.attributeValue("role");
						String nick = itemElement.attributeValue("nick");
	
						MUGRoom room = assignRoom(gameNS, nick, jid, role);
						if (room != null) {
							reply.setFrom(room.getJID());
							mugManager.sendPacket(component, reply);
						} else {
							throw new NotFoundException();
						}
					}
				} else if ("gamedata".equals(childElement.getName())) {
					
					String gameNS = childElement.attributeValue("gameId");
					if (gameNS == null) {
						throw new NotFoundException();
					}
					Element gameElement = DocumentHelper.createElement(QName.get(
							"gamedata", MUGService.mugNS));
					gameElement.addAttribute("gameId", gameNS);
					if (null != childElement.element("userdata")) {
						Element userDataElement = childElement.element("userdata");
						//if "get" query then return data
						String propertyName = "game:"+gameNS;
						String username = iq.getFrom().getNode();
						MUGProperty property = null;
						if (iq.getType() == IQ.Type.get) {
							try {
								property = component.getPersistenceProvider().getUserProperty(username, propertyName);							
							} catch (Exception ex) {
								log.info("Cannot find user data for user:"+username + ", propertyName:"+propertyName+".", ex);
								throw new ComponentException("failed to service request", ex);
							}
						} else if (iq.getType() == IQ.Type.set) {
							String userData = userDataElement.getTextTrim();
							try {
								property = component.getPersistenceProvider().setUserProperty(username, propertyName, userData);
							} catch (Exception ex) {
								log.info("Cannot find user data for user:"+username + ", propertyName:"+propertyName+".", ex);
								throw new ComponentException("failed to service request", ex);
							}
						}
						Element userdataElem = gameElement.addElement("userdata");
						
						if (property != null) {
							userdataElem.add(DocumentHelper.createCDATA(property.getValue()));
							userdataElem.addAttribute("version", Integer.toString(property.getVersion()));
						}
							
						reply.setChildElement(gameElement);
						mugManager.sendPacket(component, reply);
					}
					else if (null != childElement.element("matchdata")) {
						Element matchdataElement = gameElement.addElement("matchdata");
						List<MUGRoom> rooms = component.getGameRooms(gameNS, jid);
						for(MUGRoom room : rooms) {
							Element matchElement = matchdataElement.addElement("match");
							matchElement.addAttribute("matchId", room.getJID().toBareJID());
							matchElement.addElement("status").setText(room.getMatch().getStatus().name());
							
							Element matchState = room.getMatch().getState();
							if (matchState != null)
								matchElement.add(matchState.createCopy());
						}
						
						reply.setChildElement(gameElement);
						mugManager.sendPacket(component, reply);
					}
				}
				else if ("register".equals(childElement.getName())) {
				//	if ("turnbased".equals(childElement.attributeValue("type"))) {
						GenericTurnBasedMUG mug = new GenericTurnBasedMUG(
								mugManager, childElement);
						if (mugManager.isGameRegistered(mug.getNamespace())) {
							throw new NotAllowedException(
									"A game is already registered under the namespace '"
											+ mug.getNamespace() + "'");
						}
						mugManager.registerMultiUserGame(mug.getNamespace(),
								mug);
						Element gameElem = DocumentHelper.createElement(QName
								.get("register", MUGService.mugNS));
					//	gameElem.addAttribute("retcode", "success");
						gameElem.addAttribute("gameId", mug.getNamespace());
						reply.setChildElement(gameElem);
						mugManager.sendPacket(component, reply);
						/*
					} else {
						throw new NotAllowedException(
								"Only turnbased games can be created using IQ set");
					}
					*/
					return;
				}
				return;
			}

			// create a new game room and use the provided configuration to
				// configure it
			
			if ("game".equals(childElement.getName())) {
				String gameNS = childElement.attributeValue("gameId");

				MUGRoom room = component.createGameRoom(gameNS, jid);
				if (childElement.element("room") != null) {
					room.setOptions(childElement.element("room"));
				}
				if (childElement.element("match") != null) {
					List<Element> l = new ArrayList<Element>();
					l.add(childElement.element("match"));
					room.getMatch().setConfiguration(l);
				}

				reply.setFrom(room.getJID());
				mugManager.sendPacket(component, reply);
				return;
			} else if ("load".equals(childElement.getName())) {
				// TODO: Implement loading a game room
				throw new UnsupportedGameException();
			} else {
				// The sender is not an occupant of the room
				throw new NotAcceptableException();
			}
		}

		// Check senders address and reject conflicting packets
		if (!occupant.getUserAddress().equals(iq.getFrom())) {
			throw new ConflictException();
		}

		if ("save".equals(childElement.getName())) {
			// TODO: Implement saving a game room
			throw new UnsupportedGameException();
		} else {
			// Another request within the owner namespace
			occupant.getGameRoom().handleOwnerIQ(iq, occupant);
		}
	}

	private MUGRoom assignRoom(String gamens, String nick, JID jid,
			String requestedRole) throws ComponentException {

		for (MUGRoom room : component.getGameRoomsByGame(gamens)) {
			synchronized (room) {
				if (!room.isMembersOnly()
						&& !room.isPasswordProtected()
						&& !room.isLocked()
						&& !MUGMatch.Status.completed.equals(room.getMatch()
								.getStatus()) && !room.isOccupant(jid)
						&& room.getMatch().getFreeRoles().size() > 0) {
					if (requestedRole == null || requestedRole.isEmpty()) {
						String freeRole = room.getMatch().holdFreeRole(jid);
						if (freeRole != null)
							return room;
					} else {
						if (room.getMatch().holdRole(requestedRole, jid))
							return room;
					}
				}
			}
		}
		return null;
	}

	/**
	 * This method handles a {@see Presence} packets send to a {@see MUGRoom} or
	 * {@see MUGOccupant}. This can be creating or joining a game room, changing
	 * the nickname, reserve a role, resignation or leaving a game room.
	 * 
	 * @param presence
	 *            The XMPP stanza which should be handled.
	 */
	protected void process(Presence presence) throws ComponentException {
		JID recipient = presence.getTo();
		String roomName = (recipient != null) ? recipient.getNode() : null;

		// Ignore Presence sending to the service
		if (roomName == null) {
			return;
		}

		MUGRoom room = component.getGameRoom(roomName);
		if (room == null) {
			throw new NotFoundException();
		}

		synchronized (room) {
			MUGOccupant occupant = occupants.get(roomName);

			// request to join or rejoin a game room
			if (occupant == null) {
				if (recipient.getResource() != null
						&& recipient.getResource().trim().length() > 0) {
					if (presence.isAvailable()) {

						// get the game element
						Element gameElement = presence.getChildElement("game",
								MUGService.mugNS);
						if (gameElement == null)
							throw new IllegalArgumentException();

						Element roleElement = gameElement.element("item");
						// check if the user is already an occupant
						occupant = room.getOccupant(jid);
						if (occupant != null) {
							processRoleElement(roleElement, occupant);
							room.rejoin(occupant, presence);
							occupants.put(roomName, occupant);
							return;
						}

						// extract the game namespace
						// String gameNS = gameElement.attributeValue("gameId");
						// if (gameNS == null)
						// throw new IllegalArgumentException();

						boolean acquireRole = roleElement != null;
						String requestedRole = "";
						if (acquireRole)
							requestedRole = roleElement.attributeValue("role");

						boolean roleAcquired = false;
						if (acquireRole) {
							if (requestedRole != null
									&& !requestedRole.isEmpty()) {
								roleAcquired = room.getMatch().holdRole(
										requestedRole, jid);
							} else {
								requestedRole = room.getMatch().holdFreeRole(
										jid);
								roleAcquired = requestedRole != null
										&& !requestedRole.isEmpty();
							}
							if (!roleAcquired) {
								throw new ConflictException();
							}
						}
						/*
						 * } else { // if room is not specified then try to
						 * automatch the user to an existing room room =
						 * assignRoom(gameNS, recipient.getResource(),
						 * requestedRole); if (room != null) { acquireRole =
						 * true; roleAcquired = true; roomName = room.getName();
						 * } else { throw new NotFoundException(); } }
						 */

						String password = gameElement.element("password") != null ? gameElement
								.elementTextTrim("password") : null;

						occupant = room.join(recipient.getResource(), password,
								jid, presence, acquireRole);

						occupants.put(roomName, occupant);
					} else {
						// Ignore unavailable presence since we aren't in the
						// room
					}
				} else {
					if (presence.isAvailable()) {
						// A resource is required in order to join a room
						sendErrorPacket(presence,
								PacketError.Condition.bad_request);
					}
					// Ignore unavailable presence since we aren't in the room
				}
				return;
			}

			// Check senders address and reject conflicting packets
			if (!occupant.getUserAddress().equals(presence.getFrom())) {
				throw new ConflictException();
			}

			// mark the occupant as offline
			if (Presence.Type.unavailable.equals(presence.getType())) {
				if (occupant.hasRole()) {
					room.markOffline(occupant);
				} else {
					room.leave(occupant);
				}
				occupants.remove(roomName);
				return;
			}

			// Get resource
			String resource = null;
			if (recipient.getResource() != null
					&& recipient.getResource().trim().length() > 0)
				resource = recipient.getResource().trim();

			// Try to set new presence status
			if (resource == null
					|| occupant.getNickname().equalsIgnoreCase(resource)) {
				Element matchElement = presence.getChildElement("game",
						MUGService.mugNS);
				if (matchElement != null) {
					processRoleElement(matchElement.element("item"), occupant);
				}

				// Occupant has changed his presence status
				occupant.setPresence(presence);
				occupant.getGameRoom().broadcastPresence(occupant);
				occupant.send(occupant.getPresence());
			} else {
				// Try to change nickname
				occupant = occupant.getGameRoom().changeNickname(jid,
						occupant.getNickname(), resource, presence);
				// Refresh the occupant object
				occupants.remove(roomName);
				occupants.put(roomName, occupant);
			}
		}
	}

	private void processRoleElement(Element roleElement, MUGOccupant occupant) {
		boolean acquireRole = roleElement != null;

		if (acquireRole) {
			String roleName = roleElement.attributeValue("role");
			if (roleName == null)
				roleName = "";
			String currentRoleName = occupant.getRoleName();
			if (currentRoleName == null)
				currentRoleName = "";
			if (currentRoleName.isEmpty()) {
				// user is requesting a role
				if (!roleName.isEmpty()) {
					String assignedRole = occupant.getGameRoom().getMatch()
							.reserveFreeRole(occupant);
					if (assignedRole == null) {
						throw new ConflictException();
					}
				} else
					occupant.getGameRoom().getMatch()
							.reserveRole(occupant, roleName);
			} else if (!roleName.isEmpty() && !currentRoleName.equals(roleName)) {
				throw new UnsupportedGameException();
			}
		}
	}
}
