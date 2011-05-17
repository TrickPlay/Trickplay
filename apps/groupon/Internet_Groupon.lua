local api_key = "4e79a015b2222c3336099a080f7b3508cc62a6a0"
local publisher_id = "5287435"


local groupon_api_url_calls = {
	get_api_status = function()
		return "https://api.groupon.com/status.json?client_id="..api_key
	end,
	get_divisions = function()
		return "https://api.groupon.com/v2/divisions.json?show=all&client_id="..api_key
	end,
	deal_details = function(deal_id)
		assert(deal_id ~= nil,"deal_id is a required parameter")
		
		return "https://api.groupon.com/v2/deals/"..deal_id..".json?show=all&client_id="..api_key
	end,
	deal_posts = function(deal_id)
		assert(deal_id ~= nil,"deal_id is a required parameter")
		
		return "https://api.groupon.com/v2/deals/"..deal_id.."/posts.json?show=all&client_id="..api_key
	end,
	all_deals = function(division_id,area,lat,lng,radius)
		
		local url = "https://api.groupon.com/v2/deals.json?show=all&client_id="..api_key
		
		--[[ FROM THE API DOCUMENTATION:
		
		    * The API will attempt to determine which division's deals to return
				by examining the following values in the following order:
				
				o The division_id parameter
				o The lat, lng and radius parameters
				o The IP address in the X-Forwarded-For header with optional radius parameter
				o The regular client IP address with optional radius parameter
				
			* If any of these values is present but does not match a division, the
				API will return a "Invalid division" 400 response.
		--]]
		
		--first method
		if division_id then
			url = url.."&division_id="..division_id
			if area then
				url = url.."&area="..area
			end
		elseif area then
			error("parameter 'area' cannot be used without the parameter 'division_id'")
		--second method
		elseif lat or lng then
			assert(lat ~= nil and lng ~= nil and radius ~= nil,
				"if using latitude or longitude or radius, all three need to be provided")
			
			url = url.."&lat="..lat.."&lng="..lng.."&radius="..radius
		--fourth method
		elseif radius then
			url = url.."&radius="..radius
		end
		
		return url
	end,
	groupon_says = function(limit,random)
		local url = "https://api.groupon.com/v2/groupon_says.json?show=all&client_id="..api_key
		
		if limit then
			url = url.."&limit="..limit
		end
		if random then
			assert(random == true or random == false or random == "true" or random == "false")
			url = url.."&random="..random
		end
		
		
		return url
	end
}


--dumptable(groupon_api_url_calls)
local make_request = function(api_call,callback,...)
	
	assert(groupon_api_url_calls[api_call] ~= nil,"Tried to make non-existant api call")
	
	local req = URLRequest{
		
		url = groupon_api_url_calls[api_call](...),
		
		timeout = 10,
		
		on_complete = function(self,response_object)
			
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
				
				--print(response_object.body)
				
				local json_response = json:parse(response_object.body)
				
				if json_response == nil or type(json_response) ~= "table" then
					
					error("Unable to parse ResponseObject.body, parse result = "..json_response)
					
				end
				
				--print(json_response, type(json_response))
				
				--dumptable(json_response)
				
				callback(json_response)
				
			end
			
		end
		
	}
	
	print("Sending:"..req.url)
	
	req:send()
end

return make_request