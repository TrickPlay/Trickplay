package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;


public class TurnMessage implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#user";
	public static final String name = "turn";
    
	private String newState;
	private boolean terminate;	
	private String nextTurn;
	private boolean onlyUpdate;
	
	public String getNewState() {
		return newState;
	}

	public void setNewState(String newState) {
		this.newState = newState;
	}

	public String getNextTurn() {
		return nextTurn;
	}

	public void setNextTurn(String nextTurn) {
		this.nextTurn = nextTurn;
	}

	public boolean isTerminate() {
		return terminate;
	}

	public void setTerminate(boolean terminate) {
		this.terminate = terminate;
	}
	
	public boolean isOnlyUpdate() {
		return onlyUpdate;
	}
	
	public void setOnlyUpdate(boolean updateFlag) {
		onlyUpdate = updateFlag;
	}
	
	public TurnMessage() {
		this("", false);
	}

    public TurnMessage(String newState) {
    	this(newState, false);
    }
    
    public TurnMessage(String newState, boolean terminate) {
    	this.newState = newState;
    	this.terminate = terminate;
    }
    
    public TurnMessage(String newState, String nextTurn) {
    	this(newState, false);
    	this.nextTurn = nextTurn;
    }
    
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element startElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));
		startElement.addElement("newstate").add(DocumentHelper.createCDATA(newState != null ? newState : ""));
		
		if (terminate) {
			startElement.addElement("terminate");
		} else {
			if (nextTurn != null)
				startElement.addElement("next").setText(nextTurn);
			else if (onlyUpdate) {
				startElement.addElement("only-update");
			}
		}
		
		return startElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	
}
