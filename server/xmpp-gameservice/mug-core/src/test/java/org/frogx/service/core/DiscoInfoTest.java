/**
 * Copyright (C) 2008-2010 Guenther Niess. All rights reserved.
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
package org.frogx.service.core;


import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.Iterator;

import org.dom4j.Element;
import org.frogx.service.api.MultiUserGame;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.xmpp.packet.IQ;
import org.xmpp.packet.IQ.Type;
import org.xmpp.packet.JID;

/**
 * The {@link DefaultMUGService} implementation offers Service Discovery support.
 * These tests verifies that the component offers the correct identity and features.
 * 
 * @author G&uuml;nther Nie&szlig;, guenther.niess@web.de
 * @see <a href="http://frogx.org/xep/multi-user_gaming.html#disco-component"
 *     >Discovering MUG Component Support</a>
 * @see <a href="http://xmpp.org/extensions/xep-0030.html">XEP-0030: Service
 *     Discovery</a>
 */
public class DiscoInfoTest {
	
	public static final String DISCO_INFO_NS = "http://jabber.org/protocol/disco#info";
	public static final String DISCO_ITEMS_NS = "http://jabber.org/protocol/disco#items";
	public static final String SEARCH_NS = "jabber:iq:search";
	public static final String MULTI_USER_GAME_NS = "http://jabber.org/protocol/mug";
	
	public static final JID inquirer = new JID("user", DummyMUGManager.xmppDomain, "resource");
	
	private DummyMUGManager manager = null;
	private IQ response = null;
	private MultiUserGame game = new DummyMultiUserGame();
	
	@Before
	public void setUp() throws Exception {
		manager = new DummyMUGManager();
		manager.getMultiUserGamingService().registerApp(
				game.getGameID().getAppID().getName(), 
				game.getGameID().getAppID().getVersion(), 
				inquirer);
		manager.registerMultiUserGame(game.getGameID().getNamespace(), game);
		final IQ request = new IQ();
		request.setType(Type.get);
		request.setChildElement("query", DISCO_INFO_NS);
		request.setFrom(inquirer);
		request.setTo(manager.getMultiUserGamingService().getDomain());
		manager.processPacket(request);
		response = (IQ) manager.getSentPacket();
		System.out.println("response:"+response.toXML());
	}
	
	@After
	public void tearDown() throws Exception {
		if (manager != null) {
			manager.destroy();
		}
		manager = null;
		response = null;
	}
	
	/**
	 * Test if an identity element with category 'game', type 'multi-user'
	 * and the configured name is included in the response.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testIdentity() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("identity");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String category = element.attributeValue("category");
			final String type = element.attributeValue("type");
			final String name = element.attributeValue("name");
			if ("game".equals(category)
					&& "multi-user".equals(type)
					&& DummyMUGManager.description.equals(name)) {
				return;
			}
		}
		fail("The multi-user game service should have an identity with "
				+ "category 'game', type 'multi-user' and the configured name");
	}
	
	/**
	 * Test if a Service Discovery feature is announced.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testDiscoInfoFeature() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (DISCO_INFO_NS.equals(var)) {
				return;
			}
		}
		fail("The multi-user game service should implement and offer Service Discovery.");
	}
	
	/**
	 * Test if a Discovery Items feature is announced.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testDiscoItemsFeature() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (DISCO_ITEMS_NS.equals(var)) {
				return;
			}
		}
		fail("The multi-user game service should implement and offer Discovery Items.");
	}
	
	/**
	 * Test if a Jabber Search feature is announced.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testSearchFeature() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (SEARCH_NS.equals(var)) {
				return;
			}
		}
		fail("The multi-user game service should implement and offer Jabber Search.");
	}
	
	/**
	 * Test if a Multi-User Gaming feature is announced.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testGamingFeature() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (MULTI_USER_GAME_NS.equals(var)) {
				return;
			}
		}
		fail("The multi-user game service should implement and offer Multi-User Gaming.");
	}
	
	/**
	 * Test if a feature for the dummy game is announced.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testDummyGameFeature() throws Exception {
		assertNotNull(response);
		assertTrue(response.isResponse());
		assertTrue(manager.isGameRegistered(game.getGameID().getNamespace()));
		
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (game.getGameID().getNamespace().equals(var)) {
				return;
			}
		}
		fail("The multi-user game service should announce the registered dummy game.");
	}
	
	/**
	 * Test if a the feature for the dummy game is removed when the game is unregistered.
	 * 
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void testRemoveDummyGameFeature() throws Exception {
		assertTrue(manager.isGameRegistered(game.getGameID().getNamespace()));
		
		// setup
		manager.unregisterMultiUserGame(game.getGameID().getNamespace());
		final IQ request = new IQ();
		request.setType(Type.get);
		request.setChildElement("query", DISCO_INFO_NS);
		request.setFrom(inquirer);
		request.setTo(manager.getMultiUserGamingService().getDomain());
		manager.processPacket(request);
		response = (IQ) manager.getSentPacket();
		
		// verify
		final Element childElement = response.getChildElement();
		assertSame(childElement.getName(), "query");
		assertSame(childElement.getNamespaceURI(), DISCO_INFO_NS);
		final Iterator<Element> iter = childElement.elementIterator("feature");
		while (iter.hasNext()) {
			final Element element = iter.next();
			final String var = element.attributeValue("var");
			if (game.getGameID().getNamespace().equals(var)) {
				fail("The multi-user game service shouldn't announce a unregistered dummy game.");;
			}
		}
	}
}
