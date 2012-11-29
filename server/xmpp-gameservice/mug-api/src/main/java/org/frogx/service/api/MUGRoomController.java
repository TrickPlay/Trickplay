
package org.frogx.service.api;


import org.xmpp.packet.Packet;

/**
 *
 */
public interface MUGRoomController {
	
	/**
	 * This method handles a {@see Packet} send to a
	 * {@see net.sf.openfire.mug.lib.MUGRoom} or
	 * 
	 * @param packet The XMPP stanza which should be handled.
	 */
	public void process(Packet packet);
		
}
