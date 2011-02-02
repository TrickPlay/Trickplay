package com.trickplay.androidremote;
import java.io.File;
import java.util.ArrayList; 


import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;

import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import android.view.View.OnTouchListener;
import android.webkit.WebView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.view.MotionEvent;

import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.Socket;
import java.net.URL;
import java.lang.System;
import java.util.List;
import java.util.Observable;
import java.util.Observer;  /* this is Event Handler */
import android.os.Vibrator;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorManager;
import android.hardware.SensorEventListener;
//Look at http://developer.android.com/resources/samples/ApiDemos/src/com/example/android/apis/os/Sensors.html for sensor example


public class GestureScreen extends ListActivity implements Observer, SensorEventListener {

	public Boolean mTouchEventsAllowed;
	public Boolean mClickEventsAllowed;
	private float mTouchStartPositionX;
	private float mTouchCurrentPositionX;
	private float mTouchStartPositionY;
	private float mTouchCurrentPositionY;
	private int mAccelMode;
	private static final int MAX_TAP_DISTANCE=4;
	Socket client;
	private Boolean mKeySent;
	private Boolean mSwipeSent;
	private MediaPlayer mMediaPlayer;
	private SensorManager mSensorManager;
    private List<String> mDefinedResourceNames;
    private List<String> mDefinedResourceValues;  
    String mHostAddress; 
    int mHostPort;
    private List<String> mUIChoiceStrings;
    private List<String> mUIChoiceIDs;
    private ImageView imView;
    private Handler mHandler = new Handler();
    
