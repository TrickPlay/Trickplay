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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.component.ComponentException;
import org.xmpp.forms.DataForm;
import org.xmpp.forms.FormField;
import org.xmpp.packet.IQ;


/**
 * This class is implementing a handler for game room requests
 * within the owner namespace.
 * 
 */
public class IQOwnerHandler {
	
	private static final Logger log = LoggerFactory.getLogger(IQOwnerHandler.class);
	
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
	 * This xml element describes the response of an configuration form request.
	 * (<query xmlns='http://jabber.org/protocol/mug#owner'><options>...</options></query>)
	 */
	private Element probeResult;
	
	/**
	 * This xml element includes the configuration form of this room.
	 * (<options>...</options>)
	 */
	private Element gameOptionsElement;
	
	/**
	 * The configuration form for this room.
	 */
	private DataForm configurationForm;
	
	
	/**
	 * Create a handler for game room requests within the Owner namespace.
	 * 
	 * @param service The {@see MUGService} which hosts the game room.
	 * @param componentManager The ComponentManager provides sending and routing replies.
	 * @param room The IQOwnerHandler process messages only for this room.
	 */
	public IQOwnerHandler(MUGService service, 
			MUGManager mugManager, DefaultMUGRoom room) {
		this.service = service;
		this.mugManager = mugManager;
		this.locale = mugManager.getLocaleUtil();
		this.room = room;
		initConfigForm();
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
					Iterator<Element> optionElementIt = element.elementIterator();
					
					if (MUGOccupant.Affiliation.owner != occupant.getAffiliation()) {
						throw new ForbiddenException();
					}
					
					if (!optionElementIt.hasNext()) {
						// Send a room configuration form
						refreshConfigurationFormValues();
						reply.setChildElement(probeResult);
					}
					else {
						if ((room.getMatch().getStatus() == MUGMatch.Status.created) ||
								(room.getMatch().getStatus() == MUGMatch.Status.inactive)) {
							boolean roomConfigChanged = false;
							
							for (optionElementIt = element.elementIterator();
									optionElementIt.hasNext();) {
								Element el = optionElementIt.next();
								
								// process the room configuration form
								if (el.getName().equals("x") && 
										el.getNamespaceURI().equals("jabber:x:data")) {
									DataForm completedForm = new DataForm(el);
									
									if (DataForm.Type.cancel.equals(completedForm.getType())) {
										// If the room was just created and the owner cancels 
										// the configuration form then destroy the room
										if (room.getMatch().getStatus() == MUGMatch.Status.created) {
											log.debug(locale.getLocalizedString("mug.config.debug.destroy")
													+ room.getName());
											service.removeGameRoom(room.getName());
										}
									}
									else if (DataForm.Type.submit.equals(completedForm.getType())) {
										// The owner is changing the current room configuration
										if (completedForm.getFields().size() != 0) {
											processConfigurationForm(completedForm);
										}
										room.getMatch().setConfiguration(null);
										roomConfigChanged = true;
									}
								}
								// process the match configuration
								else if (el.getName().equals("options")) {
									if (!el.getNamespaceURI().equals(room.getGame().getGameID().getNamespace()))
										throw new UnsupportedGameException();
									
									room.getMatch().setConfiguration(el.elements());
									roomConfigChanged = true;
								}
								// An unknown and possibly incorrect element was included in the
								// options element so answer a BAD_REQUEST error
								else {
									throw new IllegalArgumentException();
								}
							}
							// Inform the occupants that the configuration has changed
							if (roomConfigChanged)
								room.broadcastRoomPresence();
						}
						else {
							// The room can not be changed in an active or paused match status
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
	private void processConfigurationForm(DataForm completedForm) {
		Iterator<String> values;
		String booleanValue;
		FormField field;
		
		field = completedForm.getField("mug#roomconfig_roomname");
		if (field != null) {
			values = field.getValues().iterator();
			room.setNaturalLanguageName((values.hasNext() ? values.next() : " "));
		}
		
		field = completedForm.getField("mug#roomconfig_matchdesc");
		if (field != null) {
			values = field.getValues().iterator();
			room.setDescription((values.hasNext() ? values.next() : " "));
		}
		
		field = completedForm.getField("mug#roomconfig_moderated");
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			room.setModerated("1".equals(booleanValue) || "true".equals(booleanValue));
		}
		
		field = completedForm.getField("mug#roomconfig_allowinvites");
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			room.setAllowInvites("1".equals(booleanValue) || "true".equals(booleanValue));
		}
		
		field = completedForm.getField("mug#roomconfig_maxusers");
		if (field != null) {
			values = field.getValues().iterator();
			if (values.hasNext())
				room.setMaxOccupants(Integer.parseInt(values.next()));
		}
		
		field = completedForm.getField("mug#roomconfig_publicroom");
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			room.setPublicRoom("1".equals(booleanValue) || "true".equals(booleanValue));
		}
		
		field = completedForm.getField("mug#roomconfig_membersonly");
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			room.setMembersOnly("1".equals(booleanValue) || "true".equals(booleanValue));
		}
		
