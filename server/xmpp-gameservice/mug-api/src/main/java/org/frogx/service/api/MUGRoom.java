package org.frogx.service.api;

import java.util.Collection;

import org.dom4j.Element;
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
import org.xmpp.component.ComponentException;
import org.xmpp.forms.FormField;
import org.xmpp.packet.IQ;
import org.xmpp.packet.JID;
import org.xmpp.packet.Packet;
import org.xmpp.packet.Presence;
import org.xmpp.resultsetmanagement.Result;


/**
 * A game room on the Multi-User Gaming server manages its occupants, 
 * sends game moves, invitations, presence information,...
 *
 */
public interface MUGRoom extends Result {
	
	/**
	 * Get the name of this room. For example chess for the room
	 * chess@games.example.com.
	 *
	 * @return The name for this room.
	 */
	public String getName();
	
	/**
	 * Get the {@see MUGService} which is hosting the room.
	 *
	 * @return The {@see MUGService} instance which the room is attached to.
	 */
	public MUGService getMUGService();
	
	/**
	 * Get the {@see JID} of this room e.g. chess@games.example.com.
	 *
	 * @return the {@see JID} for this room.
	 */
	public JID getJID();
	
	/**
	 * Returns the {@see MultiUserGame} which can be played within the room.
	 * 
	 * @return The {@see MultiUserGame} of this room.
	 */
	public MultiUserGame getGame();
	
	/**
	 * Get the current {@see MUGMatch} which handels the game state and logic.
	 * 
	 * @return The current {@see MUGMatch} of this room.
	 */
	public MUGMatch getMatch();
	
	/**
	 * Obtain a collection of all {@see MUGOccupant}s in the game room.
	 *
	 * @return A collection with all occupants of this room
	 */
	public Collection<MUGOccupant> getOccupants();
	
	/**
	 * Get a human readable name of this room which was configured by the owner.
	 *
	 * @return The human readable name of this room.
	 */
	public String getNaturalLanguageName();
	
	/**
	 * Get a description of the game room.
	 *
	 * @return The description of the game room.
	 */
	public String getDescription();
	
	/**
	 * Returns true if the room is locked.
	 * No user is allowed to join or discover a locked room.
	 * 
	 * @return True if the room is locked otherwise false.
	 */
	public boolean isLocked();
	
	/**
	 * Returns true if a user cannot enter without first providing the correct password.
	 *
	 * @return True if a user need a password to join the room.
	 */
	public boolean isPasswordProtected();
	
	/**
	 * Returns the password that the user must provide to enter the room.
	 *
	 * @return The password of this room.
	 */
	public String getPassword();
	
	/**
	 * Returns true if a user cannot join the room without being on the member list.
	 * An invitation adds the receiver to the member list.
	 *
	 * @return True if the room is a members-only room.
	 */
	public boolean isMembersOnly();
	
	/**
	 * Returns true if the room owner is allowed to kick users,
	 * revoke roles amd save the match.
	 *
	 * @return True if the room is a moderated room.
	 */
	public boolean isModerated();
	
	/**
	 * Returns true if the room is visible through service discovery or jabber search.
	 * 
	 * @return True if the room is listed in a public directory.
	 */
	public boolean isPublicRoom();
	
	/**
	 * Returns true if it's a room in which an occupant's full {@see JID} is exposed to
	 * all other occupants.
	 * 
	 * @return True if the occupants {@see JID} is publicly available.
	 */
	public boolean isNonAnonymous();
	
	/**
	 * Returns true if it's a room in which an occupant's full {@see JID} can be
	 * discovered only by the room owner.
	 * 
	 * @return True if the occupants {@see JID} is only available for the room owner.
	 */
	public boolean isSemiAnonymous();
	
	/**
	 * Returns true if it's a room in which an occupant's full {@see JID} can't be
	 * discovered by anyone. This respects all occupants privacy.
	 * 
	 * @return True if the occupants {@see JID} can't be discovered by anyone.
	 */
	public boolean isFullyAnonymous();
	
	/**
	 * Returns true if it's allowed that the occupants can invite other users.
	 * 
	 * @return True if the occupants are able to invite other users.
	 */
	public boolean canOccupantsInvite();
	
	/**
	 * Return true if it's allowed that the list of occupants is publicly available.
	 * This list include all occupants room {@see JID}.
	 * 
	 * @return True if a list of occupant is available trough 
	 *         <a href="http://xmpp.org/extensions/xep-0030.html">Service Discovery</a>.
	 */
	public boolean canDiscoverOccupants();
	
