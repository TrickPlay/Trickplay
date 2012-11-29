package org.frogx.service.games.common;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.dom4j.Element;
import org.frogx.service.api.AppID;
import org.frogx.service.api.GameID;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.frogx.service.core.RoleConfigImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GenericTurnBasedMUG implements MultiUserGame{
	private static final String[] kEmptyStringArray = {};
	private static final Logger log = LoggerFactory.getLogger(GenericTurnBasedMUG.class);
	
	private static final long TURN_TIME_LIMIT_CORRESPONDENCE = 1000 * 24 * 60 * 60 * 5; // 5 days in millis
	private static final long TURN_TIME_LIMIT_ONLINE = 1000 * 5 * 60; // 5 minutes in millis
	
	private MUGManager mugManager;
	
	private Map<String, MUGMatch> matches = new ConcurrentHashMap<String, MUGMatch>();
	
	private String name;
	
	private GameType gameType = GameType.correspondence;
	private TurnPolicy turnPolicy = TurnPolicy.roundrobin;
	private String namespace;
	
	private String description;
	private String category;
	private Map<String, Integer> roleToIndexMap = new LinkedHashMap<String, Integer>();
	private String[] roles = kEmptyStringArray;
	private String firstRole;
	private Set<GameAttribute> attributes = new LinkedHashSet<GameAttribute>();

	private Map<String, RoleConfig> roleConfigMap = new LinkedHashMap<String, RoleConfig>();
	private int minPlayersForStart = -1;
	private boolean joinAfterStart = true;
	private boolean abortWhenPlayerLeaves = true;
	private long maxDurationPerTurn=-1;
	private GameID gameID;
	
	public GenericTurnBasedMUG(MUGManager mugManager, Element gameDescriptor) {
		this.mugManager = mugManager;
		readGameDescriptor(gameDescriptor);
	}
	
	/**
	 * Read the provided game descriptor and update the plug-in attributes.
	 * 
	 * @param gameDescriptor The file which describes the game descriptor.
	 * @throws IllegalArgumentException if gameDescriptor cannot be read or has all the necessary attributes defined.
	 */
	@SuppressWarnings("unchecked")
	private void readGameDescriptor(Element gameDescriptor) {
		int cntPlayersCannotStart = 0;
	//	boolean processRoles = false;
		String appname = "";
		int appversion=-1;
		List<String> roleList = new ArrayList<String>();
		for (Iterator i = gameDescriptor.elementIterator(); i.hasNext();) {
			Element child = (Element) i.next();
			if ("app".equals(child.getName())) {
				appname = child.attributeValue("name");
				String versionstr = child.attributeValue("version");
				try {
					appversion = Integer.parseInt(versionstr);
				} catch (Exception e) {
					log.warn("Invalid value specified for app.version: "+appversion);					
				}
			} else if ("name".equals(child.getName())) {
				name = child.getText();
				namespace = MUGService.mugNS + "/" + name;
			} else if ("description".equals(child.getName())) {
				description = child.getText();
			} else if ("category".equals(child.getName())) {
				category = child.getText();
			} else if ("roles".equals(child.getName())) {
		//		processRoles = true;
			//} else if (processRoles && "role".equals(child.getName())) {
				List<Element> rolesList = (List<Element>)child.elements("role");
				if (rolesList == null)
					continue;
				for(Element roleElem: rolesList) {
					roleList.add(roleElem.getName());
					RoleConfigImpl rc = new RoleConfigImpl(roleElem.getTextTrim());
					if (roleElem.element("firstRole") != null) {
						firstRole = rc.getRole();
						rc.setFirstRole(true);
					}
					if (roleElem.element("cannotStart") != null) {
						rc.setNotAllowedToStart(true);
						cntPlayersCannotStart++;
					}
					roleConfigMap.put(rc.getRole(), rc);
				}
			} else if ("gameType".equals(child.getName())) {
				gameType = GameType.fromString(child.getTextTrim());
			} else if ("turnPolicy".equals(child.getName())) {
				turnPolicy = TurnPolicy.fromString(child.getTextTrim());
			} else if ("minPlayersForStart".equals(child.getName())) {
				try {
					minPlayersForStart = Integer.parseInt(child.getTextTrim());
				} catch (NumberFormatException ex) {
					log.warn("Invalid value specified for minPlayersForStart in game="+name+". defaulting to number of specified roles");
					minPlayersForStart = -1;
				}
				
			} else if ("joinAfterStart".equals(child.getName())) {
				try {
					joinAfterStart = Boolean.valueOf(child.getTextTrim());
				} catch (Exception e) {
					log.warn("Invalid value specified for joinAfterStart in game="+name+". defaulting to true");
					joinAfterStart = true;
				}
			} else if ("abortWhenPlayerLeaves".equals(child.getName())) {
				try {
					abortWhenPlayerLeaves = Boolean.valueOf(child.getTextTrim());
				} catch (Exception e) {
					log.warn("Invalid value specified for abortOnIdleTimeout in game="+name+". defaulting to true");
					abortWhenPlayerLeaves = true;
				}
			} else if ("maxDurationPerTurn".equals(child.getName())) {
				try {
					maxDurationPerTurn = Long.parseLong(child.getTextTrim());
				} catch (NumberFormatException ex) {
					log.warn("Invalid value specified for maxDurationPerTurn in game="+name+". Defaults will be used");
					maxDurationPerTurn = -1;
				}
				
			} else if ("attribute".equals(child.getName())) {
				GameAttribute attribute = new GameAttribute(
						child.attributeValue("name"),
						child.attributeValue("defaultValue"));

				if (!attributes.contains(attribute)) {
					attributes.add(attribute);
				}
			}
		}
		
		// verify
		if (!AppID.isValidName(appname)) {
			throw new IllegalArgumentException("Invalid app name provided. app.name:"+appname);
		} else if (appversion < 0) {
			throw new IllegalArgumentException("Invalid app version provided");
		} else if (name == null) {
			throw new IllegalArgumentException("The descriptor doesn't provide a name.");
		} 
		else if (!AppID.isValidName(name)) {
			throw new IllegalArgumentException("Provided name ["+name+"] for the game is not valid.");
		}
		if (description == null || description.trim().length() == 0) {
			description = name;
		}
		if (roleConfigMap == null || roleConfigMap.size() < 2) {
			throw new IllegalArgumentException("Atleast 2 unique roles should be specified for a turn-based multi-user game");
		}
		if (cntPlayersCannotStart >= roleConfigMap.size()) {
			throw new IllegalArgumentException("None of specified roles can start the game. Invalid configuration");
		}
		if (gameType == null) {
			throw new IllegalArgumentException("GameType should be specified. Valid types are correspondence and online");
		}
		if (turnPolicy == null) {
			throw new IllegalArgumentException("TurnPolicy should be specified. Available options are roundrobin, specifiedRole, simultaneous and custom");
		}
		
		gameID = new GameID(new AppID(appname, appversion), name);
		roles = new String[roleConfigMap.size()];
		int i=0;
		for(RoleConfig rc: roleConfigMap.values()) {
			roleToIndexMap.put(rc.getRole(), i);
			roles[i++] = rc.getRole();
		}
		if (firstRole==null)
			firstRole = roles[0];
		if (firstRole != null && !roleToIndexMap.containsKey(firstRole)) {
			throw new IllegalArgumentException("Starting player role should be one of those specified in roles element");
		}
		
		if (minPlayersForStart < 0) {
			if (joinAfterStart)
				minPlayersForStart = 1;
			else {
				minPlayersForStart = roleConfigMap.size() - cntPlayersCannotStart;
			}
		} else if (joinAfterStart == false) {
			if (minPlayersForStart < 2) {
			// 
				throw new IllegalArgumentException(
						"Invalid value "+ minPlayersForStart+" specified for minPlayersForStart for game:"+name
						+". Minimum of players required to start should be atleast 2");
			} 
		}
		
		if (minPlayersForStart > roleConfigMap.size() - cntPlayersCannotStart) {
			throw new IllegalArgumentException("Invalid configuration for game. MinPlayersForStart "
					+Integer.toString(minPlayersForStart)
					+ " is more than the number of roles in configuration which are allowed to start a game");
		}
	}
	
	
	/**
	 * Create a match which implements the game logic within a
	 * game room.
	 * 
	 * @param room The MUGRoom which offers the match.
	 * @return The created MUGMatch.
	 */
	@SuppressWarnings("unchecked")
	public MUGMatch createMatch(MUGRoom room) {
		log.debug("Create a " + description + " match: " + room.getJID().toBareJID());
		MUGMatch match = new GenericTurnBasedMatch(room, mugManager, this);
		matches.put(room.getJID().toBareJID() , match);
		return match;
	}
	
	/**
	 * Destroy the match in the specified game room.
	 * 
	 * @param room The MUGRoom which hosts the match.
	 */
	public void destroyMatch(MUGRoom room) {
		log.debug("Delete the " + description + " match: " + room.getJID().toBareJID());
		MUGMatch match = matches.get(room.getJID().toBareJID());
		if ( match != null ) {
			match.destroy();
			matches.remove(room.getJID().toBareJID());
		}
	}
	
	/**
	 * Get the name of the game.
	 * 
	 * @return the name of the game.
	 */
	public String getName() {
		return name;
	}
	
	/**
	 * Get the xml namespace of the game.
	 * 
	 * @return the xml namespace of the game.
	 */
	public String getNamespace() {
		return namespace;
	}
	
	/**
	 * Get a short human readable description of the game.
	 * 
	 * @return the description of the game.
	 */
	public String getDescription() {
		return description;
	}
	
	/**
	 * Get the category of the game e.g. board, cards, etc.
	 * 
	 * @return the category of the game.
	 */
	public String getCategory() {
		return category;
	}

	public String[] getRoles() {
		return roles;
	}

	public String getStartingPlayerRole() {
		return firstRole;
	}
	
	public int getStartingPlayerRoleIndex() {
		return getRoleIndex(firstRole);
	}

	public Set<GameAttribute> getAttributes() {
		return attributes;
	}
	
	/**
	 * returns a valid index if the role is found otherwise returns -1
	 */
	public int getRoleIndex(String rolename) {
		Integer idx = roleToIndexMap.get(rolename);
		return idx != null ? idx : -1;
	}
	
	public String getRoleForIndex(int roleIndex) {
		if (roles == null || roleIndex < 0 || roleIndex >= roles.length)
			return null;
		return roles[roleIndex];
	}
/*
	public boolean isCorrespondence() {
		return GameType.correpondence == gameType;
	}
	*/
	
	public boolean isAutonext() {
		return turnPolicy == TurnPolicy.roundrobin;		
	}

	public GameType getGameType() {
		return gameType;
	}

	public TurnPolicy getTurnPolicy() {
		return turnPolicy;
	}

	public boolean allowsJoinAfterStart() {
		return joinAfterStart;
	}

	public int getMinPlayersForStart() {
		return minPlayersForStart;
	}

	public RoleConfig getRoleConfig(String role) {
		return roleConfigMap.get(role);
	}

	public String getFirstRole() {
		return firstRole;
	}
	
	public long getMaxAllowedTimeForMove() {
		if (gameType == null)
			gameType = GameType.correspondence;
		switch (gameType) {
		case online:
			return maxDurationPerTurn > 0 ? maxDurationPerTurn : TURN_TIME_LIMIT_ONLINE;
		case correspondence:
		default:
			return maxDurationPerTurn > 0 ? maxDurationPerTurn : TURN_TIME_LIMIT_CORRESPONDENCE;
		}
	}

	public boolean abortWhenPlayerLeaves() {
		return abortWhenPlayerLeaves;
	}

	public GameID getGameID() {
		return gameID;
	}
}
