package com.trickplay.gameservice.xmpp.mug;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.IQProvider;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;

import com.trickplay.gameservice.xmpp.mug.Game.RoleConfig;


public class RegisterGame implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#owner";
	public static final String ELEMENT_NAME = "registergame";
    
	private Game game;
	
    public String getNamespace() {
    	return NAMESPACE;
    }
	public String getElementName() {
		return ELEMENT_NAME;
	}	

	public void setGame(Game game) {
		this.game = game;
	}
	public Game getGame() {
		return game;
	}
	//	public boolean 
	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element rootElement = DocumentHelper.createElement(QName.get(ELEMENT_NAME,
				NAMESPACE));

		Element appe = rootElement.addElement("app");
		appe.addAttribute("name", game.getAppname());
		appe.addAttribute("version", Integer.toString(game.getAppversion()));
		
		rootElement.addElement("name").setText(game.getName());
		Element e = rootElement.addElement("description");
		if (game.getDescription() != null)
			e.setText(game.getDescription());
		
		e = rootElement.addElement("category");
		if (game.getCategory() != null)
			e.setText(game.getCategory());
		rootElement.addElement("gameType").setText(game.getGameType().name());
		rootElement.addElement("turnPolicy").setText(game.getTurnPolicy().name());
		
		if (game.getRoles() != null) {
			Element rolesElement = rootElement.addElement("roles");
			for(RoleConfig r : game.getRoles()) {
				Element roleElement = rolesElement.addElement("role");
				if (r.isFirstRole())
					roleElement.addElement("firstRole");
				if (r.isCannotStart())
					roleElement.addElement("cannotStart");
				roleElement.setText(r.getRole());
			}
		}
		rootElement.addElement("joinAfterStart").setText(Boolean.toString(game.isJoinAfterStart()));
		e = rootElement.addElement("minPlayersForStart");
		e.setText(Integer.toString(game.getMinPlayersForStart()>0 ? game.getMinPlayersForStart() : 1));
		
		if (game.getMaxDurationPerTurn()>0) {
			rootElement.addElement("maxDurationPerTurn").setText(Long.toString(game.getMaxDurationPerTurn()));
		}

		rootElement.addElement("abortWhenPlayerLeaves").setText(Boolean.toString(game.isAbortWhenPlayerLeaves()));
		return rootElement;
	}
	
	/*
	public static class Provider implements PacketExtensionProvider, IQProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			RegisterGame resp = new RegisterGame();
			
			//resp.setRetcode(parser.getAttributeValue("", "retcode"));
		//	resp.setGameId(parser.getAttributeValue("", "gameId"));
			

			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {


				} else if (eventType == XmlPullParser.END_TAG) {
					if (parser.getName().equals(ELEMENT_NAME)) {
						done = true;
					}
				}
			}
			return resp;
            
		}

		public IQ parseIQ(XmlPullParser parser) throws Exception {
			final RegisterGame resp = (RegisterGame) parseExtension(parser);
			return new IQ() {

				@Override
				public String getChildElementXML() {
					return resp.toXML();
				}
				
			};
		}
		
	}
	*/
}
