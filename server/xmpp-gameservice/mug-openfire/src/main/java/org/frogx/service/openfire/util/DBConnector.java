/**
 * OpenfireDBConnector - Provides the loading of saved data.
 * Some parts are inspired by the MUCPersistenceManager of the Openfire
 * XMPP server.
 * 
 * Copyright (C) 2004-2008 Jive Software. All rights reserved.
 * Copyright (C) 2008-2009 Guenther Niess. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.frogx.service.openfire.util;


import java.io.IOException;
import java.io.Reader;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import org.frogx.service.api.MUGProperty;
import org.frogx.service.api.exception.NotFoundException;
import org.frogx.service.openfire.PersistenceProvider;
import org.jivesoftware.database.DbConnectionManager;
import org.jivesoftware.database.SequenceManager;
import org.jivesoftware.openfire.XMPPServer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.packet.JID;

/**
 * The OpenfireDBConnector provides loading and saving data within
 * the Openfire database. This is a simple possibility of an Openfire
 * plugin to provide a persistent storage.
 * 
 */
public class DBConnector implements PersistenceProvider{
	
	private static final Logger log = LoggerFactory.getLogger(DBConnector.class);
	
	/**
	 * The ID Type of the MUGService
	 */
	public static final int MUG_SERVICE = 60;
	
	/**
	 * SQL commands for handling Multi-User Services
	 */
	private static final String LOAD_SERVICES = "SELECT subdomain,description FROM frogxMugService";
	private static final String CREATE_SERVICE = "INSERT INTO frogxMugService(serviceID,subdomain,description) VALUES(?,?,?)";
	private static final String UPDATE_SERVICE = "UPDATE frogxMugService SET subdomain=?,description=? WHERE serviceID=?";
	private static final String DELETE_SERVICE = "DELETE FROM frogxMugService WHERE serviceID=?";
	private static final String LOAD_SERVICE_ID = "SELECT serviceID FROM frogxMugService WHERE subdomain=?";
	
