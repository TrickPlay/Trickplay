import os, telnetlib, base64, sys, random, json

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply

#from connection import *

class TrickplayEmulatorManager(QWidget):
    
    def __init__(self, main=None, parent = None):
        
        QWidget.__init__(self, parent)
                
        self.main = main
        self.inspector = main._inspector
        self._path = os.path.join(self.main.apath, 'VE')
        self.trickplay = QProcess()

        QObject.connect(self.trickplay, SIGNAL('started()'), self.app_started)
        QObject.connect(self.trickplay, SIGNAL('finished(int)'), self.app_finished)
        QObject.connect(self.trickplay, SIGNAL('readyRead()'), self.app_ready_read)

        self.manager = QNetworkAccessManager()

        self.http_port = None
        self.console_port = None

        self.name = 'Emulator'  
        self.port = '6789'
        self.address = 'localhost'
        
        #CON.port = self.port
        #CON.address = self.address

        self.run()

    def setUIInfo(self, gid, property, value):
        #print "TrickplayEmulatorManager.py setUIInfo ()"+str(value)
        #inputCmd = str("_VE_.setUIInfo("+str(gid)+",'"+str(property)+"','"+str(value)+"')")
        inputCmd = str("_VE_.setUIInfo("+str(gid)+",'"+str(property)+"',"+str(value)+")")
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def getUIInfo(self):
        inputCmd = str("_VE_.getUIInfo()")
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def app_started(self):
		print "[VE] APP Started"

    def readDebugResponse(self):
		while self.debug_socket.waitForReadyRead(1100) :
			print self.debug_socket.read(self.debug_socket.bytesAvailable())

    def app_ready_read(self):

		# Read all available output from the process
		
		while True:
			# Read one line
			if not self.trickplay.canReadLine():
			    break
			# Read one line
			s = self.trickplay.readLine()
			# If the line is null, it means there is nothing more
			# to read during this iteration
			if s.isNull():
				break
			# Convert it to a string and strip the trailing white space
			s = str( s ).rstrip()
			# Look for the VE_READY line
			if s.startswith( "<<VE_READY>>:" ):
				try:
					#self.getUIInfo()
					self.inspector.refresh() 
				except:
					print( "[VE] Failed to obtain ui info" )
					# Close the process
					self.trickplay.close()
			else:
				# Output the log line
				pdata = None
				gid = None
				if s is not None and len(s) > 9 :
				    if s[:9] == "getUIInfo":
				        pdata = json.loads(s[9:])
				        print("__VE__.getUIInfo()")
				    elif s[:9] == "repUIInfo":
				        pdata = json.loads(s[9:])
				    elif s[:9] == "openInspc":
				        gid = int(s[9:])
				    else:
				        #print(">> %s"%s)
				        pass

				    if pdata is not None:
				        #print("[VE] clear inspector tree")
				        self.inspector.clearTree()
				        #print("[VE] update inspector tree")
				        self.inspector.inspectorModel.inspector_reply_finished(pdata)

				    if gid is not None:
					try:
					    try:
					        gid = int(gid)
					    except:
					        print("error :( gid is missing!") 

					    result = self.inspector.search(gid, 'gid')
					    if result: 
					        print('Found', result['gid'], result['name'])
					        self.inspector.selectItem(result)
					        self.inspector.ui.tabWidget.setCurrentIndex(1)
					    else:
					        print("UI Element not found")

					except:
					    print("error :(")
				elif s is not None:
				    #print(">> %s"%s)
				    pass
				
                 
    def app_finished(self, errorCode):
		if self.trickplay.state() == QProcess.NotRunning :
			print "[VE] Trickplay APP is finished"
			self.inspector.clearTree()
			self.main.stop()
	
    def run(self):
        # Run on local trickplay
        print("[VE] Starting trickplay locally")
        if self.trickplay.state() == QProcess.Running:
            self.trickplay.close()

        env = self.trickplay.processEnvironment().systemEnvironment()

        for item in env.toStringList():
            if item[:3] == "TP_":
                n = re.search("=", item).end()
                env.remove(item[:n-1])

        env.insert("TP_LOG", "raw")
        env.insert("TP_config_file","")

        #  To merge stdout and stderr
        self.trickplay.setProcessChannelMode( QProcess.MergedChannels )

        self.trickplay.setProcessEnvironment(env)
        ret = self.trickplay.start('trickplay', [self.path()])
