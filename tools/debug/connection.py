import httplib, urllib, json

def send(data):
    
    #{'gid': 1, 'properties' :{'x': 1200}}
    params = json.dumps(data)

    conn = httplib.HTTPConnection("localhost:8888")
    conn.request("POST", "/debug/ui", params)

    response = conn.getresponse()
    print response.status, response.reason
    data = response.read()

    conn.close()

def test():
    send({'gid': 1, 'properties' :{'x': 1200}})

def clean(name,  value):
    return typeTable[name](value)

if __name__ == "__main__":
    test()
    
typeTable = {
    'anchor_point x': lambda v: ('anchor-x',  float(v)),
    'anchor_point y': lambda v: ('anchor-y',  float(v)),
    'is_visible': lambda v:('visible',  bool(int((v)))),
    'name': lambda v: ('name',  v),
    'text': lambda v: ('text',  v),
    'opacity': lambda v: ('opacity',  int(v)),
    'width': lambda v: ('width',  float(v)), 
    'height': lambda v: ('height',  float(v)),
    'w': lambda v: ('width',  float(v)), 
    'h': lambda v: ('height',  float(v)), 
    'x': lambda v: ('x',  float(v)), 
    'y': lambda v: ('y',  float(v)), 
    'z': lambda v: ('depth',  float(v)),
}







