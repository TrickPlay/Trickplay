local response_check = function(request_object,response_object,callback)
    if response_object.failed then
		
		print("URLRequest failed. Trying Again")
		
		self:send()
		
	elseif response_object.code ~= 200 then
		
		error(
			
			"URLRequest received a reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status
			
		)
		
	else
					
		local json_response = json:parse(response_object.body)
		
		if json_response == nil or type(json_response) ~= "table" then
			
			error("Unable to parse ResponseObject.body, parse result = "..json_response)
			
		end
		
		callback(json_response)
		
	end
end


local groupon_api_key = "4e79a015b2222c3336099a080f7b3508cc62a6a0"
local cj_publisher_id = "5287435"

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

return groupon_get_deals, google_maps_get_lat_lng_from_zip