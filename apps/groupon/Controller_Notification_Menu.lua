local state = ENUM({"HIDDEN","ANIMATING_IN","ACTIVE","ANIMATING_OUT"})

local timeout = Timer{
    interval = 5000,
    on_timer = function(self)
        state:change_state_to("ANIMATING_OUT")
    end
}
timeout:stop()

local prompt = Clone{ source = assets.controller, opacity = 0 }
local first_time = true
prompt.anchor_point = {prompt.w/2,prompt.h+20}

function prompt:display_controller()
    
    prompt.source = assets.control_mmr
    
    if state:current_state() == "HIDDEN" or  state:current_state() == "ANIMATING_OUT" then
        if not first_time then state:change_state_to("ANIMATING_IN") end
    else
        timeout:start()
    end
end

--terminal animations
local animate_in = function(self,msecs,p)
    self.opacity = 255*(p)
    if p == 1 then
        state:change_state_to("ACTIVE")
    end
end
local animate_out = function(self,msecs,p)
    self.opacity = 255*(1-p)
    if p == 1 then
        state:change_state_to("HIDDEN")
		prompt:unparent()
    end
end

---[[
--state changes


App_State.state:add_state_change_function(
    
	function(prev_state,new_state)
		
		if first_time then
			
			assert(state:current_state() == "HIDDEN")
			
			state:change_state_to("ANIMATING_IN")
			
			first_time = false
			
		end
		
    end,
    
	"LOADING",
    
	nil
	
)
--]]
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(animate_in,prompt,500)
        timeout:start()
        prompt.x = App_State.rolodex.cards[App_State.rolodex.top_card].w/2
		App_State.rolodex.cards[App_State.rolodex.top_card]:add(prompt)
		prompt:lower_to_bottom()
    end,
    nil,
    "ANIMATING_IN"
)
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(animate_out,prompt,500)
        timeout:stop()
    end,
    nil,
    "ANIMATING_OUT"
)


local keys_ROLODEX = {
    --Flip Backward closes menu
	[keys.Down] = function()
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
		end
        
	end,
	
    --Flip Forward closes menu
	[keys.Up] = function()
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
		end
        
	end,
	
	--Toggle screen
	[keys.RED] = function()
        
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
		end
        
	end,
    [keys.OK] = function()
		--if App_State.rolodex.flipping then return end
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
		end
        
	end,
}

KEY_HANDLER:add_keys("ROLODEX",keys_ROLODEX)

return prompt