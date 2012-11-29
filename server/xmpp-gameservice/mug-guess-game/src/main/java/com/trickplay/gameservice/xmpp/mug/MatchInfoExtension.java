package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;

public class MatchInfoExtension implements PacketExtension {

	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "match";

	private String matchId;
	private String status;
	private String nickname;
	private String inRoomId;

	private MatchStateExtension state;

	public MatchInfoExtension() {
	}

	public MatchInfoExtension(String matchId, String status) {
		this.matchId = matchId;
		this.status = status;
	}

	public String getMatchId() {
		return matchId;
	}

	public void setMatchId(String matchId) {
		this.matchId = matchId;
	}

	public void setState(MatchStateExtension state) {
		this.state = state;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String name) {
		this.nickname = name;
	}

	public String getInRoomId() {
		return inRoomId;
	}

	public void setInRoomId(String inRoomId) {
		this.inRoomId = inRoomId;
	}

	public String getElementName() {
		// TODO Auto-generated method stub
		return name;
	}

	public String getNamespace() {
		// TODO Auto-generated method stub
		return NAMESPACE;
	}

	public String toXML() {
		return toXMLElement().asXML();
	}

	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get(name,
				NAMESPACE));

		gameElement.addAttribute("matchId", matchId);

		Element statusElement = gameElement.addElement("status");
		statusElement.setText(status);
		if (state != null)
			gameElement.add(state.toXMLElement());

		return gameElement;
	}

	public static class Provider implements PacketExtensionProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			MatchInfoExtension resp = new MatchInfoExtension();
			resp.setMatchId(parser.getAttributeValue("", "matchId"));
			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
					if (parser.getName().equals("status")) {
						resp.setStatus(parser.nextText());
					} else if (parser.getName().equals("nickname")) {
						resp.setNickname(parser.nextText());
					} else if (parser.getName().equals("inRoomId")) {
						resp.setInRoomId(parser.nextText());
					} else if (parser.getName().equals("state")) {
							MatchStateExtension.Provider provider = new MatchStateExtension.Provider();
							resp.setState((MatchStateExtension) provider
									.parseExtension(parser));
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


}
