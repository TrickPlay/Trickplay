package com.trickplay.gameservice.xmpp.client;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver;

public class GuessGameState {
	private int attempts;
	private int guess;
	private int low;
	private int high;
	private boolean won;

	public GuessGameState() {

	}

	public GuessGameState(int low, int high) {
		this.low = low;
		this.high = high;
		this.guess = -1;
	}

	public GuessGameState(int guess) {
		this.guess = guess;
	}

	public int getAttempts() {
		return attempts;
	}

	public void setAttempts(int attempts) {
		this.attempts = attempts;
	}

	public int getGuess() {
		return guess;
	}

	public void setGuess(int guess) {
		this.guess = guess;
	}

	public int getLow() {
		return low;
	}

	public void setLow(int low) {
		this.low = low;
	}

	public int getHigh() {
		return high;
	}

	public void setHigh(int high) {
		this.high = high;
	}

	public boolean isWon() {
		return won;
	}

	public void setWon(boolean won) {
		this.won = won;
	}

	public String toJSON() {
		XStream xstream = new XStream(new JettisonMappedXmlDriver());
		xstream.setMode(XStream.NO_REFERENCES);
		xstream.alias("guessGameState", GuessGameState.class);

		return xstream.toXML(this);
	}
	
	public static GuessGameState parseGuessGameStateFromJSON(String jsonStr) {
		XStream xstream = new XStream(new JettisonMappedXmlDriver());
		xstream.alias("guessGameState", GuessGameState.class);
		GuessGameState state = (GuessGameState)xstream.fromXML(jsonStr);
		return state;
	}

	public static void main(String[] args) {
		// test marshalling and unmarshalling to xstream
		GuessGameState state = new GuessGameState(0, 9);
		
		System.out.println("marshalled game state:" + state.toJSON());
		
		String jsonState = state.toJSON();
		GuessGameState stateFromJSON = parseGuessGameStateFromJSON(jsonState);
		
		System.out.println("unmarshalled game state:" + stateFromJSON.toJSON());
		
	//	GuessGameState stateFromEmptyJSON = parseGuessGameStateFromJSON("{}");
	//	System.out.println("unmarshalled game state from empty json:" + stateFromEmptyJSON.toJSON());
	}

}
