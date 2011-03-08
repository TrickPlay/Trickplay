package com.trickplay.androidremote;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Observable;          //Observable is here

import android.util.Log;

public class ReadThread extends  Observable implements Runnable
{
  private Socket client;

  public ReadThread(Socket client)
  {
    this.client = client;
  }

  public void run()
  {
	  
	  try
	    {
		  while (true)
		  {
		      //Goes here on a touch of the screen, but gets stuck waiting for something
		      BufferedReader inFromServer = new BufferedReader(new InputStreamReader(this.client.getInputStream()));
		      String fromServer = inFromServer.readLine();
		      Log.v("Trickplay", fromServer);
		  
              setChanged();
              notifyObservers( fromServer );
		      
		      //client.getOutputStream().write(buffer);
		      if ((fromServer == null) || (fromServer.equals("Q")) || (fromServer.equals("q"))) {
		        this.client.close();
		       
		      }
		  }
	     
	    }
	    catch (Exception e)
	    {
	      System.out.println("THE SERVER IS DISCONNECTED.");
	    }
	  
  }
  
}
/*
 * public class TCPClient implements Runnable { 

  Socket socketCliente; 
  Handler handler; 

  public TCPClient(Socket socketCliente, Handler handler) { 
    this.socketCliente = socketCliente; 
    this.handler = handler; 
  } 

  @Override 
  public void run() { 
    char[] line = new char[100]; 
    BufferedReader in = null; 
    try { 
      in = new BufferedReader(new InputStreamReader(socketCliente.getInputStream())); 
      while (true) { 
        line = new char[100]; 
        in.read(line, 0, 100); 
        if (line.length > 0) { 
          String msg = new String(line); 
          // processar a mensagem 
          Message lmsg = new Message(); 
          lmsg.what = 0; 
          lmsg.obj = msg; 
          handler.sendMessage(lmsg); 
        } 
      } 
    } catch (IOException e) { 
      e.printStackTrace(); 
    } 
  } 
}
 */
