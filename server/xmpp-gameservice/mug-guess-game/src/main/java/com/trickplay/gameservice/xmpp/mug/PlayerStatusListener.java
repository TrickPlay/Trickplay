/**
 * $RCSfile$
 * $Revision: 7071 $
 * $Date: 2007-02-11 18:59:05 -0600 (Sun, 11 Feb 2007) $
 *
 * Copyright 2003-2007 Jive Software.
 *
 * All rights reserved. Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.trickplay.gameservice.xmpp.mug;

/**
 * A listener that is fired anytime a player's status in a room is changed
 * 
 */
public interface PlayerStatusListener {

    /**
     * Called when a new room occupant has joined the room. Note: Take in consideration that when
     * you join a room you will receive the list of current occupants in the room. This message will
     * be sent for each occupant.
     *
     * @param player the player that has just joined the room
     * (e.g. room@mug.jabber.org/nick).
     */
    public abstract void joined(String matchId, Participant participant, GamePresenceExtension.Item item);

    /**
     * Called when a room occupant has left the room on its own. This means that the occupant was
     * neither kicked nor banned from the room.
     *
     * @param player the player that has left the room on its own.
     * (e.g. room@conference.jabber.org/nick).
     */
    public abstract void left(String matchId, Participant participant);
    
    public abstract void unavailable(String matchId, Participant participant);


    /**
     * Called when a player changed his/her nickname in the room. The new player's 
     * nickname will be informed with the next available presence.
     * 
     * @param player the player that was revoked administrator privileges
     * (e.g. room@conference.jabber.org/nick).
     * @param newNickname the new nickname that the player decided to use.
     */
    public abstract void nicknameChanged(String matchId, Participant p, String newNickname);

}
