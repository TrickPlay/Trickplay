#!/usr/bin/env python

import asyncore,asynchat,socket
import sys
import itertools

class controller(asynchat.async_chat):

    def __init__(self, name, host, port):
        asynchat.async_chat.__init__(self)
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connect( (host, port) )
        self.push( 'D\t1\t%s\tK\n' % name )
        self.set_terminator('\n')
        
        
    def collect_incoming_data(self,data):
        self._collect_incoming_data(data)
        
    def found_terminator(self):
        
        data=self._get_data()
        
        if data.startswith("UI\tMC\t"):
            
            parts=data.split("\t")
            
            if len(parts) >= 4:
                
                k=list(itertools.islice(parts,2,None,2))
                v=list(itertools.islice(parts,3,None,2))
                
                for i,j in enumerate(k):
                    print("%s) %s"%(j,v[i]))
                
                s=raw_input("your choice > ")
                
                if s in k:
                    self.push("UI\t%s\n"%s)
        
        

name="Python"
host="localhost"
port=9009

if len(sys.argv)>1:
    name=sys.argv[1]
    if len(sys.argv)>2:
        host=sys.argv[2]
        if len(sys.argv)>3:
            port=sys.argv[3]

c = controller(name,host,port)

asyncore.loop()

