/**
 * Copyright (C) 2008-2010 Guenther Niess. All rights reserved.
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
import java.util.List;

import org.dom4j.DocumentFactory;
import org.dom4j.Element;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGOccupant;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.exception.ConflictException;
import org.frogx.service.api.exception.GameConfigurationException;
import org.frogx.service.api.exception.InvalidTurnException;
import org.frogx.service.api.exception.RequiredPlayerException;
import org.xmpp.component.ComponentException;
import org.xmpp.packet.JID;

/**
 * A dummy implementation of {@link MUGMatch}, intended to be used
 * during unit tests.
 * 
 * Instances are used to test a {@link MUGRoom}.
 * 
 * @author G&uuml;nther Nie&szlig;, guenther.niess@web.de
 */
public class DummyMatch implements MUGMatch {
	
	private MUGRoom room = null;
	private List<MUGOccupant> spectators = null;
	private MUGOccupant player = null;
	
	public DummyMatch(MUGRoom room) {
		spectators = new ArrayList<MUGOccupant>();
		this.room = room;
	}
	
	public void addSpectator(MUGOccupant occupant) {
		spectators.add(occupant);
	}
	
	public void destroy() {
		spectators = null;
	}
	
	public Collection<Element> getConfigurationForm() {
		Collection<Element> result = new ArrayList<Element>();
		Element element = DocumentFactory.getInstance().createElement("config", DummyMultiUserGame.gameID.getNamespace());
		result.add(element);
		return result;
	}
	
	public Collection<String> getFreeRoles() {
		if (player == null) {
			return null;
		}
		Collection<String> roles = new ArrayList<String>();
		roles.add("player");
		return roles;
	}
	
	public Collection<MUGOccupant> getPlayers() {
		Collection<MUGOccupant> players = new ArrayList<MUGOccupant>();
		if (player != null) {
			players.add(player);
		}
		return players;
	}
	
	public String getRole(MUGOccupant player) {
		if (this.player != null && this.player.equals(player)) {
			return "player";
		}
		return null;
	}
	
	public Element getState() {
		return DocumentFactory.getInstance().createElement("state", DummyMultiUserGame.gameID.getNamespace());
	}
	
	public Status getStatus() {
		if (player != null) {
			return Status.active;
		}
		return Status.inactive;
	}
	
	public void leave(MUGOccupant occupant) {
		if (player != null && player.equals(occupant)) {
			player = null;
		}
		else {
			spectators.remove(occupant);
		}
	}
	
	public void processTurn(MUGOccupant player, Collection<Element> moves)
			throws RequiredPlayerException, GameConfigurationException,
			InvalidTurnException, ComponentException {
		if (this.player == null || this.player.equals(player)) {
			throw new RequiredPlayerException();
		}
		if (moves == null || moves.size() != 1) {
			throw new InvalidTurnException();
		}
		room.broadcastTurn(moves, player);
	}
	
	public void releaseRole(MUGOccupant player) {
		if (this.player != null && this.player.equals(player)) {
			player = null;
		}
		if (!spectators.contains(player)) {
			spectators.add(player);
		}
	}
	
	public String reserveFreeRole(MUGOccupant occupant) {
		if (player == null) {
			return null;
		}
		player = occupant;
		return "player";
	}
	
	public void reserveRole(MUGOccupant occupant, String roleName)
			throws ConflictException, GameConfigurationException {
		if (player != null) {
			throw new ConflictException();
		}
		if (roleName == null || !"player".equals(roleName)) {
			throw new GameConfigurationException();
		}
		player = occupant;
	}
	
	public void setConfiguration(Collection<Element> config) {
		// ignore
	}
	
	public void setConstructedState(Element state) {
		// ignore
	}
	
	public void start() throws RequiredPlayerException,
			GameConfigurationException {
		// ignore
	}

	public String holdFreeRole(JID jid) {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean holdRole(String roleName, JID jid) {
		// TODO Auto-generated method stub
		return false;
	}

	public TurnInfo getTurnInfo() {
		// TODO Auto-generated method stub
		return null;
	}

	public void abort() {
		// TODO Auto-generated method stub
		
	}
}
