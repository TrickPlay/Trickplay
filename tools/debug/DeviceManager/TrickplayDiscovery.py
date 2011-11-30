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
ADDEVENT = QEvent.User + 1
REMEVENT = QEvent.User + 2


class MyCustomEvent(QEvent):
	def __init__(self, etype, ddict={}):
		QEvent.__init__(self, etype)
		self.dict = ddict

class TrickPlayListener(object):

	def __init__(self, zc, receiver):

		self.r = zc
		self.devices = {}
		self.receiver = receiver

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

		name = self.getDeviceName(name)
		ddict = {}
		ddict[0] = str(name) 
		ddict[1] = self.devices[str(name)][0]
		ddict[2] = self.devices[str(name)][1]

		QApplication.postEvent(self.receiver, MyCustomEvent(REMEVENT, ddict))

		if str(name) in self.devices:
			del self.devices[str(name)] 

	def addService(self, zeroconf, type, name):
		
		info = self.r.getServiceInfo(type, name)

		if info:
			address =  str(socket.inet_ntoa(info.getAddress()))
			port = info.getPort()
			name = self.getDeviceName(name)

			self.devices[str(name)] = {}
			self.devices[str(name)][0] = str(address)
			self.devices[str(name)][1] = str(port)

			ddict = {}
			ddict[0] = str(name) 
			ddict[1] = self.devices[str(name)][0]
			ddict[2] = self.devices[str(name)][1]
			
			QApplication.postEvent(self.receiver, MyCustomEvent(ADDEVENT, ddict))

			return True
		else:
			return False



class TrickplayDiscovery():
    
    def __init__(self, reciever):
        
        self.r = Zeroconf()
        self.type = "_trickplay-http._tcp.local."

        self.listener = TrickPlayListener(self.r, reciever)
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

        
