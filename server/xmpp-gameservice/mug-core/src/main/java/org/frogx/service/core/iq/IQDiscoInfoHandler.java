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


import java.util.Map;

import org.dom4j.Element;
import org.dom4j.Namespace;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.core.DefaultMUGService;
import org.xmpp.forms.DataForm;
import org.xmpp.forms.FormField;
import org.xmpp.packet.IQ;
import org.xmpp.packet.PacketError;


/**
 * This class is implementing a handler for discovering the Multi-User Gaming
 * service entity's identities and features
 * (<a href="http://xmpp.org/extensions/xep-0030.html#info">XEP-0030</a>).
 * This includes discovering for supported games and room configuration.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public class IQDiscoInfoHandler {
	/**
	 * The Multi-User Gaming Service which can be discovered.
	 */
	private DefaultMUGService service;
	
	/**
	 * A utility which provides localized strings.
	 */
	private LocaleUtil locale;
	
	/**
	 * Create a handler for discovering the Jabber component and its rooms.
	 * 
	 * @param service The {@see DefaultMUGService} which can be discovered.
	 */
	public IQDiscoInfoHandler(DefaultMUGService service, MUGManager mugManager) {
		this.service = service;
		this.locale = mugManager.getLocaleUtil();
	}
	
	/**
	 * Handle a disco#info query and get the resulting IQ packet.
	 * 
	 * @param packet The IQ Query which is handled.
	 * @return The IQ reply resulting from the query.
	 */
	public IQ handleIQ(IQ packet) {
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
			Namespace discoInfoNS = Namespace.get(queryElement.getNamespacePrefix(), queryElement.getNamespaceURI());
			QName identityQName = new QName("identity", discoInfoNS);
			QName featureQName = new QName("feature", discoInfoNS);
			
			if ((roomName == null) && (node == null)) {
				// Create and add a the identity of the mug service
				Element identity = queryElement.addElement(identityQName);
				identity.addAttribute("category", "game");
				identity.addAttribute("type", "multi-user");
				identity.addAttribute("name", service.getDescription());
				
				// Add Extra Identities (if exist)
				if (service.getExtraIdentities() != null)
					for (Element el : service.getExtraIdentities()) 
						queryElement.add(el);
				
				// Create and add a the disco#info feature
				Element feature = queryElement.addElement(featureQName);
				feature.addAttribute("var", "http://jabber.org/protocol/disco#info");
				// Create and add a the disco#item feature
				feature = queryElement.addElement(featureQName);
				feature.addAttribute("var", "http://jabber.org/protocol/disco#items");
				// Create and add a the search feature
				feature = queryElement.addElement(featureQName);
				feature.addAttribute("var", "jabber:iq:search");
				// Create and add a the feature provided by the mug service
				feature = queryElement.addElement(featureQName);
				feature.addAttribute("var", MUGService.mugNS);
				
				// Create and add the supported game features
				Map<String, MultiUserGame> gameClasses = service.getSupportedGames();
				for (String namespace : gameClasses.keySet()) {
					feature = queryElement.addElement(featureQName);
					feature.addAttribute("var", namespace);
				}
				
				// Add Extra Features
				if (service.getExtraFeatures() != null)
					for (String ns : service.getExtraFeatures()) { 
						feature = queryElement.addElement(featureQName);
						feature.addAttribute("var", ns);
					}
			}
			else if (roomName != null && node == null) {
				// Answer the identity and features of a given room
				MUGRoom room = service.getGameRoom(roomName);
				if (room != null && room.isPublicRoom() && !room.isLocked()) {
					Element identity = queryElement.addElement(identityQName);
					identity.addAttribute("category", "game");
					identity.addAttribute("name", room.getNaturalLanguageName());
					identity.addAttribute("type", "multi-user");
					
					// Create and add a the feature provided by the mug service
					Element feature = queryElement.addElement(featureQName);
					feature.addAttribute("var", MUGService.mugNS);
					
					// Create and add the supported game features
					feature = queryElement.addElement(featureQName);
					feature.addAttribute("var", room.getGame().getGameID().getNamespace());
					
					// Always add public since only public rooms can be discovered
					feature = queryElement.addElement(featureQName);
					feature.addAttribute("var", "mug_public");
					
					feature = queryElement.addElement(featureQName);
					if (room.isMembersOnly()) {
						feature.addAttribute("var", "mug_membersonly");
					}
					else {
						feature.addAttribute("var", "mug_open");
					}
					
					feature = queryElement.addElement(featureQName);
					if (room.isModerated()) {
						feature.addAttribute("var", "mug_moderated");
					}
					else {
						feature.addAttribute("var", "mug_unmoderated");
					}
					
					feature = queryElement.addElement(featureQName);
					if (room.isNonAnonymous()) {
						feature.addAttribute("var", "mug_nonanonymous");
					}
					else if (room.isSemiAnonymous()) {
						feature.addAttribute("var", "mug_semianonymous");
					}
					else if (room.isFullyAnonymous()) {
						feature.addAttribute("var", "mug_fullyanonymous");
					}
					
					feature = queryElement.addElement(featureQName);
					if (room.isPasswordProtected()) {
						feature.addAttribute("var", "mug_passwordprotected");
					}
					else {
						feature.addAttribute("var", "mug_unsecured");
					}
					
					if (room.getExtraFeatures() != null)
						for (String ns : room.getExtraFeatures()) { 
							feature = queryElement.addElement(featureQName);
							feature.addAttribute("var", ns);
						}
					
					DataForm dataForm = new DataForm(DataForm.Type.result);
					
					FormField field = dataForm.addField();
					field.setVariable("FORM_TYPE");
					field.setType(FormField.Type.hidden);
					field.addValue(MUGService.mugNS + "#matchinfo");
					
					field = dataForm.addField();
					field.setVariable("mug#game");
					field.setType(FormField.Type.hidden);
					field.addValue(room.getGame().getGameID().getNamespace());
					
					field = dataForm.addField();
					field.setVariable("mug#matchinfo_roomname");
					field.setLabel(locale.getLocalizedString("mug.extended.info.name"));
					field.addValue(room.getNaturalLanguageName());
					
					field = dataForm.addField();
					field.setVariable("mug#matchinfo_description");
					field.setLabel(locale.getLocalizedString("mug.extended.info.desc"));
					field.addValue(room.getDescription());
					
					field = dataForm.addField();
					field.setVariable("mug#matchinfo_category");
					field.setLabel(locale.getLocalizedString("mug.extended.info.category"));
					field.addValue(room.getGame().getCategory());
					
					field = dataForm.addField();
					field.setVariable("mug#match_occupants");
					field.setLabel(locale.getLocalizedString("mug.extended.info.occupants"));
					field.addValue(Integer.toString(room.getOccupantsCount()));
					
					field = dataForm.addField();
					field.setVariable("mug#match_players");
					field.setLabel(locale.getLocalizedString("mug.extended.info.players"));
					field.addValue(Integer.toString(room.getPlayersCount()));
					
					if (room.getMaxOccupants() > 0) {
						field = dataForm.addField();
						field.setVariable("mug#match_maxoccupants");
						field.setLabel(locale.getLocalizedString("mug.extended.info.num_occupants"));
						field.addValue(Integer.toString(room.getMaxOccupants()));
					}
					
					if (room.getExtraExtendedDiscoFields() != null)
						for (FormField fld : room.getExtraExtendedDiscoFields()) {
							//TODO: The fields shoundn't copied this way, please fix!
							field = dataForm.addField();
							field.setVariable(fld.getVariable());
							field.setLabel(fld.getLabel());
							field.addValue(fld.getValues());
						}
					
					queryElement.add(dataForm.getElement());
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