	@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.gesture_view);
       
        mTouchEventsAllowed = true;
        mClickEventsAllowed = true;
        mKeySent = false;
        mSwipeSent = false;
        mAccelMode = 0;
        mDefinedResourceNames  = new ArrayList<String>();
        mDefinedResourceValues = new ArrayList<String>();
        mUIChoiceStrings       = new ArrayList<String>();
        mUIChoiceIDs       = new ArrayList<String>();
        
        View thetextview = (View) findViewById(R.id.edittext);
        thetextview.setVisibility(View.GONE);
        
        
        mMediaPlayer = new MediaPlayer();
        imView = (ImageView)findViewById(R.id.imview);
        //downloadFile("http://www.google.com/intl/en_ALL/images/srpr/logo1w.png");
        //android:background="@drawable/default_background"
        imView.setBackgroundResource(R.drawable.default_background);
        //imView.setVisibility(View.GONE);
        //mUIChoiceStrings.add("choice1");
        //mUIChoiceStrings.add("choice2");
        //setListAdapter(new ArrayAdapter<String>(this,R.layout.list_item, mUIChoiceStrings));
        setListAdapter(new ArrayAdapter<String>(this,R.layout.list_item, mUIChoiceStrings));
        
                
        //webView.addJavascriptInterface(new MyJavaScriptInterface(), "HTMLOUT"); 
        String hostname = "";
        mHostAddress = "";
        mHostPort = 0;
        Bundle extras = getIntent().getExtras();
        
        if (extras != null) {
        	String htmlText = extras.getString("htmlText");
        	hostname = extras.getString("hostname");
        	mHostAddress = extras.getString("hostaddress");
        	mHostPort = extras.getInt("hostport");
        }
        
        
        client = null;
        try
        {
          client = new Socket(mHostAddress, mHostPort);
        } catch (Exception e) {
          e.printStackTrace();
          finish();
          return;
        }

        ReadThread readThread = new ReadThread(client);
        readThread.addObserver(this);
        Thread tRead = new Thread(readThread);
        tRead.setPriority(1);
        tRead.start();

        try
        {
            PrintWriter outStream = null;
	        outStream = new PrintWriter(client.getOutputStream(), true);
	        //android.os.Build.MODEL
	        outStream.println("ID\t2\t" + android.os.Build.PRODUCT + "\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=320x410\tUS=320x410\n");  
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        //used to be mainwindow
        findViewById(R.id.imview).setOnTouchListener(new OnTouchListener() { 
        	
            public boolean onTouch(View v, MotionEvent event) { 
            	if (event.getAction() == 0)//down
            	{
            		float xpos = event.getX();  //Starting value for X
        			float ypos = event.getY();  //Starting value for y
        			mTouchStartPositionX = xpos;
        			mTouchStartPositionY = ypos;
        			mTouchCurrentPositionX = xpos;
        			mTouchCurrentPositionY = ypos;
        			mKeySent = false;
        			
            		if (mTouchEventsAllowed )  //&& client != null
            		{
            				
            			try
            	        {
            	            PrintWriter outStream = null;
            		        outStream = new PrintWriter(client.getOutputStream(), true);
            		        
            		        outStream.println("TD\t" + xpos + "\t" + ypos + "\n");  
            	        } catch (Exception e) {
            	            e.printStackTrace();
            	        }
            		}
            	}
            	else if (event.getAction() == 2)//moved
            	{
            		float xpos = event.getX();  //Starting value for X
            		float ypos = event.getY();  //Starting value for y
            		mTouchCurrentPositionX = xpos;
            		mTouchCurrentPositionY = ypos;
            		
            		if (mTouchEventsAllowed )  //&& client != null
                	{	
            			try
            	        {
            	            PrintWriter outStream = null;
            		        outStream = new PrintWriter(client.getOutputStream(), true);
            		        
            		        outStream.println("TM\t" + xpos + "\t" + ypos + "\n");  
            	        } catch (Exception e) {
            	            e.printStackTrace();
            	        }
            		}
            		//See if a swipe was triggered
            		if (mKeySent) return true;  //Don't send another event if it has already completed one
            		
            		//Try to detect a swipe
            		if ((Math.abs(mTouchStartPositionX - mTouchCurrentPositionX) / Math.abs(mTouchStartPositionY - mTouchCurrentPositionY) > 2.0) &&
            				(Math.abs(mTouchStartPositionX - mTouchCurrentPositionX) >= 25))
            		{
            			if (mTouchStartPositionX < mTouchCurrentPositionX)
            			{
            				//Send right key -  FF53
            				sendKeyToTrickplay("FF53");
            			}
            	        else
            			{
            				//Send left key  - FF51
            				mKeySent = true;
            				sendKeyToTrickplay("FF51");
            				
            			}
            			mSwipeSent = true;
            		}
            		else if ((Math.abs(mTouchStartPositionY - mTouchCurrentPositionY) / Math.abs(mTouchStartPositionX - mTouchCurrentPositionX) > 2.0) &&
            				 (Math.abs(mTouchStartPositionY - mTouchCurrentPositionY) >= 25))
            		{
            			if (mTouchStartPositionY < mTouchCurrentPositionY)
            			{
            				//Send down key -  FF54
            				sendKeyToTrickplay("FF54");
            			}
            	        else
            			{
            				//Send up key  - FF52
            				sendKeyToTrickplay("FF52");
            			}
            			mSwipeSent = true;
            		}
            	}
            	else if (event.getAction() == 1)//up
            	{
            		
            		float xpos = event.getX();  //Starting value for X
            		float ypos = event.getY();  //Starting value for y
            		mTouchCurrentPositionX = xpos;
            		mTouchCurrentPositionY = ypos;
            		
            		if (mTouchEventsAllowed )  //&& client != null
                	{
            			try
            	        {
            	            PrintWriter outStream = null;
            		        outStream = new PrintWriter(client.getOutputStream(), true);
            		        
            		        outStream.println("TU\t" + xpos + "\t" + ypos + "\n");  
            		        
            		        //Now see if we should send an enter key if we had a tap
            	        } catch (Exception e) {
            	            e.printStackTrace();
            	        }
            		}
            		if (!mSwipeSent)
            		{
	        			//See if we have a tap
	        			if (Math.abs(mTouchStartPositionX - mTouchCurrentPositionX) <= MAX_TAP_DISTANCE &&
	        					Math.abs(mTouchStartPositionY - mTouchCurrentPositionY) <= MAX_TAP_DISTANCE)
	        			{
	        				//Send tap event
	        				sendKeyToTrickplay("FF0D");
	        				if (mClickEventsAllowed)
	                		{
	        					//NSData *sentClickData = [[NSString stringWithFormat:@"CK\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]] dataUsingEncoding:NSUTF8StringEncoding];
	        					//[listenSocket writeData:sentClickData withTimeout:-1 tag:0];
	        					sendCommandToTrickplay("CK\t" + mTouchCurrentPositionX + "\t" + mTouchCurrentPositionY + "\t" + System.currentTimeMillis());
	                		}
	        					
	        			}
            		}
            		mTouchStartPositionX = 0;
            		mTouchStartPositionY = 0;
            		mTouchCurrentPositionX = 0;
            		mTouchCurrentPositionY = 0;

        			mKeySent = false;
        			mSwipeSent = false;
            		
            	}
            	
                return true; 
            } 
        });
	
        
	}
	
	void downloadFile(String fileUrl){
        URL myFileUrl =null;          
        try {
             myFileUrl= new URL(fileUrl);
        } catch (MalformedURLException e) {
             // TODO Auto-generated catch block
             e.printStackTrace();
        }
        try {
             HttpURLConnection conn= (HttpURLConnection)myFileUrl.openConnection();
             conn.setDoInput(true);
             conn.connect();
             int length = conn.getContentLength();
             InputStream is = conn.getInputStream();
             
             final Bitmap bmImg = BitmapFactory.decodeStream(is);
             mHandler.post(new Runnable() {
					public void run() {
						imView.setImageBitmap(bmImg);
						
					}
				});
             
        } catch (IOException e) {
             // TODO Auto-generated catch block
             e.printStackTrace();
        }
   }
	
	@Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
    	super.onListItemClick(l, v, position, id);
    	
    	String uichoice = mUIChoiceIDs.get(position);
    	sendCommandToTrickplay("UI\t" + uichoice);
    	
    	mUIChoiceStrings.clear();
		mUIChoiceIDs.clear();
		setListAdapter(new ArrayAdapter<String>(this,R.layout.list_item, mUIChoiceStrings));
    	
    }
	
	

	
	public void update (Observable obj, Object arg) {
        if (arg instanceof String) {
        	
        	String message_str = (String)arg;
        	String message_array[] = message_str.split("\t");
        	
        	if (message_str.startsWith("SA"))  //start accelerometer events
        	{
        		if (message_array.length > 1)
        		{
        			if (message_array[1].matches("L"))
        			{
        				mAccelMode = 1;
        				//TODO the third parameter is time for update interval
        			}
        			else if (message_array[1].matches("H"))
        			{
        				mAccelMode = 2;
        				//TODO the third parameter is time for update interval
        			}
        		}
        		if (mSensorManager == null)
        		{
        			mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        	        Sensor accSensor = mSensorManager.getSensorList(Sensor.TYPE_ACCELEROMETER).get(0); 
        	        mSensorManager.registerListener(this, accSensor, SensorManager.SENSOR_DELAY_UI); 
        		}
        	}
        	else if (message_str.startsWith("PA"))  //stop accelerometer events
        	{
        		mAccelMode = 0;
        	}
        	else if (message_str.startsWith("SC"))  //start click events
        	{
        		mClickEventsAllowed = true;
        	}
        	else if (message_str.startsWith("PC"))  //stop click events
        	{
        		mClickEventsAllowed = false;
        	}
        	else if (message_str.startsWith("RT"))  //reset
        	{
        		//mClickEventsAllowed = false;
        		mAccelMode = 0;
        		clearUIElements();
        	}
        	else if (message_str.startsWith("DR"))
        	{
        		//Add the items to a collection
        		//int thelength = message_array.length;
        		//String[] from = new String[]{"book","chapter","verse","content"};
        		if (!mDefinedResourceNames.contains(message_array[1]))
        		{  
	        		mDefinedResourceNames.add(message_array[1]);	
	        		mDefinedResourceValues.add(message_array[2]);
        		}
        	}
        	else if (message_str.startsWith("UB"))  //UI background
        	{
        		if (mDefinedResourceNames.size() > 0)
        		{
	        		if (mDefinedResourceNames.contains(message_array[1]))
	        		{
	        		    //http://en.androidwiki.com/wiki/Loading_images_from_a_remote_server
	        			String theurl = mDefinedResourceValues.get(mDefinedResourceNames.indexOf(message_array[1]));
	        			if (!theurl.startsWith("http:") && !theurl.startsWith("https:"))
	        			{   //Use the host and port address as part of the url
		        			theurl = "http://" + mHostAddress + ":" + mHostPort + "/" + theurl;  //55664
		        			
	        			}
						View backview = (View) findViewById(R.id.imview);
        				try {
        					downloadFile(theurl);
							//backview.setBackgroundDrawable(drawable_from_url(theurl,message_array[1]));
						//} catch (MalformedURLException e) {
        				} catch (Exception e) {	
							// TODO Auto-generated catch block
							e.printStackTrace();
						//} catch (IOException e) {
							// TODO Auto-generated catch block
							//e.printStackTrace();
						}
	        		
        			}
        		}
        	}
        	else if (message_str.startsWith("SS"))  //play sound
        	{
        		//http://developer.android.com/guide/topics/media/index.html
        		if (mMediaPlayer == null)
        		{
        			mMediaPlayer = new MediaPlayer();
        		}
        		mMediaPlayer.reset();
        		if (mDefinedResourceNames.size() > 0)
        		{
	        		if (mDefinedResourceNames.contains(message_array[1]))
	        		{
	        			String theurl = mDefinedResourceValues.get(mDefinedResourceNames.indexOf(message_array[1]));
	        			if (!theurl.startsWith("http:") && !theurl.startsWith("https:"))
	        			{   //Use the host and port address as part of the url
		        			theurl = "http://" + mHostAddress + ":" + mHostPort + "/" + theurl;
		        			
	        			}
	        			
	        			try {
	        				mMediaPlayer.setDataSource(theurl);
							mMediaPlayer.prepare();
							//mMediaPlayer.prepareAsync();
							mMediaPlayer.start();
						} catch (IllegalStateException e) {
							e.printStackTrace();
						} catch (IOException e) {
							e.printStackTrace();
						}
						
					}
    			}
        		
        		
        	}
        	else if (message_str.startsWith("PS"))  //stop sound
        	{
        		mMediaPlayer.stop();
        		
        	}
        	else if (message_str.startsWith("CU"))  //clear UI elements
        	{
        		
        		clearUIElements();
        	}
        	else if (message_str.startsWith("VB"))  //vibration
        	{
        		//Vibrator vib = new Vibrator();
        		Vibrator vib = null;
        		vib.vibrate(100);
        		//vibrate(100);
        	}
        	else if (message_str.startsWith("MC"))  //multiple choice
        	{
        		mUIChoiceStrings.clear();
        		mUIChoiceIDs.clear();
        		
        		
        		String title = message_array[1];
        		int theindex = 2;  //Start at index 2 and loop through until all the items are in the arrays
        		while (theindex < message_array.length)
        		{
        			//First one is <id>
    				//Second is the text
    				//Theindex is the id
        			mUIChoiceIDs.add(message_array[theindex]);
        			mUIChoiceStrings.add(message_array[theindex + 1]);
    				theindex = theindex + 2;
        		}
        		this.onContentChanged();
        		setListAdapter(new ArrayAdapter<String>(this,R.layout.list_item, mUIChoiceStrings));
        	}
        	else if (message_str.startsWith("ET"))  //edit text
        	{
        		
        	}
        	
        	if (!message_str.startsWith("MC"))
            {
            	sendCommandToTrickplay("ECHO");
            }

        	
        }
    }
	
    private void clearUIElements()
    {
	    //Hide textview
	    
	    //Get rid of listview items, set to empty list I guess
	    mUIChoiceStrings.clear();
	    mUIChoiceIDs.clear();
	    
	    //Return background to default image
	    View backview = (View) findViewById(R.id.imview);
	    backview.setBackgroundResource(R.drawable.default_background);
	    
    }
    
    
    private android.graphics.drawable.Drawable drawable_from_url(String url, String src_name) throws java.net.MalformedURLException, java.io.IOException 
    {
    	return android.graphics.drawable.Drawable.createFromStream(((java.io.InputStream)new java.net.URL(url).getContent()), src_name);
	}
    
	private void sendCommandToTrickplay(String commandStr)
	{
		try
        {
            PrintWriter outStream = null;
	        outStream = new PrintWriter(client.getOutputStream(), true);
	        
	        outStream.println( commandStr + "\n");  
	        
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void sendKeyToTrickplay(String keyStr)
	{
		try
        {
            PrintWriter outStream = null;
	        outStream = new PrintWriter(client.getOutputStream(), true);
	        
	        outStream.println("KP\t" + keyStr + "\n");  
	        mKeySent = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	@Override
	protected void onStop()
	{
		super.onStop();
		//Disconnect the socket if it is connected
		if (client.isConnected())
		{
			try {
				client.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		if (mSensorManager != null)
		{
			mSensorManager.unregisterListener(this);
		}
		clearUIElements();
		mMediaPlayer.stop();
		 //mSensorManager.unregisterListener(this);
	}


	
	
	//Start of accelerometer code
	@Override
	public void onAccuracyChanged(Sensor arg0, int arg1) {
		// 
		
	}



	@Override
	public void onSensorChanged(SensorEvent event) {
		// Example values
		//0:   -1.7978895 
		//1:    4.955678
		//2:    8.566783
		
		if (mAccelMode > 0)
		{
			//send accelerometer event
			sendCommandToTrickplay("AX\t"+ (-1)*event.values[0]+"\t"+ (-1)*event.values[1]+"\t"+ (-1)*event.values[2]+"\t"+event.timestamp);
		}
	}
	
	//end accel code
     
     
} 
