package com.trickplay.gameservice.xmpp.client;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

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

import com.trickplay.gameservice.xmpp.mug.Game;
import com.trickplay.gameservice.xmpp.mug.GameDataExtension;
import com.trickplay.gameservice.xmpp.mug.GamePlayListener;
import com.trickplay.gameservice.xmpp.mug.GamePresenceExtension;
import com.trickplay.gameservice.xmpp.mug.InstantMatch;
import com.trickplay.gameservice.xmpp.mug.OpenApp;
import com.trickplay.gameservice.xmpp.mug.JoinMatch;
import com.trickplay.gameservice.xmpp.mug.LeaveMessageExtension;
import com.trickplay.gameservice.xmpp.mug.MatchRequest;
import com.trickplay.gameservice.xmpp.mug.MatchStateExtension;
import com.trickplay.gameservice.xmpp.mug.MatchStateListener;
import com.trickplay.gameservice.xmpp.mug.NewGameResponse;
import com.trickplay.gameservice.xmpp.mug.Participant;
import com.trickplay.gameservice.xmpp.mug.PlayerStatusListener;
import com.trickplay.gameservice.xmpp.mug.RegisterApp;
import com.trickplay.gameservice.xmpp.mug.RegisterGame;
import com.trickplay.gameservice.xmpp.mug.StartMessageExtension;
import com.trickplay.gameservice.xmpp.mug.TurnExtension;
import com.trickplay.gameservice.xmpp.mug.TurnMessage;

public class GameServiceProxy {
	//private static final String MUGServiceId = "mug.internal.trickplay.com";
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
	private String domain;
	
	private ConnectionConfiguration config;
	private XMPPConnection connection;

	private ChatManager chatManager;
	private MessageListener messageListener;
	private PacketListener mugPacketListener;
	private String loginUserId;
	private Set<PlayerStatusListener> participantStatusListeners = Collections.synchronizedSet(
			new LinkedHashSet<PlayerStatusListener>());
	private Set<MatchStateListener> matchStateListeners = Collections.synchronizedSet(
			new LinkedHashSet<MatchStateListener>());
	private Set<GamePlayListener> gamePlayListeners = Collections.synchronizedSet(new LinkedHashSet<GamePlayListener>());
	

	public GameServiceProxy(String server, int port) {
		this("internal.trickplay.com", server, port);
	}

	public GameServiceProxy(String domain, String server, int port) {
		this.server = server;
		this.port = port;
		this.domain = domain;
	}
	
	public String getMugServiceId() {
		return "mug." + domain;
	}

	public void registerParticipantStatusListener(PlayerStatusListener listener) {
		participantStatusListeners.add(listener);
	}
	
	public void registerGamePlayListener(GamePlayListener listener) {
		gamePlayListeners.add(listener);
	}
	
