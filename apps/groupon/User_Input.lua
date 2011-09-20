
--object
local key_handler = {}

--attributes
local key_callbacks = {}

key_handler.add_keys = function(self,state,key_table)
	
	assert(App_State.state:has_state(state), "App_State does not have State "..state)
	
	if key_callbacks[state] == nil then
		
		key_callbacks[state] = {}
		
	end
	
	if key_callbacks[state][key_table] then
		
		error()
		
	else
		
		key_callbacks[state][key_table] = key_table
		
	end
	
end

key_handler.key_press = function(self,k)
    
    if key_callbacks[App_State.state.current_state()] then
		
		for key_table,_ in pairs(key_callbacks[App_State.state.current_state()])do
			
			if key_table[k] then
				
				key_table[k]()
				
			end
			
		end
		
	end
    
end

key_handler.on_key_down = function(self,k)
	
    if not using_keys then
		
		mouse:hide()
		
        for f,o in pairs(mouse.to_keys) do f(o) end
        
		--if mouse.to_keys then mouse.to_keys() end
		
		using_keys = true
		
	end
    
	key_handler:key_press(k)
	
end

return key_handler
--[[
local all_keys={}

all_keys["OFFLINE"] = {}
all_keys["LOADING"] = {}

all_keys["ROLODEX"] = {
    --Flip Backward
	[keys.Down] = function()
		
        if not App_State.rolodex.flipping then
            
			App_State.rolodex:pre_backward_flip()
			
            Idle_Loop:add_function(
                App_State.rolodex.flip_backward,
                App_State.rolodex,
                1000
            )
			
            App_State.rolodex.flipping = true
        end
		
		if Zip.entry_is_up then
			Zip:fade_out_entry()
		elseif Zip.prompt_is_up then
			Zip.timer:on_timer()
		end
		
        
	end,
	
    --Flip Forward
	[keys.Up] = function()
		
        if not App_State.rolodex.flipping then
            
			App_State.rolodex:pre_forward_flip()
			
			Idle_Loop:add_function(
                App_State.rolodex.flip_forward,
                App_State.rolodex,
                1000
            )
			
            App_State.rolodex.flipping = true
        end
		
		if Zip.entry_is_up then
			Zip:fade_out_entry()
		elseif Zip.prompt_is_up then
			Zip.timer:on_timer()
		end
        
		--dumptable(r.visible_cards)
	end,
	
	--Flip Forward
	[keys.RED] = function()
		if App_State.rolodex.flipping then return end
		
		if Zip.entry_is_up then
			if Zip.cancel then Zip:cancel() end
			Zip:fade_out_entry()
		else
			if Zip.prompt_is_up then
				Zip.timer:on_timer()
			end
			Zip:fade_in_entry()
		end
        
		--dumptable(r.visible_cards)
	end,
	
	[keys["0"] ] = function() Zip:add_number(0) end,
	[keys["1"] ] = function() Zip:add_number(1) end,
	[keys["2"] ] = function() Zip:add_number(2) end,
	[keys["3"] ] = function() Zip:add_number(3) end,
	[keys["4"] ] = function() Zip:add_number(4) end,
	[keys["5"] ] = function() Zip:add_number(5) end,
	[keys["6"] ] = function() Zip:add_number(6) end,
	[keys["7"] ] = function() Zip:add_number(7) end,
	[keys["8"] ] = function() Zip:add_number(8) end,
	[keys["9"] ] = function() Zip:add_number(9) end,

}
all_keys["ZIP"] = {}
all_keys["PHONE"] = {}



--make sure all states
for _,state_name in pairs(App_State.state.states()) do
    assert(
        
        all_keys[state_name] ~= nil,
        
        "State "..state_name.." was not given a key table, update \"User_Input.lua\""
    )
end

--socket to key_handler
do 
    local keys
    
    App_State.state:add_state_change_function(function(old_state,new_state)
        keys = all_keys[new_state]
    end)
    
    function screen:on_key_down(k)
        if keys[k] then keys[k]() end
    end
end
--]]