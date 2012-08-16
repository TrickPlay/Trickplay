package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class OpenApp implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "app";
    private String appId;
    
    public OpenApp(String appId) {
    	this.appId = appId;
    }
    
	public String getAppId() {
		return appId;
	}
	
	public void setAppId(String appId) {
		this.appId = appId;
	}
	
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element appElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));
		appElement.addAttribute("appId", appId);
		
		return appElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	
}
