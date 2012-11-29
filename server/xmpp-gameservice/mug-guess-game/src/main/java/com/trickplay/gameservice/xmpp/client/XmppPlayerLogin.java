package com.trickplay.gameservice.xmpp.client;


public class XmppPlayerLogin {

	public static void main(String[] args) throws Exception {

		if (args.length != 2) {
			System.out.println("usage is XmppPlayerLogin <username> <password>");
			System.exit(1);
		}
		String username = args[0];
		String password = args[1];
		GameServiceProxy xmppManager = new GameServiceProxy("localhost", 5222);

		try {
			xmppManager.init();
			
			System.out.println("login to xmpp server with username:"+username+" and password:"+password);
			xmppManager.performLogin(username, password);
			xmppManager.setStatus(true, "Hello everyone");
			
			System.out.println("login successful");

			

			xmppManager.printRoster();


		} catch (Exception ex) {
			ex.printStackTrace();
		}
		boolean keepRunning = true;
		while (xmppManager != null && keepRunning) {
			Thread.sleep(50);
		}

		xmppManager.destroy();

	}

}
