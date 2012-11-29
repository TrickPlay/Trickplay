package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class RegisterApp implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#owner";
	public static final String ELEMENT_NAME = "registerapp";
    
	private String appname;
	private int appversion;
	
    public String getNamespace() {
    	return NAMESPACE;
    }
	public String getElementName() {
		return ELEMENT_NAME;
	}
	

	public String getAppname() {
		return appname;
	}
	public void setAppname(String appname) {
		this.appname = appname;
	}
	public int getAppversion() {
		return appversion;
	}
	public void setAppversion(int appversion) {
		this.appversion = appversion;
	}
	//	public boolean 
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element rootElement = DocumentHelper.createElement(QName.get(ELEMENT_NAME,
				NAMESPACE));


		rootElement.addElement("name").setText(getAppname());
		rootElement.addElement("version").setText(Integer.toString(getAppversion()));
		return rootElement;
	}
	


}