	/**
	 * Get the {@see JID} of the room owner.
	 * 
	 * @return The {@see JID} of the room owner.
	 */
	public JID getOwner();
	
	/**
	 * Get the number of occupants which are able to join the {@see MUGRoom}.
	 * 
	 * @return The maximal number of occupants in this room.
	 */
	public int getMaxOccupants();
	
	/**
	 * Returns the current number of occupants in the {@see MUGRoom}.
	 *
	 * @return The number of occupants which are in the room.
	 */
	public int getOccupantsCount();
	
	/**
	 * Returns the current number of occupants reserved a game role and
	 * playing a match.
	 *
	 * @return The number of players in the room.
	 */
	public int getPlayersCount();
	
	/**
	 * Obtains a collection of additional service discovery features.
	 * 
	 * @return A collection of additional service discovery features.
	 */
	public Collection<String> getExtraFeatures();
	
	/**
	 * Get additional extended service discovery fields for more
	 * informations about this room.
	 * 
	 * @return A collection of additional extended service discovery fields.
	 */
	public Collection<FormField> getExtraExtendedDiscoFields();
	
	/**
	 * An occupant wants to add a new member.
	 * 
	 * @param newMember The JID of the user which should be added to the member list.
	 * @param occupant The occupant who wants to add the new member.
	 * @throws ForbiddenException If the occupant hasn't the permission to add someone to the member list.
	 */
	public void addMember(JID newMember, MUGOccupant occupant) throws ForbiddenException;
	
	/**
	 * Broadcast the presence of an occupant to all other occupants (expecting him).
	 * 
	 * @param occupant The occupant whose presence will be broadcasted.
	 */
	public void broadcastPresence(MUGOccupant occupant);
	
	/**
	 * Broadcast the room and match information to all occupants.
	 */
	public void broadcastRoomPresence();
	
	/**
	 * A {@see MUGMatch} may want to broadcast a game moves.
	 * The turn will also be sent to the acting player. 
	 * 
	 * @param moves A collection of XML elements which will be send within a turn.
	 * @param player The {@see MUGOccupant} which makes the moves.
	 * @throws ComponentException if the turn cannot be sent to all occupants.
	 */
	public void broadcastTurn(Collection<Element> moves, MUGOccupant player) throws ComponentException;
	
	/**
	 * Use this version when a occupant has more than one role in the game. 
	 * @param moves
	 * @param sender
	 * @param role
	 * @throws ComponentException
	 */
	public void broadcastTurn(Collection<Element> moves, MUGOccupant sender, String role) throws ComponentException;	
	
	/**
	 * An {@see MUGOccupant} want to change his nickname.
	 * 
	 * @param oldNick The old nickname of the occupant.
	 * @param newNick The new nickname of the occupant.
	 * @param newPresence The new presence of the occupant.
	 * @return The changed {@see MUGOccupant} object.
	 * @throws NotFoundException if the old nickname isn't found in the room.
	 * @throws ConflictException if the new nickname is already in use.
	 */
	public MUGOccupant changeNickname(JID userJID, String oldNick, String newNick, Presence newPresence) throws NotFoundException, ConflictException;
	
	/**
	 * Handle game room requests within the Owner namespace.
	 * 
	 * @param packet The IQ stanza which should be handled.
	 * @param occupant The Sender of the IQ request.
	 * @throws ForbiddenException if the sender don't have the permission for his request.
	 * @throws IllegalArgumentException if we don't understand the request.
	 * @throws GameConfigurationException if the room or match state is not correct.
	 * @throws UnsupportedGameException if the request is unsupported or not implemented.
	 */
	public void handleOwnerIQ(IQ packet, MUGOccupant occupant) throws ForbiddenException, 
		IllegalArgumentException, GameConfigurationException, UnsupportedGameException;
	
	/**
	 * An occupant want to invite another user to join the game room.
	 * Note: This doesn't add the recipient to the member list.
	 * 
	 * @param recipient The user which will be invited.
	 * @param reason A human readable text for the invitation.
	 * @param invitor The {@see MUGOccupant} who wants to invite another user.
	 * @throws ForbiddenException if the occupant don't have the permission to invite.
	 * @throws CannotBeInvitedException if an error occurs during sending the invitation.
	 */
	public void invite(JID recipient, String reason, MUGOccupant invitor) throws ForbiddenException, 
		CannotBeInvitedException;
	
