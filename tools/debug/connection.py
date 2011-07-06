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
    
if __name__ == "__main__":
    test()
