package org.frogx.service.games.common;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

import org.dom4j.Element;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MUGService;
import org.frogx.service.api.MultiUserGame;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GenericTurnBasedMUG implements MultiUserGame{
	private static final String[] kEmptyStringArray = {};
	private static final Logger log = LoggerFactory.getLogger(GenericTurnBasedMUG.class);
	
	
	private MUGManager mugManager;
	
	private Map<String, MUGMatch> matches = new ConcurrentHashMap<String, MUGMatch>();
	
	private String name;
	
	private String namespace;
	private boolean correspondence=true;
	
	private String description;
	private static Pattern validNamePattern = Pattern.compile("^([a-zA-Z][a-zA-Z0-9_\\.\\-]*){4,}$");
	private String category;
	private Map<String, Integer> roleToIndexMap = new LinkedHashMap<String, Integer>();
	private String[] roles = kEmptyStringArray;
	private String startingPlayerRole;
	private Set<GameAttribute> attributes = new LinkedHashSet<GameAttribute>();
	
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
			for (Iterator i = gameDescriptor.elementIterator(); i.hasNext();) {
				Element child = (Element) i.next();
				if ("name".equals(child.getName())) {
					name = child.getText();
					namespace = MUGService.mugNS + "/" + name;
				}
				else if ("description".equals(child.getName())) {
					description = child.getText();
				}
				else if ("category".equals(child.getName())) {
					category = child.getText();
				} 
				else if ("roles".equals(child.getName())) {
					int roleIdx = 0;
					StringTokenizer tokens = new StringTokenizer(
							child.getText(), ",");
					while (tokens.hasMoreElements()) {
						String role = tokens.nextToken().trim();
						if (!roleToIndexMap.containsKey(role))
							roleToIndexMap.put(role, roleIdx++);
					}
					roleIdx = 0;
					roles = new String[roleToIndexMap.size()];
					for(String role : roleToIndexMap.keySet()) {
						roles[roleIdx++] = role;
					}
				} 
				else if ("startingPlayerRole".equals(child.getName())) {
					startingPlayerRole = child.getTextTrim();
				} 
				else if("attribute".equals(child.getName())) {
					GameAttribute attribute = new GameAttribute(
							child.attributeValue("name"),
							child.attributeValue("defaultValue")
							);
					
					if (!attributes.contains(attribute)) {
						attributes.add(attribute);
					}
				}
			}
		
		// verify
		if (name == null) {
			throw new IllegalArgumentException("The descriptor doesn't provide a name.");
		} 
		else if (!isValidWord(name)) {
			throw new IllegalArgumentException("Provided name ["+name+"] for the game is not valid.");
		}
		if (description == null || description.trim().length() == 0) {
			description = name;
		}
		if (roles == null || roles.length < 2) {
			throw new IllegalArgumentException("Atleast 2 unique roles should be specified for a turn-based multi-user game");
		}
		if (startingPlayerRole==null)
			startingPlayerRole = roles[0];
		if (startingPlayerRole != null && !roleToIndexMap.containsKey(startingPlayerRole)) {
			throw new IllegalArgumentException("Starting player role should be one of those specified in roles element");
		}
	}
	
	
	private boolean isValidWord(String x) {
		 return validNamePattern.matcher(x).matches();
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
		return startingPlayerRole;
	}
	
	public int getStartingPlayerRoleIndex() {
		return getRoleIndex(startingPlayerRole);
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

	public boolean isCorrespondence() {
		return correspondence;
	}
	
	public boolean isAutonext() {
		return true;		
	}
}
