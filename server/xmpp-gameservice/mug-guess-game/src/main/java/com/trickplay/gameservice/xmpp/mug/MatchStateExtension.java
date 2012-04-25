package com.trickplay.gameservice.xmpp.mug;

import java.util.ArrayList;
import java.util.List;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;



public class MatchStateExtension implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug/generic-turn-based-game";
	public static final String name = "state";
    private String opaque;
    private boolean terminated;
    private String first;
    private String next;
    private String last;
    private List<String> players = new ArrayList<String>();
    
	public MatchStateExtension() {
    	
    }
    
	
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element stateElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));

		if (first!=null)
			stateElement.addElement("first").setText(first);
		if (opaque!=null)
			stateElement.addElement("opaque").setText(opaque);
		else
			stateElement.addElement("opaque");

		Element roles = stateElement.addElement("roles");
		for(String role : getPlayers()) {
			roles.addElement("role").setText(role);
		}
		if (next != null)
			stateElement.addElement("next").setText(next);
		if (last != null)
			stateElement.addElement("last").setText(last);
		if (terminated)
			stateElement.addElement("terminated");
		
		return stateElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	

	public boolean isTerminated() {
		return terminated;
	}

	public void setTerminated(boolean terminated) {
		this.terminated = terminated;
	}

	public String getNext() {
		return next;
	}

	public void setNext(String next) {
		this.next = next;
	}

	public String getLast() {
		return last;
	}

	public void setLast(String last) {
		this.last = last;
	}


	public String getOpaque() {
		return opaque;
	}


	public void setOpaque(String opaque) {
		this.opaque = opaque;
	}


	public String getFirst() {
		return first;
	}


	public void setFirst(String first) {
		this.first = first;
	}

    public List<String> getPlayers() {
		return players;
	}


	public void setPlayers(List<String> players) {
		this.players = players;
	}




	public static class Provider implements PacketExtensionProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			MatchStateExtension resp = new MatchStateExtension();
			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
						if (parser.getName().equals("opaque")) {
							resp.setOpaque(parser.nextText());
						} else if (parser.getName().equals("terminated")) {
							resp.setTerminated(true);
						} else if (parser.getName().equals("first")) {
							resp.setFirst(parser.nextText());
						} else if (parser.getName().equals("last")) {
							resp.setLast(parser.nextText());
						} else if (parser.getName().equals("next")) {
							resp.setNext(parser.nextText());
						} else if (parser.getName().equals("role")) {
							resp.getPlayers().add(parser.nextText());
						}
					}
						
					else if (eventType == XmlPullParser.END_TAG) {
						if (parser.getName().equals(name)) {
							done = true;
						}
					}
				}
            return resp;
		}
	}



	
}
