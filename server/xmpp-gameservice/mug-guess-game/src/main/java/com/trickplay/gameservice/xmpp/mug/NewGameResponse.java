package com.trickplay.gameservice.xmpp.mug;

import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.IQProvider;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;


public class NewGameResponse implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#owner";
	public static final String name = "newGameResponse";
    private String retcode;
    private String gameId;
    
	public String getRetcode() {
		return retcode;
	}
	
	public void setRetcode(String retcode) {
		this.retcode = retcode;
	}
	
	public String getGameId() {
		return gameId;
	}
	
	public void setGameId(String gameId) {
		this.gameId = gameId;
	}
	
	public String getElementName() {
		return name;
	}
	public String toXML() {
		return "<newGameResponse xmlns='"+NAMESPACE+"' retcode='"+retcode+"' gameid='"+gameId+"'/>";
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}
	
	public static class Provider implements PacketExtensionProvider, IQProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			NewGameResponse resp = new NewGameResponse();
			resp.setRetcode(parser.getAttributeValue("", "retcode"));
			resp.setGameId(parser.getAttributeValue("", "gameId"));
            // Advance to end of extension.
            parser.next();
            return resp;
		}

		public IQ parseIQ(XmlPullParser parser) throws Exception {
			final NewGameResponse resp = (NewGameResponse) parseExtension(parser);
			return new IQ() {

				@Override
				public String getChildElementXML() {
					return resp.toXML();
				}
				
			};
		}
		
	}
}
