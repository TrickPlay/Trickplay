package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class StartMessageExtension implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#user";
	public static final String name = "start";
    
    public StartMessageExtension() {
    }
    
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element startElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));
		
		return startElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	
}
