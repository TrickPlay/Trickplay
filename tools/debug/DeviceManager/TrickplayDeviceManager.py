
import telnetlib, base64, sys, random

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtNetwork import (QTcpSocket,)

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager
from connection import *

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
ADDEVENT = QEvent.User + 1
REMEVENT = QEvent.User + 2
SIZEOF_UINT16 = 2


#self.debug_stop.setEnabled(False)

class TrickplayDeviceManager(QWidget):
    
    def __init__(self, inspector, main=None, parent = None):
        
        QWidget.__init__(self, parent)
                
        self.main = main
        self.ui = Ui_DeviceManager()
        self.ui.setupUi(self)
        
        self.addLocalComboItem()
        
        self.discovery = TrickplayDiscovery(self)
        self.inspector = inspector
        QObject.connect(self.ui.comboBox, SIGNAL('currentIndexChanged(int)'), self.service_selected)
        QObject.connect(self.ui.run,
                        SIGNAL("clicked()"),
                        self.run)
        
        self._path = ''
        self.trickplay = QProcess()
        QObject.connect(self.trickplay, SIGNAL('finished(int)'), self.app_finished)
        QObject.connect(self.trickplay, SIGNAL('started()'), self.app_started)

        self.debug_port = 9876
        self.console_port = 7777
        self.my_name = ""

        self.icon = QIcon()
        self.icon.addPixmap(QPixmap("Assets/icon-target.png"), QIcon.Normal, QIcon.Off)
        self.icon_null = QIcon()
        self.prev_index = 0
        self.ui.comboBox.setSizeAdjustPolicy(QComboBox.AdjustToContents)
        self.ui.comboBox.setIconSize(QSize(20,32))
        self.debug_mode = False

    def service_selected(self, index):
        
		if index < 0:
			return
        
		self.ui.comboBox.setItemIcon(self.prev_index, self.icon_null)
		self.ui.comboBox.setItemIcon(index, self.icon)
		self.prev_index = index

		address = self.ui.comboBox.itemData(index, ADDRESS).toPyObject()
		port = self.ui.comboBox.itemData(index, PORT).toPyObject()

		if not address or not port:
			return
        
		#self.inspector.clearTree()
        
		#print(index,address,port)

		CON.port = port
		CON.address = address

    def event(self, event):
		while 1:
			if event.type() == ADDEVENT:
				d = event.dict
				if d[0] != self.my_name:
					print "Service \'", d[0], "\' added"
					# Add item to ComboBox
					self.ui.comboBox.addItem(d[0])
					index = self.ui.comboBox.findText(d[0])
					self.ui.comboBox.setItemData(index, d[1], ADDRESS)
					self.ui.comboBox.setItemData(index, d[2], PORT)
					self.ui.comboBox.setItemData(index, d[1], NAME)
        			# Automatically select a service if only one exists
					if 1 == self.ui.comboBox.count():
						self.service_selected(1) # index -> 1 
					"""
					elif hasattr(self, 'newApp') :
						if self.newApp == True :
							self.ui.comboBox.setCurrentIndex(self.ui.comboBox.count() - 1)
							self.service_selected(self.ui.comboBox.count())
							self.newAppText = self.ui.comboBox.itemText(self.ui.comboBox.count() - 1)
							self.inspector.refresh()
							self.inspector.ui.inspector.expandAll()
							self.newApp = False
					"""
				else: 
					name = 'Emulator'  #'Trickplay Device   '
					address = d[1]
					port = d[2]
					self.ui.comboBox.setItemData(0, address, ADDRESS)
					self.ui.comboBox.setItemData(0, port, PORT)
					CON.port = port
					CON.address = address
					self.inspector.refresh()
					self.inspector.ui.inspector.expandAll()

			elif event.type() == REMEVENT:
				d = event.dict
				print "Service \'", d[0], "\' removed"
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
        print('Pushing app to', CON.get())
        tp = TrickplayPushApp(str(self.path()))
        tp.push(address = CON.get())
        print "push"+CON.get()
        self.app_started()
        
    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def app_started(self):
		#tn.interact()
		print "APP Started"
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

		print("Connecting to console port ...")


		while 1:
			try : 
				self.socket.connectToHost(CON.address, self.console_port, mode=QIODevice.ReadWrite)
				if self.socket.waitForConnected(100): 
					self.newApp = True
					break
			except : 
				pass

		"""
		if hasattr(self, "debug_mode") and self.debug_mode == 0 :
			# Debug Port 
			
			self.debug_socket = QTcpSocket()
			self.debug_nextBlockSize = 0
			self.debug_bytesAvail = 0

			self.connect(self.debug_socket, SIGNAL("connected()"), self.sendRequest)
			self.connect(self.debug_socket, SIGNAL("readyRead()"), self.readDebugResponse)
			self.connect(self.debug_socket, SIGNAL("disconnected()"), self.debugServerHasStopped)
			#self.connect(self.socket,
                     	#SIGNAL("error(QAbstractSocket::SocketError)"),
                     	#self.serverHasError)

			if self.debug_socket.isOpen():
				self.debug_socket.close()

			print("Connecting to debugger port ...")

			while 1:
				try : 
					self.debug_socket.connectToHost(CON.address, self.debug_port, mode=QIODevice.ReadWrite)
					if self.debug_socket.waitForConnected(100): 
						break
				except : 
					pass
		"""
	

    def sendRequest(self):
        print "Connected"

    def readDebugResponse(self):
		while self.debug_socket.waitForReadyRead(1100) :
			#print self.debug_socket.read(self.debug_socket.bytesAvailable())+"&&&&&&&&&&&&&&&&&&"
			print self.debug_socket.read(self.debug_socket.bytesAvailable())

    def readResponse(self):
		while self.socket.waitForReadyRead(1100) :
			print self.socket.read(self.socket.bytesAvailable())
		self.socket.flush()

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
    	print ("Connection closed by server")
    	self.debug_socket.close()

    def serverHasStopped(self):
    	print ("Connection closed by server")
    	self.socket.close()

    def serverHasError(self, error):
        print(QString("Error: %1").arg(self.socket.errorString()))
        self.socket.close()


    def app_finished(self, errorCode):

		if self.trickplay.state() == QProcess.NotRunning :
			print "Trickplay APP is finished"
			self.inspector.clearTree()
			#self.trickplay.terminate()
			self.main.debug_stop.setEnabled(False)
	
    def run(self, dm=False):
       
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()
            
            env = self.trickplay.systemEnvironment()

            for item in env:
				if item[:3] == "TP_":
					ii = env.indexOf(item)
					env.removeAt(ii)

            env.append("TP_telent_console_port="+str(self.console_port))
            env.append("TP_controllers_enabled=1")
            self.my_name = "LocalHost_"+str(int(random.random() * 100000))
            env.append("TP_controllers_name="+self.my_name)

            if dm == True :
            	self.debug_mode = True
            	self.main.debug_mode = True
            	env.append("TP_debugger_port="+str(self.debug_port))
            	env.append("TP_start_debugger=1")
            else :
				self.debug_mode = False
				self.main.debug_mode = False
            self.trickplay.setEnvironment(env)

            ret = self.trickplay.start('trickplay', [self.path()])
			
        # Push to foreign device
        else:
            self.push()
	
    def printResp(self, data, command):

		pdata = json.loads(data)

		file_name = pdata["file"] 
		tp_id = pdata["id"] 
		line_num = pdata["line"]

		self.line_no = str(line_num)
		self.file_name = str(file_name)

		if "locals" in pdata:
			#g(userdata) = Group (m:0xdd25a0,c:0xdd25a0,l:0x7fc82c0917d8)
			name_var_list = []
			type_var_list = []
			value_var_list = []
			local_vars_str = ""
			local_vars = {}
			for c in pdata["locals"]:
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

		elif "error" in pdata:
			print "\t"+pdata["error"] 
		
		elif "stack" in pdata:
			stack_info_str = ""
			stack_list = []
			info_list = []
			stack_info = {}
			index = 0
			for s in pdata["stack"]:
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

		elif "breakpoints" in pdata:
			state_var_list = []
			info_var_list = []
			file_var_list = []
			linenum_var_list = []
			breakpoints_info = {}
			breakpoints_info_str = ""
			index = 0
			if len(pdata["breakpoints"]) == 0:
				print "\t"+"No breakpoints set"
			else:
				for b in pdata["breakpoints"]:
					if "file" in b and "line" in b:
						breakpoints_info_str = breakpoints_info_str+"["+str(index)+"] "+b["file"]+":"+str(b["line"])
						info_var_list.append(b["file"]+":"+str(b["line"]))
						file_var_list.append(b["file"])
						linenum_var_list.append(str(b["line"]))
					if "on" in b:
						if b["on"] == True:
							breakpoints_info_str = breakpoints_info_str+""+"\n\t"
							state_var_list.append("on")
						else:
							breakpoints_info_str = breakpoints_info_str+" (disabled)"+"\n\t"
							state_var_list.append("off")
					index = index + 1

			breakpoints_info[1] = info_var_list
			breakpoints_info[2] = file_var_list
			breakpoints_info[3] = linenum_var_list
			breakpoints_info[4] = state_var_list

			#print "\t"+breakpoints_info_str
			return breakpoints_info
		
		elif "source" in pdata:
			source_info = ""
			for l in pdata["source"]:
				if "line" in l and "text" in l:
					if l["line"] == line_num:
						source_info = source_info+str(l["line"])+" >>"+str(l["text"])+"\n\t"
					else:
						source_info = source_info+str(l["line"])+"   "+str(l["text"])+"\n\t"
			print "\t"+source_info
		
		elif "lines" in pdata:
			fetched_lines = ""
			
			for l in pdata["lines"]:
				fetched_lines = fetched_lines+l+"\n\t"
			print "\t"+fetched_lines

		elif "app" in pdata:
			app_info = ""
			for key in pdata["app"].keys():
				if key != "contents":
					app_info = app_info+str(key)+" : "+str(pdata["app"][key])+"\n\t"
				else:
					app_info = app_info+key+" : "
					for c in pdata["app"]["contents"]:
						app_info = app_info + str(c) + ","
					app_info = app_info+"\n\t"					
			print "\t"+app_info

		if command in ['n','s','bn', 'cn']:
			#print "\t"+"Break at "+file_name+":"+str(line_num)
			pass



