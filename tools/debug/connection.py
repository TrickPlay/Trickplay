import httplib, urllib, json
params = json.dumps({'gid': 1, 'properties' :{'x': 1200}})
print(params)
#headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}
conn = httplib.HTTPConnection("localhost:8888")
conn.request("POST", "/debug/ui", params)
response = conn.getresponse()
print response.status, response.reason
data = response.read()
conn.close()
