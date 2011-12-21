--
-- This file handles all of the weather fetching from Weather Underground

--http://wiki.wunderground.com/index.php/API_-_XML




local fake_it = false
dofile("xml.lua")


local base_url = "http://api.wunderground.com/api/"
local api_key  = "8f3d39338b3a4f8e"
local features = {"forecast7day","conditions"}

local request_url = base_url..api_key

for i,v in ipairs(features) do
	
	request_url = request_url .. "/" .. v
	
end

request_url = request_url .. "/q/"






local RATE_LIMIT  = 5 --queries per minute
--local freq        = 60000/RATE_LIMIT

local queue = {}
local throttle = Timer{
	interval=60000/RATE_LIMIT,
	on_timer=function(self)
		if #queue == 0 then
			self:stop()
			self.is_running = false
		else
			table.remove(queue,1):send()
		end
	end
}
throttle:stop()
throttle.is_running = false
do
	local mt = {}
	
	function mt.__newindex(t,k,v)
		print('gots')
		if throttle.is_running then
			rawset(t,k,v)
		else
			print("send",v.url)
			v:send()
			throttle:start()
			throttle.is_running = true
		end
	end
	
	setmetatable(queue, mt)
end

function lookup_zipcode(zip,callback)
	
	if type(zip) ~= "string" and #zip ~= 5 then error("Invalid Zip",2) end
	
	print("looking up ",zip)
	
	queue[#queue+1] = URLRequest{
		
		encoding="UTF-8", url = request_url..zip..".json",
		
		
		on_complete = function(req,response)
			print("respon")
			if response == nil or response.failed or response.body == nil then
				
				callback("Unable to connect to Weather Underground.")
				
				queue[#queue+1]= req
				
			else
				
				response = json:parse(response.body)
				
				if response == nil then
					
					callback("Unable to connect to Weather Underground.")
					
					queue[#queue+1]= req
					
				else
					
					callback(response)
					
				end
				
			end
			
		end
	}
	
end


--[==[
local Geo_url      = "http://api.wunderground.com/auto/wui/geo/GeoLookupXML/index.xml?query="
local Station_url  = "http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID="
local Alerts_url   = "http://api.wunderground.com/auto/wui/geo/AlertsXML/index.xml?query="
local Forecast_url = "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query="

local RATE_LIMIT  = 20 --queries per minute
--local freq        = 60000/RATE_LIMIT

local queue = {}
local throttle = Timer{
	interval=60000/RATE_LIMIT,
	on_timer=function(self)
		if #queue == 0 then
			self:stop()
			self.is_running = false
		else
			table.remove(queue,1):send()
		end
	end
}
throttle.is_running = false
do
	local mt = {}
	
	function mt.__newindex(t,k,v)
		if throttle.is_running then
			rawset(t,k,v)
		else
			v:send()
			--throttle:start()
			--throttle.is_running = true
		end
	end
	
	setmetatable(queue, mt)
end


local xml_tbl     = {}
local tag_stack   = {}
local curr_field  = nil
local tabled_tags = {}

local traverse = function(parent)
	
	local upper = #tag_stack
	
	if parent then upper = upper - 1 end
	
	curr_field = xml_tbl
	
	for i = 1, upper do
		
		curr_field = curr_field[tag_stack[i]]
		
		if tabled_tags[curr_field] then
			
			curr_field = curr_field[#curr_field]
			
		end
		
	end
	
end

local xml = XMLParser{
	
	encoding="UTF-8",
	
	
	on_start_element = function(self,tag,attr)
		
		traverse(false)
		
		if curr_field[tag] ~= nil then
			
			if tabled_tags[curr_field[tag]] then
				
				table.insert(curr_field[tag],{})
				
			else
				local temp = curr_field[tag]
				
				curr_field[tag] = {}
				
				table.insert(curr_field[tag],temp)
				
				table.insert(curr_field[tag],{})
				
				tabled_tags[curr_field[tag]] = true
			end
			
			table.insert(tag_stack,tag)
			
		else
			
			curr_field[tag] = {}
			
			table.insert(tag_stack,tag)
			
		end
		
	end,
	
	
	on_end_element = function(self,tag)
		
		assert(tag == table.remove(tag_stack))
		
	end,
	
	
	on_character_data = function(self,data)
		
		if string.match(data,"[ \t\n]*(.*)") == "" then return end
		
		traverse(true)
		
		curr_field[ tag_stack[#tag_stack] ] = data
		
	end,
}

--a single 'URLRequest' instance is reused for each request
--local req = URLRequest{encoding="UTF-8"}

local err_occur = function(request,response,callback)
	
	if request.failed or response == nil or response.body == nil then
		
		print("\n\n\nINTERNET ERROR", response.code, response.status,"\n\n")
		
		if response.code == 6 then
			callback(nil,nil,"Connection failed.\n Trying again...")
		end
		
		return true
		
	end
	
	return false
	
end
---[[
function pws_query(loc_tbl,callback)
	
	if fake_it then
						
						
						callback(pws_xml,nil)
			return
		end
	
    local req = URLRequest{
		
		encoding="UTF-8",
		
		url = Station_url..
			loc_tbl.location.nearby_weather_stations.pws.station[1].id,
		
		on_complete = function(self,response)
			
			if err_occur(self,response,callback) then
				
				--dolater(req.send,req)
				req.url = Station_url.. loc_tbl.location.nearby_weather_stations.pws.station[1].id
				
				queue[#queue+1]= req
				
				return
				
			end
			
			xml_tbl = {}
			--print(response.body)
			xml:parse(response.body,true)
			
			callback(xml_tbl,nil)
		end
	}
	
	
	--req:send()
	
    --req:send()
	queue[#queue+1]= req
end
--]]
function geo_query(location,callback)
	
	if fake_it then
		
		callback(pws_xml,nil)
		
		return
	end
	
    local req = URLRequest{
		
		encoding="UTF-8",
		
		url = Geo_url.."\""..location.."\"",
		
		on_complete = function(self,response)
			
			if err_occur(self,response,callback) then
				
				--dolater(req.send,req)
				req.url = Geo_url.."\""..location.."\""
				
				queue[#queue+1]= req
				
				return
				
			end
			
			xml_tbl = {}
			
			xml:parse(response.body,true)
			
			callback(xml_tbl)
			
		end
	}
	
	queue[#queue+1]= req
end
function curr_conditions_query(location,callback)
	
	if fake_it then
		callback(pws_xml,nil)
		return
	end
	
	if type(location) == "table" then
		
		pws_query(location,callback)
		
	else
		
		geo_query(
			location,
			function(loc_tbl)
				if loc_tbl.location ~= nil then
					
					pws_query(loc_tbl,callback)
				else
					
					callback(loc_tbl,nil)
				end
				
			end
		)
	end
	
end


function forecast_query(location,callback)
	
	if fake_it then
		
		callback(nil,fcast_xml)
		
		return
	end
	
	if type(location) == "table" then
		location = location.location.zip
	end
	
    local req = URLRequest{
		
		encoding="UTF-8",
		
		url = Forecast_url.."\""..location.."\"",
		
		on_complete = function(self,response)
			
			if err_occur(self,response,callback) then
				
				--dolater(req.send,req)
				queue[#queue+1]= req
				
				return
				
			end
			
			xml_tbl = {}
			--print(response.body)
			xml:parse(response.body,true)
			
			callback(nil,xml_tbl)
		end
	}
	
	queue[#queue+1]= req
end
--]==]