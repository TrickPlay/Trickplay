import telnetlib, base64, sys, random

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager
from Editor.Editor import Editor
from connection import *
from Console.TrickplayConsole import *

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
        self.backtraceWindow = main.backtrace

        self.ui = Ui_DeviceManager()
        self.ui.setupUi(self)
        
        self.addLocalComboItem()
        
        self.discovery = TrickplayDiscovery(self)
        QObject.connect(self.ui.comboBox, SIGNAL('currentIndexChanged(int)'), self.service_selected)
        QObject.connect(self.ui.run, SIGNAL("clicked()"), self.run)
        
        self._path = ''
        self.trickplay = QProcess()
        QObject.connect(self.trickplay, SIGNAL('started()'), self.app_started)
        #QObject.connect(self.trickplay, SIGNAL('finished(int, QProcess.ExitStatus)'), self.app_finished)
        QObject.connect(self.trickplay, SIGNAL('finished(int)'), self.app_finished)
        QObject.connect(self.trickplay, SIGNAL('readyRead()'), self.app_ready_read)

        self.icon = QIcon()
        self.icon.addPixmap(QPixmap(self.main.apath+"/Assets/icon-target.png"), QIcon.Normal, QIcon.Off)
        self.icon_null = QIcon()
        self.prev_index = 0
        self.ui.comboBox.setSizeAdjustPolicy(QComboBox.AdjustToContents)
        self.ui.comboBox.setIconSize(QSize(20,32))

        self.debug_mode = False
        self.debug_run = False
        self.debug_port = None
        self.console_port = None
        self.http_port = None
        self.my_name = ""
        self.manager = QNetworkAccessManager()
        #self.reply = None
        #self.bs_command = False
        self.current_debug_file = None
        self.inbreak = True


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
					        print("[VDBG] debug Port : %s"%data["debugger"], d[0])
					    else :
					        print("[VDBG] Didn't get %s's debug_port information "%d[0])
					    if data.has_key("http"):
					        #self.http_port = data["http"]
					        #print("[VDBG] http Port : %s"%self.http_port)
					        self.ui.comboBox.setItemData(index, data["http"], HTTP_PORT)
					    else :
					        print("[VDBG] Didn't get %s's http_port information "%d[0])
					    if data.has_key("console"):
					        self.console_port = data["console"]
					        #print("[VDBG] console Port : %s"%self.console_port)
					        self.ui.comboBox.setItemData(index, data["console"], CONSOLE_PORT)
					        CON.port = self.http_port
					    else :
					        print("[VDBG] Didn't get %s's console_port information "%d[0])
					else:
					    print("[VDBG] Didn't get %s's Control information "%d[0])

			elif event.type() == REMEVENT:
				d = event.dict
				print "[VDBG] Service ' %s ' removed"%d[0]
				# Remove item from ComboBox
				index = self.ui.comboBox.findText(d[0])
				if index == self.ui.comboBox.currentIndex():
				    self.ui.comboBox.removeItem(index)
				    self.ui.comboBox.setCurrentIndex(0)
				    self.service_selected(0)
				else :
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
        icon.addPixmap(QPixmap(self.main.apath+"/Assets/icon-target.png"), QIcon.Normal, QIcon.Off)

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
        tp = TrickplayPushApp(self, str(self.path()))
        ret = tp.push(address = CON.get())
        if ret is not False:
            self.app_started()
        return ret
        
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
		    print("[VDBG] Connecting to console port ")
		    cnt = 0
		    while cnt < 5:
			    try : 
				    self.socket.connectToHost(CON.address, self.console_port, mode=QIODevice.ReadWrite)
				    if self.socket.waitForConnected(100): 
					    self.newApp = True
					    break
			    except : 
			        cnt = cnt + 1

    def sendRequest(self):
        print "Connected"

    def readDebugResponse(self):
		while self.debug_socket.waitForReadyRead(1100) :
			print self.debug_socket.read(self.debug_socket.bytesAvailable())

    def readResponse(self):
		while self.socket.waitForReadyRead(1100) :
			EGN_MSG(self.socket.read(self.socket.bytesAvailable())[:-1].replace('\033[34;1m','').replace('\033[31;1m','').replace('\033[0m','').replace('\033[37m','').replace('\033[32m',''))

    def debugServerHasStopped(self):
    	self.debug_socket.close()

    def serverHasStopped(self):
        print("Console port disconnected")
    	self.socket.close()

    def serverHasError(self, error):
        print(QString("[VDBG] Error: %1").arg(self.socket.errorString()))
        self.socket.close()

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
			# Look for the CONTROL line
			if s.startswith( "<<CONTROL>>:" ):
				try:
					# Parse the contents of the control line and get the
					# debugger port.
					control = json.loads( s[12:] )
					# Store it. This could fail if the engine has no debugger
					# port.
					if control.has_key("debugger"):
					    self.debug_port = control[ "debugger" ]
					if control.has_key("http"):
					    self.http_port = control[ "http" ]
					if control.has_key("console"):
					    self.console_port = control[ "console" ]

					self.ui.comboBox.setItemData(0, self.http_port, PORT)
					CON.port = self.http_port

					# Send our first debugger command, which will return
					# when the app breaks
					if self.debug_mode == True:
					    self.inbreak = False
					    self.send_debugger_command(DBG_CMD_INFO)
					    if len(self.editorManager.bp_info[1]) > 0 :
					        self.send_debugger_command(DBG_CMD_BB)
					else :
					    self.inspector.ui.refresh.setEnabled(True)
					    self.inspector.ui.search.setEnabled(True)
				except:
					print( "[VDBG] Failed to obtain debugger port" )
					# Close the process
					self.trickplay.close()
			else:
				# Output the log line
				EGN_MSG(">> %s"%s.replace('\033[34;1m','').replace('\033[31;1m','').replace('\033[0m','').replace('\033[37m','').replace('\033[32m',''))
				
    def send_debugger_command(self, command):
	    if self.debug_port is None:
		print "No debugger port"
		return
	    url = QUrl()
	    url.setScheme( "http" )
	    url.setHost( CON.address )
	    url.setPort( self.debug_port )
	    url.setPath( "/debugger" )
	
	    print ("[VDBG] ' %s ' Command Sent"%command)
		
	    data = {}
	    request = QNetworkRequest( url )
	    if command == "bb":
	        data['clear'] =  True
	        data['add'] =  []
	        bpCnt = len(self.editorManager.bp_info[1])
	        for r in range(0, bpCnt):
	            bp_info = self.editorManager.bp_info[2][r]
	            n = re.search(":", bp_info).end()
	            fName = bp_info[:n-1]
	            lNum  = int(bp_info[n:]) -1
	            if self.editorManager.bp_info[1][r] == "on":
	                bState = True
	            else:
	                bState = False
	            #data['add'].append({'file':fName, 'line':lNum, 'on':bState})
	            bp_item = {}
	            bp_item['file'] = fName
	            bp_item['line'] = lNum + 1
	            bp_item['on'] = bState
	            data['add'].append(bp_item)
		    
	        params = json.dumps(data)
	        reply = self.manager.post( request ,command+' '+params)
	        reply.command = command
	    else:
	        reply = self.manager.post( request , command )
	        reply.command = command

	    def debugger_reply_finished(reply):
		    def foo ():
		        if reply.error()== QNetworkReply.NoError:
		            print("[VDBG] ' %s ' Response"%reply.command)

		            if reply.command == "bn":
		                return
    
		            if reply.command == "r":
		                self.main.deviceManager.socket.write('/close\n\n')
		                self.main.rSent = False
		                if self.main.onExit == True:
		                    if self.editorManager.tab != None:
		                        while self.editorManager.tab.count() != 0:
		                            self.editorManager.close()
		                    self.stop()
		                    self.main.close()


		            data = self.getFileLineInfo_Resp(str(reply.readAll()), command)
		            if data is not None:
		                if reply.command == DBG_CMD_INFO:
		                    self.inbreak = True
		                    self.inspector.ui.refresh.setEnabled(False)
		                    self.inspector.ui.search.setEnabled(False)

		                    # Open File, Show Current Lines 
		                    if self.file_name.startswith("/"):
		                        self.file_name= self.file_name[1:]
		                    self.file_name= self.file_name+'/'

		                    if self.file_name.endswith("/"):
		                        self.file_name= self.file_name[:len(self.file_name) - 1]
    
		                    current_file = os.path.join(str(self.main.path), str(self.file_name))
    
		                    if self.current_debug_file != current_file:
		                        self.editorManager.newEditor(current_file, None, self.line_no, self.current_debug_file, True)
		                    else :
		                        self.editorManager.newEditor(current_file, None, self.line_no, None, True)
    
		                    self.current_debug_file = current_file

		                    # Local Variable Table
		                    local_info = self.getLocalInfo_Resp(data)
		                    if local_info is not None:
		                        self.debugWindow.populateLocalTable(local_info)

		                    # Global Variable Table
		                    global_info = self.getGlobalInfo_Resp(data)
		                    if global_info is not None:
		                        self.debugWindow.populateGlobalTable(global_info, self.editorManager)

		                    # Stack Trace Table
		                    stack_info = self.getStackInfo_Resp(data)
		                    if stack_info is not None:
		                        self.backtraceWindow.populateTraceTable(stack_info, self.editorManager)
                        
		                    #reply = None
		                    #reply.command = None
			                # TODO: Here we should enable the debug UI
		                    self.main.debug_stepinto.setEnabled(True)
		                    self.main.debug_stepover.setEnabled(True)
		                    self.main.debug_stepout.setEnabled(False)
		                    self.main.debug_pause_bt.setEnabled(False)
		                    self.main.debug_continue_bt.setEnabled(True)

		                    self.main.ui.actionContinue.setEnabled(True)
		                    self.main.ui.actionPause.setEnabled(False)
		                    self.main.ui.actionStep_into.setEnabled(True)
		                    self.main.ui.actionStep_over.setEnabled(True)
		                    self.main.ui.actionStep_out.setEnabled(False)

		                    self.main.debug_run = False

		                elif reply.command[:1] == DBG_CMD_BREAKPOINT or reply.command == DBG_CMD_BB or reply.command[:1] == DBG_CMD_DELETE:
        
		                    # Break Point 
		                    break_info = self.getBreakPointInfo_Resp(data)
        
		                    if break_info is not None:
		                        self.debugWindow.populateBreakTable(break_info, self.editorManager)

		                    if reply.command == DBG_CMD_BB :
		                        return

		                    editor = self.editorManager.app.focusWidget()
		                    if editor is not None : 
		                        nline = editor.margin_nline
		                    else:
		                        index = self.editorManager.tab.currentIndex()
		                        editor = self.editorManager.tab.editors[index]
		                        nline = editor.margin_nline
    
		                    if reply.command[:1] == DBG_CMD_DELETE and nline is not None:
		                        if editor.current_line != nline :
		                            editor.markerDelete(nline, -1)
		                        else :
		                            editor.markerDelete(nline, -1)
		                            editor.markerAdd(nline, editor.ARROW_MARKER_NUM)
		                        editor.line_click[nline] = 0
		                        return
		                    elif nline is None:
		                        return
    
		                    # Break Point Setting t
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
		                        if editor.current_line != nline :
		                            editor.markerDelete(nline, editor.DEACTIVE_BREAK_MARKER_NUM)
		                            editor.markerAdd(nline, editor.ACTIVE_BREAK_MARKER_NUM)
		                        else :
		                            editor.markerDelete(nline, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
		                            editor.markerAdd(nline, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
    
		                        editor.line_click[nline] = 1
        
		                        #reply = None
		                        #self.command = None
		            if reply.command in DBG_ADVANCE_COMMANDS:
		                if reply.command == DBG_CMD_CONTINUE :
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
		                    self.debugWindow.clearGlobalTable(0)
    
		                # Leave the debug UI disabled, and wait for the info command to return
		                self.send_debugger_command( DBG_CMD_INFO )
       				
		    return foo
		
	    f=debugger_reply_finished(reply)

	    QObject.connect( reply , SIGNAL( 'finished()' ) , f)
	    reply.command = command[:]
		
	    if command in DBG_ADVANCE_COMMANDS:
	    	# TODO: Here we should disable the debug UI
	        self.main.debug_stepinto.setEnabled(False)
	        self.main.debug_stepover.setEnabled(False)
	        self.main.debug_stepout.setEnabled(False)
	        self.main.debug_pause_bt.setEnabled(True)
	        self.main.debug_continue_bt.setEnabled(False)
    
	        self.main.ui.actionContinue.setEnabled(False)
	        self.main.ui.actionPause.setEnabled(True)
	        self.main.ui.actionStep_into.setEnabled(False)
	        self.main.ui.actionStep_over.setEnabled(False)
	        self.main.ui.actionStep_out.setEnabled(False)
	        self.main.debug_run = True
	        return True

    def app_finished(self, errorCode):
        if errorCode == 0 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", FailedToStart] the process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program" )
        elif errorCode == 1 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", Crashed] The process crashed some time after starting successfully.")
        elif errorCode == 2 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", Timedout] The process crashed some time after starting successfully.")
        elif errorCode == 3 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", ReadError] An error occurred when attempting to read from the process.  For example, the process may not be running.")
        elif errorCode == 4 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", WriteError] An error occurred when attempting to write to the process.  For example, the process may not be running, or it may have closed its input channel.")
        elif errorCode == 5 :
            print ("[VDBG] Error Code : ["+str(errorCode)+", UnknownError] An unknown error occurred.")

	if self.trickplay.state() == QProcess.NotRunning :
	    print "[VDBG] Trickplay APP is finished"
	    if self.trickplay.exitStatus() == QProcess.NormalExit :
		print ("[VDBG] ExitStatus :  The process exited normally.")
	    elif self.trickplay.exitStatus() == QProcess.CrashExit :
		print ("[VDBG] ExitStatus :  The process crashed.")
		if self.main.closedByIDE == False :
		    msg = QMessageBox()
		    msg.setText("The process crashed.")
		    msg.setInformativeText('ErrorCode : [ '+str(errorCode)+' ]')
		    msg.setWindowTitle("Warning")
		    msg.setGeometry(500,500,0,0)
		    msg.exec_()

	    self.inspector.clearTree()
	    self.inspector.ui.refresh.setEnabled(False)
	    self.inspector.ui.search.setEnabled(False)
	    self.main.stop()

	
    def run(self, dMode=False):
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("[VDBG] Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()

            env = self.trickplay.processEnvironment().systemEnvironment()

            if self.main.config is None :
                print("[VDBG] .trickplay config file is ignored.")
                for item in env.toStringList():
   				    if item[:3] == "TP_":
   					    n = re.search("=", item).end()
   					    env.remove(item[:n-1])
                env.insert("TP_config_file","")
            else:
                print("[VDBG] .trickplay config file is read.")
                

            env.insert("TP_LOG", "bare")

            if dMode == True :
            	self.debug_mode = True
            	self.main.debug_mode = True
            	env.insert("TP_start_debugger","true")
            else :
            	self.debug_mode = False
            	self.main.debug_mode = False
			
            #  To merge stdout and stderr
            self.trickplay.setProcessChannelMode( QProcess.MergedChannels )

            self.trickplay.setProcessEnvironment(env)
            ret = self.trickplay.start('trickplay', [self.path()])

        # Push to remote device
        else:
            if dMode == True:
                if self.debug_port is None:
                    print("[VDBG] Debug port is missing")
                    return False
                # POST http://<host>:<debugger port>/debugger "r"
                #url = QUrl()
                #url.setScheme( "http" )
                #url.setHost( CON.address )
                #url.setPort( self.debug_port )
                #url.setPath( "/debugger" )
		
                #print ("[VDBG] ' %s ' Command Sent"%'r')
                #request = QNetworkRequest( url )
                #self.manager.post( request , 'r' )
            
            	self.debug_mode = True
            	self.main.debug_mode = True
            
            ret = self.push()
            if ret == False:
                return ret
            elif dMode == True:
			    self.inbreak = False
			    self.send_debugger_command(DBG_CMD_INFO)
			    if len(self.editorManager.bp_info[1]) > 0 :
			        self.send_debugger_command(DBG_CMD_BB)
            else :
                self.inspector.ui.refresh.setEnabled(True)
                self.inspector.ui.search.setEnabled(True)
            
	
    def getFileLineInfo_Resp(self, data, command):

		pdata = json.loads(data)
		if command == "i":
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
		else:
		    return pdata



    def getGlobalInfo_Resp(self, data):
		if "globals" in data:
			name_var_list = []
			type_var_list = []
			value_var_list = []
			defined_var_list = []
			global_vars_str = ""
			global_vars = {}
			for c in data["globals"]:
				if c["name"] != "(*temporary)":
					c_v = None
					if global_vars_str != "":
						global_vars_str = global_vars_str+"\n\t"

					global_vars_str = global_vars_str+str(c["name"])+"("+str(c["type"])+")"
					name_var_list.append(str(c["name"]))
					type_var_list.append(str(c["type"]))
					defined_var_list.append(str(c["defined"]))
					try:
						c_v = c["value"]	
					except KeyError: 
						pass

					if c_v:
						global_vars_str = global_vars_str+" = "+str(c["value"])
						value_var_list.append(str(c["value"]))
					else:
						value_var_list.append("")

			global_vars[1] = name_var_list
			global_vars[2] = type_var_list
			global_vars[3] = value_var_list
			global_vars[4] = defined_var_list

			return global_vars
		else:
			return None

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
			file_var_list = []
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
