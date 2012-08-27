package org.frogx.service.games.common;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.dom4j.DocumentFactory;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.exception.ConflictException;
import org.frogx.service.api.exception.GameConfigurationException;
import org.frogx.service.api.exception.InvalidTurnException;
import org.frogx.service.api.exception.LeasedException;
import org.frogx.service.api.exception.NotAllowedException;
import org.frogx.service.api.exception.RequiredPlayerException;
import org.frogx.service.api.exception.UnsupportedGameException;
import org.frogx.service.core.DefaultTurnInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.JID;

/**
 * An implementation of simple turn based match play where the player to play next is determined 
 * by the order in which roles are listed in the game configuration
 */
public class GenericTurnBasedMatch implements MUGMatch {
	
	private static final Logger log = LoggerFactory.getLogger(GenericTurnBasedMatch.class);
		
	private static final String NAMESPACE = "http://jabber.org/protocol/mug/generic-turn-based-game";
	/**
	 * The room which supports the match
	 */
	private MUGRoom room = null;
	
	private GenericTurnBasedMUG mug;
	private MUGOccupant[] players = null;
	private TurnInfo turnInfo;
	
	private int lastTurnIndex = -1;
	private int firstTurnIndex = -1;
	private int nextTurnIndex = -1;
	private int minPlayers=2;
	private boolean enforceMinPlayersForStart = false;
	
	private static class LeasedRole {
		final JID owner;
		final long start;
		final long end;
		final String role;
		
		public LeasedRole(JID owner, String role) {
			this.owner = owner;
			this.role = role;
			this.start = System.currentTimeMillis();
			this.end = start + 2*60*1000; // 2 minutes...
		}
		
		public boolean isValid() {
			return end > System.currentTimeMillis();
		}
		
		
	}
	
	
	private static class LeaseManager {
		Map<String, LeasedRole> roleLeaseMap = new HashMap<String, LeasedRole>();
		Map<String, LeasedRole> userLeaseMap = new HashMap<String, LeasedRole>();
		
		public boolean isLeased(String role) {
			return roleLeaseMap.containsKey(role) && roleLeaseMap.get(role).isValid();
		}
		
		public boolean acquireLease(String role, JID jid) {
				LeasedRole lease = roleLeaseMap.get(role);
				if (lease == null || !lease.isValid())
					lease = new LeasedRole(jid, role);
				else if (lease.owner.equals(jid) || lease.owner.toBareJID().equals(jid.toBareJID())) {/* should use baseJID instead??? */
					lease = new LeasedRole(jid, role);
				} else {
					return false;
				}
				roleLeaseMap.put(role, lease);
				userLeaseMap.put(jid.toBareJID(), lease);
				return true;
		}
		
		public void terminateLease(String role) {
			LeasedRole lease = roleLeaseMap.remove(role);
			if (lease != null)
				userLeaseMap.remove(lease.owner.toBareJID());
		}
		
		public void terminateLease(JID jid) {
			LeasedRole lease = userLeaseMap.remove(jid.toBareJID());
			if (lease != null)
				roleLeaseMap.remove(lease.role);
		}
		
		public LeasedRole getLeasedRole(JID jid) {
			return userLeaseMap.get(jid.toBareJID());
		}
	}
	
	private LeaseManager leaseManager = new LeaseManager();
	/**
	 * The match status according the protocol.
	 * It can be created, inactive, paused or active.
	 */
	private Status status;
	
	/**
	 * This field represents the match state.
	 * This is used for the presence of the room.
	 */
	private String opaqueMatchState="";
	
	
	
	/**
	 * Occupants who don't play. They are watching the match.
	 */
	private Set<MUGOccupant> spectators = null;
	
	private Set<String> freeRoles = new HashSet<String>(); 
	private Set<String> releasedRoles = new HashSet<String>();
	
	/**
	 * To create a match a multi-user game room is needed.
	 * 
	 * @param room The game room which hosts and handles the match.
	 */
	public GenericTurnBasedMatch(MUGRoom room, MUGManager mugManager, GenericTurnBasedMUG turnBasedMug) {
		this.room = room;
		this.spectators = new LinkedHashSet<MUGOccupant>();
		this.mug = turnBasedMug;
		this.players = new MUGOccupant[mug.getRoles().length];
		this.status = Status.created;
		freeRoles.addAll(Arrays.asList(turnBasedMug.getRoles()));
		firstTurnIndex = turnBasedMug.getStartingPlayerRoleIndex();	
		enforceMinPlayersForStart = turnBasedMug.getMinPlayersForStart() > 0;
		minPlayers = turnBasedMug.getMinPlayersForStart();
	}
	
