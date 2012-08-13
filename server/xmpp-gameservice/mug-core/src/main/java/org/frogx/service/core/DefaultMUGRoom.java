/**
 * DefaultMUGRoom - A Multi-User Gaming room.
 * Some parts are inspired by the LocalMUCRoom of the Openfire XMPP
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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

import org.dom4j.DocumentFactory;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGMatch.Status;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.MultiUserGame.RoleConfig;
import org.frogx.service.api.exception.CannotBeInvitedException;
import org.frogx.service.api.exception.ConflictException;
import org.frogx.service.api.exception.ForbiddenException;
import org.frogx.service.api.exception.GameConfigurationException;
import org.frogx.service.api.exception.NotFoundException;
import org.frogx.service.api.exception.RequiredPlayerException;
import org.frogx.service.api.exception.RoomLockedException;
import org.frogx.service.api.exception.ServiceUnavailableException;
import org.frogx.service.api.exception.UnauthorizedException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.frogx.service.api.exception.UserAlreadyExistsException;
import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.core.iq.IQNonFormOwnerHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.forms.FormField;
import org.xmpp.packet.IQ;
import org.xmpp.packet.JID;
import org.xmpp.packet.Message;
import org.xmpp.packet.Packet;
import org.xmpp.packet.Presence;
import org.xmpp.packet.Presence.Type;

/**
 * The first implementation of a {@see MUGRoom}.
 * A game room manages its occupants, sends game moves, invitations,
 * presence information,...
 * 
 */
public class DefaultMUGRoom implements MUGRoom {
	
	private static final Logger log = LoggerFactory.getLogger(DefaultMUGRoom.class);
	
	/**
	 * This represents the privacy type of a {@see MUGRoom}.
	 * 
	 * @author G&uuml;nther Nie&szlig;
	 *
	 */
	public enum Anonymity {
		
		/**
		 * The real JID of an occupant is exposed to each other.
		 */
		nonAnonymous,
		
		/**
		 * Only the room owner can see the real JID of an occupant.
		 */
		semiAnonymous, 
		
		/**
		 * Nobody is allowed to get the real JID of an occupant.
		 */
		fullyAnonymous;
	}
	
	/**
	 * The service hosting the room.
	 */
	private MUGService mugService;
	
	/**
	 * The ComponentManager provides a logging utility, localized Strings
	 *  and allows to send XML stanzas.
	 */
	private MUGManager mugManager;
	
	private LocaleUtil locale;
	
	/**
	 * The game which can be played in this room
	 */
	MultiUserGame game;
	
	/**
	 * The running match represents the game logic and game state.
	 */
	MUGMatch match;
	
	/**
	 * The name of the room which is used in the JID address of the room.
	 */
	private String name;
	
	/**
	 * The natural language name of the room.
	 */
	private String naturalLanguageName;
	
	/**
	 * Description of the room.
	 * The owner can change the description using the room configuration form.
	 */
	private String description;
	
	/**
	 * A public room means that the room is searchable and visible.
	 * This means that the room can be located using disco or search requests.
	 */
	private boolean publicRoom;
	
	/**
	 * Moderated rooms enables the owner to kick users, revoke roles
	 * and save and reload the match.
	 */
	private boolean moderated;
	
	/**
	 * In a member-only room a user cannot enter without being on the member list.
	 * This can be done by inviting the user to a room.
	 */
	private boolean membersOnly;
	
	/**
	 * A List of bare JIDs, that are game room's members.
	 */
	private List<String> members = new ArrayList<String>();
	
	/**
	 * The privacy type of this room.
	 * This describes who is able to see the occupants real JIDs.
	 */
	private Anonymity anonymity;
	
	/**
	 * Some rooms may restrict the occupants that are able to send invitations.
	 * Sending an invitation in a members-only room adds the invitee to the members list.
	 */
	private boolean canOccupantsInvite;
	
	/**
	 * This describes if the room occupants are public available via a disco items query.
	 */
	private boolean canDiscoverOccupants;
	
