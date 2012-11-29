/**
 * Copyright (C) 2008 Guenther Niess. All rights reserved.
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


import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.core.DefaultMUGService;
import org.xmpp.forms.DataForm;
import org.xmpp.forms.FormField;
import org.xmpp.packet.IQ;
import org.xmpp.packet.PacketError;
import org.xmpp.packet.PacketError.Condition;
import org.xmpp.resultsetmanagement.ResultSet;
import org.xmpp.resultsetmanagement.ResultSetImpl;



/**
 * This class is implementing the Jabber Search 
 * (<a href="http://xmpp.org/extensions/xep-0055.html">XEP-0055</a>)
 * to search for rooms on a Multi-User Gaming service.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public class IQSearchHandler {
	
	private static final String nameField       = "mug#roomsearch_name";
	private static final String exactNameField  = "name_is_exact_match";
	private static final String savedRoomsField = "mug#roomsearch_saved";
	private static final String categoryField   = "mug#roomsearch_category";
	private static final String gameField       = "mug#roomsearch_game";
	private static final String rolesField      = "mug#roomsearch_roles";
	private static final String occupantsField  = "mug#roomsearch_max_occupants";
	
	/**
	 * This service hosts our game rooms.
	 */
	DefaultMUGService service;
	
	/**
	 * The MUGManager provides sending and routing packages.
	 */
	private MUGManager mugManager;
	
	/**
	 * A utility which provices localized strings.
	 */
	private LocaleUtil locale;
	
	/**
	 * Create a handler for searching rooms on the multi-user gaming service.
	 * 
	 * @param service The multi-user service which offers the searched rooms.
	 */
	public IQSearchHandler(DefaultMUGService service, MUGManager mugManager) {
		this.service = service;
		this.mugManager = mugManager;
		this.locale = this.mugManager.getLocaleUtil();
	}
	
	/**
	 * Handle a Jabber Search query and get the resulting IQ packet.
	 * 
	 * @param packet The IQ Query.
	 * @return The IQ reply resulting from the query.
	 */
	public IQ handleIQ(IQ packet) {
		// Ignore packets with type error or result
		if (packet.getType() == IQ.Type.error || 
				packet.getType() == IQ.Type.result) {
			return null;
		}
		
		IQ reply = IQ.createResultIQ(packet);
		Element query = packet.getChildElement();
		Element formElement = query.element(
				QName.get("x", "jabber:x:data"));
		
		// check if its a jabber search request
		if (!query.getName().equals("query") || 
				!query.getNamespaceURI().equals("jabber:iq:search")) { 
			reply.setError(PacketError.Condition.bad_request);
			return reply;
		}
		
		if (formElement == null) {
			// return an empty form
			reply.setChildElement(getSearchForm());
		}
		else {
			// get the list of the found rooms
			List<MUGRoom> mugrsm = processSearchForm(formElement);
			
			// handle jabber resulting set management
			Element set = query.element(
					QName.get("set", ResultSet.NAMESPACE_RESULT_SET_MANAGEMENT));
			ResultSet<MUGRoom> resultSet = new ResultSetImpl<MUGRoom>(
					sortByUserAmount(mugrsm));
			
			if (set != null) {
				if (!ResultSet.isValidRSMRequest(set))
				{
					reply.setError(Condition.bad_request);
					return reply;
				}
				
				try
				{
					mugrsm = resultSet.applyRSMDirectives(set);
				}
				catch (NullPointerException e)
				{
					reply.setError(Condition.item_not_found);
					return reply;
				}
			}
			
			Element resultQuery = reply.setChildElement("query", "jabber:iq:search");
			DataForm resultForm = createResultingForm(mugrsm);
			
			if (resultForm != null) {
				resultQuery.add(resultForm.getElement());
				
				if (set != null)
					resultQuery.add(resultSet.generateSetElementFromResults(mugrsm));
			}
		}
		
		return reply;
	}
	
	/**
	 * Parsing the Jabber Search form and looking for the searched rooms.
	 * 
	 * @param formElement A xml element which describes the search form.
	 * @return A list of found game rooms.
	 */
	private List<MUGRoom> processSearchForm(Element formElement) {
		// default search options
		String name = null;
		boolean exactName = false;
		boolean savedRooms = false;
		String category = null;
		FormField games = null;
		int minFreeRoles = 0;
		int maxOccupants = -1;
		
		// parse params from request.
		DataForm df = new DataForm(formElement);
		Iterator<String> values;
		String booleanValue;
		FormField field;
		
		field = df.getField(nameField);
		if (field != null) {
			values = field.getValues().iterator();
			name = (values.hasNext() ? values.next() : null);
			if (name != null && name.trim().length() == 0)
				name = null;
		}
		
		field = df.getField(exactNameField);
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			exactName = "1".equals(booleanValue) || "true".equals(booleanValue);
		}
		
		field = df.getField(savedRoomsField);
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			savedRooms = "1".equals(booleanValue) || "true".equals(booleanValue);
		}
		
		field = df.getField(categoryField);
		if (field != null) {
			values = field.getValues().iterator();
			category = (values.hasNext() ? values.next() : null);
			if ( (category != null) && 
					(category.equals("any") ||  category.trim().length() == 0))
				category = null;
		}
		
		games = df.getField(gameField);
		
		field = df.getField(rolesField);
		if (field != null) {
			values = field.getValues().iterator();
			minFreeRoles = (values.hasNext() ? Integer.valueOf(values.next()) : 0);
		}
		
		field = df.getField(occupantsField);
		if (field != null) {
			values = field.getValues().iterator();
			maxOccupants = (values.hasNext() ? Integer.valueOf(values.next()) : -1);
		}
		
		Collection<MUGRoom> rooms = null;
		
		// TODO: Support saved rooms
		if (savedRooms)
			rooms = new ArrayList<MUGRoom>();
		
		if (rooms == null && category != null) {
			rooms = service.getGameRoomsByCategory(category);
			category = null;
		}
		
		if (rooms == null)
			rooms = service.getGameRooms();
		
		
		List<MUGRoom> searchResults;
		searchResults = new ArrayList<MUGRoom>();
		for (MUGRoom room : rooms) {
			boolean find = true;
			
			if (name != null) {
				if (exactName) {
					if (!name.equalsIgnoreCase(room.getNaturalLanguageName()))
					{
						find = false;
					}
				}
				else
				{
					if (room.getNaturalLanguageName().toLowerCase().indexOf(
						name.toLowerCase()) == -1)
					{
						find = false;
					}
				}
			}
			
			if (category != null && 
					!room.getGame().getCategory().equals(category)) {
				find = false;
			}
			
			if (games != null && games.getValues().iterator().hasNext()) {
				boolean withinCategory = false;
				for (Iterator<String> gameIterator = games.getValues().iterator(); gameIterator.hasNext();) {
					if (room.getGame().getGameID().getNamespace().equals(gameIterator.next())) {
						withinCategory = true;
						break;
					}
				}
				if (!withinCategory)
					find = false;
			}
			
			if (minFreeRoles > 0 && (
					room.getMatch().getFreeRoles() == null || 
					room.getMatch().getFreeRoles().size() < minFreeRoles) ) {
				find = false;
			}
			
			if (maxOccupants != -1 && room.getMaxOccupants() < maxOccupants) {
				find = false;
			}
			
			if (find && room.isPublicRoom() && !room.isLocked())
				searchResults.add(room);
		}
		return searchResults;
	}
	
	/**
	 * Sorts the provided list in such a way that the MUG with the fewest users
	 * will be the first one in the list.
	 * 
	 * @param mugs The unordered list that will be sorted.
	 * @return The sorted list of MUG rooms.
	 */
	private static List<MUGRoom> sortByUserAmount(List<MUGRoom> mugs)
	{
		Collections.sort(mugs, new Comparator<MUGRoom>()
		{
			public int compare(MUGRoom o1, MUGRoom o2)
			{
				return o2.getOccupantsCount() - o1.getOccupantsCount();
			}
		});

		return mugs;
	}
	
	/**
	 * Creates a XMPP form with search results.
	 * 
	 * @param rooms A collection of game rooms which should be listed in the result.
	 * @return The Jabber form with the results.
	 */
	private DataForm createResultingForm(Collection<MUGRoom> rooms) {
		if (rooms == null || rooms.isEmpty())
			return null;
		
		DataForm resultForm = new DataForm(DataForm.Type.result);
		FormField field = resultForm.addField();
		field.setVariable("FORM_TYPE");
		field.setType(FormField.Type.hidden);
		field.addValue("jabber:iq:search");
		boolean atLeastoneResult = false;
		
		for (MUGRoom room : rooms) {
			Map<String, Object> fields = new HashMap<String, Object>();
			
			fields.put("name", room.getNaturalLanguageName());
			fields.put("game", room.getGame().getGameID().getNamespace());
			fields.put("jid", room.getJID().toString());
			
			resultForm.addItemFields(fields);
			atLeastoneResult = true;
		}
		
		if (atLeastoneResult) {
			resultForm.addReportedField("name",
					locale.getLocalizedString("mug.search.result.name"),
					FormField.Type.text_single);
			resultForm.addReportedField("game",
					locale.getLocalizedString("mug.search.result.game"),
					FormField.Type.text_single);
			resultForm.addReportedField("jid",
					locale.getLocalizedString("mug.search.result.jid"),
					FormField.Type.jid_single);
		}
		return resultForm;
	}
	
	/**
	 * Creates a Jabber Search form and returns the XML query element.
	 * 
	 * @return A search element with an empty form.
	 */
	private Element getSearchForm() {
		Element element = DocumentHelper.createElement(QName.get("query",
			"jabber:iq:search"));
		DataForm searchForm = new DataForm(DataForm.Type.form);
		Map<String, MultiUserGame> games = service.getSupportedGames();
		
		searchForm.setTitle(locale.getLocalizedString("mug.search.form.title"));
		searchForm.addInstruction(
				locale.getLocalizedString("mug.search.form.instruction"));
		
		FormField field = searchForm.addField();
		field.setVariable("FORM_TYPE");
		field.setType(FormField.Type.hidden);
		field.addValue("jabber:iq:search");
		
		field = searchForm.addField();
		field .setVariable(nameField);
		field.setType(FormField.Type.text_single);
		field.setLabel(locale.getLocalizedString(
				"mug.search.form.name"));
		field.setRequired(false);
		
		field = searchForm.addField();
		field.setVariable(exactNameField);
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString(
				"mug.search.form.exact_name"));
		field.setRequired(false);
		
		field = searchForm.addField();
		field.setVariable(savedRoomsField);
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString(
				"mug.search.form.saved"));
		field.setRequired(false);
		
		field = searchForm.addField();
		field.setVariable(rolesField);
		field.setType(FormField.Type.list_single);
		field.setLabel(locale.getLocalizedString(
				"mug.search.form.min_roles"));
		field.setRequired(false);
		for (int i = 0; i <= 15; i++) {
			field.addOption(Integer.toString(i), Integer.toString(i));
		}
		field.addValue("0");
		
		field = searchForm.addField();
		field.setVariable(occupantsField);
		field.setType(FormField.Type.list_single);
		field.setLabel(locale.getLocalizedString(
				"mug.search.form.max_occupants"));
		field.setRequired(false);
		for (int i = 5; i <= 40; i = i+5) {
			field.addOption(Integer.toString(i), Integer.toString(i));
		}
		field.addValue("20");
		
		
		if (games != null && !games.isEmpty()) {
			Collection<String> categories = service.getGameCategories();
			field = searchForm.addField();
			field.setVariable(categoryField);
			field.setType(FormField.Type.list_single);
			field.setLabel(locale.getLocalizedString(
					"mug.search.form.category"));
			field.setRequired(false);
			if (categories.size() > 1) {
				field.addOption("any", "any");
				field.addValue("any");
			}
			for (String category : categories) {
				field.addOption(category, category);
			}
			
			field = searchForm.addField();
			field.setVariable(gameField);
			field.setType(FormField.Type.list_multi);
			field.setLabel(locale.getLocalizedString(
					"mug.search.form.games"));
			field.setRequired(false);
			for (MultiUserGame game : games.values()) {
				field.addOption(game.getDescription(), game.getGameID().getNamespace());
			}
		}
		
		element.add(searchForm.getElement());
		return element;
	}
}
