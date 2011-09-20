package com.trickplay.androidremote;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

//import android.R;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiManager.MulticastLock;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import javax.jmdns.JmDNS;
import javax.jmdns.ServiceInfo;
import javax.jmdns.ServiceEvent;
import javax.jmdns.ServiceListener;
import javax.jmdns.ServiceTypeListener;

import org.cybergarage.upnp.*;
import org.cybergarage.upnp.device.DeviceChangeListener;
import org.cybergarage.upnp.device.NotifyListener;
import org.cybergarage.upnp.device.SearchResponseListener;
import org.cybergarage.upnp.event.EventListener;
import org.cybergarage.upnp.ssdp.SSDPPacket;





public class TrickplayRemote extends ListActivity implements ServiceListener, ServiceTypeListener, NotifyListener, SearchResponseListener, DeviceChangeListener, EventListener  {
	private static final int BONJOUR_MODE=1;
	private static final int UPNP_MODE=2;
	private List<ServiceEvent> mServerObjects; 
	private List<String> mUPnPDeviceObjects;
	 private Handler mHandler = new Handler();
	 private List<String> mServerStrings; 
	 private int mDiscoveryMode;
	 JmDNS jmdns;
	 ControlPoint UPnPClient;
	 private String mSelectedServer;
	 private boolean mAddedWifiLock;
	 
	 private class ServiceRequestor implements Runnable {
			private ServiceEvent event_;
			public ServiceRequestor(ServiceEvent e) 
			{ 
				event_ = e; 
			}
			public void run() 
			{ 
				jmdns.requestServiceInfo(event_.getType(), event_.getName()); 
			}
		}
	 
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        mServerStrings = new ArrayList<String>();
        mServerObjects = new ArrayList<ServiceEvent>();
        mAddedWifiLock = false;
       
        
        
        TextView theTextView = (TextView)findViewById(R.id.mainlabel);
        theTextView.setText("Trickplay Remote");
        
        mDiscoveryMode = BONJOUR_MODE;
        
