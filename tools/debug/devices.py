from PyQt4.QtGui import *
from PyQt4.QtCore import *

import avahi
import socket
import sys

from discovery import ServiceDiscovery, ServiceTypeDatabase
from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
    
class TrickplayDiscovery(ServiceDiscovery):
    
    def __init__(self, widget, main):
        
        ServiceDiscovery.__init__(self)
        
        self.widget = widget
        
        self.main = main
        
        QObject.connect(self.widget, SIGNAL('currentIndexChanged(int)'), self.service_selected)
    
    def service_selected(self, index):
        
        # No services exist yet
        if index < 0:
            return
        
        name = self.widget.itemData(index, NAME).toPyObject()
        address = self.widget.itemData(index, ADDRESS).toPyObject()
        port = self.widget.itemData(index, PORT).toPyObject()
        
        if not name or not address or not port:
            return
        
        self.main.clearTree()
        
        print(index,name,address,port)
        
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
        
        print "Found service '%s' of type '%s' in domain '%s' on %s.%i." \
            % (name, type, domain, self.siocgifname(interface),
               protocol)
        
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
        
        #new = QListWidgetItem(name)
        #new.setData(ADDRESS, address)
        #new.setData(PORT, port)
        #new.setData(NAME, name)
        #
        
        # Add item to ComboBox
        self.widget.addItem(name)
        index = self.widget.findText(name)
        self.widget.setItemData(index, address, ADDRESS)
        self.widget.setItemData(index, port, PORT)
        self.widget.setItemData(index, address, NAME)
        
        print "Service data for service '%s' of type '%s' (%s) in domain '%s' on %s.%i:" \
            % (
            name,
            h_type,
            type,
            domain,
            self.siocgifname(interface),
            protocol,
            )
        print '\tHost %s (%s), port %i, TXT data: %s' % (host, address,
                port, avahi.txt_array_to_string_array(txt))
        
    def remove_service(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        flags,
        ):
        
        index = self.widget.findText(name)
        
        self.widget.removeItem(index)
        
        self.main.clearTree()
        
        #for item in list:
        #    
        #    r = self.widget.row(item)
        #    
        #    self.widget.takeItem(r)
    
        print "Service '%s' of type '%s' in domain '%s' on %s.%i disappeared." \
            % (name, type, domain, self.siocgifname(interface),
               protocol)

        