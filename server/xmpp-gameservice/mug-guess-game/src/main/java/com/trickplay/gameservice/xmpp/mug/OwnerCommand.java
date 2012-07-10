package com.trickplay.gameservice.xmpp.mug;

import org.jivesoftware.smack.packet.PacketExtension;

public abstract class OwnerCommand implements PacketExtension {
	
	public static final String NAMESPACE = "http://jabber.org/protocol/mug#owner";
	
	public enum PayloadType { REQUEST, RESPONSE, ERROR }
	
	protected PayloadType payloadType;
	
	public final String getNamespace() {
		return NAMESPACE;
	}
	
	public PayloadType getPayloadType() {
		return payloadType;
	}
	
	public void setPayloadType(PayloadType payloadType) {
		this.payloadType = payloadType;
	}
	
}
