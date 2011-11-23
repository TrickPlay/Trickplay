import socket
from connection import *
from zeroconf.mdns import *

class MyListener(object):
	def __init__(self, r):
		self.r = r
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

		if str(name) in self.devices:
			del self.devices[str(name)] 

	def addService(self, zeroconf, type, name):
		
		info = self.r.getServiceInfo(type, name)
		if info:
			print "Service", name, "added"
			address =  str(socket.inet_ntoa(info.getAddress()))
			port = info.getPort()

			name = self.getDeviceName(name)

			self.devices[str(name)] = {}
			self.devices[str(name)][0] = str(address)
			self.devices[str(name)][1] = str(port)
			return True
		else:
			return False

class TrickplayDiscovery():
	def __init__(self):
		print "Trickplay Discovery"
		self.r = Zeroconf()
		self.type = "_trickplay-http._tcp.local."
		self.listener = MyListener(self.r)
		browser = ServiceBrowser(self.r, self.type, self.listener)
		return	

	def devices(self):
		return self.listener.devices

	def service_selected(self, name):
		if name == "" or name == None:
			return
		address = self.listener.devices[name][0]
		port = self.listener.devices[name][1]

		if not address or not port:
			return 
		CON.port = port 
		CON.address = address

	def force_lookup(self, name):
		if self.listener.addService(self.r, "_trickplay-http._tcp.local.", name+'.'+self.type) :
			return True
		else :
			return False

	