		field = completedForm.getField("mug#roomconfig_anonymity");
		if (field != null) {
			values = field.getValues().iterator();
			if (values.hasNext()) {
				String tempValue = values.next();
				if (tempValue.equals("fully-anonymous"))
					room.setAnonymity(DefaultMUGRoom.Anonymity.fullyAnonymous);
				else if (tempValue.equals("non-anonymous"))
					room.setAnonymity(DefaultMUGRoom.Anonymity.nonAnonymous);
				else
					room.setAnonymity(DefaultMUGRoom.Anonymity.semiAnonymous);
			}
		}
		
		field = completedForm.getField("mug#roomconfig_passwordprotectedroom");
		if (field != null) {
			values = field.getValues().iterator();
			booleanValue = (values.hasNext() ? values.next() : "1");
			if ("1".equals(booleanValue)) {
				field = completedForm.getField("mug#roomconfig_roomsecret");
				if (field != null) {
					values = field.getValues().iterator();
					room.setPassword((values.hasNext() ? values.next() : null ));
				}
			}
		}
	}
	
	/**
	 * Set the current room configuration as default values of the configuration form
	 */
	private void refreshConfigurationFormValues() {
		FormField field = configurationForm.getField("mug#roomconfig_roomname");
		field.clearValues();
		field.addValue(room.getNaturalLanguageName());
		
		field = configurationForm.getField("mug#roomconfig_matchdesc");
		field.clearValues();
		field.addValue(room.getDescription());
		
		field = configurationForm.getField("mug#roomconfig_moderated");
		field.clearValues();
		field.addValue((room.isModerated() ? "1" : "0"));
		
		field = configurationForm.getField("mug#roomconfig_allowinvites");
		field.clearValues();
		field.addValue((room.canOccupantsInvite() ? "1" : "0"));
		
		field = configurationForm.getField("mug#roomconfig_maxusers");
		field.clearValues();
		field.addValue(Integer.toString(room.getMaxOccupants()));
		
		field = configurationForm.getField("mug#roomconfig_publicroom");
		field.clearValues();
		field.addValue((room.isPublicRoom() ? "1" : "0"));
		
		field = configurationForm.getField("mug#roomconfig_membersonly");
		field.clearValues();
		field.addValue((room.isMembersOnly() ? "1" : "0"));
		
		field = configurationForm.getField("mug#roomconfig_anonymity");
		field.clearValues();
		if (room.isFullyAnonymous())
			field.addValue("fully-anonymous");
		else if (room.isNonAnonymous())
			field.addValue("non-anonymous");
		else
			field.addValue("semi-anonymous");
		
		field = configurationForm.getField("mug#roomconfig_passwordprotectedroom");
		field.clearValues();
		field.addValue((room.isPasswordProtected() ? "1" : "0"));
		
		field = configurationForm.getField("mug#roomconfig_roomsecret");
		field.clearValues();
		if (room.isPasswordProtected())
			field.addValue(room.getPassword());
		
		// Remove the old element
		gameOptionsElement.remove(gameOptionsElement.element(QName.get("x", "jabber:x:data")));
		// Add the new representation of configurationForm as an element 
		gameOptionsElement.add(configurationForm.getElement());
		gameOptionsElement.remove(gameOptionsElement.element(QName.get("options", room.getGame().getGameID().getNamespace())));
		Element gameOptions = gameOptionsElement.addElement("options", room.getGame().getGameID().getNamespace());
		Collection<Element> gameConfig = room.getMatch().getConfigurationForm();
		if (gameConfig != null) {
			for (Iterator<Element> it=gameConfig.iterator();it.hasNext();) {
				gameOptions.add(it.next());
			}
		}
	}
	
	/**
	 * Generating the configuration form
	 */
	private void initConfigForm() {
		Element element = DocumentHelper.createElement(QName.get("query",
				MUGService.mugNS + "#owner"));
		
		configurationForm = new DataForm(DataForm.Type.form);
		configurationForm.setTitle(
				locale.getLocalizedString("mug.config.form.title.1")
				+ " " + room.getName() + " "
				+ locale.getLocalizedString("mug.config.form.title.2"));
		List<String> params = new ArrayList<String>();
		params.add(room.getName());
		configurationForm.addInstruction(
				locale.getLocalizedString("mug.config.form.instruction"));
		
		FormField field = configurationForm.addField();
		field.setVariable("FORM_TYPE");
		field.setType(FormField.Type.hidden);
		field.addValue(MUGService.mugNS + "#matchconfig");
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_roomname");
		field.setType(FormField.Type.text_single);
		field.setLabel(locale.getLocalizedString("mug.config.form.name"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_matchdesc");
		field.setType(FormField.Type.text_single);
		field.setLabel(locale.getLocalizedString("mug.config.form.description"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_moderated");
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString("mug.config.form.moderated"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_allowinvites");
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString("mug.config.form.allowinvites"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_maxusers");
		field.setType(FormField.Type.list_single);
		field.setLabel(locale.getLocalizedString("mug.config.form.maxusers"));
		field.addOption("10", "10");
		field.addOption("20", "20");
		field.addOption("30", "30");
		field.addOption("40", "40");
		field.addOption("50", "50");
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_publicroom");
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString("mug.config.form.publicroom"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_membersonly");
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString("mug.config.form.membersonly"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_anonymity");
		field.setType(FormField.Type.list_single);
		field.setLabel(locale.getLocalizedString("mug.config.form.anonymity"));
		field.addOption(
				locale.getLocalizedString("mug.config.form.anonymity.fully"),
				"fully-anonymous");
		field.addOption(
				locale.getLocalizedString("mug.config.form.anonymity.semi"),
				"semi-anonymous");
		field.addOption(
				locale.getLocalizedString("mug.config.form.anonymity.non"),
				"non-anonymous");
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_passwordprotectedroom");
		field.setType(FormField.Type.boolean_type);
		field.setLabel(locale.getLocalizedString("mug.config.form.password.protected"));
		
		field = configurationForm.addField();
		field.setType(FormField.Type.fixed);
		field.addValue(locale.getLocalizedString("mug.config.form.password.instruction"));
		
		field = configurationForm.addField();
		field.setVariable("mug#roomconfig_roomsecret");
		field.setType(FormField.Type.text_private);
		field.setLabel(locale.getLocalizedString("mug.config.form.password"));
		
		
		gameOptionsElement = element.addElement("options");
		gameOptionsElement.add(configurationForm.getElement());
		probeResult = element;
	}
}
