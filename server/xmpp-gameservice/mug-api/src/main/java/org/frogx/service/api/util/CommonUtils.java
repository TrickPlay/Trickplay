package org.frogx.service.api.util;

import java.util.StringTokenizer;
import java.util.regex.Pattern;

import org.frogx.service.api.AppID;
import org.frogx.service.api.GameID;

public class CommonUtils {
	
	private static final String APP_NS_PREFIX = "urn:xmpp:mug:tp:";
	private static final Pattern validNamePattern = Pattern.compile("^([a-zA-Z][a-zA-Z0-9_\\.\\-]*){4,}$");

	public static boolean isValidWord(String x) {
		 return validNamePattern.matcher(x).matches();
	}
	
	
	public static String buildAppNS(AppID appID) {
		return APP_NS_PREFIX+appID.getName()+":"+Integer.toString(appID.getVersion());
	}
	
	public static String buildGameNS(AppID appID, String gameName) {
		return buildAppNS(appID) + ":" + gameName;
	}

	public static String buildGameNS(GameID gameID) {
		return buildGameNS(gameID.getAppID(), gameID.getName());
	}
	
	/**
	 *  either gamens or appns should be passed as an input argument
	 * @param namespace game or app namespace
	 * @return AppID
	 */
	public static AppID extractAppID(String namespace) {
		if (namespace == null || !namespace.startsWith(APP_NS_PREFIX))
			throw new IllegalArgumentException("provided namespace:"+namespace+" doesn't correspond to a valid game or app namespace");
		String nsSuffix = namespace.substring(APP_NS_PREFIX.length());
		StringTokenizer tokens = new StringTokenizer(nsSuffix, ":");
		int numTokens = tokens.countTokens();
		if (numTokens < 2)
			throw new IllegalArgumentException("provided namespace:"+namespace+" doesn't contain app name and version tokens");
		String name = tokens.nextToken();
		String versionstr = tokens.nextToken();
		
		int version = -1;
		try {
			version = Integer.parseInt(versionstr);
		} catch (NumberFormatException ex) {
		//	throw new IllegalArgumentException("provided namespace:"+namespace+" has invalid value for app version. version:"+versionstr);
		}
		if (version < 0)
			throw new IllegalArgumentException("provided namespace:"+namespace+" has invalid value for app version. version:"+versionstr);
		
		return new AppID(name, version);
	}
	
	public static String extractGameName(String gamens) {
		if (gamens == null || !gamens.startsWith(APP_NS_PREFIX))
				throw new IllegalArgumentException("provided namespace:"+gamens+" doesn't correspond to a valid game or app namespace");
			String nsSuffix = gamens.substring(APP_NS_PREFIX.length());
			StringTokenizer tokens = new StringTokenizer(nsSuffix, ":");
			int numTokens = tokens.countTokens();
			if (numTokens != 3)
				throw new IllegalArgumentException("provided namespace:"+gamens+" doesn't contain app name, version and game name tokens");
		
			tokens.nextToken(); //skip app name token
			tokens.nextToken(); //skip app version token
			return tokens.nextToken();
	}
	
	public static void main(String[] args) {
		AppID tpID = new AppID("trickplay", 1);
		String appNS = buildAppNS(tpID);
		System.out.println(tpID + " namespace is " + appNS); 
		
		String gameNS = buildGameNS(tpID, "chess");
		System.out.println(tpID + " namespace for game chess is " + gameNS);
		
		String sampleGameNS = "urn:xmpp:mug:tp:sampleapp:1:sample";
		System.out.println("extracted appID from sample namespace:"+sampleGameNS+ " is "+extractAppID(sampleGameNS));
		
		System.out.println("extracted gameName from sample namespace:"+sampleGameNS+ " is "+extractGameName(sampleGameNS));
	}

}