	public void registerMatchStateListener(MatchStateListener listener) {
		matchStateListeners.add(listener);
	}
	
	
	private void fireLeftEvent(String matchId, Participant participant) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.left(matchId, participant);
		}
		
	}
	
	private void fireUnavailableEvent(String matchId, Participant participant) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.unavailable(matchId, participant);
		}
	}
	
	private void fireJoinedEvent(String matchId, Participant participant, GamePresenceExtension.Item item) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.joined(matchId, participant, item);
		}
	}
	
	private void fireNickChangedEvent(String matchId, Participant p, String newname) {
		for(PlayerStatusListener listener : participantStatusListeners) {
				listener.nicknameChanged(matchId, p, newname);
		}
	}
	
	private void fireMatchStateEvent(String matchId, String status, MatchStateExtension matchState) {
		for(MatchStateListener listener : matchStateListeners) {
				listener.currentMatchState(matchId, status, matchState);
		}
	}
	
	private void fireMatchStartEvent(String matchId, Participant participant) {
		for(GamePlayListener listener : gamePlayListeners)
			listener.start(matchId, participant);
	}
	
	private void fireTurnEvent(String matchId, Participant p, TurnMessage turn) {
		for(GamePlayListener listener : gamePlayListeners)
			listener.turn(matchId, p, turn);
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
				String matchId = StringUtils.parseBareAddress(p.getFrom());
				String resource = StringUtils.parseResource(p.getFrom());

				if (PRESENCE_FILTER.accept(p)) {
					if (MUG_FILTER.accept(p)) {
						GamePresenceExtension ext = (GamePresenceExtension)p.getExtension(GAME_ELEMENT_TAG, MUGns);
							switch (ext.getType()) {
							case Occupant:
								if (((Presence)p).getType().equals(Presence.Type.unavailable)) 
									fireUnavailableEvent(matchId, Participant.parseParticipant(resource));
								else
									fireJoinedEvent(matchId, Participant.parseParticipant(resource), ext.getItem());
								break;
							case NickChanged:
								fireNickChangedEvent(matchId, Participant.parseParticipant(resource), ext.getItem().getNick());
								break;								
							case Status:
								fireMatchStateEvent(matchId, ext.getStatus(), ext.getState());
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
							fireMatchStartEvent(matchId, Participant.parseParticipant(resource));
						} else if (null != (ext = p.getExtension(TURN_ELEMENT_TAG, MUGuserns))) {
							fireTurnEvent(matchId, Participant.parseParticipant(resource), (TurnExtension)ext);
						} else if (null != (ext = p.getExtension(LeaveMessageExtension.name, LeaveMessageExtension.NAMESPACE))) {
							fireLeftEvent(matchId, Participant.parseParticipant(resource));
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
					if (p.getFrom().contains(getMugServiceId())) {
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

		DiscoverInfo discoInfo = discoManager.discoverInfo(getMugServiceId());

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


	private boolean isValidGameName(String x) {
		return Pattern
				.matches(
						"^http://jabber\\.org/protocol/mug/[a-zA-Z]([a-zA-Z_0-9\\.\\-]*{3,})$",x) 
						||
						Pattern.matches("^urn:xmpp:mug:tp:[a-zA-Z]([a-zA-Z_0-9\\.\\-]*{3,}):[0-9]+:[a-zA-Z]([a-zA-Z_0-9\\.\\-]*{3,})", x);
	}

	public void registerApp(final String appname, final int appversion) throws XMPPException {
		final RegisterApp registerApp = new RegisterApp();
		registerApp.setAppname(appname);
		registerApp.setAppversion(appversion);
		IQ iq = new IQ() {

			@Override
			public String getChildElementXML() {
				return registerApp.toXML();
			}

		};

		iq.setType(org.jivesoftware.smack.packet.IQ.Type.SET);
		iq.setTo(getMugServiceId());

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
		} 

		System.out.println("registered app with (name:" + appname + ", version:" + appversion
				+ "). server response:" + result.toXML());
	}
	
	public void registerGame(final Game game) throws XMPPException {
		final RegisterGame registerGame = new RegisterGame();
		registerGame.setGame(game);
		IQ iq = new IQ() {

			@Override
			public String getChildElementXML() {
				return registerGame.toXML();
			}

		};

		iq.setType(org.jivesoftware.smack.packet.IQ.Type.SET);
		iq.setTo(getMugServiceId());

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
		} 

		System.out.println("registerd game '" + game.getName()
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
				return new InstantMatch(gameId).toXML();
			}

		};

		createMatchIQ.setTo(getMugServiceId());

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(createMatchIQ
						.getPacketID()));

		connection.sendPacket(createMatchIQ);

		IQ result = (IQ) collector.nextResult(50000);
		// Stop queuing results
		collector.cancel();
		if (result == null) {
			throw new XMPPException("No response from the server.");
		} else if (result.getError() != null) {
			throw new XMPPException(result.getError());
		}


		return result.getFrom();
	}

	public String findMatch(final String gameId) throws XMPPException {
		IQ createMatchIQ = new IQ() {

			@Override
			public String getChildElementXML() {
				return new MatchRequest(gameId, null, loginUserId).toXML();
			}

		};

		createMatchIQ.setTo(getMugServiceId());

		PacketCollector collector = connection
				.createPacketCollector(new PacketIDFilter(createMatchIQ
						.getPacketID()));

		connection.sendPacket(createMatchIQ);

		IQ result = (IQ) collector.nextResult(50000);
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

	public String openApp(final String appId) throws XMPPException {
		Presence openAppPresence = new Presence(Type.available);
		openAppPresence.addExtension(new OpenApp(appId));
		openAppPresence.setTo(getMugServiceId());

		connection.sendPacket(openAppPresence);
		return openAppPresence.getPacketID();
	}
	
	public String closeApp(final String appId) throws XMPPException {
		Presence closeAppPresence = new Presence(Type.unavailable);
		closeAppPresence.addExtension(new OpenApp(appId));
		closeAppPresence.setTo(getMugServiceId());
		connection.sendPacket(closeAppPresence);
		return closeAppPresence.getPacketID();
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

		connection.sendPacket(joinMatchPresence);
		return joinMatchPresence.getPacketID();
	}

	public void startMatch(final String matchId) throws XMPPException {
		Message startMatchMessage = new Message();
		startMatchMessage.addExtension(new StartMessageExtension());

		startMatchMessage.setTo(matchId);


		connection.sendPacket(startMatchMessage);
	}
	
	public void leaveMatch(final String matchId) throws XMPPException {
		Message leaveMatchMessage = new Message();
		leaveMatchMessage.addExtension(new LeaveMessageExtension());

		leaveMatchMessage.setTo(matchId);


		connection.sendPacket(leaveMatchMessage);
	}

	public void sendTurn(final String matchId, String newstate, boolean terminate)
			throws XMPPException {
		Message turnMessage = new Message();
		turnMessage.addExtension(new TurnMessage(newstate, terminate));

		turnMessage.setTo(matchId);

		connection.sendPacket(turnMessage);
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
		matchdataIQ.setTo(getMugServiceId());

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
		userDataIQ.setTo(getMugServiceId());

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
		userDataIQ.setTo(getMugServiceId());

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
