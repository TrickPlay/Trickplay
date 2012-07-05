package com.trickplay.gameservice.xmpp.client;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver;

public class UserGameData {
	private int wins;
	private int losses;
	private int played;

	
	public UserGameData(int played, int wins, int losses) {
		this.setPlayed(played);
		this.wins = wins;
		this.losses = losses;
	}

	public UserGameData() {
		this(0, 0,0);
	}

	
	public void setPlayed(int played) {
		this.played = played;
	}

	public int getPlayed() {
		return played;
	}

	public int getWins() {
		return wins;
	}

	public void setWins(int wins) {
		this.wins = wins;
	}

	public int getLosses() {
		return losses;
	}

	public void setLosses(int losses) {
		this.losses = losses;
	}

	public String toJSON() {
		XStream xstream = new XStream(new JettisonMappedXmlDriver());
		xstream.setMode(XStream.NO_REFERENCES);
		xstream.alias("userGameData", UserGameData.class);

		return xstream.toXML(this);
	}
	
	public static UserGameData parseFromJSON(String jsonStr) {
		if (jsonStr == null || jsonStr.isEmpty())
			return new UserGameData();
		XStream xstream = new XStream(new JettisonMappedXmlDriver());
		xstream.alias("userGameData", UserGameData.class);
		UserGameData state = (UserGameData)xstream.fromXML(jsonStr);
		return state;
	}

	public static void main(String[] args) {
		// test marshalling and unmarshalling to xstream
		UserGameData state = new UserGameData(10, 0, 9);
		
		System.out.println("marshalled userdata:" + state.toJSON());
		
		String jsonState = state.toJSON();
		UserGameData stateFromJSON = parseFromJSON(jsonState);
		
		System.out.println("unmarshalled gamedata:" + stateFromJSON.toJSON());
		
	//	GuessGameState stateFromEmptyJSON = parseGuessGameStateFromJSON("{}");
	//	System.out.println("unmarshalled game state from empty json:" + stateFromEmptyJSON.toJSON());
	}

}
