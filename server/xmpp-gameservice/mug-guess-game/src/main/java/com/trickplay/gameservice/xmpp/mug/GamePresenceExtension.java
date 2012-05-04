package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;

public class GamePresenceExtension implements PacketExtension {

	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "game";
	
	public static class Item {
		private String role;
		private String affiliation;
		private String jid;
		private String nick;
		
		public Item() {
			
		}
		
		public Item(String role, String affiliation, String jid, String nick) {
			super();
			this.role = role;
			this.affiliation = affiliation;
			this.jid = jid;
			this.nick = nick;
		}
		public String getRole() {
			return role;
		}
		public void setRole(String role) {
			this.role = role;
		}
		public String getAffiliation() {
			return affiliation;
		}
		public void setAffiliation(String affiliation) {
			this.affiliation = affiliation;
		}
		public String getJid() {
			return jid;
		}
		public void setJid(String jid) {
			this.jid = jid;
		}
		public String getNick() {
			return nick;
		}
		public void setNick(String nick) {
			this.nick = nick;
		}
		
		public String toXML() {
			StringBuilder builder = new StringBuilder();
			builder.append("<item ");
			if (role!=null)
				builder.append("role='").append(role).append("' ");
			if (affiliation!=null)
				builder.append("affiliation='").append(affiliation).append("' ");
			if (jid!=null)
				builder.append("jid='").append(jid).append("' ");
			if (nick!=null)
				builder.append("nick='").append(nick).append("' ");
			builder.append("/>");
			return builder.toString();
		}
	}
	
	private Item item;
	
	private String status;
	private MatchStateExtension state;

	private Type type;

	public enum Type {
		Occupant, NickChanged, Status
	}

	public GamePresenceExtension() {
		item = new Item();
	}


	public void setItem(Item item) {
		this.item = item;
	}


	public Item getItem() {
		return item;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public MatchStateExtension getState() {
		return state;
	}

	public void setType(Type type) {
		this.type = type;
	}

	public Type getType() {
		return type;
	}

	public void setState(MatchStateExtension state) {
		this.state = state;
	}

	public String toXML() {
		return toXMLElement().asXML();
	}

	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get(name,
				NAMESPACE));

		if (Type.Occupant.equals(type)) {
			Element item = gameElement.addElement("item");
			if (getItem().getRole() != null)
				item.addAttribute("role", getItem().getRole());
			if (getItem().getAffiliation() != null)
				item.addAttribute("affiliation", getItem().getAffiliation());
			else
				item.addAttribute("affliliation", "none");
			if (getItem().getJid() != null)
				item.addAttribute("jid", getItem().getJid());

		} else if (Type.NickChanged.equals(type)) {
			Element item = gameElement.addElement("item");
			item.addAttribute("nick", getItem().getNick());
		} else if (Type.Status.equals(type)) {
			Element statusElement = gameElement.addElement("status");
			statusElement.setText(status);
			if (state != null)
				gameElement.add(state.toXMLElement());

		}

		return gameElement;
	}

	public static class Provider implements PacketExtensionProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			GamePresenceExtension resp = new GamePresenceExtension();
			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
					if (resp.getType() == null
							&& parser.getName().equals("item")) {
						if (parser.getAttributeValue(null, "nick") != null) {
							resp.setType(Type.NickChanged);
							resp.getItem().setNick(parser.getAttributeValue(null, "nick"));
						} else {
							resp.setType(Type.Occupant);
							resp.getItem().setRole(parser.getAttributeValue(null, "role"));
							resp.getItem().setAffiliation(parser.getAttributeValue(null,
									"affiliation"));
							resp.getItem().setJid(parser.getAttributeValue(null, "jid"));
						}
					} else if (resp.getType() == null && parser.getName().equals("status")) {
						resp.setType(Type.Status);
						resp.setStatus(parser.nextText());
					} else if (Type.Status.equals(resp.getType())) {
						if (parser.getName().equals("state")) {
							MatchStateExtension.Provider provider = new MatchStateExtension.Provider();
							resp.setState((MatchStateExtension) provider
									.parseExtension(parser));
						}
					}

				} else if (eventType == XmlPullParser.END_TAG) {
					if (parser.getName().equals(name)) {
						done = true;
					}
				}
			}
			return resp;
		}
	}

	public String getElementName() {
		return name;
	}


	public String getNamespace() {
		return NAMESPACE;
	}

}
