import socket

from connection import *
from Service import ServiceDiscovery, ServiceTypeDatabase

class TrickplayDiscovery(ServiceDiscovery):
	def __init__(self):
		print "Trickplay Discovery"
		ServiceDiscovery.__init__(self)
		self.devices = {}
		return 

	def addLocalDevice(self):
		name = 'local'
		port = '6789'
		address = 'localhost'
		self.devices[name] = {}
		self.devices[name][0] = address
		self.devices[name][1] = port
		
	def new_service(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        flags,
        ):
        
		ServiceDiscovery.new_service(
            self,
            interface,
            protocol,
            name,
            type,
            domain,
            flags
            )

	def service_selected(self, name):
		if name == "" or name == None:
			return
		address = self.devices[name][0]
		port = self.devices[name][1]

		if not address or not port:
			return 
		CON.port = port 
		CON.address = address

	def service_resolved(self, interface, protocol, name, type, domain, host, aprotocol, address, port, txt, flags):
		stdb = ServiceTypeDatabase()
		h_type = stdb.get_human_type(type)

		self.devices[str(name)] = {}
		self.devices[str(name)][0] = str(address)
		self.devices[str(name)][1] = str(port)

	def remove_service(self, interface, protocol, name, type, domain, flags):
		if str(name) in self.devices:
			del self.devices[str(name)] 

