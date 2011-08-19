from PyQt4.QtGui import *
from PyQt4.QtCore import *

import avahi
import socket
import sys

from Service import ServiceDiscovery, ServiceTypeDatabase
from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
    
class TrickplayDiscovery(ServiceDiscovery):
    
    def __init__(self, combo, inspector):
        
        ServiceDiscovery.__init__(self)
        
        self.combo = combo
        
        self.inspector = inspector
        
        QObject.connect(self.combo, SIGNAL('currentIndexChanged(int)'), self.service_selected)
    
    def service_selected(self, index):
        
        # No services exist yet
        if index < 0:
            return
        
        address = self.combo.itemData(index, ADDRESS).toPyObject()
        port = self.combo.itemData(index, PORT).toPyObject()

        if not address or not port:
            return
        
        self.inspector.clearTree()
        
        print(index,address,port)
        
        # Echo client program
        # http://docs.python.org/release/2.5.2/lib/socket-example.html
        
        s = None
        for res in socket.getaddrinfo(address, port, socket.AF_UNSPEC, socket.SOCK_STREAM):
            
            af, socktype, proto, canonname, sa = res
            try:
                s = socket.socket(af, socktype, proto)
            except socket.error, msg:
                s = None
                continue
            
            try:
                s.connect(sa)
            except socket.error, msg:
                s.close()
                s = None
                continue
            break
        
        if s is None:
            print 'could not open socket'
        else:
            s.send('ID\t40\tDEBUGGER\n')
            data = s.recv(1024)
            s.close()
            msg = data.rstrip().split('\t')
                
            print 'Received', repr(msg)
            
            CON.port = msg[2]
            CON.address = address
        
    def new_service(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        flags,
        ):
        
        #print "Found service '%s' of type '%s' in domain '%s' on %s.%i." \
        #    % (name, type, domain, self.siocgifname(interface),
        #       protocol)
        
        ServiceDiscovery.new_service(
            self,
            interface,
            protocol,
            name,
            type,
            domain,
            flags
            )
        
    def service_resolved(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        host,
        aprotocol,
        address,
        port,
        txt,
        flags,
        ):
        stdb = ServiceTypeDatabase()
        h_type = stdb.get_human_type(type)
        
        # Add item to ComboBox
        self.combo.addItem(name)
        index = self.combo.findText(name)
        self.combo.setItemData(index, address, ADDRESS)
        self.combo.setItemData(index, port, PORT)
        self.combo.setItemData(index, address, NAME)
        
        print('Found', address, port)
        
        # Automatically select a service if only one exists
        if 1 == self.combo.count():
            self.service_selected(index)
        
        #print "Service data for service '%s' of type '%s' (%s) in domain '%s' on %s.%i:" \
        #    % (
        #    name,
        #    h_type,
        #    type,
        #    domain,
        #    self.siocgifname(interface),
        #    protocol,
        #    )
        #print '\tHost %s (%s), port %i, TXT data: %s' % (host, address,
        #        port, avahi.txt_array_to_string_array(txt))
        
    def remove_service(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        flags,
        ):
        
        index = self.combo.findText(name)
        
        self.combo.removeItem(index)
        
        self.inspector.clearTree()
        
        #for item in list:
        #    
        #    r = self.combo.row(item)
        #    
        #    self.combo.takeItem(r)
    
        print "Service '%s' of type '%s' in domain '%s' on %s.%i disappeared." \
            % (name, type, domain, self.siocgifname(interface),
               protocol)

        