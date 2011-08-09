#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys

try:
    import gobject
    import avahi
    import dbus
    #import gtk
    import avahi.ServiceTypeDatabase
except ImportError, e:
    print 'A required python module is missing!\n%s' % e
    sys.exit()

try:
    import dbus.glib
except ImportError, e:
    pass


class ServiceTypeDatabase:

    def __init__(self):
        self.pretty_name = \
            avahi.ServiceTypeDatabase.ServiceTypeDatabase()

    def get_human_type(self, type):
        if self.pretty_name.has_key(type):
            return self.pretty_name[type]
        else:
            return type


class ServiceDiscovery:

    def __init__(self):

    # Start Service Discovery

        self.domain = ''
        try:
            self.system_bus = dbus.SystemBus()
            self.system_bus.add_signal_receiver(self.avahi_dbus_connect_cb,
                    'NameOwnerChanged', 'org.freedesktop.DBus',
                    arg0='org.freedesktop.Avahi')
        except dbus.DBusException, e:
            pprint.pprint(e)
            sys.exit(1)

        self.service_browsers = {}

        self.start_service_discovery(None, None, None)

    def avahi_dbus_connect_cb(
        self,
        a,
        connect,
        disconnect,
        ):
        if connect != '':
            print 'We are disconnected from avahi-daemon'
            self.stop_service_discovery(None, None, None)
        else:
            print 'We are connected to avahi-daemon'
            self.start_service_discovery(None, None, None)

    def siocgifname(self, interface):
        if interface <= 0:
            return 'any'
        else:
            return self.server.GetNetworkInterfaceNameByIndex(interface)

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

#        txts = avahi.txt_array_to_string_array(txt)

    def print_error(self, err):

    # FIXME we should use notifications

        print 'Discovery Error >>', str(err)

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

# this check is for local services
#        try:
#            if flags & avahi.LOOKUP_RESULT_LOCAL:
#                return
#        except dbus.DBusException:
#            pass

        self.server.ResolveService(
            interface,
            protocol,
            name,
            type,
            domain,
            avahi.PROTO_INET,
            dbus.UInt32(0),
            reply_handler=self.service_resolved,
            error_handler=self.print_error,
            )

    def remove_service(
        self,
        interface,
        protocol,
        name,
        type,
        domain,
        flags,
        ):
        print "Service '%s' of type '%s' in domain '%s' on %s.%i disappeared." \
            % (name, type, domain, self.siocgifname(interface),
               protocol)

    def add_service_type(
        self,
        interface,
        protocol,
        type,
        domain,
        ):

    # Are we already browsing this domain for this type?

        if self.service_browsers.has_key((interface, protocol, type,
                domain)):
            return

        print "Browsing for services of type '%s' in domain '%s' on %s.%i ..." \
            % (type, domain, self.siocgifname(interface), protocol)

        b = dbus.Interface(self.system_bus.get_object(avahi.DBUS_NAME,
                           self.server.ServiceBrowserNew(interface,
                           protocol, type, domain, dbus.UInt32(0))),
                           avahi.DBUS_INTERFACE_SERVICE_BROWSER)
        b.connect_to_signal('ItemNew', self.new_service)
        b.connect_to_signal('ItemRemove', self.remove_service)

        self.service_browsers[(interface, protocol, type, domain)] = b

    def del_service_type(
        self,
        interface,
        protocol,
        type,
        domain,
        ):

        service = (interface, protocol, type, domain)
        if not self.service_browsers.has_key(service):
            return
        sb = self.service_browsers[service]
        try:
            sb.Free()
        except dbus.DBusException:
            pass
        del self.service_browsers[service]

    # delete the sub menu of service_type

        if self.zc_types.has_key(type):
            self.service_menu.remove(self.zc_types[type].get_attach_widget())
            del self.zc_types[type]
        if len(self.zc_types) == 0:
            self.add_no_services_menuitem()

    def start_service_discovery(
        self,
        component,
        verb,
        applet,
        ):
        if len(self.domain) != 0:
            print 'domain not null %s' % self.domain
            self.display_notification(_('Already Discovering'), '')
            return
        try:
            self.server = \
                dbus.Interface(self.system_bus.get_object(avahi.DBUS_NAME,
                               avahi.DBUS_PATH_SERVER),
                               avahi.DBUS_INTERFACE_SERVER)
            self.domain = self.server.GetDomainName()
        except:
            print 'Check that the Avahi daemon is running!'
            return

        try:
            self.use_host_names = self.server.IsNSSSupportAvailable()
        except:
            self.use_host_names = False

        print 'Starting discovery'

        self.interface = avahi.IF_UNSPEC
        self.protocol = avahi.PROTO_INET

        service_type = '_tp-remote._tcp'
        self.add_service_type(self.interface, self.protocol,
                              service_type, self.domain)

    def stop_service_discovery(
        self,
        component,
        verb,
        applet,
        ):
        if len(self.domain) == 0:
            print 'Discovery already stopped'
            return

        print 'Discovery stopped'


def main():
    sda = ServiceDiscovery()
    gtk.main()


if __name__ == '__main__':
    main()