	/**
	 * A user want to join the game room.
	 * 
	 * @param nick The nickname of the user.
	 * @param passwd The password for entering the room.
	 * @param fullJID The real {@see JID} of the user.
	 * @param presence The {@see Presence} of the user.
	 * @return A {@see MUGOccupant} object which represents the new praticipant of the room.
	 * @throws ServiceUnavailableException if the room has reached his capacity.
	 * @throws RoomLockedException if the room is locked and only the owner is allowed to enter.
	 * @throws UserAlreadyExistsException if the nickname is already in use.
	 * @throws UnauthorizedException if the provided password is not correct.
	 * @throws ForbiddenException if the room is only for members but the user is not on the member list.
	 * @throws ComponentException if the room is unable to send the presence updates.
	 */
	public MUGOccupant join(String nick, String passwd, JID fullJID, Presence presence) throws
	ServiceUnavailableException, RoomLockedException, UserAlreadyExistsException,
	UnauthorizedException, ForbiddenException, ComponentException;
	
	public MUGOccupant join(String nick, String passwd, JID fullJID, Presence presence, boolean acquireRole) throws
	ServiceUnavailableException, RoomLockedException, UserAlreadyExistsException,
	UnauthorizedException, ForbiddenException, ComponentException;
	
	/**
	 * A occupant can send another occupant a private message.
	 * The recipient is defined by the "to" attribute of the package and must be a room {@see JID}.
	 * 
	 * @param packet A XML stanza which should be sent.
	 * @param occupant The sender of this packet.
	 * @throws NotFoundException if the recipient (from the to attribute of the package)
	 * @throws ComponentException if the room is unable to send the packet.
	 */
	public void sendPrivatePacket(Packet packet, MUGOccupant occupant) throws NotFoundException,
		ComponentException;
	
	/**
	 * A user declines an invitation.
	 * 
	 * @param recipient The user who was sending the invitation.
	 * @param reason A human readable reason for his rejection.
	 * @param sender The user who want to decline his invitation.
	 * @throws ComponentException if the room is unable to send the rejection.
	 */
	public void sendInvitationRejection(JID recipient, String reason, JID sender) throws ComponentException;
	
	/**
	 * A {@see MUGMatch} may want to send game moves.
	 * 
	 * @param moves A collection of XML elements which will be send within a turn.
	 * @param player The {@see MUGOccupant} which makes the moves.
	 * @param recipient The turn will be send to this {@see MUGOccupant}.
	 * @throws ComponentException if the turn cannot be sent.
	 */
	public void sendTurn(Collection<Element> moves, MUGOccupant player, MUGOccupant recipient) 
		throws ComponentException;
	
	/**
	 * An {@see MUGOccupant} signals that he is ready to start the match.
	 * If all player are ready, the room will pass the request on the match.
	 * 
	 * @param occupant The {@see MUGOccupant} which is ready for starting.
	 * @return True if the match is started.
	 * @throws RequiredPlayerException if some free roles of the game must be assigned
	 * before the match is ready.
	 * @throws GameConfigurationException if no playable configuration is available.
	 * @throws ComponentException if the start signal is accepted but could not be 
	 * reflected to the other occupants.
	 */
	public boolean startMatch(MUGOccupant occupant) throws RequiredPlayerException, 
		GameConfigurationException, ComponentException;
	
	/**
	 * An occupant is quitting the participation of this room.
	 * 
	 * @param occupant The leaving occupant.
	 */
	public void leave(MUGOccupant occupant);
	
	/**
	 * Destroy the room. This method should called to cleanup the room.
	 */
	public void destroy();
	
	public boolean isOccupant(JID jid);
	
		
	/**
	 * 
	 * @param jid
	 * @return an occupant whose bare JID matches the passed param jid
	 */
	public MUGOccupant getOccupant(JID jid);
	
	/**
	 * 
	 * @param roomOptions a xml element with the follow format 
	 * <room>
	 * </room>
	 */
	public void setOptions(Element roomOptions);
	
	public Element getOptions();
	
	
	public void rejoin(MUGOccupant occupant, Presence presence) throws ForbiddenException, ComponentException;
	
	public void markOffline(MUGOccupant occupant);
	
	public void abortMatch();
}
