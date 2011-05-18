App_State.states[STATES.OFFLINE].keys = {}
App_State.states[STATES.LOADING].keys = {}

App_State.states[STATES.ROLODEX ].keys = {
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
	
	[keys["0"]] = function() Zip:add_number(0) end,
	[keys["1"]] = function() Zip:add_number(1) end,
	[keys["2"]] = function() Zip:add_number(2) end,
	[keys["3"]] = function() Zip:add_number(3) end,
	[keys["4"]] = function() Zip:add_number(4) end,
	[keys["5"]] = function() Zip:add_number(5) end,
	[keys["6"]] = function() Zip:add_number(6) end,
	[keys["7"]] = function() Zip:add_number(7) end,
	[keys["8"]] = function() Zip:add_number(8) end,
	[keys["9"]] = function() Zip:add_number(9) end,

}
App_State.states[STATES.ZIP  ].keys = {}
App_State.states[STATES.PHONE].keys = {}



--make sure all states
for state_name,state_value in pairs(STATES) do
    assert(
        
        App_State.states[state_value].keys ~= nil,
        
        "State "..state_name.." was not given a key table, update \"User_Input.lua\""
    )
end

--socket to key_handler
do 
    local keys
    
    App_State:add_state_change_function(function(old_state,new_state)
        keys = App_State.states[new_state].keys
    end)
    
    function screen:on_key_down(k)
        if keys[k] then keys[k]() end
    end
end