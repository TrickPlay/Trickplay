package com.trickplay.gameservice.xmpp.mug;

import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;



public class TurnExtension extends TurnMessage implements PacketExtension {
	
    
    
	public TurnExtension() {
    	super();
    }
    
	



	public static class Provider implements PacketExtensionProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			TurnExtension resp = new TurnExtension();
			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
						if (parser.getName().equals("newstate")) {
							resp.setNewState(parser.nextText());
						} else if (parser.getName().equals("terminate")) {
							resp.setTerminate(true);
						} else if (parser.getName().equals("next")) {
							resp.setNextTurn(parser.nextText());
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
