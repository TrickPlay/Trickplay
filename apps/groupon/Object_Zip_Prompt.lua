local zip_prompt = Group{opacity=0}

local state = ENUM({"HIDDEN","ANIMATING_IN","ACTIVE","ANIMATING_OUT"})

local timeout = Timer{
    interval = 5000,
    on_timer = function(self)
        state:change_state_to("ANIMATING_OUT")
    end
}
timeout:stop()



local zip_bg = Clone{ source = assets.red_message }

zip_bg.anchor_point = {zip_bg.w/2,0}

local prompt = Text{
    text  = "Change Location:",
    font  = "DejaVu Sans Condensed 20px",
    color = "#000000",
    y     =  zip_bg.h/2,
}
prompt.anchor_point = {
    prompt.w+40,
    prompt.h/2
}

local location = Text{
    name="Location",
    text="",
    font="DejaVu Sans Condensed Bold 24px",
    color="#86ad53",
    x = -30,
    y = zip_bg.h/2,
}
location.anchor_point = {
    0,
    location.h/2
}


zip_prompt.set_city = function(self,t)
    
    local str = ""
    local amt = 0
    for name,num in pairs(t) do
        if num > amt then
            str = name
        end
    end
    
    location.text = str
end

zip_prompt:add(zip_bg,prompt,location)

zip_prompt.anchor_point = {0,zip_bg.h-10}

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
    end
end

--state changes
App_State.state:add_state_change_function(
    function(prev_state,new_state)
        assert(state:current_state() == "HIDDEN")
        state:change_state_to("ANIMATING_IN")
    end,
    "LOADING",
    nil
)
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(animate_in,zip_prompt,500)
        timeout:start()
        zip_prompt.y = -App_State.rolodex.cards[App_State.rolodex.top_card].h
    end,
    nil,
    "ANIMATING_IN"
)
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(animate_out,zip_prompt,500)
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

return zip_prompt