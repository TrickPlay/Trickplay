package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class CreateMatch implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#owner";
	public static final String name = "game";
    private String gameId;
    
    public CreateMatch(String gameId) {
    	this.gameId = gameId;
    }
    
	public String getGameId() {
		return gameId;
	}
	
	public void setGameId(String gameId) {
		this.gameId = gameId;
	}
	
	
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get("game", NAMESPACE));
		gameElement.addAttribute("gameId", gameId);
		
		
		return gameElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	
}
