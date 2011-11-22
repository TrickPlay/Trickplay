from PyQt4.QtGui import *
from PyQt4.QtCore import *

import socket
import sys
import time

from zeroconf.mdns import *
from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3


class TrickPlayListener(object):

	def __init__(self, r, c, i):

		self.r = r
		self.combo = c
		self.inspector = i
		self.devices = {}

	def getDeviceName(self, name):

		n_name = ""
		cnt = 0
		for c in name:
			if c == ".":
				n_name = name[:cnt]
				break
			cnt = cnt + 1
		if n_name != "":
			name = n_name
		return name

	def removeService(self, zeroconf, type, name):

		print "Service", name, "removed"
		
		name = self.getDeviceName(name)
		index = self.combo.findText(name)
		self.combo.removeItem(index)
		self.inspector.clearTree()
		if str(name) in self.devices:
			del self.devices[str(name)] 

	def addService(self, zeroconf, type, name):
		
		info = self.r.getServiceInfo(type, name)
		if info:
			print "Service", name, "added"
			address =  str(socket.inet_ntoa(info.getAddress()))
			port = info.getPort()
			if port != 6789:
				name = self.getDeviceName(name)
				self.devices[str(name)] = {}
				self.devices[str(name)][0] = str(address)
				self.devices[str(name)][1] = str(port)
				# Add item to ComboBox
				self.combo.addItem(name)
				index = self.combo.findText(name)
				self.combo.setItemData(index, address, ADDRESS)
				self.combo.setItemData(index, port, PORT)
				self.combo.setItemData(index, address, NAME)
        		# Automatically select a service if only one exists
        		if 1 == self.combo.count():
        			self.service_selected(1) # index -> 1 
			return True
		else:
			return False

	def service_selected(self, index):
        
		if index < 0:
			return
        
		address = self.combo.itemData(index, ADDRESS).toPyObject()
		port = self.combo.itemData(index, PORT).toPyObject()

		if not address or not port:
			return
        
		self.inspector.clearTree()
        
		print(index,address,port)

		CON.port = port
		CON.address = address


class TrickplayDiscovery():
    
    def __init__(self, combo, inspector):
        
        self.combo = combo
        self.inspector = inspector
        self.r = Zeroconf()
        self.type = "_trickplay-http._tcp.local."

        self.listener = TrickPlayListener(self.r, self.combo, self.inspector)
        self.service_selected = self.listener.service_selected 
        QObject.connect(self.combo, SIGNAL('currentIndexChanged(int)'), self.service_selected)
        browser = ServiceBrowser(self.r, self.type, self.listener)
        time.sleep(2)

    def stop(self):
    	self.r.stop()

	def devices(self):
		return self.listener.devices
    
	def force_lookup(self, name):
		if self.listener.addService(self.r, "_trickplay-http._tcp.local.", name+'.'+self.type) :
			return True
		else :
			return False

        
