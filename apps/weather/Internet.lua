--
-- This file handles all of the weather fetching from Weather Underground

--http://wiki.wunderground.com/index.php/API_-_XML

local Geo_url      = "http://api.wunderground.com/auto/wui/geo/GeoLookupXML/index.xml?query="
local Station_url  = "http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID="
local Alerts_url   = "http://api.wunderground.com/auto/wui/geo/AlertsXML/index.xml?query="
local Forecast_url = "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query="

--a single 'URLRequest' instance is reused for each request
local req = URLRequest{encoding="UTF-8"}
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
			curr_field--[[ [tag_stack[#tag_stack] ] ]][tag] = {}
			table.insert(tag_stack,tag)
		end
	end,
	on_end_element = function(self,tag)

		assert(tag == table.remove(tag_stack))

		if tag == "location" then
			--dumptable(xml_tbl)
			print("parsed")
			--self:finish()
		end
	end,
	
	on_character_data = function(self,data)
		
		local t = string.match(data,"[ \t\n]*(.*)")
		
		if t == "" then return end
		
		traverse(true)
		
		curr_field[ tag_stack[#tag_stack] ] = data
		
	end,
}

function xml_to_tbl(str)
	xml_tbl={}
	xml:parse(str,true)
	
end

local geo_callback = function(req,response)
	print("received")
    xml_to_tbl(response.body)
	print("back")
end



function lookup(location)
    
    req.url         = Geo_url.."\""..location.."\""
    req.on_complete = geo_callback
    req:send()
    print("sent",req.url)
end
