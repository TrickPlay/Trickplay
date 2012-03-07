package com.trickplay.gameservice.xmpp.client;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.smack.Chat;
import org.jivesoftware.smack.ChatManager;
import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.ConnectionConfiguration.SecurityMode;
import org.jivesoftware.smack.MessageListener;
import org.jivesoftware.smack.PacketCollector;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.Roster;
import org.jivesoftware.smack.RosterEntry;
import org.jivesoftware.smack.SmackConfiguration;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.filter.MessageTypeFilter;
import org.jivesoftware.smack.filter.PacketExtensionFilter;
import org.jivesoftware.smack.filter.PacketFilter;
import org.jivesoftware.smack.filter.PacketIDFilter;
import org.jivesoftware.smack.filter.PacketTypeFilter;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smack.packet.PacketExtension;
import org.jivesoftware.smack.packet.Presence;
import org.jivesoftware.smack.packet.Presence.Type;
import org.jivesoftware.smack.provider.ProviderManager;
import org.jivesoftware.smack.util.StringUtils;
import org.jivesoftware.smackx.ServiceDiscoveryManager;
import org.jivesoftware.smackx.packet.DiscoverInfo;
import org.jivesoftware.smackx.packet.DiscoverInfo.Feature;

import com.trickplay.gameservice.xmpp.mug.CreateMatch;
import com.trickplay.gameservice.xmpp.mug.FindMatch;
import com.trickplay.gameservice.xmpp.mug.GamePlayListener;
import com.trickplay.gameservice.xmpp.mug.GamePresenceExtension;
import com.trickplay.gameservice.xmpp.mug.JoinMatch;
import com.trickplay.gameservice.xmpp.mug.LeaveMessageExtension;
import com.trickplay.gameservice.xmpp.mug.MatchStateExtension;
import com.trickplay.gameservice.xmpp.mug.MatchStateListener;
import com.trickplay.gameservice.xmpp.mug.NewGameResponse;
import com.trickplay.gameservice.xmpp.mug.Participant;
import com.trickplay.gameservice.xmpp.mug.PlayerStatusListener;
import com.trickplay.gameservice.xmpp.mug.StartMessageExtension;
import com.trickplay.gameservice.xmpp.mug.TurnExtension;
import com.trickplay.gameservice.xmpp.mug.TurnMessage;
import com.trickplay.gameservice.xmpp.mug.GameDataExtension;

public class XmppManager {
	private static final String MUGServiceId = "mug.internal.trickplay.com";
	private static final String MUGownerns = "http://jabber.org/protocol/mug#owner";
	private static final String MUGuserns = "http://jabber.org/protocol/mug#user";
	private static final String MUGns = "http://jabber.org/protocol/mug";
	private static final String GAME_ELEMENT_TAG = "game";
	private static final String TURN_ELEMENT_TAG = "turn";
	private static final String START_ELEMENT_TAG = "start";
	private static final int packetReplyTimeout = 5000; // millis

	private static final PacketFilter MESSAGE_FILTER = new MessageTypeFilter(
			Message.Type.normal);
	private static final PacketFilter PRESENCE_FILTER = new PacketTypeFilter(
			Presence.class);
	
	private static final PacketExtensionFilter MUG_USER_FILTER = new PacketExtensionFilter(MUGuserns);
	private static final PacketExtensionFilter MUG_FILTER = new PacketExtensionFilter(GAME_ELEMENT_TAG,
			MUGns);
	private static final PacketExtensionFilter MUG_OWNER_FILTER = new PacketExtensionFilter(GAME_ELEMENT_TAG,
			MUGownerns);

	private String server;
	private int port;

	private ConnectionConfiguration config;
	private XMPPConnection connection;

	private ChatManager chatManager;
	private MessageListener messageListener;
	private PacketListener mugPacketListener;
	private String loginUserId;
	private List<PlayerStatusListener> participantStatusListeners = Collections.synchronizedList(
			new ArrayList<PlayerStatusListener>());
	private List<MatchStateListener> matchStateListeners = Collections.synchronizedList(
			new ArrayList<MatchStateListener>());
	private List<GamePlayListener> gamePlayListeners = Collections.synchronizedList(
			new ArrayList<GamePlayListener>());
	

	public XmppManager(String server, int port) {
		this.server = server;
		this.port = port;
	}

