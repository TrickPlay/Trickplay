local attempts = {}

local last_req = nil

local try_again = Timer{
	
	interval = 10*1000,
	
	on_timer = function(self)
		
		self:stop()
		
		last_req:send()
		
	end
}

try_again:stop()

local response_check = function(request_object,response_object,callback)
    if response_object.failed or response_object.code ~= 200 then
		
		print(
			
			"URLRequest received a reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status
			
		)
		if attempts[request_object] == nil then
			
			attempts[request_object] = 1
			
		elseif attempts[request_object] > 3 then
			
			
			
		else
			
			attempts[request_object] = attempts[request_object] + 1
			
		end
		
		--request_object:send()
		
		last_req = request_object
		
		try_again:start()
		
	elseif response_object.code ~= 200 then
		
		error(
			
			"URLRequest received a reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status
			
		)
		
	elseif response_object.body == nil then
		
		error(
			response_object.code.." - "..
			
			response_object.status
		)
		
	else
					
		local json_response = json:parse(response_object.body)
		
		
		if json_response == nil then
		
			json_response = Xml_Parse(response_object.body)
		end
		--[[
		if json_response == nil or type(json_response) ~= "table" then
			
			print(response_object.body)
			
			error("Unable to parse ResponseObject.body, parse result = "..json_response)
			
		end
		--]]
		
		callback(json_response)
		
	end
end

--------------------------------------------------------------------------------
local groupon_api_key = "4e79a015b2222c3336099a080f7b3508cc62a6a0"

local groupon_get_deals = function(callback,lat,lng,radius)
    
    assert(type(callback) == "function")
    
    local req = URLRequest{
        
        url = "https://api.groupon.com/v2/deals.json?show=all&client_id="..groupon_api_key,
        
        on_complete = function(self,response_object)
            
            response_check(self,response_object,callback)
            
        end
    }
    
    if lat ~= nil and lng ~= nil and radius ~= nil then
        req.url = req.url.."&lat="..lat.."&lng="..lng.."&radius="..radius
    end
    
    return req:send()
end
--------------------------------------------------------------------------------


local tropo_api_key = "016ed2530c3bcc47b397ead9357a41a777093018d4ab25f85220a86ac342f29bea28e88efc53f74872082eee"
local cj_publisher_id = "5287435"

local tropo_sms = function(callback,msg,to)
    
    assert(type(callback) == "function")
    
    local req = URLRequest{
        
        url = "https://api.tropo.com/1.0/sessions?action=create&token="..tropo_api_key.."&msg="..msg.."&to="..to,
        
        on_complete = function(self,response_object)
            
            response_check(self,response_object,callback)
            
        end
    }
    
    return req:send()
end

--------------------------------------------------------------------------------
local google_maps_get_lat_lng_from_zip = function(zip, callback)
    
    assert(type(callback) == "function")
    
    local req = URLRequest{
        
        url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=true&"..
            "address="..zip,
        
        on_complete = function(self,response_object)
            
            response_check(self,response_object,callback)
            
        end
    }
    
    return req:send()
end

return groupon_get_deals, tropo_sms, google_maps_get_lat_lng_from_zip, try_again