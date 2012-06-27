import os, telnetlib, base64, sys, random, json, time

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply

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
        self.pdata = None
        
        self.run()

    def chgStyleName(self, gid, new_name, old_name):
        self.setUIInfo(gid, "style", "Style('"+new_name+"'):set('"+old_name+"')")

    def setStyleInfo(self, style_name, property1, property2, property3=None, value=None):
        if property1 == 'name':
            inputCmd = str("Style('"+str(style_name)+"')."+str(property1)+" = '"+str(property2)+"'")
        elif property3 == "style":
            inputCmd = str("Style('"+str(style_name)+"')."+str(property2)+"."+str(property1)+" = "+str(value))
        else:
            inputCmd = str("Style('"+str(style_name)+"')."+str(property3)+"."+str(property2)+"."+str(property1)+" = "+str(value))
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()
        
    def setUIInfo(self, gid, property, value):
        inputCmd = str("_VE_.setUIInfo("+str(gid)+",'"+str(property)+"',"+str(value)+")")
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def repStInfo(self):
        inputCmd = str("_VE_.repStInfo()")
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def getStInfo(self):
        inputCmd = str("_VE_.getStInfo()")
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def getUIInfo(self):
        inputCmd = str("_VE_.getUIInfo()")
        print inputCmd
        self.trickplay.write(inputCmd+"\n")
        self.trickplay.waitForBytesWritten()

    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def app_started(self):
		print "[VE] APP Started"

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
					#self.main.open() # load setting path !! 
					print "Currnet Project:%s"%self.main.currentProject
                    
					if self.main and self.main.currentProject is None: 
					     return
					elif self.main and self.main.currentProject : 
					     if self.main.command == "newProject":
					        self.main.newLayer()
					        self.main.inspector.screens["Default"].append("Layer0")
					        self.main.save() 
					     else:
					        print "Loading .... %s"%self.main.currentProject
					        self.main.open() 

					self.inspector.refresh() 
				except:
					print( "[VE] Failed to obtain ui info" )
					# Close the process
					self.trickplay.close()
			else:
				# Output the log line
				#pdata = None
				sdata = None
				gid = None
				if s is not None and len(s) > 9 :
				    luaCmd= s[:9] 
				    if luaCmd == "getUIInfo":
				        self.pdata = json.loads(s[9:])
				    elif luaCmd == "repUIInfo":
				        self.pdata = json.loads(s[9:])
				    elif luaCmd == "repStInfo" :
				        sdata = json.loads(s[9:])
				    elif luaCmd == "getStInfo" :
				        sdata = json.loads(s[9:])
				    elif luaCmd == "openInspc":
				        gid = int(s[9:])
				    elif luaCmd == "scrJSInfo":
				        scrData = json.loads(s[9:])
				        self.inspector.screens = {} 
				        screenNames = []
				        for i in scrData[0]:
				            if i != "currentScreenName":
				                self.inspector.screens[str(i)]=[]
				                screenNames.append(str(i))
				                for j in scrData[0][i]:
				                    self.inspector.screens[str(i)].append(str(j))
				            else:
				                self.inspector.currentScreenName = scrData[0][i] 
				                self.inspector.old_screen_name = ""

				        while self.inspector.ui.screenCombo.count() > 0 :
				            curIdx = self.inspector.ui.screenCombo.currentIndex()
				            self.inspector.ui.screenCombo.removeItem(curIdx)

				        self.inspector.addItemToScreens = True
				        for scrName in screenNames:
				            if self.inspector.ui.screenCombo.findText(scrName) < 0 and scrName != "_AllScreens":
				                self.inspector.ui.screenCombo.addItem(scrName)
				        self.inspector.addItemToScreens = False

				    else:
				        pass

				    if gid is not None and luaCmd == "openInspc":
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

				    if luaCmd == "repStInfo":
				        if self.main.command == "openFile" :
				            return 
				        self.inspector.inspectorModel.styleData = sdata
				        self.inspector.preventChanges = True
				        self.inspector.propertyFill(self.inspector.curData, self.inspector.cbStyle.currentIndex())
				        self.inspector.preventChanges = False
				        return

				    elif luaCmd == "repUIInfo":
				        if self.main.command == "openFile" :
				            return 
				        self.pdata = self.pdata[0]
				        self.inspector.curData = self.pdata
				        self.inspector.preventChanges = True
				        self.inspector.propertyFill(self.inspector.curData)
				        self.inspector.preventChanges = False
				        return

				    if sdata is not None and self.pdata is not None:
				        self.inspector.clearTree()
				        self.inspector.inspectorModel.inspector_reply_finished(self.pdata, sdata)
				        self.inspector.screenChanged(self.inspector.ui.screenCombo.findText(self.inspector.currentScreenName))

				        if self.main.command == "openFile":
				            self.main.command = ""

                        
				elif s is not None:
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
