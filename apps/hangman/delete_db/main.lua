user = "admin"
pswd = "admin"

URLRequest{
    url = "http://tp-gameservice-dev.elasticbeanstalk.com/rest/user/resetDB",
    headers = {
        
        ["Accept"]       = "application/json",
        
        ["Content-Type"] = "application/json",
        
        ["Authorization"] = "Basic " .. base64_encode( user .. ":" .. pswd ),
    },
    on_complete = function(self,response)
        
        print(response.body)
        
    end
}:send()
print("sent")