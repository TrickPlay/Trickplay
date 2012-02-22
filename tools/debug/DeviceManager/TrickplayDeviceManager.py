import telnetlib, base64, sys, random

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager
from Editor.Editor import Editor
from connection import *

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
ADDEVENT = QEvent.User + 1
REMEVENT = QEvent.User + 2
SIZEOF_UINT16 = 2
DEBUG_PORT = Qt.UserRole + 4
HTTP_PORT = Qt.UserRole + 5
CONSOLE_PORT = Qt.UserRole + 6

#self.debug_stop.setEnabled(False)

class TrickplayDeviceManager(QWidget):
    
    def __init__(self, main=None, parent = None):
        
        QWidget.__init__(self, parent)
                
        self.main = main
        self.inspector = main._inspector
        self.editorManager = main._editorManager
        self.debugWindow = main._debug
        self.backtraceWindow = main._backtrace

        self.ui = Ui_DeviceManager()
        self.ui.setupUi(self)
        
        self.addLocalComboItem()
        
        self.discovery = TrickplayDiscovery(self)
        QObject.connect(self.ui.comboBox, SIGNAL('currentIndexChanged(int)'), self.service_selected)
        QObject.connect(self.ui.run, SIGNAL("clicked()"), self.run)
        
        self._path = ''
        self.trickplay = QProcess()
        QObject.connect(self.trickplay, SIGNAL('started()'), self.app_started)
        QObject.connect(self.trickplay, SIGNAL('finished(int)'), self.app_finished)
        QObject.connect(self.trickplay, SIGNAL('readyRead()'), self.app_ready_read)

        self.icon = QIcon()
        self.icon.addPixmap(QPixmap("Assets/icon-target.png"), QIcon.Normal, QIcon.Off)
        self.icon_null = QIcon()
        self.prev_index = 0
        self.ui.comboBox.setSizeAdjustPolicy(QComboBox.AdjustToContents)
        self.ui.comboBox.setIconSize(QSize(20,32))

        self.debug_mode = False
        self.debug_port = None
        self.console_port = None
        self.http_port = None
        self.my_name = ""
        self.manager = QNetworkAccessManager()
        self.reply = None
        self.command = None


    def service_selected(self, index):
        
	if index < 0:
	    return
        
	self.ui.comboBox.setItemIcon(self.prev_index, self.icon_null)
	self.ui.comboBox.setItemIcon(index, self.icon)
	self.prev_index = index
	address = self.ui.comboBox.itemData(index, ADDRESS).toPyObject()
	port = self.ui.comboBox.itemData(index, PORT).toPyObject()

	self.debug_port = self.ui.comboBox.itemData(index, DEBUG_PORT).toPyObject()
	self.http_port = self.ui.comboBox.itemData(index, HTTP_PORT).toPyObject()
	self.console_port = self.ui.comboBox.itemData(index, CONSOLE_PORT).toPyObject()

	if not address or not port:
	    return
        
	#self.inspector.clearTree()
	#print(index,address,port)

	CON.port = port
	CON.address = address

    def event(self, event):
        QCoreApplication.setOrganizationName('Trickplay');

        while 1:
			if event.type() == ADDEVENT:
				d = event.dict
				if d[0] != self.my_name:
					print "[VDBG] Service ' %s ' added"%d[0]
					# Add item to ComboBox
					self.ui.comboBox.addItem(d[0])
					index = self.ui.comboBox.findText(d[0])
					self.ui.comboBox.setItemData(index, d[1], ADDRESS)
					self.ui.comboBox.setItemData(index, d[2], PORT)
					self.ui.comboBox.setItemData(index, d[1], NAME)
        			# Automatically select a service if only one exists
					if 1 == self.ui.comboBox.count():
						self.service_selected(1) # index -> 1 

					data = getTrickplayControlData("%s:"%str(d[1])+"%s"%str(d[2]))
					if data is not None:
					    if data.has_key("debugger"):
					        self.ui.comboBox.setItemData(index, data["debugger"], DEBUG_PORT)
					        #d_port = data["debugger"]
					        #print("[VDBG] debug Port : %s"%d_port)
					    else:
					        self.ui.comboBox.setItemData(index, None, DEBUG_PORT)
					    if data.has_key("http"):
					        #self.http_port = data["http"]
					        #print("[VDBG] http Port : %s"%self.http_port)
					        self.ui.comboBox.setItemData(index, data["http"], HTTP_PORT)
					    else:
					        self.ui.comboBox.setItemData(index, None, HTTP_PORT)
					    if data.has_key("console"):
					        #self.console_port = data["console"]
					        #print("[VDBG] console Port : %s"%self.console_port)
					        self.ui.comboBox.setItemData(index, data["console"], CONSOLE_PORT)
					    else:
					        self.ui.comboBox.setItemData(index, 7777, CONSOLE_PORT)
					else:
					    print("[VDBG] Didn't get Control information ")

					"""
					elif hasattr(self, 'newApp') :
						if self.newApp == True :
							self.ui.comboBox.setCurrentIndex(self.ui.comboBox.count() - 1)
							self.service_selected(self.ui.comboBox.count())
							self.newAppText = self.ui.comboBox.itemText(self.ui.comboBox.count() - 1)
							self.inspector.refresh()
							self.inspector.ui.inspector.expandAll()
							self.newApp = False
				else: 
					address = d[1]
					port = d[2]
					self.ui.comboBox.setItemData(0, address, ADDRESS)
					self.ui.comboBox.setItemData(0, port, PORT)
					CON.port = port
					CON.address = address
					#if getattr(self, "debug_mode") != True :
						##self.inspector.refresh()
						#self.inspector.ui.inspector.expandAll()
					"""

			elif event.type() == REMEVENT:
				d = event.dict
				print "[VDBG] Service ' %s ' removed"%d[0]
				# Remove item from ComboBox
				index = self.ui.comboBox.findText(d[0])
				self.ui.comboBox.removeItem(index)
				#self.inspector.clearTree()

			return True

    def stop(self):
		self.discovery.stop()

    def addLocalComboItem(self):
        """
        Add combo box from running app locally. This always exists.
        """
        name = 'Emulator'  #'Trickplay Device   '
        port = '6789'
        address = 'localhost'
        icon = QIcon()
        icon.addPixmap(QPixmap("Assets/icon-target.png"), QIcon.Normal, QIcon.Off)

        self.ui.comboBox.addItem(name)
        index = self.ui.comboBox.findText(name)
        self.ui.comboBox.setItemIcon(index, icon)
        self.ui.comboBox.setItemData(index, address, ADDRESS)
        self.ui.comboBox.setItemData(index, port, PORT)
        self.ui.comboBox.setItemData(index, address, NAME)
        
        CON.port = port
        CON.address = address
    
    def push(self):   
        print('[VDBG] Pushing app to %s'%CON.get())
        tp = TrickplayPushApp(str(self.path()))
        tp.push(address = CON.get())
        self.app_started()
        
    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def app_started(self):
		print "[VDBG] APP Started"
		self.newApp = True

		# Console Port 
		self.socket = QTcpSocket()
		self.nextBlockSize = 0
		self.bytesAvail = 0

		self.connect(self.socket, SIGNAL("connected()"), self.sendRequest)
		self.connect(self.socket, SIGNAL("readyRead()"), self.readResponse)
		self.connect(self.socket, SIGNAL("disconnected()"), self.serverHasStopped)

		if self.socket.isOpen():
			self.socket.close()

		if self.ui.comboBox.currentIndex() != 0:
		    print("[VDBG] Connecting to console port")
		    while 1:
			    try : 
				    self.socket.connectToHost(CON.address, self.console_port, mode=QIODevice.ReadWrite)
				    if self.socket.waitForConnected(100): 
					    self.newApp = True
					    break
			    except : 
				    #print("console_port : [%s]"%str(self.console_port))
				    pass

    def sendRequest(self):
        print "Connected"

    def readDebugResponse(self):
		while self.debug_socket.waitForReadyRead(1100) :
			#print self.debug_socket.read(self.debug_socket.bytesAvailable())+"&&&&&&&&&&&&&&&&&&"
			print self.debug_socket.read(self.debug_socket.bytesAvailable())

    def readResponse(self):
		while self.socket.waitForReadyRead(1100) :
			print self.socket.read(self.socket.bytesAvailable())[:-1]
			#print self.socket.read(self.socket.bytesAvailable())[:-1].replace('\033[34;1m','').replace('\033[31;1m','').replace('\033[0m','').replace('\033[37m','').replace('\033[32m','')
		#self.socket.flush()

		"""
		stream = QDataStream(self.socket)
		stream.setVersion(QDataStream.Qt_4_2)
		self.bytesAvail = self.bytesAvail + self.socket.bytesAvailable() 
		print self.bytesAvail 
		print self.nextBlockSize 

		while True:
			if self.nextBlockSize == 0:
				if self.socket.bytesAvailable() < SIZEOF_UINT16:
					break
				self.nextBlockSize = stream.readUInt16()
				print str(self.nextBlockSize)+"**"
			#if self.socket.bytesAvailable() < self.nextBlockSize:
			if self.bytesAvail < self.nextBlockSize:
				break

			print "herehehrehr"py
			msg = QString()
			stream >> msg
			print str(msg)

			self.nextBlockSize = 0
		"""

    def debugServerHasStopped(self):
    	print ("[VDBG] Connection closed by server")
    	self.debug_socket.close()

    def serverHasStopped(self):
    	print ("Connection closed by server")
    	self.socket.close()

    def serverHasError(self, error):
        print(QString("Error: %1").arg(self.socket.errorString()))
        self.socket.close()

    def app_ready_read(self):

		# Read all available output from the process
		
		while True:
			# Read one line
			s = self.trickplay.readLine()
			# If the line is null, it means there is nothing more
			# to read during this iteration
			if s.isNull():
				break
			# Convert it to a string and strip the trailing white space
			s = str( s ).rstrip()
			# Look for the CONTROL line
			if s.startswith( "<<CONTROL>>:" ):
				try:
					# Parse the contents of the control line and get the
					# debugger port.
					control = json.loads( s[12:] )
					# Store it. This could fail if the engine has no debugger
					# port.
					#print("[VDBG] Debug Port : %s"%self.debug_port)

					if control.has_key("debugger"):
					    self.debug_port = control[ "debugger" ]
					if control.has_key("http"):
					    self.http_port = control[ "http" ]
					if control.has_key("console"):
					    self.console_port = control[ "console" ]

					self.ui.comboBox.setItemData(0, self.http_port, PORT)
					# Send our first debugger command, which will return
					# when the app breaks
					if self.debug_mode == True:
					    self.send_debugger_command(DBG_CMD_INFO)
				except:
					print( "FAILED TO OBTAIN DEBUGGER PORT" )
					# Kill the process
					self.trickplay.close()
			else:
				# Output the log line
				print( ">> %s" % s )
				
    def debugger_reply_finished(self):

        if self.reply.error()== QNetworkReply.NoError:

		    data = self.getFileLineInfo_Resp(str(self.reply.readAll()))

		    if data is not None:

		        print("[VDBG] %s Response"%self.command)
		        #print("[VDBG] %s DATA"%data)

		        if self.command == DBG_CMD_INFO:
		            # Open File, Show Current Lines 
		            if self.file_name.startswith("/"):
		                self.file_name= self.file_name[1:]

		            self.current_debug_file = os.path.join(self.main.path, self.file_name)
		            self.editorManager.newEditor(self.current_debug_file, None, self.line_no, None, True)

		            # Local Variable Table
		            local_info = self.getLocalInfo_Resp(data)
		            if local_info is not None:
		                self.debugWindow.populateLocalTable(local_info)

		            # Stack Trace Table
		            stack_info = self.getStackInfo_Resp(data)
		            if stack_info is not None:
		                self.backtraceWindow.populateTraceTable(stack_info, self.editorManager)
                        
		            self.reply = None
		            self.command = None

		        elif len(self.command) > 3 and self.command[:1] == DBG_CMD_BREAKPOINT or self.command[:1] == DBG_CMD_DELETE:

		            self.bs_command = False
		            #if self.command[-2:] == "ff" or self.command[-2:] == "on" :
		                #self.bs_command = True
		            self.reply = None
		            self.command = None
		            self.send_debugger_command(DBG_CMD_BREAKPOINT)

		        elif self.command == DBG_CMD_BREAKPOINT:

		            # Break Point 
		            break_info = self.getBreakPointInfo_Resp(data)

		            if break_info is not None:
		                self.debugWindow.populateBreakTable(break_info, self.editorManager)

		            if self.bs_command == True :
		                self.reply = None
		                self.command = None
		                return

		            editor = self.editorManager.app.focusWidget()
		            nline = editor.margin_nline

		            """
		            m=0
		            for item in break_info[3]: #info_var_list 
		                if item == editor.path+":"+str(nline+1) :
		                    return m
		                m += 1

		            editor.bp_num[nline] = m-1
		            print(editor.path+":"+str(nline)+":"+str(m-1))
		            """

		            # Break Point Setting 
		            if not editor.line_click.has_key(nline) or editor.line_click[nline] == 0 :
		                if editor.current_line != nline :
		                    editor.markerAdd(nline, editor.ACTIVE_BREAK_MARKER_NUM)
		                else:
		                    editor.markerDelete(nline, editor.ARROW_MARKER_NUM)
		                    editor.markerAdd(nline, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)

		                editor.line_click[nline] = 1

		            # Break Point Deactivate  
		            elif editor.line_click[nline] == 1:
		                if editor.current_line != nline :
		                    editor.markerDelete(nline, editor.ACTIVE_BREAK_MARKER_NUM)
		                    editor.markerAdd(nline, editor.DEACTIVE_BREAK_MARKER_NUM)
		                else :
		                    editor.markerDelete(nline, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
		                    editor.markerAdd(nline, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)

		                editor.line_click[nline] = 2

                    # Break Point Active 
		            elif editor.line_click[nline] == 2:
				"""
                                # Delete Break Point 
                                if editor.current_line != nline :
				    editor.markerDelete(nline, editor.DEACTIVE_BREAK_MARKER_NUM)
                                else :
				    editor.markerDelete(nline, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
				    editor.markerAdd(nline, editor.ARROW_MARKER_NUM)
				"""
		                if editor.current_line != nline :
		                    editor.markerDelete(nline, editor.DEACTIVE_BREAK_MARKER_NUM)
		                    editor.markerAdd(nline, editor.ACTIVE_BREAK_MARKER_NUM)
		                else :
		                    editor.markerDelete(nline, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
		                    editor.markerAdd(nline, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
		                editor.line_click[nline] = 1

		            self.reply = None
		            self.command = None

		        elif self.command not in DBG_ADVANCE_COMMANDS:
		            self.reply = None
		            self.command = None

        if self.command in DBG_ADVANCE_COMMANDS:
			if self.command == DBG_CMD_CONTINUE :
				# delete current line marker 
				for m in self.editorManager.editors:
					if self.current_debug_file == m:
						# check what kind of arrow marker was on the current line and delete just arrow mark not break points 
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].markerDelete(
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].current_line, Editor.ARROW_MARKER_NUM)
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].current_line = -1

				# clean backtrace and debug windows
				self.backtraceWindow.clearTraceTable(0)
				self.debugWindow.clearLocalTable(0)

			# TODO: Leave the debug UI disabled, and wait for the info command to return

			self.reply = None
			self.command = None
			self.send_debugger_command( DBG_CMD_INFO )
			#self.reply = None
			#self.command = None
        else:

			# TODO: Here we should enable the debug UI
			pass
				
        #self.send_debugger_command( DBG_CMD_STEP_OVER )
		
    def send_debugger_command(self, command):
		# We don't have a debugger port yet
		print("send_debugger_command : [%s]"%command)
		if self.debug_port is None:
			raise "NO DEBUGGER PORT"
		
		# We are processing a request
		if self.reply is not None:
			print("reply is not None")
			return False
		
		url = QUrl()
		url.setScheme( "http" )
		url.setHost( CON.address )
		url.setPort( self.debug_port )
		url.setPath( "/debugger" )
		
		print ("[VDBG] ' %s ' Command Sent"%command)
		
		request = QNetworkRequest( url )
		self.reply = self.manager.post( request , command )
		QObject.connect( self.reply , SIGNAL( 'finished()' ) , self.debugger_reply_finished )
		self.command = command
		
		# print( "WAITING FOR TRICKPLAY TO BREAK" )
		
		if command in DBG_ADVANCE_COMMANDS:
			# TODO: Here we should disable the debug UI
			pass
		
		return True

    def app_finished(self, errorCode):
		if self.trickplay.state() == QProcess.NotRunning :
			print "[VDBG] Trickplay APP is finished"
			self.inspector.clearTree()
			self.main.stop()
			if self.reply is not None:
			    self.reply.abort()
			    self.reply = None 
			    self.command = None 

	
    def run(self, dMode=False):
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("[VDBG] Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()

            env = self.trickplay.processEnvironment().systemEnvironment()

            for item in env.toStringList():
   				if item[:3] == "TP_":
   					n = re.search("=", item).end()
   					env.remove(item[:n-1])

            env.insert("TP_LOG", "bare")
            env.insert("TP_config_file","")

            #env.insert("TP_telnet_console_port", str(self.console_port))
            #env.insert("TP_controllers_enabled", "1")
            #self.my_name = str(u"\u0020")+str(int(random.random() * 100000))
            #env.insert("TP_controllers_name",self.my_name)

            if dMode == True :
            	self.debug_mode = True
            	self.main.debug_mode = True
            	#env.insert("TP_debugger_port",str(self.debug_port))
            	env.insert("TP_start_debugger","true")
            else :
            	self.debug_mode = False
            	self.main.debug_mode = False

			
            #  To merge stdout and stderr
            self.trickplay.setProcessChannelMode( QProcess.MergedChannels )

            self.trickplay.setProcessEnvironment(env)
            ret = self.trickplay.start('trickplay', [self.path()])

			
        # Push to foreign device
        else:

            if dMode == True:
                # POST http://<host>:<debugger port>/debugger "r"
                url = QUrl()
                url.setScheme( "http" )
                url.setHost( CON.address )
                url.setPort( self.debug_port )
                url.setPath( "/debugger" )
		
                #print ("[VDBG] ' %s ' Command Sent"%'r')
                #request = QNetworkRequest( url )
                #self.manager.post( request , 'r' )
            
                # GET http://<host>:<http port>/debug/start 
                getTrickplayDebug()
            	self.debug_mode = True
            	self.main.debug_mode = True
            
            self.push()

            if dMode == True:
			    self.send_debugger_command(DBG_CMD_INFO)
            
	
    def getFileLineInfo_Resp(self, data):

		pdata = json.loads(data)

		if "error" in pdata:
			print "[VDBG] "+pdata["error"]
			return None
		else:
			file_name = pdata["file"] 
			tp_id = pdata["id"] 
			line_num = pdata["line"]
	
			self.line_no = str(line_num)
			self.file_name = str(file_name)
			return pdata

		
    def getLocalInfo_Resp(self, data):
		if "locals" in data:
			name_var_list = []
			type_var_list = []
			value_var_list = []
			local_vars_str = ""
			local_vars = {}
			for c in data["locals"]:
				if c["name"] != "(*temporary)":
					c_v = None
					if local_vars_str != "":
						local_vars_str = local_vars_str+"\n\t"

					local_vars_str = local_vars_str+str(c["name"])+"("+str(c["type"])+")"
					name_var_list.append(str(c["name"]))
					type_var_list.append(str(c["type"]))
					try:
						c_v = c["value"]	
					except KeyError: 
						pass

					if c_v:
						local_vars_str = local_vars_str+" = "+str(c["value"])
						value_var_list.append(str(c["value"]))
					else:
						value_var_list.append("")

			local_vars[1] = name_var_list
			local_vars[2] = type_var_list
			local_vars[3] = value_var_list

			return local_vars
		else:
			return None

		
    def getStackInfo_Resp(self, data):
		if "stack" in data:
			stack_info_str = ""
			stack_list = []
			info_list = []
			stack_info = {}
			index = 0
			for s in data["stack"]:
				if "file" in s and "line" in s:
					stack_info_str = stack_info_str+"["+str(index)+"] "+s["file"]+":"+str(s["line"])+"\n\t"
					stack_list.append("["+str(index)+"] "+s["file"]+":"+str(s["line"]))
					#info_list.append(str(self.path())+'/'+s["file"]+":"+str(s["line"]))
					
					eChar = ""
					if s["file"][:1] != "/" :
						eChar = "/"

					info_list.append(str(self.path())+eChar+s["file"]+":"+str(s["line"]))
					index = index + 1

			stack_info[1] = stack_list
			stack_info[2] = info_list

			#print "\t"+stack_info_str
			return stack_info
		else:
			return None

    def getBreakPointInfo_Resp(self, data):
		if "breakpoints" in data:
			state_var_list = []
			info_var_list = []
			file_var_list = []
			#linenum_var_list = []
			breakpoints_info = {}
			breakpoints_info_str = ""
			index = 0
			if len(data["breakpoints"]) == 0:
				print "[VDBG] No breakpoints set"
				return breakpoints_info
			else:
				for b in data["breakpoints"]:
					if "file" in b and "line" in b:
						breakpoints_info_str = breakpoints_info_str+"["+str(index)+"] "+b["file"]+":"+str(b["line"])
						"""if path is not None :
							info_var_list.append(path+":"+str(b["line"]))
						else:
                        """
						info_var_list.append(b["file"]+":"+str(b["line"]))

						#n = re.search("[/]+\S+[/]+", b["file"]).end()
					
						file_var_list.append(b["file"]+":"+str(b["line"]))
					if "on" in b:
						if b["on"] == True:
							breakpoints_info_str = breakpoints_info_str+""+"\n       "
							state_var_list.append("on")
						else:
							breakpoints_info_str = breakpoints_info_str+" (disabled)"+"\n       "
							state_var_list.append("off")
					index = index + 1

			
				breakpoints_info[1] = state_var_list
				breakpoints_info[2] = file_var_list
				breakpoints_info[3] = info_var_list
				#breakpoints_info[4] = linenum_var_list

				print "[VDBG] "+breakpoints_info_str
				return breakpoints_info
		else:
			return None


    def printResp(self, data, command):

		if "source" in data:
			source_info = ""
			for l in data["source"]:
				if "line" in l and "text" in l:
					if l["line"] == line_num:
						source_info = source_info+str(l["line"])+" >>"+str(l["text"])+"\n\t"
					else:
						source_info = source_info+str(l["line"])+"   "+str(l["text"])+"\n\t"
			print "\t"+source_info
		
		elif "lines" in data:
			fetched_lines = ""
			
			for l in data["lines"]:
				fetched_lines = fetched_lines+l+"\n\t"
			print "\t"+fetched_lines

		elif "app" in data:
			app_info = ""
			for key in data["app"].keys():
				if key != "contents":
					app_info = app_info+str(key)+" : "+str(data["app"][key])+"\n\t"
				else:
					app_info = app_info+key+" : "
					for c in data["app"]["contents"]:
						app_info = app_info + str(c) + ","
					app_info = app_info+"\n\t"					
			print "\t"+app_info

		if command in ['n','s','bn', 'cn']:
			#print "\t"+"Break at "+file_name+":"+str(line_num)
			pass

		return True
