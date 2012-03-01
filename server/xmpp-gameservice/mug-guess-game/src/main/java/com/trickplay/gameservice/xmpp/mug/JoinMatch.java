package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class JoinMatch implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "game";
    private String role;
    private boolean freerole;
    
    public JoinMatch(boolean freerole) {
    	this.freerole = freerole;
    	role = null;
    }
    public JoinMatch(String role) {
    	this.role = role;
    	this.freerole = false;
    }
    
	public String getRole() {
		return role;
	}
	
	public void setRole(String role) {
		this.role = role;
	}
	
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));
		if (freerole)
			gameElement.addElement("item");
		else {
			if (role != null && !role.isEmpty()) {
				gameElement.addElement("item").addAttribute("role", role);
			}
		}
				
		return gameElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	
}