	/**
	 * The password that every occupant should provide in order to enter the room.
	 */
	private String password = null;
	
	/**
	 * The max. number of occupants who are able to join the room.
	 */
	private int maxOccupants;
	
	/**
	 * The occupants of the room accessible by the occupants nickname.
	 */
	private Map<String,MUGOccupant> occupants = new HashMap<String, MUGOccupant>();
	
	/**
	 * A list of the occupants nicknames who want to start the match.
	 */
	private List<String> startMatch = new ArrayList<String>();
	
	/**
	 * The bare JID of the room owner.
	 */
	private String owner;
	
	private int nextAvailableInRoomId = 0;
	
	/**
	 * The IQ handler for the owner namespace.
	 * It helps to configure the room.
	 */
	private IQNonFormOwnerHandler iqOwnerHandler;
	
	private static AtomicLong roomIdGen = new AtomicLong();
	
	private String createRoomName(MultiUserGame game) {
		return "room" + roomIdGen.incrementAndGet();
		/*
		try {
			// token is a 256-bit base64 encoded random string
			SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
			byte[] bytes = new byte[256 / 8];
			random.nextBytes(bytes);
			return new String(Base64.encodeBase64(bytes), Charset.forName("US-ASCII"));
		} catch (Exception e) {
			log.error("Got exception creating name for a game room. Exception details are:", e);
			throw new RuntimeException("Failed to create name for a game room");
		}
		*/
	}
	
	/**
	 * Create a game room.
	 * 
	 * @param service The {@see MUGService} which hosts this room.
	 * @param componentManager A {@see ComponentManager} provides a utility for sending 
	 *         packages and logging.
	 * @param game A {@see MultiUserGame} which can be played within the room.
	 * @param creator The {@see JID} of the user who is creating this room.
	 */
	public DefaultMUGRoom(MUGService service, 
			MUGManager mugManager, MultiUserGame game, JID creator) {
		this.mugService = service;
		this.mugManager = mugManager;
		this.locale = mugManager.getLocaleUtil();
		String roomName = createRoomName(game);
		this.name = roomName;
		this.naturalLanguageName = roomName;
		this.description = roomName;
		this.game = game;
		this.owner = creator.toBareJID();
		this.iqOwnerHandler = new IQNonFormOwnerHandler(service, mugManager, this);
		loadDefaultValues();
		
		this.match = game.createMatch(this);
		
		log.debug(locale.getLocalizedString("mug.room.debug.create") + game.getGameID().getNamespace() + "/" + roomName);
	}
	
	public void destroy() {
		if (match != null)
			game.destroyMatch(this);
		match = null;
		game = null;
		name = null;
		description = null;
		password = null;
		if (occupants != null)
			occupants.clear();
		mugManager = null;
	}
	
	public void setOptions(Element roomOptions) {
		if (roomOptions != null) {
			if (roomOptions != null) {
				setModerated(Boolean.valueOf(roomOptions.elementText("moderated")));
				setAllowInvites(Boolean.valueOf(roomOptions.elementText("allowInvites")));
				setMaxOccupants(Integer.valueOf(roomOptions.elementText("maxUsers")));
				setPublicRoom(Boolean.valueOf(roomOptions.elementText("publicRoom")));
				setMembersOnly(Boolean.valueOf(roomOptions.elementText("membersOnly")));
				
				String anonymity = roomOptions.elementText("anonymity");
				if ("fully-anonymous".equals(anonymity)) {
					setAnonymity(Anonymity.fullyAnonymous);
				} else if ("non-anonymous".equals(anonymity)) {
					setAnonymity(Anonymity.nonAnonymous);
				} else if ("semi-anonymous".equals(anonymity)) {
					setAnonymity(Anonymity.semiAnonymous);
				}
				
				
				setPassword(roomOptions.elementText("secret"));

				setModerated(Boolean.valueOf(roomOptions.elementText("moderated")));
				setModerated(Boolean.valueOf(roomOptions.elementText("moderated")));
				setModerated(Boolean.valueOf(roomOptions.elementText("moderated")));
			}
		}
	}
	