	public int getNumberOfPlayers() {
		int cnt = 0;
		//while
		for(int i=0; players != null && i<players.length; i++)
			if (players[i] != null)
				cnt++;
		return cnt;
	}
	/**
	 * This method is called if the match will be destroyed.
	 */
	public void destroy() {
		room = null;
		spectators = null;
		players = null;
	}
	
	/**
	 * Get a collection of the active players or null if no occupant
	 * has a game role reserved.
	 * 
	 * @return A collection of occupants who have reserved a game role.
	 */
	public Collection<MUGOccupant> getPlayers() {
		List<MUGOccupant> l = new ArrayList<MUGOccupant>();
	//	synchronized (leaseManager) {
			for(MUGOccupant player: players) {
				if (player!=null)
					l.add(player);
			}
	//	}
		return l;
		
	}
	
	public String holdFreeRole(JID jid) {
	//	synchronized(leaseManager) {
			LeasedRole leasedRole = leaseManager.getLeasedRole(jid);
			if (leasedRole != null && leasedRole.isValid()) {
				leaseManager.acquireLease(leasedRole.role, jid);
				return leasedRole.role;
			}
			Iterator<String> iter = freeRoles.iterator();
			while(iter.hasNext()) {
				String role = iter.next();
				if (leaseManager.acquireLease(role, jid))
					return role;
			}
	//	}
		return null;
	}

	public boolean holdRole(String role, JID jid) {
	//	synchronized(leaseManager) {
			LeasedRole leasedRole = leaseManager.getLeasedRole(jid);
			if (leasedRole != null && leasedRole.isValid() && !leasedRole.role.equals(role)) {
				throw new NotAllowedException();
			}
			return leaseManager.acquireLease(role, jid);
		//}
	}

	/**
	 * An occupant which have no role yet can try to reserve a game role.
	 * If the role isn't available this method returns null.
	 * 
	 * @param occupant The room occupant who wants to reserve a role.
	 * @param roleName The name of the role which wants the occupant reserve.
	 * @throws ConflictException If the role is reserved by another occupant.
	 * @throws GameConfigurationException If the role doesn't exist.
	 */
	public void reserveRole(MUGOccupant occupant, String roleName) 
			throws ConflictException, GameConfigurationException {
		//	synchronized(leaseManager) {
				int roleIdx = mug.getRoleIndex(roleName);
				if (roleIdx >= 0) {
					if (players[roleIdx] != null) {
						if (!players[roleIdx].equals(occupant)) {
							throw new ConflictException();
						}
					} else {
						if (leaseManager.isLeased(roleName)) {
							LeasedRole lease = leaseManager.getLeasedRole(occupant.getUserAddress());
							if (lease != null && lease.role.equals(roleName)) {
								players[roleIdx] = occupant;
								leaseManager.terminateLease(roleName);
							} else {
								throw new LeasedException();
							}
						} else {
							players[roleIdx] = occupant;
							leaseManager.terminateLease(roleName);
							leaseManager.terminateLease(occupant.getUserAddress());
						}
					}
					freeRoles.remove(roleName);
					removeSpectator(occupant);
				}
		//	}
	}
	
	
	/**
	 * An occupant who has no role yet can reserve any free game role.
	 * 
	 * @param occupant The room occupant who wants to reserve a role.
	 * @return The name of the reserved role or null if no role could be reserved.
	 */
	public String reserveFreeRole(MUGOccupant occupant) {
	//	synchronized(leaseManager) {
			LeasedRole lease = leaseManager.getLeasedRole(occupant.getUserAddress());
			int roleidx = lease != null ? mug.getRoleIndex(lease.role) : -1;
			String reservedRole = null;
			if (roleidx >= 0) {
				players[roleidx] = occupant;
				leaseManager.terminateLease(lease.role);
				reservedRole = lease.role;
			} else {
				Collection<String> freeRoles = getFreeRoles();
				String role = freeRoles != null && !freeRoles.isEmpty() ? freeRoles.iterator().next() : null;
				roleidx = mug.getRoleIndex(role);
				if (roleidx >= 0) {
					players[roleidx] = occupant;
					reservedRole = role;
				}
			}
			freeRoles.remove(reservedRole);
			removeSpectator(occupant);
			return reservedRole;
	//	}
	}
	
