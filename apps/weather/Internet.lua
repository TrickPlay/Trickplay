--
-- This file handles all of the weather fetching from Weather Underground

--http://wiki.wunderground.com/index.php/API_-_XML





local base_url = "http://api.wunderground.com/api/"
local api_key  = "8f3d39338b3a4f8e"
local features = {"forecast7day","conditions"}

local request_url = base_url..api_key

for i,v in ipairs(features) do
	
	request_url = request_url .. "/" .. v
	
end

request_url = request_url .. "/q/"






local req
local RATE_LIMIT  = 10 --queries per minute
--local freq        = 60000/RATE_LIMIT

local queue = {}
local throttle = Timer{
	interval=60000/RATE_LIMIT,
	on_timer=function(self)
		if #queue == 0 then
			self:stop()
			self.is_running = false
		else
			req = table.remove(queue,1)
			req.cancel_obj = req:send()
		end
	end
}
throttle:stop()
throttle.is_running = false
do
	local mt = {}
	
	function mt.__newindex(t,k,v)
		
		if throttle.is_running then
			rawset(t,k,v)
		else
			
			v:send()
			throttle:start()
			throttle.is_running = true
		end
	end
	
	setmetatable(queue, mt)
end

local notify_of_failure = function()
	for i,req in ipairs(queue)do
		req:notify_of_failure()
	end
end
function lookup_zipcode(zip,callback)
	
	if type(zip) ~= "string" and #zip ~= 5 then error("Invalid Zip",2) end
	
	
	req = URLRequest{
		
		encoding="UTF-8", url = request_url..zip..".json",
		
		
		on_complete = function(req,response)
			
			req.cancel_obj = nil
			
			if response == nil or response.failed or response.body == nil then
				
				queue[#queue+1]= req
				
				notify_of_failure()
				
			else
				
				response = json:parse(response.body)
				
				if response == nil then
					
					queue[#queue+1]= req
					
					notify_of_failure()
					
				else
					
					callback(response)
					
				end
				
			end
			
		end,
	}
	req.notify_of_failure = function(req)
		
		callback("Unable to connect to Weather Underground.")
		
	end
	
	req.cancel = function(req)
		
		if req.cancel_obj then
			req.cancel_obj:cancel()
			return true
		else
			for i,r in ipairs(queue) do
				if req == r then
					table.remove(queue,i)
					return true
				end
			end
		end
		return false
	end
	
	queue[#queue+1] = req
	
	return req
	--queue[#queue].notify_of_failure = function(req)
	--	
	--	callback("Unable to connect to Weather Underground.")
	--	
	--end
end












