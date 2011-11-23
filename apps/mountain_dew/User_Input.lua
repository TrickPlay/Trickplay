--object
local key_handler = {}

local hold = false

key_handler.hold    = function() hold = true  end
key_handler.release = function() hold = false end

--attributes
local key_callbacks = {}
key_handler.add_keys = function(self,state,key_table)
	
	assert(GLOBAL_STATE:has_state(state), "App_State does not have State "..state)
	
	if key_callbacks[state] == nil then
		
		key_callbacks[state] = {}
		
	end
	
	if key_callbacks[state][key_table] then
		
		error()
		
	else
		
		key_callbacks[state][key_table] = key_table
		
	end
	
end

key_handler.on_key_down = function(self,k)
	
    if hold then return end
    
	if key_callbacks[GLOBAL_STATE.current_state()] then
		
		for key_table,_ in pairs(key_callbacks[GLOBAL_STATE.current_state()])do
			
			if key_table[k] then
				
				key_table[k]()
				
			end
			
		end
		
	end
	
end

return key_handler, hold_keys