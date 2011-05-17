App_State.states[STATES.OFFLINE].keys = {}
App_State.states[STATES.LOADING].keys = {}

local r
App_State.states[STATES.ROLODEX ].keys = {
    --Flip Backward
	[keys.Down] = function()
		
		r = screen:find_child("Rolodex")
		
        if not r.flipping then
            
			r:pre_backward_flip()
			
            Idle_Loop:add_function(
                r.flip_backward,
                r,
                1000
            )
			
            r.flipping = true
        end
		
		if Zip.is_up then
			Zip.timer:on_timer()
		end
        
		--dumptable(r.visible_cards)
	end,
	
    --Flip Forward
	[keys.Up] = function()
		
		r = screen:find_child("Rolodex")
		
        if not r.flipping then
            
			r:pre_forward_flip()
			
			Idle_Loop:add_function(
                r.flip_forward,
                r,
                1000
            )
			
            r.flipping = true
        end
		
		if Zip.is_up then
			Zip.timer:on_timer()
		end
        
		--dumptable(r.visible_cards)
	end,
	
	--Flip Forward
	[keys.Red] = function()
		
		r = screen:find_child("Rolodex")
		
        if not r.flipping then
            
			r:pre_forward_flip()
			
			Idle_Loop:add_function(
                r.flip_forward,
                r,
                1000
            )
			
            r.flipping = true
        end
		
		if Zip.is_up then
			Zip.timer:on_timer()
		end
        
		--dumptable(r.visible_cards)
	end,
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