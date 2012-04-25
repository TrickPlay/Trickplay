package com.trickplay.gameservice.xmpp.mug;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.provider.IQProvider;
import org.jivesoftware.smack.provider.PacketExtensionProvider;
import org.xmlpull.v1.XmlPullParser;



public class GameDataExtension implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug";
	public static final String name = "gamedata";
    private String userdata;
    private List<MatchInfoExtension> matchdata = new ArrayList<MatchInfoExtension>();
    private Integer version;
    private String gameId;
    private Type dataType;
    
    public enum Type {
    	USERDATA, MATCHDATA
    }
    
	public GameDataExtension(String gameId, String userdata, Integer version) {
		this(gameId, Type.USERDATA);
		
		this.userdata = userdata;
		this.version = version;
	}

	public GameDataExtension(String gameId, Type datatype) {
		this.gameId = gameId;
		this.setDataType(datatype);
    }
	
	public GameDataExtension(String gameId, List<MatchInfoExtension> matchData) {
		this(gameId, Type.MATCHDATA);
		if (matchData!=null)
			this.matchdata.addAll(matchData);
    }
	
	public GameDataExtension() {		
    }
    
	
	public void setDataType(Type dataType) {
		this.dataType = dataType;
	}

	public Type getDataType() {
		return dataType;
	}

	public void setMatchdata(List<MatchInfoExtension> matchData) {
		this.matchdata.clear();
		this.matchdata.addAll(matchData);
	}

	public void addMatchInfo(MatchInfoExtension matchInfo) {
		matchdata.add(matchInfo);
	}
	
	public List<MatchInfoExtension> getMatchdata() {
		return matchdata;
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
		Element rootElement = Type.USERDATA.equals(dataType) ? 
				DocumentHelper.createElement(QName.get("userdata", NAMESPACE))
				:
					DocumentHelper.createElement(QName.get("matchdata", NAMESPACE))	;

		if (gameId != null)
			rootElement.addAttribute("gameId", gameId);
		if (Type.USERDATA.equals(dataType)) {
			Element userElem = rootElement.addElement("opaque");
			if (userdata!=null)
				userElem.add(DocumentHelper.createCDATA(userdata));
			
			if (version != null)
				userElem.addAttribute("version", version.toString());
		} else {
			Element matchdataElem = rootElement;
			for(MatchInfoExtension matchinfo : matchdata) {
				matchdataElem.add(matchinfo.toXMLElement());
			}
		}
		return rootElement;
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
			GameDataExtension resp = new GameDataExtension();
//			Map<String,String> attributeMap = getAttributes(parser);
			resp.setGameId(parser.getAttributeValue(null, "gameId"));
			boolean done = false;
			boolean processingMatchdata = false;
			while (!done) {
				int eventType = parser.next();
				if (eventType == XmlPullParser.START_TAG) {
						System.out.println("processing element:"+parser.getName());
						if (parser.getName().equals("userdata")) {
							resp.setDataType(Type.USERDATA);
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
						else if (parser.getName().equals("matchdata")) {
							processingMatchdata = true;
							resp.setDataType(Type.MATCHDATA);
						}
						else if (processingMatchdata && parser.getName().equals("match")) {
							MatchInfoExtension.Provider p = new MatchInfoExtension.Provider();
							resp.addMatchInfo((MatchInfoExtension)p.parseExtension(parser));
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
			final GameDataExtension gameData = (GameDataExtension)parseExtension(parser);
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
