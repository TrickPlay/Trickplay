package com.trickplay.gameservice.xmpp.mug;

public class Participant {

	private int inRoomId;
	private String nick;
	public Participant(int inRoomId, String nick) {
		super();
		this.inRoomId = inRoomId;
		this.nick = nick;
	}
	public Participant() {
		super();
		// TODO Auto-generated constructor stub
	}
	public int getInRoomId() {
		return inRoomId;
	}
	public void setInRoomId(int inRoomId) {
		this.inRoomId = inRoomId;
	}
	public String getNick() {
		return nick;
	}
	public void setNick(String nick) {
		this.nick = nick;
	}
	
	public static Participant parseParticipant(String resource) {
		Participant p = new Participant();
		if (resource == null)
			return p;
		int underscoreLoc = resource.indexOf("_");
		if (underscoreLoc >= 0) {
			String inRoomIdStr = resource.substring(0, underscoreLoc);
			p.setInRoomId(Integer.parseInt(inRoomIdStr));
			p.setNick(resource.substring(underscoreLoc+1));
		}
		return p;
	}
}
