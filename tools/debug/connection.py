import httplib, urllib, urllib2, json
from socket import error
from data import BadDataException

def send(data):
    
    params = json.dumps(data)

    conn = httplib.HTTPConnection("localhost:8888")
    
    try:
    
        conn.request("POST", "/debug/ui", params)
            
        response = conn.getresponse()
        
        data = response.read()
            
        conn.close()

    except error, e:
        
        print("Error >> Trickplay Application unavailable.")
        
        print(e)
        
    
def getTrickplayData():
    
    r = urllib2.Request("http://localhost:8888/debug/ui")
    
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
    
    
def decode(input):
    
    return json.loads(input)


"""
Test the connection
"""
def test():
    
    send({'gid': 1, 'properties' :{'x': 1200}})


if __name__ == "__main__":
    
    test()
