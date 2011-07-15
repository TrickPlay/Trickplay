import httplib, urllib, urllib2,  json
from data import getTypeTable,  BadDataException

def send(data):
    
    #{'gid': 1, 'properties' :{'x': 1200}}
    params = json.dumps(data)

    conn = httplib.HTTPConnection("localhost:8888")
    conn.request("POST", "/debug/ui", params)

    response = conn.getresponse()
    #print response.status, response.reason
    data = response.read()

    conn.close()
    
def getTrickplayData():
    r = urllib2.Request("http://localhost:8888/debug/ui")
    f = urllib2.urlopen(r)
    return decode(f.read())

def decode(input):
    return json.loads(input)

def test():
    send({'gid': 1, 'properties' :{'x': 1200}})

def clean(name,  value):
    try:
        return getTypeTable()[name](value)
    except BadDataException,  (e):
        raise e
    
if __name__ == "__main__":
    test()