	public Element getOptions() {
		Element roomConfig = DocumentHelper.createElement(QName.get("room",
				MUGService.mugNS + "#owner"));
		
		roomConfig.addElement("moderated").setText(String.valueOf(isModerated()));
		roomConfig.addElement("allowInvites").setText(String.valueOf(canOccupantsInvite()));
		roomConfig.addElement("maxUsers").setText(String.valueOf(getMaxOccupants()));
		roomConfig.addElement("publicRoom").setText(String.valueOf(isPublicRoom()));
		roomConfig.addElement("membersOnly").setText(String.valueOf(isMembersOnly()));
		
		Element anonymity = roomConfig.addElement("anonymity");
		if (isFullyAnonymous())
			anonymity.setText("fully-anonymous");
		else if (isNonAnonymous())
			anonymity.setText("non-anonymous");
		else
			anonymity.setText("semi-anonymous");

	//	roomConfig.addElement("passwordProtected").setText(String.valueOf(room.isPasswordProtected()));
		if (isPasswordProtected())
			roomConfig.addElement("secret").setText(String.valueOf(getPassword()));
		
		return roomConfig;
	}
	
	public String getName() {
		return name;
	}
	
	public MUGService getMUGService() {
		return mugService;
	}
	
	public JID getJID() {
		return new JID(getName(), getMUGService().getAddress().getDomain(), null);
	}
	
	public MultiUserGame getGame() {
		return game;
	}
	
	public MUGMatch getMatch() {
		return match;
	}
	
	public Collection<MUGOccupant> getOccupants() {
		return Collections.unmodifiableCollection(occupants.values());
	}
	
	public String getNaturalLanguageName() {
		return naturalLanguageName;
	}
	
	public String getDescription() {
		return description;
	}
	
	public boolean isLocked() {
		return match.getStatus() == MUGMatch.Status.created;
	}
	
	public boolean isPasswordProtected() {
		return password != null && password.trim().length() > 0;
	}
	
	public String getPassword() {
		return password;
	}
	
	public boolean isMembersOnly() {
		return membersOnly;
	}
	
	public boolean isModerated() {
		return moderated;
	}
	
	public boolean isPublicRoom() {
		return publicRoom;
	}
	
	public boolean isNonAnonymous() {
		return (anonymity == Anonymity.nonAnonymous);
	}
	
	public boolean isSemiAnonymous() {
		return (anonymity == Anonymity.semiAnonymous);
	}
	
	public boolean isFullyAnonymous() {
		return (anonymity == Anonymity.fullyAnonymous);
	}
	
	public boolean canOccupantsInvite() {
		return canOccupantsInvite;
	}
	
	public boolean canDiscoverOccupants() {
		return (!isLocked() && canDiscoverOccupants);
	}
	
	public JID getOwner() {
		return new JID(owner);
	}
	
	public int getMaxOccupants() {
		return maxOccupants;
	}
	
	public int getOccupantsCount() {
		return occupants.size();
	}
	
	public int getPlayersCount() {
		return match.getPlayers().size();
	}
	
	public Collection<String> getExtraFeatures() {
		// We don't have additional disco features
		return null;
	}
	
	public Collection<FormField> getExtraExtendedDiscoFields() {
		// We don't have additional extended disco fields
		return null;
	}
	
	public String getUID() {
		return getJID().toString();
	}
	
	/**
	 * Load the default room configuration.
	 */
	protected void loadDefaultValues() {
		//TODO: Read a adjustable default room configuration from DB
		canDiscoverOccupants = true;
		canOccupantsInvite = true;
		maxOccupants = 20;
		membersOnly = false;
		moderated = false;
		publicRoom = true;
		anonymity = Anonymity.semiAnonymous;
	}
	