	/**
	 * SQL commands for handling Multi-User Service Properties
	 */
	private static final String LOAD_PROPERTY = "SELECT propValue FROM frogxMugServiceProp WHERE serviceID=? AND name=?";
	private static final String INSERT_PROPERTY = "INSERT INTO frogxMugServiceProp(serviceID,name,propValue) VALUES(?,?,?)";
	private static final String UPDATE_PROPERTY = "UPDATE frogxMugServiceProp SET propValue=? WHERE serviceID=? AND name=?";
	private static final String DELETE_PROPERTY = "DELETE FROM frogxMugServiceProp WHERE serviceID=? AND name=?";
	private static final String DELETE_PROPERTIES = "DELETE FROM frogxMugServiceProp WHERE serviceID=?";
	
	
	/**
	 * SQL commands for handling user data
	 */
	private static final String LOAD_USER_PROPERTY = "SELECT propValue, version FROM frogxUserData WHERE username=? AND propName=?";
	private static final String INSERT_USER_PROPERTY = "INSERT INTO frogxUserData(username,propName,propValue, version) VALUES(?,?,?,1)";
	private static final String UPDATE_USER_PROPERTY = "UPDATE frogxUserData SET propValue=?, version=(version+1) WHERE username=? AND propName=? AND version=?";
	
	
	/**
	 * If there is no description for a service available this will be used.
	 */
	private String defaultServiceDescription;
	
	
	/**
	 * Create a connection to the database of Openfire.
	 * 
	 * @param defaultServiceDescription Set the default description of
	 *     Multi-User Gaming services.
	 */
	public DBConnector(String defaultServiceDescription) {
		this.defaultServiceDescription = defaultServiceDescription;
	}
	
	
	/**
	 * Get all stored multi-user game services
	 * 
	 * @return ConcurrentHashMap of subdomains and descriptions.
	 */
	public ConcurrentHashMap<String,String> getGameServices() throws SQLException {
		// load MUG Services 
		ConcurrentHashMap<String,String> mugServices = new ConcurrentHashMap<String,String>();
		Connection con = null;
		PreparedStatement pstmt = null;
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(LOAD_SERVICES);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next()) {
				String subdomain = rs.getString(1);
				String description = rs.getString(2);
				if ( (description == null) || (description.trim().length() == 0) )
					description = defaultServiceDescription;
				mugServices.put(subdomain, description);
			}
			rs.close();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
		return mugServices;
	}
	
	/**
	 * Updates an existing service's subdomain and description in the storage.
	 * 
	 * @param oldSubdomain The subdomain (e.g. games for games.example.com)
	 *     of the service which should be updated.
	 * @param newSubdomain The new subdomain which should be set.
	 * @param description A description of the game service or null for
	 *     the default description.
	 */
	public void updateGameService(String oldSubdomain, String newSubdomain, 
			String description) throws SQLException {
		Long serviceID = getGameServiceID(oldSubdomain);
		Connection con = null;
		PreparedStatement pstmt = null;
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(UPDATE_SERVICE);
			pstmt.setString(1, newSubdomain);
			if (description != null) {
				pstmt.setString(2, description);
			}
			else {
				pstmt.setNull(2, Types.VARCHAR);
			}
			pstmt.setLong(3, serviceID);
			pstmt.executeUpdate();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
	}
	
	/**
	 * Inserts a new MUG service into the database.
	 * 
	 * @param subdomain Subdomain of new service.
	 * @param description Description of MUG service.
	 *     Can be null for default description.
	 */
	public void insertGameService(String subdomain,
			String description) throws SQLException{
		Connection con = null;
		PreparedStatement pstmt = null;
		
		// Get a new ID
		Long serviceID = SequenceManager.nextID(MUG_SERVICE);
		
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(CREATE_SERVICE);
			pstmt.setLong(1, serviceID);
			pstmt.setString(2, subdomain);
			if (description != null) {
				pstmt.setString(3, description);
			}
			else {
				pstmt.setNull(3, Types.VARCHAR);
			}
			pstmt.executeUpdate();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
	}
	
	/**
	 * Deletes a service based on its subdomain
	 * e.g. games for games.example.com.
	 * 
	 * @param subdomain The subdomain of the service to delete.
	 */
	public void deleteGameService(String subdomain) throws SQLException {
		Long serviceID = getGameServiceID(subdomain);
		Connection con = null;
		PreparedStatement pstmt = null;
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(DELETE_PROPERTIES);
			pstmt.setLong(1, serviceID);
			pstmt.executeUpdate();
			pstmt = con.prepareStatement(DELETE_SERVICE);
			pstmt.setLong(1, serviceID);
			pstmt.executeUpdate();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
	}
	
	/**
	 * Gets a specific subdomain/service's ID number.
	 * 
	 * @param subdomain Subdomain to retrieve ID for.
	 * @return ID number of service.
	 */
	public long getGameServiceID(String subdomain) throws SQLException {
		Long id = (long)-1;
		Connection con = null;
		PreparedStatement pstmt = null;
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(LOAD_SERVICE_ID);
			pstmt.setString(1, subdomain);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				id = rs.getLong(1);
			}
			else {
				throw new NotFoundException(
						"Unable to locate Service ID for subdomain "
						+subdomain);
			}
			rs.close();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
		return id;
	}
	
	/**
	 * Get a collection of the bare JIDs of administrators of a
	 * XMPP component.
	 * 
	 * @return A collection of administrators bare JIDs.
	 * @throws SQLException 
	 */
	public Collection<JID> getServiceAdmins(String subdomain) throws SQLException {
		XMPPServer server = XMPPServer.getInstance();
		
		if (subdomain == null) {
			// return the server admins
			return server.getAdmins();
		}
		
		List<JID> admins = new ArrayList<JID>();
		// Add the room itself
		admins.add(new JID(null,
				subdomain + "." + server.getServerInfo().getXMPPDomain(),
				null));
		String localAdminProperty = getServiceProperty(subdomain, "admins");
		if (localAdminProperty == null) {
			// use server administrators as fallback
			admins.addAll(server.getAdmins());
		}
		else {
			for (String admin : localAdminProperty.split(",")) {
				admins.add(new JID(admin));
			}
		}
		
		return Collections.unmodifiableCollection(admins);
	}
	
	/**
	 * Get a property value for a specific Multi-User Gaming component
	 * or null if none is present.
	 * 
	 * @param subdomain The subdomain of the Multi-User Gaming component.
	 * @param name The name of the property.
	 * @param value The value of the property.
	 */
	public void setServiceProperty(String subdomain, String name,
			String value) throws SQLException {
		if (subdomain == null || name == null)
			throw new IllegalArgumentException();
		
		Connection con = null;
		PreparedStatement pstmt = null;
		Long serviceID = getGameServiceID(subdomain);
		if (subdomain == null)
			throw new NotFoundException(
					"Can't locate a service for subdomain: "
					+ subdomain);
		
		if (value == null || value.trim().length() == 0) {
			// Delete the empty property
			try {
				con = DbConnectionManager.getConnection();
				pstmt = con.prepareStatement(DELETE_PROPERTY);
				pstmt.setLong(1, serviceID);
				pstmt.setString(2, name);
				pstmt.executeUpdate();
			}
			finally {
				try { if (pstmt != null) { pstmt.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
				try { if (con != null) { con.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
			}
		}
		else {
			// Try to update the value or insert a new one
			try {
				con = DbConnectionManager.getConnection();
				pstmt = con.prepareStatement(UPDATE_PROPERTY);
				pstmt.setString(1, value);
				pstmt.setLong(2, serviceID);
				pstmt.setString(3, name);
				if (pstmt.executeUpdate() == 0) {
					// The update failed, so insert a new property
					pstmt = con.prepareStatement(INSERT_PROPERTY);
					pstmt.setLong(1, serviceID);
					pstmt.setString(2, name);
					pstmt.setString(3, value);
					pstmt.executeUpdate();
				}
			}
			finally {
				try { if (pstmt != null) { pstmt.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
				try { if (con != null) { con.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
			}
		}
	}
	
	/**
	 * Get a property value for a specific Multi-User Gaming component
	 * or null if none is present.
	 * 
	 * @param subdomain The subdomain of the Multi-User Gaming component.
	 * @param name The name of the property.
	 * @return The value of the property or null.
	 */
	public String getServiceProperty(String subdomain,
			String name) throws SQLException {
		if (subdomain == null || name == null)
			throw new IllegalArgumentException();
		
		String value = null;
		Connection con = null;
		PreparedStatement pstmt = null;
		Long serviceID = getGameServiceID(subdomain);
		if (subdomain == null)
			throw new NotFoundException(
					"Can't locate a service for subdomain: "
					+ subdomain);
		
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(LOAD_PROPERTY);
			pstmt.setLong(1, serviceID);
			pstmt.setString(2, name);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				value = rs.getString(1);
			}
			rs.close();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
		return value;
	}


	public MUGProperty getUserProperty(String username, String propertyName) throws SQLException {
		if (username == null || propertyName == null)
			throw new IllegalArgumentException();
		
		String value = null;
		int version = -1;
		Connection con = null;
		PreparedStatement pstmt = null;
		
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(LOAD_USER_PROPERTY);
			pstmt.setString(1, username);
			pstmt.setString(2, propertyName);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				value = extractStringFromClob(rs.getClob(1));
				version = rs.getInt(2);
			}
			rs.close();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
		return value != null ? new MUGProperty(propertyName, value, version) : null;
	}
	
	private String extractStringFromClob(Clob c) throws SQLException {
		if (c==null || c.length() == 0)
			return "";
		StringBuilder buffer = new StringBuilder();
		Reader r = c.getCharacterStream();
		char cbuf[] = new char[1024];
		int nread = 0;
		try {
			while(-1 != (nread=r.read(cbuf, 0, 1024))) {
				buffer.append(cbuf, 0, nread);
			}
			r.close();
		} catch (IOException ex) {
			log.error("got exception reading data from CLOB.", ex);
		}
		return buffer.toString();
	}


	public MUGProperty setUserProperty(String username, String propertyName, String value) throws SQLException {
		if (username == null || propertyName == null || value == null)
			throw new IllegalArgumentException();
		MUGProperty property = getUserProperty(username, propertyName);
		if (property == null) {
			property = new MUGProperty(propertyName, value, 1);
			Connection con = null;
			PreparedStatement pstmt = null;
			try {
				con = DbConnectionManager.getConnection();
				pstmt = con.prepareStatement(INSERT_USER_PROPERTY);
				pstmt.setString(1, username);
				pstmt.setString(2, propertyName);
				pstmt.setString(3, value);
				pstmt.executeUpdate();
			}
			finally {
				try { if (pstmt != null) { pstmt.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
				try { if (con != null) { con.close(); } }
				catch (Exception e) { log.error(e.getMessage(), e); }
			}
			return property;
		} else {
			property.setValue(value);
			return updateUserProperty(username, property);
		}
	}


	public MUGProperty updateUserProperty(String username, MUGProperty property) throws SQLException {
		if (username == null || property == null)
			throw new IllegalArgumentException();
		Connection con = null;
		PreparedStatement pstmt = null;
		int rows=0;
		try {
			con = DbConnectionManager.getConnection();
			pstmt = con.prepareStatement(UPDATE_USER_PROPERTY);
			pstmt.setString(1, property.getValue());
			pstmt.setString(2, username);
			pstmt.setString(3, property.getName());
			pstmt.setInt(4, property.getVersion());
			rows = pstmt.executeUpdate();
		}
		finally {
			try { if (pstmt != null) { pstmt.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
			try { if (con != null) { con.close(); } }
			catch (Exception e) { log.error(e.getMessage(), e); }
		}
		return rows==1 ? getUserProperty(username, property.getName()) : null ;
	}
}
