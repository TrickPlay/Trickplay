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


import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MultiUserGame;

/**
 * A dummy implementation of {@link MultiUserGame}, intended to be used
 * during unit tests.
 * 
 * Instances are used to create a {@link DummyMatch} to be able to test a
 * {@link MUGRoom}.
 */
public class DummyMultiUserGame implements MultiUserGame {
	
	static public String category = "testing";
	static public String description = "A dummy multi-user game for testing.";
	static public String namespace = "urn:xmpp:mug:game:testing:1";
	
	private Map<MUGRoom, MUGMatch> matches = new HashMap<MUGRoom, MUGMatch>();
	
	public MUGMatch createMatch(MUGRoom room) {
		if (matches.containsKey(room)) {
			throw new IllegalStateException("Match already exists!");
		}
		MUGMatch match = new DummyMatch(room);
		matches.put(room, match);
		return match;
	}
	
	public void destroyMatch(MUGRoom room) {
		if (matches.containsKey(room)) {
			MUGMatch match = matches.get(room);
			if (match != null) {
				match.destroy();
			}
			matches.remove(room);
		}
	}
	
	public Collection<MUGMatch> getMatches() {
		return matches.values();
	}
	
	public String getCategory() {
		return category;
	}
	
	public String getDescription() {
		return description;
	}
	
	public String getNamespace() {
		return namespace;
	}

	public boolean isCorrespondence() {
		// TODO Auto-generated method stub
		return false;
	}

	public GameType getGameType() {
		// TODO Auto-generated method stub
		return null;
	}

	public TurnPolicy getTurnPolicy() {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean allowsJoinAfterStart() {
		// TODO Auto-generated method stub
		return false;
	}

	public int getMinPlayersForStart() {
		// TODO Auto-generated method stub
		return 0;
	}

	public RoleConfig getRoleConfig(String role) {
		// TODO Auto-generated method stub
		return null;
	}

	public String[] getRoles() {
		// TODO Auto-generated method stub
		return null;
	}

	public String getFirstRole() {
		// TODO Auto-generated method stub
		return null;
	}

	public long getMaxAllowedTimeForMove() {
		// TODO Auto-generated method stub
		return 0;
	}

	public boolean abortWhenPlayerLeaves() {
		// TODO Auto-generated method stub
		return false;
	}
}