	protected Presence getPresence() {
		Presence presence = new Presence();
		presence.setFrom(getJID());
		Element game = presence.addChildElement("game", MUGService.mugNS);
		Element statusElement = game.addElement("status");
		statusElement.addText(match.getStatus().name());
		if (match == null || match.getState() == null) {
			if (match == null)
				log.warn("[MUG] No match in room " + getJID() + "!");
			if (match.getState() == null)
				log.debug("[MUG] No game state available in room " + getJID());
		}
		else
			game.add(match.getState().createCopy());
		
		return presence;
	}
	
	protected void resetStartMatch() {
		startMatch.clear();
	}
	
	protected void sendBroadcastPacket(Packet packet, MUGOccupant sender) throws ComponentException {
		packet.setFrom(sender.getRoomAddress());
		
		for (MUGOccupant recipient : occupants.values()) {
			recipient.send(packet);
		}
	}
	
	private void onlyOwner(JID user) throws ForbiddenException {
		// Check Permissions: only owners, admins or the MUG service are ok
		if (!mugService.getAdmins().contains(user.toBareJID()) && 
				!owner.equals(user.toBareJID()) &&
				!getJID().equals(user))
			throw new ForbiddenException();
	}
	
	/**
	 * Set a human readable name of this room.
	 *
	 * @param name the human readable name of this room.
	 */
	public void setNaturalLanguageName(String name) {
		naturalLanguageName = name;
	}
	
	public void setAllowInvites(boolean canOccupantsInvite) {
		this.canOccupantsInvite = canOccupantsInvite;
	}
	
	public void setMembersOnly(boolean membersOnly) {
		this.membersOnly = membersOnly;
	}
	
	public void setMUGService(MUGService service) {
		this.mugService = service;
	}
	
	public void setPassword(String password) {
		this.password = password;
	}
	
	public void setPublicRoom(boolean publicRoom) {
		this.publicRoom = publicRoom;
	}
	
