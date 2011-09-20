--local attempts = {}

local try_again = Timer{
	
	interval = 10*1000,
	
	on_timer = function(self)
		
		self:stop()
		
        print( "Resending " .. self.req.url )
        
		self.req:send()
		
	end
}

try_again:stop()

local response_check = function(request_object,response_object,callback)
	
	if response_object.failed then
        print(
			
			"URLRequest FAILED, receiving the reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status..".  Trying again in "..try_again.interval/1000
			
		)
    elseif response_object.code ~= 200 then
		
        
        
        
		print(
			
			"URLRequest received a reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status..".  Trying again in "..try_again.interval/1000
			
		)
        --]]
        
        --[[
		if attempts[request_object] == nil then
			
			attempts[request_object] = 1
			
		elseif attempts[request_object] > 3 then
			
			
			
		else
			
			attempts[request_object] = attempts[request_object] + 1
			
		end
		--]]
        
		
		
	elseif response_object.body == nil then
		
		error(
			"\n\nReceived a nil Response body\n"..
            
            "Status: "..response_object.code.." - "..response_object.status.."\n"
		)
		
	else
		
		local json_response = json:parse(response_object.body)
		
		
		if json_response == nil then
			
			callback(  Xml_Parse(response_object.body)  )
			
        else
            
            callback(json_response)
            
		end
        
		--[[
		if json_response == nil or type(json_response) ~= "table" then
			
			print(response_object.body)
			
			error("Unable to parse ResponseObject.body, parse result = "..json_response)
			
		end
		--]]
		
        return
	end
    
    try_again.req = request_object
		
	try_again:start()
end

--------------------------------------------------------------------------------
-- GOOGLE MAPS
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

--------------------------------------------------------------------------------
--GROUPON
--------------------------------------------------------------------------------

local groupon_api_key = "4e79a015b2222c3336099a080f7b3508cc62a6a0"

local function groupon_get_deals(callback,lat,lng,radius)
	
	assert(type(callback) == "function")
	
	local req = URLRequest{
		
		url = "https://api.groupon.com/v2/deals.json?show=all&client_id="..groupon_api_key,
		
		on_complete = function(self,response_object)
			
			if response_object.code == 400 and lat == nil then
				
				groupon_get_deals(callback,33.93,-118.4,50)
				
			else
				
				response_check(self,response_object,callback)
				
			end
		end
	}
	
	if lat ~= nil and lng ~= nil and radius ~= nil then
		
		req.url = req.url.."&lat="..lat.."&lng="..lng.."&radius="..radius
		
	end
	
	
	return req:send()
end

--------------------------------------------------------------------------------
-- BITLY
--------------------------------------------------------------------------------

local login         = 'trickplayaffiliate'
local bitly_api_key = 'R_b7a6a475fa6baf58fea332a1718779ed'

local shorten_url = function(url,callback)
	
	assert(type(callback) == "function")
	
	local req = URLRequest{
		
		url = "http://api.bitly.com/v3/shorten?"..
			"login="  ..login.."&"..
			"apiKey=" ..bitly_api_key.."&"..
			"longUrl="..uri:escape(url),
		
		on_complete = function(self,response_object)
		    
			response_check(self,response_object,callback)
		    
		end
	}
	
	return req:send()
	
end


--------------------------------------------------------------------------------
-- TROPO
--------------------------------------------------------------------------------


local tropo_api_key = "016ed2530c3bcc47b397ead9357a41a777093018d4ab25f85220a86ac342f29bea28e88efc53f74872082eee"
local cj_publisher_id = "5287435"
local groupon_s_AID = "10804307"

local function cj_link(deal_url)
	return "http://www.anrdoezrs.net/click-"..
			cj_publisher_id.."-"..groupon_s_AID..
			"?url="..uri:escape(deal_url)
end

local tropo_sms = function(callback,merchant_name,deal_url,to)
    
	
	assert(type(callback) == "function")
	
	shorten_url(
		
		cj_link(deal_url),
		
		function(response)
			dumptable(response)
			local req = URLRequest{
				
				url = "https://api.tropo.com/1.0/sessions?action=create&token="..
					tropo_api_key.."&msg="..uri:escape("Here's your "..'"'..merchant_name..'"'.." Groupon offer: "..response.data.url).."&to="..to,
				
				on_complete = function(self,response_object)
					
					response_check(self,response_object,callback)
					
				end
			}
			
			req:send()
			
		end
	)
    
	print("sent")
end

return groupon_get_deals, tropo_sms, google_maps_get_lat_lng_from_zip, try_again