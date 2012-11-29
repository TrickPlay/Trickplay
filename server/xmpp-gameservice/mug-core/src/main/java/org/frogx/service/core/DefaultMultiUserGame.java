package org.frogx.service.core;

import java.io.File;
import java.lang.reflect.Constructor;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.frogx.service.api.GameID;
import org.frogx.service.api.MUGManager;
import org.frogx.service.api.MUGMatch;
import org.frogx.service.api.MUGRoom;
import org.frogx.service.api.MultiUserGame;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DefaultMultiUserGame implements MultiUserGame {
	
	private static final Logger log = LoggerFactory.getLogger(DefaultMultiUserGame.class);
	
	private String matchClassName;
	
	private ClassLoader matchClassloader;
	
	private MUGManager mugManager;
	
	private Map<String, MUGMatch> matches = new ConcurrentHashMap<String, MUGMatch>();
	
	private String name;
	
	private String namespace;
	
	private String description;
	
	private String category;
	private GameID gameID;
	
	public DefaultMultiUserGame(File pluginDirectory, MUGManager mugManager) throws DocumentException {
		this.mugManager = mugManager;
		readGameDescriptor(new File(pluginDirectory, "frogx.xml"));
		if (matchClassloader == null) {
			matchClassloader = DefaultMultiUserGame.class.getClassLoader();
		}
		if (matchClassloader == null) {
			matchClassloader = ClassLoader.getSystemClassLoader();
		}
	}
	
	/**
	 * Read the provided game descriptor and update the plug-in attributes.
	 * 
	 * @param gameDescriptor The file which describes the game descriptor.
	 * @throws DocumentException if the file can't be read.
	 */
	@SuppressWarnings("unchecked")
	public void readGameDescriptor(File gameDescriptor) throws DocumentException {
		SAXReader reader = new SAXReader();
		reader.setEncoding("UTF-8");
		Document document = reader.read(gameDescriptor);
		Element root = document.getRootElement();
		Element type = root.element("type");
		if (type == null || "match".equals(type.getText().toLowerCase())) {
			for (Iterator i = root.elementIterator(); i.hasNext();) {
				Element child = (Element) i.next();
				if ("match".equals(child.getName())) {
					matchClassName = child.getText();
				}
				else if ("namespace".equals(child.getName())) {
					namespace = child.getText();
				}
				else if ("name".equals(child.getName())) {
					name = child.getText();
				}
				else if ("description".equals(child.getName())) {
					description = child.getText();
				}
				else if ("category".equals(child.getName())) {
					category = child.getText();
				}
			}
		}
		else {
			throw new IllegalArgumentException("The descriptor don't provide a match.");
		}
		
		// verify
		if (matchClassName == null || matchClassName.trim().length() == 0) {
			throw new IllegalArgumentException("The descriptor don't provide a match class.");
		}
		if (namespace == null || namespace.trim().length() == 0) {
			throw new IllegalArgumentException("The descriptor don't provide a namespace.");
		}
		if (description == null || description.trim().length() == 0) {
			description = name;
		}
	}
	
	public void setMatchClassloader(ClassLoader classloader) {
		if (classloader == null) {
			throw new IllegalArgumentException("No classloader is set.");
		}
		this.matchClassloader = classloader;
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
		MUGMatch match = null;
		try {
			Class matchClass = matchClassloader.loadClass(matchClassName);
			Class[] parameterTypes = new Class[2];
			parameterTypes[0] = MUGRoom.class;
			parameterTypes[1] = MUGManager.class;
			Constructor consttructor = matchClass.getConstructor(parameterTypes);
			Object[] parameter = new Object[2];
			parameter[0] = room;
			parameter[1] = mugManager;
			
			match = (MUGMatch)consttructor.newInstance(parameter);
		} catch (Exception e) {
			log.error("Can't create a " + description + " match.", e);
		}
		if (match != null)
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
/*
	public boolean isCorrespondence() {
		// TODO Auto-generated method stub
		return false;
	}
	*/

	public GameType getGameType() {
		// TODO Auto-generated method stub
		return GameType.online;
	}

	public TurnPolicy getTurnPolicy() {
		// TODO Auto-generated method stub
		return TurnPolicy.custom;
	}

	public boolean allowsJoinAfterStart() {
		// TODO Auto-generated method stub
		return false;
	}

	public int getMinPlayersForStart() {
		// TODO Auto-generated method stub
		return 0;
	}

	public RoleConfig getRoleConfig(String role) {
		// TODO Auto-generated method stub
		return null;
	}

	public String[] getRoles() {
		// TODO Auto-generated method stub
		return null;
	}

	public String getFirstRole() {
		// TODO Auto-generated method stub
		return null;
	}

	public long getMaxAllowedTimeForMove() {
		return 300 * 1000; // 5 minutes
	}

	public boolean abortWhenPlayerLeaves() {
		// TODO Auto-generated method stub
		return false;
	}

	public GameID getGameID() {
		return gameID;
	}
}
