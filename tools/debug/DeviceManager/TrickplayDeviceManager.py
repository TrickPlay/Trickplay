from PyQt4.QtGui import *
from PyQt4.QtCore import *

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager

from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
ADDEVENT = QEvent.User + 1
REMEVENT = QEvent.User + 2


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
        name = 'Local device'
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
        
    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def run(self):
        
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()
                #print('exit status', self.trickplay.exitStatus())
            
            #env = self.trickplay.systemEnvironment()
            #env.append("TP_http_port=6789")
            #self.trickplay.setEnvironment(env)
            self.trickplay.start('trickplay', [self.path()])
        
        # Push to foreign device
        else:
            self.push()