	/**
	 * A MUGPlayer want to release his role.
	 * 
	 * @param player The MUGPlayer which wants to release his role.
	 */
	public void releaseRole(MUGOccupant player) {
	//	synchronized(leaseManager) {
			String role = getRole(player);
			if (role!=null) {
				int roleidx = mug.getRoleIndex(role);
				if (roleidx>=0) {
					players[roleidx] = null;
					freeRoles.add(role);
					releasedRoles.add(role);
				}
			}
	//	}
	}

	
	/**
	 * Get a collection of game roles which are available and can be
	 * reserved by an occupant or null if all roles are reserved.
	 * 
	 * @return A collection of available game roles.
	 */
	public Collection<String> getFreeRoles() {
	//	synchronized(leaseManager) {
			return Collections.unmodifiableSet(freeRoles);
	//	}
	}
	
	/**
	 * Get the role of an {@see MUGOccupant}. 
	 * @param player The occupant of the role.
	 * @return The name of the role or null if he hasn't any role.
	 */
	public String getRole(MUGOccupant player) {
		String[] allRoles = mug.getRoles();
		if (player == null)
			return null;
	//	synchronized(leaseManager) {
			for(int i=0; i<players.length; i++) {
				if (player.equals(players[i]))
					return allRoles[i];
			}
	//	}
		return null;
	}
	
	/**
	 * A room occupant wants to watch the match.
	 * 
	 * @param occupant The room occupant who joins the match without a game role.
	 */
	public void addSpectator(MUGOccupant occupant) {
		//synchronized(spectators) {
			spectators.add(occupant);
	//	}
	}
	
	public void removeSpectator(MUGOccupant occupant) {
	//	synchronized(spectators) {
			spectators.add(occupant);
	//	}
	}
	/**
	 * Get the state of the match in an xml element. This is used for
	 * the presence of the game room.
	 * 
	 * @return The current match state as an xml element.
	 */
	public Element getState() {
		Element stateElement = null;
	//	if (status == Status.active)
			stateElement = calculateStateElement();
		return stateElement;
	}
	
	/**
	 * Try to start the match.
	 * 
	 * @throws RequiredPlayerException If not all required game roles are
	 *                     assigned a RequiredPlayerException will be thrown.
	 * @throws GameConfigurationException The GameConfigurationException will 
	 *                     be thrown if the match options aren't playable.
	 */
	public void start() throws RequiredPlayerException, GameConfigurationException {
	//	synchronized (leaseManager) {
			/* if game is already started then ignore the request */
			if (status == Status.active) {
				return;
			} else if (status != Status.inactive && status != Status.created) {
				throw new GameConfigurationException();
			}
			
			int cntPlayers = getNumberOfPlayers();
			if (cntPlayers <= 0 ||
					(enforceMinPlayersForStart && cntPlayers < minPlayers)) {
				throw new RequiredPlayerException();
			}
			
			status = Status.active;
			if (firstTurnIndex<0) {
				for(int i=0; i<players.length; i++)
					if (players[i] != null) {
						firstTurnIndex = i;
						break;
					}
			}
			nextTurnIndex = firstTurnIndex;
			setTurnInfo();
	//	}
	}
	
	private void setTurnInfo() {
		long now = System.currentTimeMillis();
		long expiration = now + mug.getMaxAllowedTimeForMove();
		turnInfo = new DefaultTurnInfo(nextTurnIndex >= 0 ? players[nextTurnIndex] : null, now, expiration);
	}
	
