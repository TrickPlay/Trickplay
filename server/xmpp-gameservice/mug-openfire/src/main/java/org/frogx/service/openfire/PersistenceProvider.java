/**
 * Copyright (C) 2009 Guenther Niess. All rights reserved.
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
package org.frogx.service.openfire;

import java.util.concurrent.ConcurrentHashMap;

import org.frogx.service.api.MUGPersistenceProvider;

public interface PersistenceProvider extends MUGPersistenceProvider {
	
	/**
	 * Gets all stored multi-user game services.
	 * 
	 * @return ConcurrentHashMap of subdomains and descriptions.
	 */
	public ConcurrentHashMap<String,String> getGameServices() throws Exception;
	
	/**
	 * Updates an existing service's subdomain and description in the storage.
	 * 
	 * @param oldSubdomain The subdomain (e.g. games for games.example.com)
	 *     of the service which should be updated.
	 * @param newSubdomain The new subdomain which should be set.
	 * @param description A description of the game service or null for
	 *     the default description.
	 */
	public void updateGameService(String oldSubdomain, String newSubdomain, String description) throws Exception; 
	
	/**
	 * Inserts a new MUG service into the storage.
	 * 
	 * @param subdomain Subdomain of new service.
	 * @param description A description of the game service or null for
	 *     the default description.
	 */
	public void insertGameService(String subdomain, String description) throws Exception;
	
	/**
	 * Deletes a service based on its subdomain
	 * e.g. games for games.example.com.
	 * 
	 * @param subdomain The subdomain of the service to delete.
	 */
	public void deleteGameService(String subdomain) throws Exception;
}
