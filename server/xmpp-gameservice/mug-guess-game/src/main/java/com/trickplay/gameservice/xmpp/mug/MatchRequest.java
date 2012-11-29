package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;

public class MatchRequest implements PacketExtension {

	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	//public static final String name = "game";
	public static final String name = "matchrequest";
	private String role;
	private String nick;
	private String gameId;

	public MatchRequest(String gameId, String role, String nick) {
		this.setGameId(gameId);
		this.role = role;
		this.nick = nick;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}

	public void setNick(String nick) {
		this.nick = nick;
	}

	public String getNick() {
		return nick;
	}

	public String toXML() {
		return toXMLElement().asXML();
	}

	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get(name,
				NAMESPACE));
		gameElement.addAttribute("gameId", gameId);
	//	Element itemElement = gameElement.addElement("item");
		if (role != null && !role.isEmpty()) {
			gameElement.addElement("role").setText(role);
		} else {
			gameElement.addElement("freerole");
		}
		if (nick != null && !nick.isEmpty()) {
			gameElement.addElement("nickname").setText(nick);
		}

		return gameElement;
	}

	public void setGameId(String gameId) {
		this.gameId = gameId;
	}

	public String getGameId() {
		return gameId;
	}


}
