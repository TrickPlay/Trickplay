import httplib, urllib, urllib2, json
from socket import error
from Inspector.Data import BadDataException

class Connection():
    
    def __init__(self, address, port):
        self.address = address        
        self.port = port
    
    def get(self):
        s = str(self.address) + ':' + str(self.port)
        print('Address returned', s)
        return s
    
    def set(self, address, port):
        self.address = address        
        self.port = port
    
#CON = Connection('localhost', '8888')
CON = Connection('', '')

def send(data):
    
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
    
    s = CON.get()
    
    print(s)
    
    r = urllib2.Request("http://" + s + "/debug/ui")
    
    f = None
    
    try:
    
        f = urllib2.urlopen(r)
            
        return decode(f.read())
    
    # Connection refused
    except urllib2.URLError, e:
        
        print("Error >> Connection to Trickplay application unsuccessful.")
        
        print(e)
        
        return None
    
    except httplib.BadStatusLine, e:
        
        print("Error >> Trickplay application closed before data could be retreived.")
        
        print(e)
        
        return None
    
    except httplib.InvalidURL, e:
    
        print('Could not find a Trickplay device.')
        
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