        if (mDiscoveryMode == BONJOUR_MODE)
        {
          try {
        	  WifiManager wifi = (WifiManager)getSystemService(Context.WIFI_SERVICE);
              
              MulticastLock lock = wifi.createMulticastLock("mylock");
              lock.acquire();
              mAddedWifiLock = true;
              
                this.CreateBonjourInterface();
                

          } catch (Exception e) {
                //e.printStackTrace();
                Log.e("Trickplay", Log.getStackTraceString(e));
          }
        }
        else if (mDiscoveryMode == UPNP_MODE)
        {
        	
        	this.CreateUPNPInterface();
        }
        

    }
    
    private void CreateBonjourInterface()
    {
    	try {
    		jmdns = JmDNS.create();
    		jmdns.addServiceListener("_tp-remote._tcp.local.", this);
    		jmdns.registerServiceType("_tp-remote._tcp.local.");
    	} catch (Exception e) {
            //e.printStackTrace();
            Log.e("Trickplay", Log.getStackTraceString(e));
      }
    }
    
    private void CreateUPNPInterface()
    {
    	try {
    		UPnPClient = new ControlPoint();
    		UPnPClient.start();
    		UPnPClient.addNotifyListener(this);
    		UPnPClient.addSearchResponseListener(this);
    		UPnPClient.addDeviceChangeListener(this);
    		UPnPClient.addEventListener(this);
    	} catch (Exception e) {
            //e.printStackTrace();
            Log.e("Trickplay", Log.getStackTraceString(e));
      }	
    }
    
    @Override
    public void serviceTypeAdded(ServiceEvent event)
    {
    	
    	jmdns.removeServiceListener(event.getType(), this);
    	jmdns.addServiceListener(event.getType(), this);
    }
    
    public void serviceAdded(ServiceEvent event) {
    	
    	//Toast.makeText(getApplicationContext(),"A service event has been added: " + event.getName(),Toast.LENGTH_LONG).show();
    	//System.out.println("added event=["+event+"]");
    	//TextView theTextView = (TextView)findViewById(R.id.mainlabel);
        //theTextView.setText("Service event added");
    	Log.v("Trickplay", "Service found: " + event.getName());
    	//event.getDNS().requestServiceInfo("_tp-remote._tcp.local.",event.getName(),3000);
    	ServiceRequestor oRequest = new ServiceRequestor(event);
    	
    }
    public void updateServerList()
    {
    	setListAdapter(new ArrayAdapter<String>(this,R.layout.list_item, mServerStrings));
    }

    public void serviceRemoved(ServiceEvent event) {
    		//Toast.makeText(getApplicationContext(),"A service event has been removed: " + event.getName(),Toast.LENGTH_LONG).show();
    	//System.out.println("removed event=["+event+"]");
    		//TextView theTextView = (TextView)findViewById(R.id.mainlabel);
            //theTextView.setText("Service removed");
    	if (!mServerStrings.isEmpty())
    	{
    		//Remove this entry from the list
    		mServerStrings.remove(event.getName());
    	}
    	mServerObjects.remove(event);
    	mHandler.post(new Runnable() {
			public void run() {
				//Update the list
				updateServerList();
				
			}
		});
    	Log.v("Trickplay", "Service removed: " + event.getName());
    }

    public void serviceResolved(ServiceEvent event) {
    	//Launch the subview that shows the background like on the iPhone
    	Log.v("Trickplay", "Service resolved: " + event.getName());
    	mServerObjects.add(event);
    	mServerStrings.add(event.getName());
    	mHandler.post(new Runnable() {
			public void run() {
				//Update the list
				updateServerList();
				
			}
		});
    	
    }
    
    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
    	super.onListItemClick(l, v, position, id);
    	
    	if (mDiscoveryMode == BONJOUR_MODE)
    	{
		    	//resolve the service
	    	ServiceEvent event = (ServiceEvent)mServerObjects.get(position);
	    	
	    	String hostname = "";
	    	String hostaddress = "";
	    	String serveraddress = "";
	    	
	    	int hostport = 0;
			try {
				hostname = event.getName();
				hostaddress = event.getInfo().getHostAddress();
				serveraddress = event.getInfo().getServer();
				String a2 = event.getInfo().getAddress().getHostAddress();
				String a3 = event.getInfo().getAddress().getHostName();
				String a4 = event.getInfo().getServer();
				String a33 = event.getDNS().getInterface().getHostAddress();
				String a34 = event.getInfo().getURL();
				String a5 = event.getInfo().getInetAddress().getHostAddress();
				String a6 = event.getInfo().getInetAddress().getHostName();
				hostport = event.getInfo().getPort();
			} catch (Exception e) {
				// TODO: handle exception
			}
	    	//jmdns.requestServiceInfo("_tp-remote._tcp.local.", event.getName());
	    	Intent intentObj = new Intent(this, GestureScreen.class);
	    	//Bundle bundle2 = new Bundle();
	    	intentObj.putExtra("hostname", hostname);
	    	//if (hostaddress.startsWith("192"))
	    	//{
	    		intentObj.putExtra("hostaddress", hostaddress); 
	    	//}
	    	//else
	    	//{
	    	//	intentObj.putExtra("hostaddress", serveraddress);  
	    	//}
	    	
	    	intentObj.putExtra("hostport", hostport);
	    	//bundle.
	    	startActivityForResult(intentObj, 1);
    	}
    	else
    	{
    		//UPnP mode
    		Intent intentObj = new Intent(this, GestureScreen.class);
    		//Device thedev = (Device)mUPnPDeviceObjects.get(position);
    		String hostname = "";//thedev.getInterfaceAddress();
	    	String hostaddress = "";//thedev.getMulticastIPv4Address();
	    	int theport = 0;
	    	String[] theitems = mSelectedServer.split(";");
	    	//String[] theitems = (String[])mUPnPDeviceObjects.get(position).split(";");
	    	hostname = theitems[0];
	    	hostaddress = theitems[1];
	    	theport = Integer.parseInt( theitems[2]);
	    	//theport = thedev.getHTTPPort();
	    	//int otherport = thedev.getSSDPPort();
    		
    		intentObj.putExtra("hostname", hostname );
    		intentObj.putExtra("hostaddress", hostaddress); 
    		intentObj.putExtra("hostport", theport);
    		startActivityForResult(intentObj, 1);
    	}
    	
    }
	@Override
	public void deviceNotifyReceived(SSDPPacket ssdpPacket) {
		Log.w("Trickplay", "device notify received");
		//if (!mServerStrings.contains(ssdpPacket.getServer()) && ssdpPacket.getServer().length() > 0)
		//{
		@SuppressWarnings("unused")
		String str1 = ssdpPacket.getHost();
		String str2 = ssdpPacket.getLocalAddress();
		String str3 = ssdpPacket.getLocation();
		String str4 = ssdpPacket.getMAN();
		String str5 = ssdpPacket.getNT();
		String str6 = ssdpPacket.getRemoteAddress();
		String str7 = ssdpPacket.getServer();
		@SuppressWarnings("unused")
		String str8 = ssdpPacket.getUSN();
		
		
			//mServerStrings.add("DNR: " + ssdpPacket.getServer());
			mHandler.post(new Runnable() {
				public void run() {
					//Update the list
					updateServerList();
				
				}
			});
		//}		
	}
	
	@Override
	public void deviceSearchResponseReceived(SSDPPacket ssdpPacket) {
		Log.w("Trickplay", "search response received");
	}
	@Override
	public void deviceAdded(Device dev) {
		Log.w("Trickplay", "Device added");
		//if (!mServerStrings.contains(dev.getFriendlyName()) && dev.getFriendlyName().length() > 0)
		//{
			String str1 = dev.getDescriptionFilePath();
			String str2 = dev.getInterfaceAddress();
			String str3 = dev.getLocation();
			String str4 = dev.getMulticastIPv4Address();
			String str5 = dev.getSSDPIPv4MulticastAddress();
			String str6 = dev.getUDN();
			//String str20 = dev.getHTTPBindAddress()[0].getHostName();
			//String str21 = dev.getHTTPBindAddress()[0].getHostAddress();
			//String aserer = dev.getHTTPBindAddress()[0].getCanonicalHostName();
			int theport = dev.getHTTPPort();
			
			
			if (!mServerStrings.contains(dev.getFriendlyName()))
			{
				mServerStrings.add("" + dev.getFriendlyName() + theport);
				//mUPnPDeviceObjects.add(str3 + ";" + str4 );//+ ";" + theport);
				mSelectedServer =  str3 + ";" + str4 + ";" + theport;
				
			}
			mHandler.post(new Runnable() {
				public void run() {
					//Update the list
					updateServerList();
				
				}
			});
		//}
	}
	@Override
	public void deviceRemoved(Device dev) {
		
		Log.w("Trickplay", "device removed");
	}
	@Override
	public void eventNotifyReceived(String uuid, long seq, String varName,
			String value) {
		Log.w("Trickplay", "event notify received");
		
	}
	
	private void CloseTheInterfaces()
	{
		//Disconnect the socket if it is connected
		if (UPnPClient != null)
		{
			try {
				UPnPClient.stop();
				UPnPClient.removeDeviceChangeListener(this);
				UPnPClient.removeEventListener(this);
				UPnPClient.removeNotifyListener(this);
				UPnPClient.removeSearchResponseListener(this);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		if (jmdns != null)
		{
			try {
				jmdns.removeServiceListener("_tp-remote._tcp.local.", this);
				jmdns.removeServiceTypeListener(this);
			} catch (Exception e) {
				e.printStackTrace();
			}
            
		}
	}
	
	@Override
	protected void onStop()
	{
		
		this.CloseTheInterfaces();
		super.onStop();
	}
	
	@Override
	protected void onPause()
	{
		//this.CloseTheInterfaces();
		super.onPause();
	}
	
	 @Override
	 public boolean onCreateOptionsMenu(Menu menu) {
	    super.onCreateOptionsMenu(menu);
	    
	    	menu.add(0, 0, 0, "UPNP Mode");
	    	    
	    	menu.add(0, 1, 0, "Bonjour Mode");
	    	    
	    return true;
	 }
	 
	 public boolean onOptionsItemSelected(MenuItem item) {
	    	
	        
	        switch (item.getItemId()) {
	        case 0:
	        	//Switch to UPNP
	        	mServerStrings.clear();
	        	//this.updateServerList();
	        	CloseTheInterfaces();
	        	mDiscoveryMode = UPNP_MODE;
	        	this.CreateUPNPInterface();
	        	mHandler.post(new Runnable() {
					public void run() {
						//Update the list
						updateServerList();
					
					}
				});
	        	
	            return true;
	        case 1:  //Search
	        	//Switch to Bonjour
	        	mServerStrings.clear();
	        	//this.updateServerList();
	        	CloseTheInterfaces();
	        	mServerObjects.clear();
	        	mDiscoveryMode = BONJOUR_MODE;
	        	
	        	if (!mAddedWifiLock)
	        	{
	        		WifiManager wifi = (WifiManager)getSystemService(Context.WIFI_SERVICE);
	              
	        		MulticastLock lock = wifi.createMulticastLock("mylock");
	        		lock.acquire();
	        	}
	        	CreateBonjourInterface();
	        	mHandler.post(new Runnable() {
					public void run() {
						//Update the list
						updateServerList();
					
					}
				});
	        	
	            return true;
	        		
	        }
	        return false;
	    }
}
