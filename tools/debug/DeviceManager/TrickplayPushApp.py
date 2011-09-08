#!/usr/bin/env python

# TODO: The paths sent will be in this system's format. If you run this on
# Windows, the server will receive windows paths.

import os
import json
import sys
import hashlib
import socket
import urllib2

from PyQt4.QtGui import *
from PyQt4.QtCore import *

class TrickplayPushApp():   

    def __init__(self, path = None):
        
        self.path = path
    
    def push(self, path = None, address = None):
        
        path = path or self.path
        
        if not path:
            print('No path given')
            return False
        
        if not address:
            print('No location given for pushing app')
            return False
        
        path = str(path)
        address = str(address)
        
        message = {}
        
        file_list = []
        
        for root , dirs , files in os.walk( path ):
        
            for file in files:
                
                file_list.append( os.path.join( root , file ) )
                
                
        prefix = os.path.commonprefix( file_list )
        
        if len( prefix ) == 0:
            sys.exit( "Invalid file list prefix" )
        
        try:    
        
            app_index = file_list.index( os.path.join( prefix , "app" ) )
            
        except:
            
            print( "Missing 'app' file" )
            
            return False
        
        app_file = open( file_list[ app_index ] )
        message[ "app" ] = app_file.read()
        app_file.close()
        
        message[ "files" ] = []
        
        file_map = {}
        
        for file in file_list:
            
            f = open( file )
            contents = f.read()
            f.close()
            m = hashlib.md5()
            m.update( contents )
            m = m.hexdigest()
            
            short_name = file[ len( prefix ) : ]
            
            file_map[ short_name ] = file
            
            message[ "files" ].append( [ short_name , m , len( contents ) ] )
        
        #-----------------------------------------------------------------------
        
        response = {}
        
        try:
            
            print( "Connecting..." )
            request = urllib2.Request( "http://" + address + "/push" , json.dumps( message ) , { "Content-Type" : "application/json" } )
            response = urllib2.urlopen( request )
            response = json.load( response )
           
        except:
            
            print( "Connection failed" )
            
            return False
        
        
        numFiles = len(file_list)
        progress = QProgressDialog("Pushing application...", "Abort", 0, numFiles);
        progress.setWindowModality(Qt.WindowModal)
        progress.setMinimumDuration(0)
        currentFile = 0
        
        while not response[ "done" ]:
            
            try:
                
                progress.setValue(currentFile);
                
                if (progress.wasCanceled()):
                    raise Exception
                
                file_name = file_map[ response[ "file" ] ]
                length = os.path.getsize( file_name )
                print( "Sending %s" % response[ "file" ] )
                
                f = open( file_name )
                
                request = urllib2.Request( "http://" + address + response[ "url" ] , f , { "Content-Type" : "application/octet-stream" , "Content-Length" : "%d" % length } )
                response = json.load( urllib2.urlopen( request ) )
                
                f.close()
                
                currentFile += 1
                
            except:
                
                print( "Failed to send files" )
                
                return False
        
        progress.setValue(100);
            
        print( response[ "msg" ] )
        
        return True
        
        #-----------------------------------------------------------------------
