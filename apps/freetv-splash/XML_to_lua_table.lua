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


return function(xml_string)
    
	--print("STRANG",xml_string)
    xml_tbl = {}
    
    xml:parse(xml_string,true)
    	
    return xml_tbl
    
end