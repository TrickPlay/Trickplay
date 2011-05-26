--object
local zip_entry = Group{opacity=0, x = 185, y =  - 52}

local state = ENUM({"HIDDEN","ANIMATING_IN","ACTIVE","SENDING","ANIMATING_OUT"})

local cancel_object = nil
local cursor_index  = 1
local zip_digit_max = 5
local cursor_base_x = 0
local digit_spacing = 35

local zip_bg = Clone{ source = assets.zip_cells }

--zip_bg.anchor_point = {zip_bg.w/2,0}
---[[
local prompt = Text{
    text="Enter a zip code:",
    font="DejaVu Sans Condensed 18px",
    color="#515b4c",
    y = -25,
	x=17
}
--[[
prompt.anchor_point = {
    prompt.w+10,
    prompt.h/2
}
--]]
local entered = Image{
    src = "assets/cell-dark-grey-small.png",
    x=cursor_base_x,
    --y=10,
    tile={true,false},
    w=0
}

local cursor = Clone{
    source=assets.cell_green_s,
    x=cursor_base_x--,y=10
}

local entry = {}

for i = 1,5 do
    entry[i] = Text{
        text  = "",
        font  = "DejaVu Sans Condensed Bold 30px",
        color = "#f4fce9",
        y     = zip_bg.h/2,
        x     = digit_spacing*i-28
    }
    entry[i].anchor_point={0,entry[i].h/2}
end

zip_entry:add(zip_bg,prompt,entered,cursor)
zip_entry:add(unpack(entry))

--zip_entry.anchor_point = {0,zip_bg.h-10}


local reset_form = function()
    for i = 1,5 do
        entry[i].text=""
    end
    --[[
    if invalid then
        prompt.text="Entered Invalid ZIP"
    else
        prompt.text="Enter a zip code:"
    end
    prompt.anchor_point = {
        prompt.w,
        prompt.h/2
    }
    --]]
    entered.w = 0
    cursor.x = cursor_base_x
    cursor.opacity=255
    cursor_index=1
end

local lat_lng_callback = function(zip_info)
	
    cancel_object = nil
    
    --local zip_info = json:parse(response_object.body)
    
    if zip_info.status ~= "OK" then
        print("not ok")
        prompt.text="Entered Invalid ZIP"
        
        reset_form()
		
		state:change_state_to("ACTIVE")
		--App_State.state:change_state_to("ROLODEX")
    elseif  zip_info.results[1].address_components[
                #zip_info.results[1].address_components
            ].short_name ~= "US" then
        
        print("not US")
        prompt.text="Entered Invalid ZIP"
        
        reset_form()
		
		state:change_state_to("ACTIVE")
		--App_State.state:change_state_to("ROLODEX")
    else
        local lat = zip_info.results[1].geometry.location.lat
        local lng = zip_info.results[1].geometry.location.lng
        
        
        --zip_prompt.opacity=255
        
        --zip_prompt:unparent()
        
        GET_DEALS(Rolodex_Constructor,lat,lng,50)
        
        
        Loading_G.opacity=255
        
        Loading_G:raise_to_top()
        
        Loading_G.x = 450
        
        Loading_G.y = screen_h - 200
        
        Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
        App_State.state:change_state_to("LOADING")
        state:change_state_to("ANIMATING_OUT")
        
        --App_State.state:change_state_to("LOADING")
        
    end
end

local add_number = function(num)
    print(22)
    if state.current_state() ~= "ACTIVE" then return end
    
    assert(cursor_index>0 and cursor_index <= zip_digit_max)
    entry[cursor_index].text = num
	entered.w = assets.cell_dark_s.w*(cursor_index)
    cursor_index = cursor_index + 1
    
    
    
    if cursor_index == zip_digit_max+1 then
        
        
        state:change_state_to("SENDING")
	else
		
		cursor.x = cursor_base_x+digit_spacing*(cursor_index-1)
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
    end
end

--state changes
App_State.state:add_state_change_function(
    function(prev_state,new_state)
        if state:current_state() == "SENDING" then
            state:change_state_to("ANIMATING_OUT")
        end
    end,
    "LOADING",
    nil
)
state:add_state_change_function(
    function(prev_state,new_state)
        assert(App_State.state:current_state() == "ROLODEX")
        
        
        cursor.opacity = 0
        prompt.text = "Geocoding"
        
        
        
        cancel_object = GET_LAT_LNG(
            entry[1].text..
            entry[2].text..
            entry[3].text..
            entry[4].text..
            entry[5].text,
            
            lat_lng_callback
        )
    end,
    nil,
    "SENDING"
)
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(animate_in,zip_entry,500)
        reset_form()
		prompt.text = "Enter a zip code:"
        --zip_entry.y =  -App_State.rolodex.cards[App_State.rolodex.top_card].h
		App_State.rolodex.cards[App_State.rolodex.top_card]:find_child("change location").text = ""
        zip_entry:raise_to_top()--lower_to_bottom()
    end,
    nil,
    "ANIMATING_IN"
)
state:add_state_change_function(
    function(prev_state,new_state)
        if prev_state == "ANIMATING_IN" then
            Idle_Loop:remove_function(animate_in)
        end
        Idle_Loop:add_function(animate_out,zip_entry,500)
    end,
    nil,
    "ANIMATING_OUT"
)

--keys
local cancel = function()
    assert(cancel_object ~= nil)
	--print("pre_cancel")
	TRY_AGAIN:stop()
    cancel_object:cancel()
	--print("post_cancel")
    state:change_state_to("ANIMATING_OUT")
    App_State.state:change_state_to("ROLODEX")
end
local keys_LOADING = {
    [keys.Down] = cancel,
    [keys.Up]   = cancel,
    [keys.RED]  = cancel,
}

local keys_ROLODEX = {
    --Flip Backward closes menu
	[keys.Down] = function()
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
            
		elseif state:current_state() == "SENDING" then
			
			cancel()			
		end
        
	end,
	
    --Flip Forward closes menu
	[keys.Up] = function()
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
			
		elseif state:current_state() == "SENDING" then
			
			cancel()
			
		end
        
	end,
	
	--Toggle screen
	[keys.RED] = function()
		if App_State.rolodex.flipping then return end
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
        elseif state:current_state() == "HIDDEN" then
			state:change_state_to("ANIMATING_IN")
		elseif state:current_state() == "SENDING" then
			cancel()
		end
        
	end,
	[keys.OK] = function()
		--if App_State.rolodex.flipping then return end
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
		end
        
	end,
	[ keys["0"] ] = function() add_number(0) end,
	[ keys["1"] ] = function() add_number(1) end,
	[ keys["2"] ] = function() add_number(2) end,
	[ keys["3"] ] = function() add_number(3) end,
	[ keys["4"] ] = function() add_number(4) end,
	[ keys["5"] ] = function() add_number(5) end,
	[ keys["6"] ] = function() add_number(6) end,
	[ keys["7"] ] = function() add_number(7) end,
	[ keys["8"] ] = function() add_number(8) end,
	[ keys["9"] ] = function() add_number(9) end,
}

KEY_HANDLER:add_keys("LOADING",keys_LOADING)
KEY_HANDLER:add_keys("ROLODEX",keys_ROLODEX)

return zip_entry