	/**
	 * A Player set a cross or nought on the board.
	 * 
	 * @param player The MUGOccupant which wants to make the turn.
	 * @param moves Only one the turn element in the moves is allowed.
	 * @throws RequiredPlayerException This Exception is thrown if a 
	 * the crosses or noughts role isn't assigned by a occupant.
	 * @throws GameConfigurationException This Exception is thrown if
	 * the match hasn't started yet.
	 * @throws InvalidTurnException 
	 * @throws ComponentException
	 */
	public void processTurn(MUGOccupant player, Collection<Element> moves) throws InvalidTurnException, ComponentException {
		
	//	synchronized (leaseManager) {
			if (status != Status.active) {
				log.debug("Match " + room.getJID() + " cannot accept turns in its current state. status="+status);
				throw new GameConfigurationException();
			}
			
			String role = getRole(player);
			int playerIdx = mug.getRoleIndex(role);
			
			if (!player.hasRole() || role == null || playerIdx < 0) {
				log.debug("A Spectator wants to send a move in match " + room.getJID());
				throw new GameConfigurationException();
			}
			
			if (playerIdx != nextTurnIndex) {
				log.debug("Not ready for move in match " + room.getJID());
						throw new InvalidTurnException();
			}
			
			if (moves == null || moves.size()  == 0 || moves.size() > 2) {
				log.debug("No valid move in match " + room.getJID());
				throw new InvalidTurnException();
			}
			
			// Only one move per turn with the name move in the game ns is permitted
			Iterator<Element> moveIter = moves.iterator();
			Element stateElement = moveIter.hasNext() ? moveIter.next() : null;
			if (stateElement == null || !stateElement.getName().equals("newstate")) {
				log.debug("Not valid move in match " + room.getJID() + ": " + stateElement.asXML());
				throw new InvalidTurnException();
			}
			
			boolean matchFinished = false;
			int nextRoleIdx = -1;
			boolean only_update_match_state = false;
			boolean invalid_move = false;
			Element nextElement = moveIter.hasNext() ? moveIter.next() : null;
			if (nextElement != null) {
				if (nextElement.getName().equals("terminate")) {
					matchFinished = true;
				} else if (nextElement.getName().equals("only-update")) {
					only_update_match_state = true;
				} 				
			} else if (mug.isAutonext()) {
				nextRoleIdx = computeNextTurnIndex(playerIdx);
				nextElement = DocumentHelper.createElement(QName.get("next", MUGService.mugUserNS));
			} 
			
			if (!mug.isAutonext() && !only_update_match_state && !matchFinished) {
				if (nextElement == null || !nextElement.getName().equals("next")) {
					log.debug("Not valid move in match " + room.getJID() + ": " + nextElement.asXML());
					throw new InvalidTurnException();
				}

				nextRoleIdx = mug.getRoleIndex(nextElement != null ? nextElement.getTextTrim() : "");
				if (nextRoleIdx < 0) {
					log.debug("Not valid move in match " + room.getJID() + ": " + nextElement.asXML());
					throw new InvalidTurnException();
				}
			} 
			
			opaqueMatchState = stateElement.getText();
			
			if (!only_update_match_state) {
				nextTurnIndex = nextRoleIdx;
				lastTurnIndex = playerIdx;
				setTurnInfo();
				if (!matchFinished) {
					List<Element> movesCopy = new ArrayList<Element>();
					movesCopy.add(stateElement);
					if (nextRoleIdx >= 0) {
						movesCopy.add(nextElement.addText(mug.getRoleForIndex(nextRoleIdx)));
					}
					moves = movesCopy;
				}
				room.broadcastTurn(moves, player);
				
				if (matchFinished) {
				//	reset();
					status = Status.completed;
					room.broadcastRoomPresence();
				}
			}
		
	//	}
	}
	