	public void registerParticipantStatusListener(PlayerStatusListener listener) {
		if (!participantStatusListeners.contains(listener))
			participantStatusListeners.add(listener);
	}
	
	public void registerGamePlayListener(GamePlayListener listener) {
		if (!gamePlayListeners.contains(listener))
			gamePlayListeners.add(listener);
	}
	
	public void registerMatchStateListener(MatchStateListener listener) {
		if (!matchStateListeners.contains(listener))
			matchStateListeners.add(listener);
	}
	
	private void fireLeftEvent(Participant participant) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.left(participant);
		}
	}
	
	private void fireUnavailableEvent(Participant participant) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.unavailable(participant);
		}
	}
	
	private void fireJoinedEvent(Participant participant, GamePresenceExtension.Item item) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.joined(participant, item);
		}
	}
	
	private void fireNickChangedEvent(Participant p, String newname) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.nicknameChanged(p, newname);
		}
	}
	
	private void fireMatchStateEvent(String status, MatchStateExtension matchState) {
		for(MatchStateListener listener : matchStateListeners) {
				listener.currentMatchState(status, matchState);
		}
	}
	
	private void fireMatchStartEvent(Participant participant) {
		for(GamePlayListener listener : gamePlayListeners)
			listener.start(participant);
	}
	
	private void fireTurnEvent(Participant p, TurnMessage turn) {
		for(GamePlayListener listener : gamePlayListeners)
			listener.turn(p, turn);
	}
	
	public void init() throws XMPPException {

		ProviderManager.getInstance().addIQProvider(NewGameResponse.name,
				NewGameResponse.NAMESPACE, new NewGameResponse.Provider());
		ProviderManager.getInstance().addExtensionProvider(GamePresenceExtension.name,
				GamePresenceExtension.NAMESPACE, new GamePresenceExtension.Provider());
		ProviderManager.getInstance().addExtensionProvider(MatchStateExtension.name,
				MatchStateExtension.NAMESPACE, new MatchStateExtension.Provider());
		ProviderManager.getInstance().addExtensionProvider(TurnExtension.name,
				TurnExtension.NAMESPACE, new TurnExtension.Provider());
		ProviderManager.getInstance().addExtensionProvider(GameDataExtension.name,
				GameDataExtension.NAMESPACE, new GameDataExtension.Provider());
		ProviderManager.getInstance().addIQProvider(GameDataExtension.name,
				GameDataExtension.NAMESPACE, new GameDataExtension.Provider());
		System.out.println(String.format(
				"Initializing connection to server %1$s port %2$d", server,
				port));

		SmackConfiguration.setPacketReplyTimeout(packetReplyTimeout);
		SmackConfiguration.setLocalSocks5ProxyPort(-7777);

		config = new ConnectionConfiguration(server, port);
		config.setSASLAuthenticationEnabled(false);
		config.setSecurityMode(SecurityMode.disabled);
		config.setDebuggerEnabled(true);
		// Connection.DEBUG_ENABLED = true;

		connection = new XMPPConnection(config);
		connection.connect();

		System.out.println("Connected: " + connection.isConnected());

		chatManager = connection.getChatManager();
		messageListener = new MyMessageListener();

		mugPacketListener = new PacketListener() {

			public void processPacket(Packet p) {
				System.out.println("received packet. contents:"+p.toXML());

				if (PRESENCE_FILTER.accept(p)) {
					if (MUG_FILTER.accept(p)) {
						GamePresenceExtension ext = (GamePresenceExtension)p.getExtension(GAME_ELEMENT_TAG, MUGns);
							switch (ext.getType()) {
							case Occupant:
								if (((Presence)p).getType().equals(Presence.Type.unavailable)) 
									fireUnavailableEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())));
								else
									fireJoinedEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())), ext.getItem());
								break;
							case NickChanged:
								fireNickChangedEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())), ext.getItem().getNick());
								break;								
							case Status:
								fireMatchStateEvent(ext.getStatus(), ext.getState());
								break;
							default:
							// log error		
							}
							return;
						}
					
				} else if (MESSAGE_FILTER.accept(p)) {
					if (MUG_USER_FILTER.accept(p)) {
					// turn and start messages need to be supported for now
						
						PacketExtension ext = p.getExtension(START_ELEMENT_TAG, MUGuserns);
						if (ext != null) {
							fireMatchStartEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())));
						} else if (null != (ext = p.getExtension(TURN_ELEMENT_TAG, MUGuserns))) {
							fireTurnEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())), (TurnExtension)ext);
						} else if (null != (ext = p.getExtension(LeaveMessageExtension.name, LeaveMessageExtension.NAMESPACE))) {
							fireLeftEvent(Participant.parseParticipant(StringUtils.parseResource(p.getFrom())));
						} else {
							//log message
						}
						return;
					}
					
				} else {
					// is an IQ packet
				}
			}
		};

	}
	

	public void performLogin(String username, String password)
			throws XMPPException {
		if (connection != null && connection.isConnected()) {
			loginUserId = username;
			connection.login(username, password);
			PacketFilter mugFilter = new PacketFilter() {

				public boolean accept(Packet p) {
					if (p == null)
						return false;
			//		System.out.println("packet filter processing packet with contents:"+p.toXML());
					if (p.getFrom().contains(MUGServiceId)) {
						return true;
					}
						
					return false;
				}

			};
			connection.addPacketListener(mugPacketListener, mugFilter);

			connection.addPacketSendingListener(new PacketListener() {

				public void processPacket(Packet p) {
					System.out.println("sending packet. contents:"+p.toXML());
					/*
					if (p instanceof Presence && Presence.Type.unavailable.equals(((Presence)p).getType())) {
						Thread.dumpStack();
					}
					*/
				}
				
			},
					new PacketFilter() {

						public boolean accept(Packet packet) {
							return true;
						}

					});
		}
	}

	public void setStatus(boolean available, String status) {

		Presence.Type type = available ? Type.available : Type.unavailable;
		Presence presence = new Presence(type);

		presence.setStatus(status);
		connection.sendPacket(presence);

	}

	public void destroy() {
		if (connection != null && connection.isConnected()) {
			connection.disconnect();
		}
	}

	public void printRoster() throws Exception {
		Roster roster = connection.getRoster();
		Collection<RosterEntry> entries = roster.getEntries();
		for (RosterEntry entry : entries) {
			System.out.println(String.format("Buddy:%1$s - Status:%2$s",
					entry.getName(), entry.getStatus()));
		}
	}

	public void sendMessage(String message, String buddyJID)
			throws XMPPException {
		System.out.println(String.format("Sending mesage '%1$s' to user %2$s",
				message, buddyJID));
		Chat chat = chatManager.createChat(buddyJID, messageListener);
		chat.sendMessage(message);
	}

	public List<String> getRegisteredGames() throws XMPPException {
		ServiceDiscoveryManager discoManager = ServiceDiscoveryManager
				.getInstanceFor(connection);

		DiscoverInfo discoInfo = discoManager.discoverInfo(MUGServiceId);
		/*
		 * // Get the discovered identities of the remote XMPP entity Iterator
		 * it = discoInfo.getIdentities(); // Display the identities of the
		 * remote XMPP entity while (it.hasNext()) { DiscoverInfo.Identity
		 * identity = (DiscoverInfo.Identity) it.next();
		 * System.out.println(identity.getName());
		 * System.out.println(identity.getType());
		 * System.out.println(identity.getCategory()); }
		 */
		List<String> allGames = new ArrayList<String>();
		for (Iterator<Feature> iter = discoInfo.getFeatures(); iter.hasNext();) {
			Feature f = iter.next();
			String game = f.getVar();
			if (isValidGameName(game)) {
				allGames.add(game);
			}

		}
		return allGames;
	}

	/*
	 * IQ iq = new IQ() {...}; iq.setType(IQ.Type.GET); iq.setTo(entityID);
	 * 
	 * // Create a packet collector to listen for a response. PacketCollector
	 * collector = connection.createPacketCollector(new
	 * PacketIDFilter(iq.getPacketID()));
	 * 
	 * connection.sendPacket(disco);
	 * 
	 * // Wait up to 5 seconds for a result. IQ result = (IQ)
	 * collector.nextResult(SmackConfiguration.getPacketReplyTimeout()); // Stop
	 * queuing results collector.cancel(); if (result == null) { throw new
	 * XMPPException("No response from the server."); } if (result.getType() ==
	 * IQ.Type.ERROR) { throw new XMPPException(result.getError()); } return
	 * result;
	 */
	private boolean isValidGameName(String x) {
		return Pattern
				.matches(
						"^http://jabber\\.org/protocol/mug/[a-zA-Z]([a-zA-Z_0-9\\.\\-]*{3,})$",
						x);
	}

	public void createGame(final Game game) throws XMPPException {
		IQ iq = new IQ() {

			@Override
			public String getChildElementXML() {
				Element element = DocumentHelper.createElement(QName.get(
						"newGame", "http://jabber.org/protocol/mug#owner"));
				element.addAttribute("type", game.isTurnbased() ? "turnbased"
						: "undefined");
				element.addElement("name").addText(game.getName());
				element.addElement("description")
						.addText(game.getDescription());
				element.addElement("category").addText(game.getCategory());
				StringBuilder allRoles = new StringBuilder();
				boolean first = true;
				List<String> rolesList = game.getRoles();
				for (String role : rolesList) {
					if (!first)
						allRoles.append(",");
					else {
						first = false;
					}
					allRoles.append(role);
				}
				element.addElement("roles").addText(allRoles.toString());
				element.addElement("startingPlayerRole").addText(
						rolesList.get(0));
				return element.asXML();
			}

		};

		iq.setType(org.jivesoftware.smack.packet.IQ.Type.SET);
		iq.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(iq.getPacketID()));

		connection.sendPacket(iq);

		IQ result = (IQ) collector.nextResult(360000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getType() == IQ.Type.ERROR) {
			throw new XMPPException(result.getError());
		} /*
		 * else if (result.getExtension(MUGownerNS) == null) { throw new
		 * XMPPException("Invalid response from server"); }
		 */

		System.out.println("created game '" + game.getName()
				+ "'. server response:" + result.toXML());
	}

	public void createBuddyEntry(String user, String name) throws Exception {
		System.out.println(String.format(
				"Creating entry for buddy '%1$s' with name %2$s", user, name));
		Roster roster = connection.getRoster();
		roster.createEntry(user, name, null);
	}

	/*
	 * <newMatch xmlns="http://jabber.org/protocol/mug#owner"
	 * gameId="http://jabber.org/protocol/mug/challenge">
	 * 
	 * </newMatch>
	 */
	public String createMatch(final String gameId) throws XMPPException {
		IQ createMatchIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new CreateMatch(gameId).toXML();
			}

		};

		createMatchIQ.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(createMatchIQ
						.getPacketID()));

		connection.sendPacket(createMatchIQ);

		IQ result = (IQ) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		// result.getExtension(JoinGameResponse.NAMESPACE,
		// JoinGameResponse.getElement());

		// System.out.println("created game '"+game.getName()+"'. server response:"+result.toXML());

		return result.getFrom();
	}

	public String findMatch(final String gameId) throws XMPPException {
		IQ createMatchIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new FindMatch(gameId, null, loginUserId).toXML();
			}

		};

		createMatchIQ.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(createMatchIQ
						.getPacketID()));

		connection.sendPacket(createMatchIQ);

		IQ result = (IQ) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		// result.getExtension(JoinGameResponse.NAMESPACE,
		// JoinGameResponse.getElement());

		// System.out.println("created game '"+game.getName()+"'. server response:"+result.toXML());

		return result.getFrom();
	}

	public String joinMatch(final String matchId) throws XMPPException {
		return joinMatch(matchId, true, null);
	}

	public String joinMatch(final String matchId, final boolean freerole,
			final String role) throws XMPPException {
		Presence joinMatchPresence = new Presence(Type.available);
		joinMatchPresence.addExtension(freerole ? new JoinMatch(freerole)
				: new JoinMatch(role));

		joinMatchPresence.setTo(matchId + "/" + loginUserId);
/*
		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(joinMatchPresence
						.getPacketID()));
*/
		connection.sendPacket(joinMatchPresence);
		return joinMatchPresence.getPacketID();
/*
		Presence result = (Presence) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}
*/
		// result.getExtension(JoinGameResponse.NAMESPACE,
		// JoinGameResponse.getElement());

		// System.out.println("created game '"+game.getName()+"'. server response:"+result.toXML());

	//	return result.getFrom();
	}

	public void startMatch(final String matchId) throws XMPPException {
		Message startMatchMessage = new Message();
		startMatchMessage.addExtension(new StartMessageExtension());

		startMatchMessage.setTo(matchId);

	/*	PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(startMatchMessage
						.getPacketID()));
						*/

		connection.sendPacket(startMatchMessage);

	/*	Presence result = (Presence) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		// result.getExtension(JoinGameResponse.getElement(), JoinGameResponse.NAMESPACE,
		// );

		// System.out.println("created game '"+game.getName()+"'. server response:"+result.toXML());

		return result.getFrom();
		*/
	}
	
	public void leaveMatch(final String matchId) throws XMPPException {
		Message leaveMatchMessage = new Message();
		leaveMatchMessage.addExtension(new LeaveMessageExtension());

		leaveMatchMessage.setTo(matchId);

	/*	PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(startMatchMessage
						.getPacketID()));
						*/

		connection.sendPacket(leaveMatchMessage);

	/*	Presence result = (Presence) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		// result.getExtension(JoinGameResponse.getElement(), JoinGameResponse.NAMESPACE,
		// );

		// System.out.println("created game '"+game.getName()+"'. server response:"+result.toXML());

		return result.getFrom();
		*/
	}

	public void sendTurn(final String matchId, String newstate, boolean terminate)
			throws XMPPException {
		Message turnMessage = new Message();
		turnMessage.addExtension(new TurnMessage(newstate, terminate));

		turnMessage.setTo(matchId);
/*
		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(turnMessage
						.getPacketID()));
*/
		connection.sendPacket(turnMessage);
		/*

		Presence result = (Presence) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		return result.getFrom();
		*/
	}
	
	public GameDataExtension getMatchdata(final String gameId) throws XMPPException {
		System.out.println("Inside getMatchData().");
		IQ matchdataIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new GameDataExtension(gameId, GameDataExtension.Type.MATCHDATA).toXML();
			}

		};

		matchdataIQ.setType(IQ.Type.GET);
		matchdataIQ.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(matchdataIQ
						.getPacketID()));

		connection.sendPacket(matchdataIQ);

		IQ result = (IQ) collector.nextResult(500000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		GameDataExtension gamedata = (GameDataExtension)result.getExtension(GameDataExtension.name, GameDataExtension.NAMESPACE);

		if (gamedata != null)
			System.out.println("Inside getMatchdata(). matchdata:"+gamedata.toXML());

		return gamedata;
	}

	public String getUserdata(final String gameId) throws XMPPException {
		System.out.println("Inside getUserData().");
		IQ userDataIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new GameDataExtension(gameId, GameDataExtension.Type.USERDATA).toXML();
			}

		};

		userDataIQ.setType(IQ.Type.GET);
		userDataIQ.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(userDataIQ
						.getPacketID()));

		connection.sendPacket(userDataIQ);

		IQ result = (IQ) collector.nextResult(500000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		GameDataExtension userData = (GameDataExtension)result.getExtension(GameDataExtension.name, GameDataExtension.NAMESPACE);

		if (userData != null)
			System.out.println("Inside getUserdata(). userdata:"+userData.toXML());

		return userData != null ? userData.getUserdata() : "";
	}
	
	public void setUserdata(final String gameId, final String userdata) throws XMPPException {
		System.out.println("Inside setUserData(). input userdata="+userdata);
		IQ userDataIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new GameDataExtension(gameId, userdata, null).toXML();
			}

		};

		userDataIQ.setType(IQ.Type.SET);
		userDataIQ.setTo(MUGServiceId);

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(userDataIQ
						.getPacketID()));

		connection.sendPacket(userDataIQ);

		IQ result = (IQ) collector.nextResult(5000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}

		GameDataExtension userData = (GameDataExtension)result.getExtension(GameDataExtension.name, GameDataExtension.NAMESPACE);

		if (userData != null)
			System.out.println("Inside setUserData(). updated userdata="+userData.toXML());

		//return userData != null ? userData.getUserdata() : null;
	}

	class MyMessageListener implements MessageListener {

		public void processMessage(Chat chat, Message message) {
			String from = message.getFrom();
			String body = message.getBody();
			System.out.println(String.format(
					"Received message '%1$s' from %2$s", body, from));
		}

	}

}
