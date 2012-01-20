
import telnetlib
import base64
import sys

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager

from connection import *

from PyQt4.QtNetwork import (QTcpSocket,)

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
ADDEVENT = QEvent.User + 1
REMEVENT = QEvent.User + 2
SIZEOF_UINT16 = 2


class TrickplayDeviceManager(QWidget):
    
    def __init__(self, inspector, parent = None):
        
        QWidget.__init__(self, parent)
                
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

    def service_selected(self, index):
        
		if index < 0:
			return
        
		address = self.ui.comboBox.itemData(index, ADDRESS).toPyObject()
		port = self.ui.comboBox.itemData(index, PORT).toPyObject()

		if not address or not port:
			return
        
		self.inspector.clearTree()
        
		print(index,address,port)

		CON.port = port
		CON.address = address

    def event(self, event):
		while 1:
			if event.type() == ADDEVENT:
				d = event.dict
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
			elif event.type() == REMEVENT:
				d = event.dict
				print "Service \'", d[0], "\' removed"
				# Remove item from ComboBox
				index = self.ui.comboBox.findText(d[0])
				self.ui.comboBox.removeItem(index)
				self.inspector.clearTree()
			return True

 
    def stop(self):
		self.discovery.stop()

    def addLocalComboItem(self):
        """
        Add combo box from running app locally. This always exists.
        """
        name = 'Local Device'  #'Trickplay Device   '
        port = '6789'
        address = 'localhost'
        
        self.ui.comboBox.addItem(name)
        index = self.ui.comboBox.findText(name)
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
		"""
		while 1:
			try : 
				tn = telnetlib.Telnet(CON.address, "7777")
				break
			except : 
				print "retry ..."

		tn.interact()
		"""
		print "APP Started"
		self.socket = QTcpSocket()
		self.nextBlockSize = 0
		self.bytesAvail = 0

		self.connect(self.socket, SIGNAL("connected()"), self.sendRequest)
		self.connect(self.socket, SIGNAL("readyRead()"), self.readResponse)
		self.connect(self.socket, SIGNAL("disconnected()"),
					self.serverHasStopped)
		#self.connect(self.socket,
                     #SIGNAL("error(QAbstractSocket::SocketError)"),
                     #self.serverHasError)

		if self.socket.isOpen():
			self.socket.close()
		print("Connecting to server...")

		while 1:
			try : 
				self.socket.connectToHost(CON.address, 7777, mode=QIODevice.ReadWrite)
				if self.socket.waitForConnected(100): 
					break
			except : 
				pass

    def sendRequest(self):
        print "Connected"

    def readResponse(self):
		while self.socket.waitForReadyRead(1100) :
			print self.socket.read(self.socket.bytesAvailable())

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

			print "herehehrehr"
			msg = QString()
			stream >> msg
			print str(msg)

			self.nextBlockSize = 0
		
		"""

    def serverHasStopped(self):
    	print ("Error: Connection closed by server")
    	self.socket.close()

    def serverHasError(self, error):
        print(QString("Error: %1").arg(self.socket.errorString()))
        self.socket.close()


    def app_finished(self, errorCode):

		print errorCode
		if self.trickplay.state() == QProcess.NotRunning :
			print "trickplay app is finished"
			#self.trickplay.terminate()
	
    def run(self):
        
       
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()
            
            #env = self.trickplay.systemEnvironment()
            #env.append("TP_http_port=6789")
            #self.trickplay.setEnvironment(env)
            env = self.trickplay.systemEnvironment()
            env.append("TP_telent_console_port=7777")
            env.append("TP_controllers_enabled=1")
            env.append("TP_controllers_name=LocalHost")
            self.trickplay.setEnvironment(env)

            #self.trickplay.ProcessChannelMode(QProcess.MergedChannels)

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
			local_vars = ""
			for c in pdata["locals"]:
				if c["name"] != "(*temporary)":
					c_v = None
					if local_vars != "":
						local_vars = local_vars+"\n\t"

					local_vars = local_vars+str(c["name"])+"("+str(c["type"])+")"
					try:
						c_v = c["value"]	
					except KeyError: 
						pass

					if c_v:
						local_vars = local_vars+" = "+str(c["value"])

			print "\t"+local_vars
			print "\t"+"Break at "+file_name+":"+str(line_num)

		elif "error" in pdata:
			print "\t"+pdata["error"] 
		
		elif "stack" in pdata:
			stack_info = ""
			index = 0
			for s in pdata["stack"]:
				if "file" in s and "line" in s:
					stack_info = stack_info+"["+str(index)+"] "+s["file"]+":"+str(s["line"])+"\n\t"
					index = index + 1
			print "\t"+stack_info

		elif "breakpoints" in pdata:
			breakpoints_info = ""
			index = 0
			if len(pdata["breakpoints"]) == 0:
				print "\t"+"No breakpoints set"
			else:
				for b in pdata["breakpoints"]:
					if "file" in b and "line" in b:
						breakpoints_info = breakpoints_info+"["+str(index)+"] "+b["file"]+":"+str(b["line"])
						index = index + 1
					if "on" in b:
						if b["on"] == True:
							breakpoints_info = breakpoints_info+""+"\n\t"
						else:
							breakpoints_info = breakpoints_info+" (disabled)"+"\n\t"

			print "\t"+breakpoints_info
		
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
			print "\t"+"Break at "+file_name+":"+str(line_num)



