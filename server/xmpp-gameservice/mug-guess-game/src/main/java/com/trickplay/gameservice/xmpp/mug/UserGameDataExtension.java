package com.trickplay.gameservice.xmpp.mug;

import java.util.HashMap;
import java.util.Map;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.IQProvider;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;



public class UserGameDataExtension implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "gamedata";
    private String userdata;
    private Integer version;
    private String gameId;
    
	public UserGameDataExtension(String gameId, String userdata, Integer version) {
		super();
		
		this.gameId = gameId;
		this.userdata = userdata;
		this.version = version;
	}


	public UserGameDataExtension(String gameId) {
		this(gameId, null, null);
    }
	
	public UserGameDataExtension() {
    }
    
	
	public void setGameId(String gameId) {
		this.gameId = gameId;
	}


	public String getGameId() {
		return gameId;
	}


	public String getUserdata() {
		return userdata;
	}


	public void setUserdata(String userdata) {
		this.userdata = userdata;
	}


	public Integer getVersion() {
		return version;
	}


	public void setVersion(Integer version) {
		this.version = version;
	}


	public String toXML() {
		return toXMLElement().asXML();
	}
	
	public Element toXMLElement() {
		Element gameElement = DocumentHelper.createElement(QName.get(name, NAMESPACE));

		if (gameId != null)
			gameElement.addAttribute("gameId", gameId);
		
		Element userDataElem = gameElement.addElement("userdata");
		if (userdata!=null)
			userDataElem.add(DocumentHelper.createCDATA(userdata));
		
		if (version != null)
			userDataElem.addAttribute("version", version.toString());

		return gameElement;
	}
	
	public String getNamespace() {
		return NAMESPACE;
	}

	public String getElementName() {
		return name;
	}
	



	public static class Provider implements PacketExtensionProvider, IQProvider {

		public PacketExtension parseExtension(XmlPullParser parser)
				throws Exception {
			UserGameDataExtension resp = new UserGameDataExtension();
//			Map<String,String> attributeMap = getAttributes(parser);
			resp.setGameId(parser.getAttributeValue(null, "gameId"));
			boolean done = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
						System.out.println("processing element:"+parser.getName());
						if (parser.getName().equals("userdata")) {
							String versionStr = parser.getAttributeValue(null, "version");
							resp.setUserdata(parser.nextText());
							if (versionStr != null) {
								int version = -1;
								try {
									version = Integer.parseInt(versionStr);
								} catch (Exception e) {
									System.out.println("failed to parse value for version attribute. value="+versionStr);
								}
								if (version!=-1) {
									resp.setVersion(version);
								}
							}
						} 
					}
						
					else if (eventType == XmlPullParser.END_TAG) {
						if (parser.getName().equals(name)) {
					//		resp.setGameId(parser.getAttributeValue("", "gameId"));
							done = true;
						}
					}
				}
            return resp;
		}

		public IQ parseIQ(XmlPullParser parser) throws Exception {
			final UserGameDataExtension gameData = (UserGameDataExtension)parseExtension(parser);
			IQ iq = new IQ() {

				@Override
				public String getChildElementXML() {
					PacketExtension ext = getExtension(name, NAMESPACE);
					return (ext != null) ? ext.toXML() : null;						
				}
				
			};
			iq.addExtension(gameData);
			return iq;
		}
		
		private Map<String,String>  getAttributes(XmlPullParser parser) throws Exception {
		    Map<String,String> attrs=null;
		    int cnt=parser.getAttributeCount();
		    if(cnt != -1) {
		        System.out.println("Attributes for ["+parser.getName()+"]");
		        attrs = new HashMap<String,String>(cnt);
		        for(int x=0;x<cnt;x++) {
		        	System.out.println("\t["+parser.getAttributeName(x)+"]=" +
		                    "["+parser.getAttributeValue(x)+"]");
		            attrs.put(parser.getAttributeName(x), parser.getAttributeValue(x));
		        }
		    }
		    
		    return attrs;
		}
	}



	
}
