from PyQt4.QtGui import *
from PyQt4.QtCore import *

import avahi
from discovery import ServiceDiscovery, ServiceTypeDatabase
from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3
    
class TrickplayDiscovery(ServiceDiscovery):
    
    def __init__(self, widget):
        
        ServiceDiscovery.__init__(self)
        
        self.widget = widget
        
        QObject.connect(self.widget, SIGNAL('clicked(QModelIndex)'), self.service_selected)
    
    def service_selected(self, index):
        
        name = index.data(NAME).toPyObject()
        address = index.data(ADDRESS).toPyObject()
        port = index.data(PORT).toPyObject()
        
        print(name,address,port)
        
        #CON.port = port
        #CON.address = address
        #
        
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
        
        new = QListWidgetItem(name)
        new.setData(ADDRESS, address)
        new.setData(PORT, port)
        new.setData(NAME, name)
        
        self.widget.addItem(new)
        
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
        
        list = self.widget.findItems(name, Qt.MatchExactly)
        
        for item in list:
            
            r = self.widget.row(item)
            
            self.widget.takeItem(r)
    
        print "Service '%s' of type '%s' in domain '%s' on %s.%i disappeared." \
            % (name, type, domain, self.siocgifname(interface),
               protocol)

        