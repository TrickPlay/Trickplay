import httplib, urllib, urllib2, json
import os, time, re
from socket import error
#from Inspector.Data import BadDataException

class Connection():
    
    def __init__(self, address, port):
        self.address = address        
        self.port = port
    
    def get(self):
        """
        Get the current address and port selected
        """
        
        s = str(self.address) + ':' + str(self.port)
        #print('Address returned', s)
        return s
    
    def set(self, address, port):
        """
        Set the current address and port
        """
        
        self.address = address        
        self.port = port
    
# TODO:
# Better way of passing connection between widgets?
CON = Connection('', '')

def send(data):
    """
    Send UI parameters for Trickplay to change
    """
    
    params = json.dumps(data)
    conn = httplib.HTTPConnection( CON.get() )
    
    try:
        conn.request("POST", "/debug/ui", params)
        response = conn.getresponse()
        data = response.read()
        conn.close()
        return True

    except error, e:
        print("Error >> Trickplay Application unavailable.")
        print(e)
        return False
        
    
def getTrickplayData():
    """
    Get Trickplay UI tree data for the inspector
    """
    
    s = CON.get()
    r = urllib2.Request("http://" + s + "/debug/ui")
    f = None
    
    try:
        f = urllib2.urlopen(r)
        return decode(f.read())
    
    # Connection refused
    except urllib2.URLError, e:
        print("Error >> Connection to Trickplay application unsuccessful.")
        print(e)
    
    except httplib.BadStatusLine, e:
        print("Error >> Trickplay application closed before data could be retreived.")
        print(e)
    
    except httplib.InvalidURL, e:
        print('Could not find a Trickplay device.')
        print(e)
        
    return None
    
    
def sendTrickplayDebugCommand(db_port, cmd, start=False):
    """
    Send Start Trickplay Remote Debugger
    """
    
    if start == True:
		print "Connecting remote debugger ..."

    s = str(CON.address+":"+db_port)
	
    #conn = httplib.HTTPConnection( CON.address, db_port)
    conn = httplib.HTTPConnection( s )
    
    try:
        #print("sending "+cmd)
        conn.request("POST", "/debugger", cmd)
        response = conn.getresponse()
        data = response.read()
        #print(" response "+data)
        conn.close()
        return data

    # Connection refused
    except error, e:
        print("Error >> Trickplay Application unavailable.")
        print(e)
        return False
 


def getTrickplayDebug():
    """
    Get Trickplay UI tree data for the inspector
    """

    s = CON.get()
    #print s
    r = urllib2.Request("http://" + s + "/debug/start")
    f = None
    
    try:
        f = urllib2.urlopen(r)
        return decode(f.read())
    
    # Connection refused
    except urllib2.URLError, e:
        print("Error >> Connection to Trickplay application unsuccessful.")
        print(e)
    except httplib.BadStatusLine, e:
        print("Error >> Trickplay application closed before data could be retreived.")
        print(e)
    
    except httplib.InvalidURL, e:
        print('Could not find a Trickplay device.')
        print(e)
        
    return None

def decode(input):
    
    return json.loads(input)


"""
Test the connection
"""
def test():
    
    send({'gid': 1, 'properties' :{'x': 1200}})


if __name__ == "__main__":
    
    test()

def printResp(data, command):

	pdata = json.loads(data)

	file_name = pdata["file"] 
	tp_id = pdata["id"] 
	line_num = pdata["line"]

	if "error" in pdata:
		print "\t"+pdata["error"] 
	elif "breakpoints" in pdata:
		state_var_list = []
		info_var_list = []
		file_var_list = []
		#linenum_var_list = []
		breakpoints_info = {}
		breakpoints_info_str = ""
		index = 0
		if len(pdata["breakpoints"]) == 0:
			#print "\t"+"No breakpoints set"
			return breakpoints_info
		else:
			for b in pdata["breakpoints"]:
				if "file" in b and "line" in b:
					breakpoints_info_str = breakpoints_info_str+"["+str(index)+"] "+b["file"]+":"+str(b["line"])
					info_var_list.append(b["file"]+":"+str(b["line"]))

					n = re.search("[/]+\S+[/]+", b["file"]).end()
					
					file_var_list.append(b["file"][n:]+" : "+str(b["line"]))
				if "on" in b:
					if b["on"] == True:
						breakpoints_info_str = breakpoints_info_str+""+"\n\t"
						state_var_list.append("on")
					else:
						breakpoints_info_str = breakpoints_info_str+" (disabled)"+"\n\t"
						state_var_list.append("off")
				index = index + 1

			breakpoints_info[1] = state_var_list
			breakpoints_info[2] = file_var_list
			breakpoints_info[3] = info_var_list
			#breakpoints_info[4] = linenum_var_list

			#print "\t"+breakpoints_info_str
			return breakpoints_info