	private int computeNextTurnIndex(int curPlayerIdx) {
		if (curPlayerIdx < 0 || curPlayerIdx >= players.length)
			return firstTurnIndex;

		int nextRoleIdx = -1;
		int nextIdx = curPlayerIdx < (players.length - 1) ? curPlayerIdx + 1 : players.length - curPlayerIdx - 1;
		while (nextIdx != curPlayerIdx) {
			if (players[nextIdx] != null) {
				nextRoleIdx = nextIdx;
				break;
			}
			nextIdx = nextIdx < (players.length - 1) ? nextIdx + 1 : players.length - nextIdx - 1;
		}
		return nextRoleIdx;
	}
	
		
	/**
	 * Calculate the xml representation of the present match state.
	 */
	private Element calculateStateElement() {
		Element stateElement = DocumentFactory.getInstance().createDocument().addElement("state", NAMESPACE);

	//		synchronized (leaseManager) {
			
				
				if (firstTurnIndex >= 0)
					stateElement.addElement("first").addText(mug.getRoleForIndex(firstTurnIndex));
		
				
				stateElement.addElement("opaque").add(DocumentHelper.createCDATA(opaqueMatchState!=null?opaqueMatchState:""));
				
				String[] allRoles = mug.getRoles();
				Element rolesElem = stateElement.addElement("roles");
				
			//	synchronized (leaseManager) {
					for(int i=0; i<players.length; i++) {
						if (players[i] != null) {
							rolesElem.addElement("role").addText(allRoles[i]);
						}
					}
					if (lastTurnIndex >= 0)
						stateElement.addElement("last").addText(mug.getRoleForIndex(lastTurnIndex));
					
					// handle the case of a match with only one player and it is started by that player. when a second player joins
					// we will assign the turn to the second player for a roundrobin style match
					if (status == status.active && mug.isAutonext() && lastTurnIndex >= 0 && nextTurnIndex < 0) {
						nextTurnIndex = computeNextTurnIndex(lastTurnIndex);
					}
					if (nextTurnIndex >= 0)
						stateElement.addElement("next").addText(mug.getRoleForIndex(nextTurnIndex));
					if (releasedRoles.size()>0) {
						Element releasedRolesElem = stateElement.addElement("releasedRoles");
						for(String role:releasedRoles) {
							releasedRolesElem.addElement("role").addText(role);
						}
					}
					if (status == Status.completed || status == Status.aborted)
						stateElement.addElement("terminated");
					
				
			//	}
		//}
		return stateElement;
	}

	
	/**
	 * Get the current status of the match.
	 * 
	 * @return The pressent match status.
	 */
	public Status getStatus() {
		return status;
	}
	
	/**
	 * The owner requests a constructed match by sending an starting match state.
	 * 
	 * @param state The starting match state.
	 */
	public void setConstructedState(Element state) {
		//TODO: Implement this
		throw new UnsupportedGameException();
	}
	
	/**
	 * An {@see MUGOccupant} leaves the match.
	 * This means an occupant is neither a player nor a spectator anymore.
	 * 
	 * @param occupant The occupant who leaves the match.
	 */
	public void leave(MUGOccupant occupant) {
		if (status == Status.active 
				&& occupant != null 
				&& occupant.hasRole()) {
		//	releasedRoles
			if (mug.abortWhenPlayerLeaves()) {
				status = Status.aborted;
			} else {
				nextTurnIndex = -1; // TODO: this part is flaky ??
			}
			//
		}
		releaseRole(occupant);
		removeSpectator(occupant);
	}

	public void abort() {
		if (status != Status.completed)
			status = Status.aborted;
	}

	/**
	 * Initialize the configuration form of the match.
	 */
	public Collection<Element> getConfigurationForm() {
		Element element = DocumentHelper.createElement(QName.get("match", NAMESPACE));
		
		
		element.addElement("minPlayers").setText(String.valueOf(minPlayers));
		element.addElement("firstPlayerRole").setText(mug.getRoleForIndex(firstTurnIndex));
		element.addElement("enforceMinPlayersForStart").setText(Boolean.toString(enforceMinPlayersForStart));
		
		List<Element> list = new ArrayList<Element>();
		list.add(element);
		return list;
	}
	
	
	/**
	 * 
	 * @param config A xml element which describes the new configuration or null if
	 * 		the default configuration should be applied.
	 */
	public void setConfiguration(Collection<Element> options) {
		//synchronized (leaseManager) {
			if (status == Status.active || status == Status.completed) {
				throw new NotAllowedException();
			}
	//	}
		if (options != null && !options.isEmpty() && options.size() != 1)
			throw new GameConfigurationException();
		
		Element matchElement = null;
		if (options != null && !options.isEmpty())
			matchElement = options.iterator().next();

		if (matchElement != null) {
			if (!matchElement.getName().equals("match")
					|| !matchElement.getNamespaceURI().equals(NAMESPACE))
				throw new GameConfigurationException();

			try {

				String str = matchElement.elementText("minPlayersForStart");
				if (str != null) {
					int value = Integer.parseInt(str);
					if (value < 2 || value > 10) {
						throw new GameConfigurationException();
					}
					minPlayers = value;
				}
				
				str = matchElement.elementText("firstRole");
				if (str != null) {
					int value = mug.getRoleIndex(str);
					if (value < 0) {
						throw new GameConfigurationException();
					}
					firstTurnIndex = value;
				}
				
				enforceMinPlayersForStart = minPlayers > 0;
			} catch (Exception ex) {
				throw new GameConfigurationException();
			}
		}		
		
		status = Status.inactive;

	}

	public TurnInfo getTurnInfo() {
		return turnInfo;
	}

}
