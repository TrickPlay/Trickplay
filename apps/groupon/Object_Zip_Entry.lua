--object
local top_bg = Clone{ source = assets.zip_entry_top }

local btm_bg = Clone{ source = assets.zip_entry_btm, y = 81 }

local zip_entry = Group{name="Zip Entry", x = 380, y = 347}

local state = ENUM({"HIDDEN","ANIMATING_IN","ACTIVE","SENDING","ANIMATING_OUT"})

local mouse_on = nil
local cancel_object = nil
local cursor_index  = 1
local zip_digit_max = 5
local cursor_base_x = 96
local digit_spacing = 50

--local zip_bg = Clone{ source = assets.zip_cells }

--zip_bg.anchor_point = {zip_bg.w/2,0}
---[[
local prompt = Text{
    text="Enter a zip code:",
    font="DejaVu Sans Condensed Bold 20px",
    color="#86ad53",
    y = 15,
	x = top_bg.w/2
}
prompt.anchor_point={prompt.w/2,0}
prompt:move_anchor_point(prompt.w/2,prompt.h/2)

local cursor = Clone{
    source=assets.cell_green,
    x=cursor_base_x,
    y=44
}

local x_btn = Clone{
    source  = assets.x,
    x       = 410,
    y       =   3,
    opacity =   0
}
function x_btn:on_enter()
    x_btn.opacity=255
    mouse_on = x_btn
end
function x_btn:on_leave()
    x_btn.opacity=0
    mouse_on = nil
end

function x_btn:on_button_up()
    KEY_HANDLER:key_press(keys.RED)
    return true
end

local entry = {}
local entered = {}

for i = 1,5 do
    entered[i] = Clone{
        source = assets.cell_dark,
        y     = 44,
        x     = digit_spacing*(i-1)+cursor_base_x
    }
    entered[i]:hide()
    entry[i] = Text{
        text  = "",
        font  = "DejaVu Sans Condensed Bold 30px",
        color = "#f4fce9",
        y     = 67,
        x     = digit_spacing*(i-1)+114
    }
    entry[i].anchor_point = {entry[i].w/2,entry[i].h/2}
end




local num_hl = Clone{
    name="number_highlight",
    source = assets.hor_num_hl,
    x=0,
    y=102,
}
num_hl:move_anchor_point(num_hl.w/2,num_hl.h/2)
num_hl:hide()

zip_entry:add(top_bg,btm_bg,prompt,cursor,x_btn,num_hl)
zip_entry:add(unpack(entered))
zip_entry:add(unpack(entry))

function btm_bg:on_enter()
    num_hl:show()
    --local_to_mouse = num_hl
    mouse.to_mouse[num_hl.show] = num_hl
    mouse.to_keys[num_hl.hide]  = num_hl
end
function btm_bg:on_leave()
    num_hl:hide()
    --local_to_mouse = nil
    mouse.to_mouse[num_hl.show] = nil
    mouse.to_keys[num_hl.hide]  = nil
end
--contain the upvals
do
    
    local num_pad_x = 830
    
    local hover_i
    
    function btm_bg:on_motion(x,y)
        
        hover_i = math.floor((x-num_pad_x+20)/40)
        
        if     hover_i <  1 then hover_i =  1
        
        elseif hover_i > 10 then hover_i = 10 end
        
        num_hl.x = 40*( hover_i )+4
        
    end
    
    function btm_bg:on_button_up(x,y)
        
        if hover_i > 9 then
            
            KEY_HANDLER:key_press(keys["0"])
            
        else
            
            KEY_HANDLER:key_press(keys[""..hover_i])
            
        end
        
    end
end





--zip_entry.anchor_point = {0,zip_bg.h-10}


local reset_form = function()
    for i = 1,5 do
        entry[i].text=""
        entered[i]:hide()
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
    cursor.x = cursor_base_x
    cursor.opacity=255
    cursor_index=1
end

local lat_lng_callback = function(zip_info)
	
    cancel_object = nil
    
    --local zip_info = json:parse(response_object.body)
    
    if zip_info.status ~= "OK" or
        zip_info.results[1].address_components[
                #zip_info.results[1].address_components
            ].short_name ~= "US" then
        
        print("not US")
        prompt.text="Entered Invalid ZIP"
        prompt.anchor_point = {prompt.w/2,prompt.h/2}
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
        
        Loading_G.x = 450
        
        Loading_G.y = screen_h - 200
        
        Loading_G:raise_to_top()
        
        mouse:raise_to_top()
        
        Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
        App_State.state:change_state_to("LOADING")
        state:change_state_to("ANIMATING_OUT")
        
        --App_State.state:change_state_to("LOADING")
        
    end
end

local add_number = function(num)
    
    if state.current_state() ~= "ACTIVE" then return end
    
    assert(cursor_index>0 and cursor_index <= zip_digit_max)
    entry[cursor_index].text = num
    entry[cursor_index].anchor_point = {entry[cursor_index].w/2,entry[cursor_index].h/2}
	
    entered[cursor_index]:show()
    --entered.w = assets.cell_dark_s.w*(cursor_index)
    cursor_index = cursor_index + 1
    
    
    
    if cursor_index == zip_digit_max+1 then
        
        state:change_state_to("SENDING")
        
	else
		
		cursor.x = cursor_base_x+digit_spacing*(cursor_index-1)
        
    end
end

local to_keys = function()
    btm_bg:hide()
    if mouse_on then mouse_on.opacity=0 end
    x_btn:show()
    x_btn.opacity=255
end
local to_mouse = function()
    x_btn.opacity=0
    btm_bg:show()
    if mouse_on then mouse_on.opacity=255 end
end



--terminal animations
local x_pos = Interval(780-top_bg.w,780)
local animate_in = function(self,msecs,p)
    self.x = x_pos:get_value(p)
    if p == 1 then
        state:change_state_to("ACTIVE")
    end
end
local animate_out = function(self,msecs,p)
    self.x = x_pos:get_value(1-p)
    if p == 1 then
		self:unparent()
        App_State.rolodex.cards[
            
            App_State.rolodex.top_card
            
        ]:find_child("change location").text = "Change location"
        
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
        
        prompt.text    = "Geocoding"
        prompt.anchor_point = {prompt.w/2,prompt.h/2}
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
        x_btn.reactive = true
        btm_bg.reactive = true
        mouse_on = nil
        mouse.to_mouse[to_mouse] = true
        mouse.to_keys[to_keys] = true
        if using_keys then
            to_keys()
        else
            to_mouse()
        end
		prompt.text = "Enter a zip code:"
        prompt.anchor_point = {prompt.w/2,prompt.h/2}
        --zip_entry.y =  -App_State.rolodex.cards[App_State.rolodex.top_card].h
		--App_State.rolodex.cards[App_State.rolodex.top_card]:find_child("change location").text = ""
        App_State.rolodex.cards[App_State.rolodex.top_card]:fade_out_change_locs()
        --lower_to_bottom()
        --App_State.rolodex.cards[App_State.rolodex.top_card]:raise_to_top()
        App_State.rolodex.cards[App_State.rolodex.top_card]:add(zip_entry)
        zip_entry:lower_to_bottom()
    end,
    nil,
    "ANIMATING_IN"
)
state:add_state_change_function(
    function(prev_state,new_state)
        if prev_state == "ANIMATING_IN" then
            Idle_Loop:remove_function(animate_in)
        end
        x_btn.reactive = false
        btm_bg.reactive = false
        mouse.to_mouse[to_mouse] = nil
        mouse.to_keys[to_keys] = nil
        Idle_Loop:add_function(animate_out,zip_entry,500)
        App_State.rolodex.cards[App_State.rolodex.top_card]:fade_in_change_locs()
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