	public void setModerated(boolean moderated) {
		this.moderated = moderated;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public void setMaxOccupants(int maxOccupants) {
		this.maxOccupants = maxOccupants;
	}
	
	/**
	 * Set the privacy type of this room.
	 * 
	 * @param anonymity describes who can see the real JID of occupants.
	 */
	public void setAnonymity(Anonymity anonymity) {
		this.anonymity = anonymity;
	}
	
	public void addMember(JID newMember, MUGOccupant occupant) throws ForbiddenException {
		onlyOwner(occupant.getUserAddress());
		
		String bareJID = newMember.toBareJID();
		if (!members.contains(bareJID))
			members.add(bareJID);
	}
	
	public boolean isOccupant(JID jid) {
	//	return occupants.containsKey(nick) && occupants.get(nick).getUserAddress().toBareJID().equals(jid.toBareJID());
		return occupants.containsKey(jid.toBareJID());
	}
	
	public MUGOccupant getOccupant(JID jid) {
		if (isOccupant(jid)) {
			return occupants.get(jid.toBareJID());
		}
		return null;
	}
	

	public void broadcastPresence(MUGOccupant occupant) {
		/** 
		 * TODO: handle when occupant is unavailable
		 */
		Presence presence = occupant.getPresence().createCopy();
		for (MUGOccupant otherOccupant: occupants.values() ) {
			if (!otherOccupant.isAvailable())
				continue;
			if (otherOccupant.equals(occupant))
				continue;
			try {
				// In semi-anonymous rooms we must add the real JID for room owners
				if ((anonymity == Anonymity.semiAnonymous) && 
						MUGOccupant.Affiliation.owner.equals(otherOccupant.getAffiliation())) {
					Presence extPresence = presence.createCopy();
					Element frag = extPresence.getChildElement("game", MUGService.mugNS);
					frag.element("item").addAttribute("jid", occupant.getUserAddress().toBareJID());
					otherOccupant.send(extPresence);
				}
				else {
					otherOccupant.send(presence);
				}
			}
			catch (ComponentException e) {
				log.error(locale.getLocalizedString("mug.room.error.presence")
						+ otherOccupant.getUserAddress(), e);
			}
		}
	}
	
	public void broadcastRoomPresence() {
		Packet roomPresence = getPresence();
		for (MUGOccupant recipient : occupants.values()) {
			try {
				log.info("sending room presence. room="+getJID()+",recipient="+recipient.getNickname());
				recipient.send(roomPresence);
			} catch (ComponentException e) {
				log.error(locale.getLocalizedString("mug.room.error.presence")
						+ recipient.getUserAddress(), e);
			}
		}
	}
	
	public void broadcastTurn(Collection<Element> moves, MUGOccupant sender) throws ComponentException {
		Element rawMessage = DocumentFactory.getInstance().createDocument().addElement("message");
		Element turn = rawMessage.addElement("turn", MUGService.mugNS + "#user");
		
		if (moves != null) {
			for (Element move : moves) {
				move.setParent(null);
				turn.add(move);
			}
		}
			
		Message message = new Message(rawMessage, false);
		sendBroadcastPacket(message, sender);
	}
	
	public void broadcastTurn(Collection<Element> moves, MUGOccupant sender, String role) throws ComponentException {
		Element rawMessage = DocumentFactory.getInstance().createDocument().addElement("message");
		Element turn = rawMessage.addElement("turn", MUGService.mugNS + "#user");
		turn.addAttribute("role", role);
		
		if (moves != null) {
			for (Element move : moves) {
				move.setParent(null);
				turn.add(move);
			}
		}
			
		Message message = new Message(rawMessage, false);
		sendBroadcastPacket(message, sender);
	}
	
	public MUGOccupant changeNickname(JID userJID, String oldNick, String newNick, Presence newPresence) throws NotFoundException,
			ConflictException {
		MUGOccupant occupant = occupants.get(userJID.toBareJID());
		
		if (occupant == null)
			throw new NotFoundException();
		
		if (occupants.containsKey(newNick.toLowerCase()))
			throw new ConflictException();
		
		/*
		// Refresh start counter
		if (startMatch.contains(oldNick.toLowerCase())) {
			startMatch.remove(oldNick.toLowerCase());
			startMatch.add(newNick.toLowerCase());
		}
		
		// Submit changing
		occupants.remove(oldNick.toLowerCase());
		occupants.put(newNick.toLowerCase(), occupant);
		*/
		occupant.changeNickname(newNick);
		
		// Update presence
		if (newPresence != null)
			occupant.setPresence(newPresence);
		
		// Inform the occupants about the change
		Presence presence = occupant.getPresence().createCopy();
		presence.setFrom(new JID(getName(), mugService.getDomain(), oldNick));
		Element gameElement = presence.getChildElement("game", MUGService.mugNS);
		Element item = gameElement.element("item");
		item.addAttribute("nick", newNick);
		for (MUGOccupant otherOccupant: occupants.values() ) {
			// In semi-anonymous rooms we must add the real JID for room owners
			if ((anonymity == Anonymity.semiAnonymous) && 
					MUGOccupant.Affiliation.owner.equals(otherOccupant.getAffiliation())) {
				gameElement.element("item").addAttribute("jid", occupant.getUserAddress().toBareJID());
			}
			try {
				otherOccupant.send(presence);
			}
			catch (ComponentException e) {
				log.error(locale.getLocalizedString("mug.room.error.presence")
						+ otherOccupant.getUserAddress(), e);
			}
		}
		return occupant;
	}
	
	public void handleOwnerIQ(IQ iq, MUGOccupant occupant) throws ForbiddenException, 
			IllegalArgumentException, GameConfigurationException, UnsupportedGameException {
		iqOwnerHandler.handleIQ(iq, occupant);
	}
	
	public void invite(JID recipient, String reason, MUGOccupant invitor) throws ForbiddenException, 
			CannotBeInvitedException {
		if (canOccupantsInvite() || MUGOccupant.Affiliation.owner.equals(invitor.getAffiliation())) {
			Message message = new Message();
			message.setFrom(getJID());
			message.setTo(recipient);
			
			Element gameElement = message.addChildElement("game", MUGService.mugNS + "#user");
			Element invite = gameElement.addElement("invited");
			invite.addAttribute("var", game.getGameID().getNamespace());
			if (invitor.getUserAddress() != null) {
				invite.addAttribute("from", invitor.getUserAddress().toBareJID());
			}
			if (reason != null && reason.length() > 0) {
				invite.addElement("reason").setText(reason);
			}
			if (isPasswordProtected()) {
				gameElement.addElement("password").setText(getPassword());
			}
			
			try {
				// TODO: Remove debug output
				log.debug("[MUG]: Sending: " + message.toXML());
				
				mugManager.sendPacket(mugService, message);
			}
			catch (Exception e) {
				log.error(locale.getLocalizedString("mug.room.error.invite"), e);
				throw new CannotBeInvitedException();
			}
		}
		else {
			throw new ForbiddenException();
		}
	}
	
	public MUGOccupant join(String nick, String passwd, JID fullJID, Presence presence) throws
	ServiceUnavailableException, RoomLockedException, UserAlreadyExistsException,
	UnauthorizedException, ForbiddenException, ComponentException {
		return join(nick, passwd, fullJID, presence, false);
	}
	
	public MUGOccupant join(String nick, String passwd, JID fullJID, Presence presence, boolean acquireRole) throws
			ServiceUnavailableException, RoomLockedException, UserAlreadyExistsException,
			UnauthorizedException, ForbiddenException, ComponentException {
		
		DefaultMUGOccupant occupant = null;
		boolean isOwner = true;
		
		// Check permission
		try {
			onlyOwner(fullJID);
		}
		catch (ForbiddenException e) {
			isOwner = false;
		}
		
		// Check capacity
		if (getMaxOccupants() > 0 && 
				getOccupantsCount() >= getMaxOccupants() &&
				!isOwner)
			throw new ServiceUnavailableException();
		
		// Check if the room is locked
		if (isLocked()) {
			if (!isOwner) {
				throw new RoomLockedException();
			}
		}
		
		// Check if the nickname is already used in the room
		if (occupants.containsKey(fullJID.toBareJID())) {
			throw new UserAlreadyExistsException();
		}
		
		// Check password
		if (isPasswordProtected()) {
			if (password == null || !password.equals(getPassword())) {
				throw new UnauthorizedException();
			}
		}
		
		// Set affiliation
		MUGOccupant.Affiliation affiliation;
		if (isOwner) {
			affiliation = MUGOccupant.Affiliation.owner;
		}
		else if (members.contains(fullJID.toBareJID())) {
			affiliation = MUGOccupant.Affiliation.member;
		}
		else if (isMembersOnly()) {
			throw new ForbiddenException();
		}
		else {
			affiliation = MUGOccupant.Affiliation.none;
		}
		
		if (presence == null) {
			presence = new Presence();
			presence.setFrom(fullJID);
			presence.setTo(getJID());
		}
		// Add the new occupant
		occupant = new DefaultMUGOccupant(this, fullJID, nextAvailableInRoomId++, nick, affiliation, presence, mugManager, acquireRole);
		occupants.put(fullJID.toBareJID(), occupant);
		
		// Send presence of the room itself (room and match information)
		occupant.send(getPresence());
		
		// Send presence of existing occupants to new occupant
		for (MUGOccupant otherOccupant : occupants.values() ) {
			if (otherOccupant.equals(occupant))
				continue;
			// In semi-anonymous rooms we must add the real JID for room owners
			if ((anonymity == Anonymity.semiAnonymous) && isOwner) {
				Presence pres = otherOccupant.getPresence().createCopy();
				Element frag = pres.getChildElement("game", MUGService.mugNS);
				frag.element("item").addAttribute("jid", otherOccupant.getUserAddress().toBareJID());
				occupant.send(pres);
			}
			else {
				occupant.send(otherOccupant.getPresence());
			}
		}
		
		// Broadcast the presence of the new occupant
		broadcastPresence(occupant);
		
		// Confirm and welcome the new occupant by his presence in the room
		occupant.send(occupant.getPresence(true));
		
		
		return occupant;
	}
	
	public void rejoin(MUGOccupant occupant, Presence presence) throws ForbiddenException, ComponentException {
		
		// make sure user is the member of this room already
		if (occupants.get(occupant.getUserAddress().toBareJID()) == null) {
			throw new ForbiddenException();
		}
		
		occupant.setPresence(presence);
		
		// send room presence to the rejoined occupant
		occupant.send(getPresence());
		
		boolean isOwner = true;
		
		// Check permission
		try {
			onlyOwner(occupant.getUserAddress());
		}
		catch (ForbiddenException e) {
			isOwner = false;
		}
		
		// Send presence of existing occupants to rejoined occupant
		for (MUGOccupant otherOccupant : occupants.values() ) {
			if (otherOccupant.equals(occupant))
				continue;
			// In semi-anonymous rooms we must add the real JID for room owners
			if ((anonymity == Anonymity.semiAnonymous) && isOwner) {
				Presence pres = otherOccupant.getPresence().createCopy();
				Element frag = pres.getChildElement("game", MUGService.mugNS);
				frag.element("item").addAttribute("jid", otherOccupant.getUserAddress().toBareJID());
				occupant.send(pres);
			}
			else {
				occupant.send(otherOccupant.getPresence());
			}
		}
		
		// Broadcast the presence of the new occupant
		broadcastPresence(occupant);
		
		// Confirm and welcome the new occupant by his presence in the room
		occupant.send(occupant.getPresence());
	}
	
	public void sendPrivatePacket(Packet packet, MUGOccupant sender) throws NotFoundException, ComponentException {
		String barejid = packet.getTo().toBareJID();
		MUGOccupant occupant = occupants.get(barejid);
		if (occupant != null) {
			packet.setFrom(sender.getRoomAddress());
			occupant.send(packet);
		}
		else {
			throw new NotFoundException();
		}
	}
	
	public void sendInvitationRejection(JID recipient, String reason, JID sender) throws ComponentException {
		Message message = new Message();
		message.setFrom(getJID());
		message.setTo(recipient);
		Element frag = message.addChildElement("game", MUGService.mugNS + "#user");
		frag.addElement("declined").addAttribute("from", sender.toBareJID());
		if (reason != null && reason.length() > 0) {
			frag.element("declined").addElement("reason").setText(reason);
		}
		
		// TODO: Remove debug output
		log.debug("[MUG]: Sending: " + message.toXML());
		
		mugManager.sendPacket(mugService, message);
	}
	
	public void sendTurn(Collection<Element> moves, MUGOccupant sender, MUGOccupant recipient) throws ComponentException {
		Element rawMessage = DocumentFactory.getInstance().createDocument().addElement("message");
		Element turn = rawMessage.addElement("turn", MUGService.mugNS + "#user");
		
		if (moves != null) {
			for (Element move : moves) {
				move.setParent(null);
				turn.add(move);
			}
		}
			
		Message message = new Message(rawMessage, false);
		message.setFrom(sender.getRoomAddress());
		recipient.send(message);
	}
	
	public boolean startMatch(MUGOccupant occupant) throws RequiredPlayerException, 
			GameConfigurationException, ComponentException {
		//TODO: Make this robust against changing roles or nicknames
		// if already started just return
		if (match != null && (match.getStatus() == Status.active || match.getStatus() == Status.completed))
			return true;
		
		boolean started = false;
		if (occupant.hasRole()) {
			// check if the user's role is allowed to start the match 
			// otherwise just ignore the start message
			RoleConfig rc = getGame().getRoleConfig(occupant.getRoleName());
			if (rc == null || rc.isNotAllowedToStart()) {
				return started;
			}
			
			if (!startMatch.contains(occupant.getUserAddress().toBareJID())) {
				startMatch.add(occupant.getUserAddress().toBareJID());
			}

			/*
			// If all players sent a start, try to start.
			if (getGame().isCorrespondence()) {
				resetStartMatch();
				match.start();
				started = true;
			} else {
			*/
			if (match != null && match.getPlayers() != null
					&& match.getPlayers().size() >= startMatch.size()
					&& startMatch.size() >= getGame().getMinPlayersForStart()) {
				resetStartMatch();
				match.start();
				started = true;
			}

			// Reflect Start Message to other players
			Message startMessage = new Message();
			startMessage.setFrom(occupant.getRoomAddress());
			startMessage.addChildElement("start", MUGService.mugNS + "#user");

			for (MUGOccupant player : match.getPlayers()) {
				if (player == occupant)
					continue;
				player.send(startMessage);
			}
			
		/*	} */
			// If the game has started, broadcast the room state
			if (started)
				broadcastRoomPresence();
			
			// send the start message to the sender finally
			occupant.send(startMessage);
		}
		else
			throw new ForbiddenException();
		
		return started;
	}
	
	public void markOffline(MUGOccupant occupant) {
		boolean hasRole = occupant.hasRole();
		
		if (occupant.getPresence().getType() != Type.unavailable)
			occupant.setPresence(new Presence(Type.unavailable));
		
		// we will inform all the occupants that the user has gone offline. this doesn't mean the user left the game
		broadcastPresence(occupant);
		
		// remove the occupant if he/she doesn't have a role
		if (!hasRole && occupants.containsKey(occupant.getUserAddress().toBareJID())) {
			occupants.remove(occupant.getUserAddress().toBareJID());
			occupant.destroy();
			occupant = null;
		}
	}
	
	public void leave(MUGOccupant occupant) {
		
		boolean hasRole = occupant.hasRole();
		MUGMatch.Status matchStateBefore = match.getStatus();
		
		// leave the match and inform the occupants about changes
		match.leave(occupant);
		// reflect the occupant left message to all other occupants
	//	broadcastPresence(occupant);
		// Reflect Start Message to other players
		Message leftMessage = new Message();
		leftMessage.setFrom(occupant.getRoomAddress());
		leftMessage.addChildElement("leave", MUGService.mugNS + "#user");

		for (MUGOccupant player : match.getPlayers()) {
			if (player == occupant) {
				continue;
			}
			try {
				player.send(leftMessage);
			} catch (Exception ex) {
				// TODO: unable to send message to a player.... handle this gracefully
			}
		}
		
		// inform occupants about the changing match status
		if (!matchStateBefore.equals(match.getStatus()))
			broadcastRoomPresence();

		if (occupant.getPresence().getType() != Type.unavailable)
			occupant.setPresence(new Presence(Type.unavailable));
		
		try {
			occupant.send(occupant.getPresence());
		}
		catch (ComponentException e) {
			log.error(locale.getLocalizedString("mug.room.error.leave"), e);
		}
		
		// remove the occupant
		if (occupants.containsKey(occupant.getUserAddress().toBareJID()))
			occupants.remove(occupant.getUserAddress().toBareJID());
		
		occupant.destroy();
		occupant = null;
		
		
		// reset start counter
	//	if (hasRole)
		//	resetStartMatch();
		
		// if he was the last, remove the room
		if (occupants.size() == 0) {
			mugService.removeGameRoom(name);
		}
	}

	public void abortMatch() {
		log.info("aborting match associated with room="+getJID());
		MUGMatch.Status beforeStatus = getMatch().getStatus();
		getMatch().abort();
		log.info("match aborted. room="+getJID());
		MUGMatch.Status afterStatus = getMatch().getStatus();
		if (!afterStatus.equals(beforeStatus)) {
			log.info("room status changed to "+afterStatus+". broadcasting new room presence to all occupants. room="+getJID());
			broadcastRoomPresence();
		}
	}

}
