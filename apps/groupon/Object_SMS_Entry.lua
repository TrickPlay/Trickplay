--object
local sms_entry = Group{opacity=0}

local state = ENUM({"HIDDEN","ANIMATING_IN","ACTIVE","SENDING","ANIMATING_OUT"})

local cancel_object = nil
local cursor_index  = 1
local phone_digit_max = 3+3+4
local cursor_base_x = 14
local digit_spacing = 40
local first_digit_x = 219
local deal_url = "failed to set url"
local merchant_name = "failed to set merchant"

local test_f_p = 'At a time when intelligence tells us that terrorists remain interested in attacking transportation, this amendment would cut TSA’s screening workforce by more than 10 percent,” about 5,000 people, said Kristin Lee, an agency spokeswoman.'..
'In a letter to House members before the vote on Rep. John L. Mica’s (R-Fla.) amendment, Colleen M. Kelley, president of the National Treasury Employees Union, said the budget cut would “damage the traveling safety of the public and hurt Transportation Security Officers’ ability to do their jobs."'..
'In February, TSA Administrator John Pistole said he would allow strictly limited collective bargaining for about 44,000 officers, who screen passengers and baggage at the nation’s airports.'

local sms_bg = Clone{ source = assets.info_panel }
sms_entry.h = sms_bg.h
local fine_print_title = Text{
    text="The Fine Print",
    font="DejaVu Sans Condensed Bold 20px",
    color="#484747",
    x = 40,
	y = 20,
}
local fine_print_body = Text{
    text="The Fine Print",
    font="DejaVu Sans Condensed 16px",
    color="#484747",
    --x = fine_print_title.x,
	wrap = true,
	w = 370,
	--y = fine_print_title.y+fine_print_title.h,
}
local fp_clip = Group{
	name = "Clip for Fine Print",
	x = fine_print_title.x,
	y = fine_print_title.y+fine_print_title.h,
	clip = {
		0,
		0,
		fine_print_body.w,
		155
	}
}
fp_clip:add(fine_print_body)

local highlights_title = Text{
    text="Highlights",
    font="DejaVu Sans Condensed Bold 20px",
    color="#484747",
    x = 440,
	y = fine_print_title.y,
}
local highlights_body = Text{
    text="",
    font="DejaVu Sans Condensed 16px",
    color="#484747",
    --x = 440,
	wrap = true,
	w = 300,
	--y = highlights_title.y+highlights_title.h,
}
local hl_clip = Group{
	name = "Clip for Highlights",
	x = highlights_title.x,
	y = highlights_title.y+highlights_title.h,
	clip = {
		0,
		0,
		highlights_body.w,
		fp_clip.clip[4]
	}
}
hl_clip:add(highlights_body)

local entered = Image{
    src = "assets/cell-dark-grey.png",
    x=first_digit_x-6,
    y=345,
    tile={true,false},
    w=0
}

local cursor = Clone{
    source=assets.cell_green,
    x=first_digit_x-6,y=345
}

local prompt = Text{
	text = "Unable to send.",
	font = "DejaVu Sans Condensed 30px",
	color = "#000000",
	opacity=0,
	y     = 270,
    x     = first_digit_x
}

local entry = {}

for i = 1,phone_digit_max do
    entry[i] = Text{
        text  = "",
        font  = "DejaVu Sans Condensed Bold 40px",
        color = "#f4fce9",
        y     = 369,
        x     = first_digit_x+digit_spacing*(i-1)
    }
    entry[i].anchor_point={0,entry[i].h/2}
end

local local_to_mouse, to_mouse_obj

local close_btn = Clone{
    name   = "Close Button",
    source = assets.close_btn,
    x= 56,
    y=432
}
close_btn:move_anchor_point(close_btn.w/2,close_btn.h/2)
function close_btn:on_enter()
    close_btn.source = assets.close_focus
    close_btn.anchor_point = {close_btn.w/2,close_btn.h/2}
    mouse.to_mouse[close_btn.show] = close_btn
    mouse.to_keys[close_btn.hide]  = close_btn
end
function close_btn:on_leave()
    close_btn.source = assets.close_btn
    close_btn.anchor_point = {close_btn.w/2,close_btn.h/2}
    mouse.to_mouse[close_btn.show] = nil
    mouse.to_keys[close_btn.hide]  = nil
end
function close_btn:on_button_up()
    KEY_HANDLER:key_press(keys.BLUE)
    return true
end
local clear_btn = Clone{
    name   = "Clear Button",
    source = assets.clear_btn,
    x= 176,
    y=432
}
clear_btn:move_anchor_point(clear_btn.w/2,clear_btn.h/2)

function clear_btn:on_button_up()
    KEY_HANDLER:key_press(keys.YELLOW)
    return true
end
function clear_btn:on_enter()
    clear_btn.source = assets.clear_focus
    clear_btn.anchor_point = {clear_btn.w/2,clear_btn.h/2}
    mouse.to_mouse[clear_btn.show] = clear_btn
    mouse.to_keys[clear_btn.hide]  = clear_btn
end
function clear_btn:on_leave()
    clear_btn.source = assets.clear_btn
    clear_btn.anchor_point = {clear_btn.w/2,clear_btn.h/2}
    mouse.to_mouse[clear_btn.show] = nil
    mouse.to_keys[clear_btn.hide]  = nil
end

local num_pad = Clone{
    source = assets.hor_num_pad,
    x=291,
    y=403,
}
local num_hl = Clone{
    source = assets.hor_num_hl,
    x=291,
    y=422,
}
num_hl:move_anchor_point(num_hl.w/2,num_hl.h/2)
num_hl:hide()
function num_pad:on_enter()
    num_hl:show()
    --local_to_mouse = num_hl
    mouse.to_mouse[num_hl.show] = num_hl
    mouse.to_keys[num_hl.hide]  = num_hl
end
function num_pad:on_leave()
    num_hl:hide()
    --local_to_mouse = nil
    mouse.to_mouse[num_hl.show] = nil
    mouse.to_keys[num_hl.hide]  = nil
end
--contain the upvals
do
    
    local num_pad_x = num_pad.x
    
    local hover_i
    
    function num_pad:on_motion(x,y)
        
        hover_i = math.floor((x-num_pad_x-40)/40)
        
        if     hover_i <  1 then hover_i =  1
        
        elseif hover_i > 10 then hover_i = 10 end
        
        num_hl.x = num_pad_x + 40*( hover_i )
        
    end
    
    function num_pad:on_button_up(x,y)
        
        if hover_i > 9 then
            
            KEY_HANDLER:key_press(keys["0"])
            
        else
            
            KEY_HANDLER:key_press(keys[""..hover_i])
            
        end
        
    end
end
local submit_button = Clone{
	source = assets.submit_btn,
	x = 627,
	y = 335
}
local submit_button_focus = Clone{
	source = assets.submit_glow,
	x = 627,
	y = 335,
}
submit_button_focus:hide()
function submit_button:on_enter()
    submit_button_focus:show()
    local_to_mouse = submit_button_focus
    mouse.to_mouse[submit_button_focus.show] = submit_button_focus
    mouse.to_keys[submit_button_focus.hide]  = submit_button_focus
end
function submit_button:on_leave()
    submit_button_focus:hide()
    mouse.to_mouse[submit_button_focus.show] = nil
    mouse.to_keys[submit_button_focus.hide]  = nil
end
function submit_button:on_button_up()
    KEY_HANDLER:key_press(keys.OK)
end
local submit_button_shadow = Text{
	text  = "Send",
	font  = "DejaVu Condensed Bold 22px",
	color = "#000000",
	opacity = 255*.5,
	x = submit_button.x + submit_button.w/2 + 1,
	y = submit_button.y + submit_button.h/2 + 1,
}
local submit_button_text = Text{
	text = "Send",
	font = "DejaVu Condensed Bold 22px",
	color = "#ffffff",
	x = submit_button.x + submit_button.w/2,
	y = submit_button.y + submit_button.h/2,
}
submit_button_shadow.anchor_point = {submit_button_shadow.w/2,submit_button_shadow.h/2}
submit_button_text.anchor_point   = {submit_button_text.w/2,  submit_button_text.h/2}

sms_entry:add(
	sms_bg,
	fine_print_title,
	fp_clip,
	highlights_title,
	hl_clip,
	entered,
	cursor,
	prompt,
    close_btn,
    clear_btn,
    num_pad,
    num_hl,
	submit_button,
	submit_button_focus,
	submit_button_shadow,
	submit_button_text
)
sms_entry:add(unpack(entry))

sms_entry.anchor_point = {sms_bg.w/2,0}

local reset_form = function()
    for i = 1,phone_digit_max do
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
	prompt.opacity = 0
    entered.w = 0
    cursor.x = first_digit_x-6
    cursor.opacity=255
    cursor_index=1
	
	submit_button_focus:hide()
end

local sms_callback = function(sms_result)
	
    cancel_object = nil
	
	
	dumptable(sms_result)
    
    --local zip_info = json:parse(response_object.body)
    ---[[
    if sms_result.session == nil then
		error("unexpected response from tropo")
	elseif sms_result.session.success ~= "true" then
        
        print("failed")
        
        reset_form()
		prompt.opacity = 255
		
		state:change_state_to("ACTIVE")
		
    else
        
		App_State.rolodex.cards[App_State.rolodex.top_card]:sent()
		
        state:change_state_to("ANIMATING_OUT")
        
        --App_State.state:change_state_to("LOADING")
        
    end
end

local add_number = function(num)
    
    if state.current_state() ~= "ACTIVE" then return end
    
    if cursor_index<1 or cursor_index > phone_digit_max then return end
	
    entry[cursor_index].text = num
    cursor_index = cursor_index + 1
    
    entered.w = assets.cell_dark.w*(cursor_index-1)
    cursor.x = first_digit_x-6+digit_spacing*(cursor_index-1)
    if cursor_index == phone_digit_max+1 then
        
        cursor.opacity = 0
		submit_button_focus:show()
        --state:change_state_to("SENDING")
    end
end

--terminal animations
local start_y
local animate_in = function(self,msecs,p)
	
    self.y = start_y-self.h*p
    if p == 1 then
        state:change_state_to("ACTIVE")
    end
end
local animate_out = function(self,msecs,p)
    --self.opacity = 255*(1-p)
	self.y = start_y-self.h*(1-p)
    if p == 1 then
        state:change_state_to("HIDDEN")
		sms_entry:unparent()
    end
end

local fine_print_h
local clip_h = fp_clip.clip[4]
local speed = 5
local hl_elapsed, fp_elapsed = 0, 0

sms_entry.fp_scroll_down = function(self,msecs,p)
	fp_elapsed = fp_elapsed + msecs
	--print(1)
	if fp_elapsed < 5000 then return end
	--print(2)
	fine_print_body.y = fine_print_body.y - speed*msecs/1000
	if fine_print_body.y < (clip_h - fine_print_h) then
		fine_print_body.y = (clip_h - fine_print_h)
		fp_elapsed = 0
		Idle_Loop:remove_function(sms_entry.fp_scroll_down)
		Idle_Loop:add_function(sms_entry.fp_scroll_up,sms_entry)
	end
end
sms_entry.fp_scroll_up = function(self,msecs,p)
	fp_elapsed = fp_elapsed + msecs 
	if fp_elapsed < 10000 then return end
	fine_print_body.y = fine_print_body.y + 10*speed*msecs/1000
	if fine_print_body.y > 0 then
		fine_print_body.y = 0
		fp_elapsed = 0
		Idle_Loop:remove_function(sms_entry.fp_scroll_up)
		Idle_Loop:add_function(sms_entry.fp_scroll_down,sms_entry)
	end
end

local highlights_h

sms_entry.hl_scroll_down = function(self,msecs,p)
	hl_elapsed = hl_elapsed + msecs
	--print(1)
	if hl_elapsed < 5000 then return end
	--print(2)
	highlights_body.y = highlights_body.y - speed*msecs/1000
	if highlights_body.y < (clip_h - highlights_h) then
		highlights_body.y = (clip_h - highlights_h)
		hl_elapsed = 0
		Idle_Loop:remove_function(sms_entry.hl_scroll_down)
		Idle_Loop:add_function(sms_entry.hl_scroll_up,sms_entry)
	end
end
sms_entry.hl_scroll_up = function(self,msecs,p)
	hl_elapsed = hl_elapsed + msecs 
	if hl_elapsed < 10000 then return end
	highlights_body.y = highlights_body.y + 10*speed*msecs/1000
	if highlights_body.y > 0 then
		highlights_body.y = 0
		hl_elapsed = 0
		Idle_Loop:remove_function(sms_entry.hl_scroll_up)
		Idle_Loop:add_function(sms_entry.hl_scroll_down,sms_entry)
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
		
		submit_button_focus:hide()
		
		cancel_object = SEND_SMS(
			sms_callback,
			merchant_name,
			deal_url,
			entry[ 1].text..
            entry[ 2].text..
            entry[ 3].text..
            entry[ 4].text..
			entry[ 5].text..
            entry[ 6].text..
            entry[ 7].text..
            entry[ 8].text..
            entry[ 9].text..
            entry[10].text
		)
		
		
		Loading_G.opacity = 255
        
        Loading_G.y = 350
        
        Loading_G:raise_to_top()
        
        mouse:raise_to_top()
        
        Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
		
		--[[
        assert(App_State.state:current_state() == "ROLODEX")
        App_State.state:change_state_to("LOADING")
        
        cursor.opacity = 0
        prompt.text = "Geocoding"
        
        prompt.anchor_point = {
            prompt.w+40,
            prompt.h/2
        }
        
        GET_LAT_LNG(
            entry[1].text..
            entry[2].text..
            entry[3].text..
            entry[4].text..
            entry[5].text,
            
            lat_lng_callback
        )--]]
    end,
    nil,
    "SENDING"
)
state:add_state_change_function(
    function(prev_state,new_state)
        Idle_Loop:add_function(Loading_G.fade_out,Loading_G,500)
    end,
    "SENDING",
    nil
)
local card = nil

local to_keys

local to_mouse = function()
    
    submit_button.reactive = true
    
    close_btn.reactive = true
    close_btn.opacity  = 255
    close_btn:on_leave()
    
    clear_btn.reactive = true
    clear_btn.opacity  = 255
    clear_btn:on_leave()
    
    num_pad.reactive   = true
    num_pad.opacity    = 255
    --num_pad:on_leave()
    
    mouse.to_keys[to_keys] = true
    
    --if local_to_mouse ~= nil  then local_to_mouse:show() end
    
end

to_keys = function()
    
    submit_button.reactive = false
    
    close_btn.reactive = false
    close_btn.opacity  = 0
    
    clear_btn.reactive = false
    clear_btn.opacity  = 0
    
    num_pad.reactive   = false
    num_pad.opacity    = 0
    
    mouse.to_mouse[to_mouse] = true
    
    --if local_to_mouse ~= nil  then local_to_mouse:hide() end
    
end

state:add_state_change_function(
    function(prev_state,new_state)
		card              = App_State.rolodex.cards[App_State.rolodex.top_card]
        
        card:less_info()
        
		sms_entry.x       = card.w/2
		start_y           = card.title_h
		sms_entry.y       = start_y
		sms_entry.opacity = 255
        
		Idle_Loop:add_function(animate_in,sms_entry,500)
        Idle_Loop:add_function(card.animate_in_sms,card,500)
        
		reset_form()
		
		fine_print_body.text = card.fine_print --test_f_p--
		highlights_body.text = card.highlights
		deal_url             = card.deal_url
		merchant_name        = card.merchant
        card:add(sms_entry)
		sms_entry:lower_to_bottom()
		
		fp_elapsed = 0
		hl_elapsed = 0
		fine_print_h = fine_print_body.h
		highlights_h = highlights_body.h
		fine_print_body.y = 0
		highlights_body.y = 0
		if clip_h < fine_print_h then
			Idle_Loop:add_function(sms_entry.fp_scroll_down,sms_entry)
		end
		if clip_h < highlights_h then
			Idle_Loop:add_function(sms_entry.hl_scroll_down,sms_entry)
		end
        
        if using_keys then
            
            to_keys()
            
        else
            
            to_mouse()
            
        end
        
    end,
    nil,
    "ANIMATING_IN"
)
state:add_state_change_function(
    function(prev_state,new_state)
        if prev_state == "ANIMATING_IN" then
            Idle_Loop:remove_function(animate_in)
			Idle_Loop:remove_function(card.animate_in_sms)
        end
        Idle_Loop:add_function(animate_out,sms_entry,500)
        Idle_Loop:add_function(card.animate_out_sms,card,500)
		Idle_Loop:remove_function(sms_entry.fp_scroll_up)
		Idle_Loop:remove_function(sms_entry.fp_scroll_down)
		Idle_Loop:remove_function(sms_entry.hl_scroll_up)
		Idle_Loop:remove_function(sms_entry.hl_scroll_down)
        
        mouse.to_mouse[to_mouse] = nil
        mouse.to_mouse[to_keys]  = nil
        card:more_info()
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
    --App_State.state:change_state_to("ROLODEX")
end
--[[
local keys_LOADING = {
    [keys.Down] = cancel,
    [keys.Up]   = cancel,
    [keys.RED]  = cancel,
}
--]]
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
	--clear
	[keys.YELLOW] = function()
		--if App_State.rolodex.flipping then return end
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			reset_form()
		end
        
	end,
	--Crossfade zip screen
	[keys.RED] = function()
		--if App_State.rolodex.flipping then return end
		
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
			
		elseif state:current_state() == "SENDING" then
			
			cancel()
			
		end
        
	end,
	--close
	[keys.BLUE] = function()
		--if App_State.rolodex.flipping then return end
		
        --App_State.rolodex.cards[App_State.rolodex.top_card]:get_focus()
        
		if state:current_state() == "ACTIVE" or
            state:current_state() == "ANIMATING_IN" then
            
			state:change_state_to("ANIMATING_OUT")
			
		elseif state:current_state() == "SENDING" then
			
			cancel()
			
		end
        
	end,
	--open
	[keys.OK] = function()
		if App_State.rolodex.flipping then return end
		
		if state:current_state() == "HIDDEN" then
			
			if App_State.rolodex.cards[App_State.rolodex.top_card]:find_child("N/A").opacity == 0 then
				
				state:change_state_to("ANIMATING_IN")
				
			end
            
            --App_State.rolodex.cards[App_State.rolodex.top_card]:lose_focus()
			
		elseif  state:current_state() == "ACTIVE" and
			
            cursor_index == phone_digit_max + 1 then
			
			state:change_state_to("SENDING")
            
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

--KEY_HANDLER:add_keys("LOADING",keys_LOADING)
KEY_HANDLER:add_keys("ROLODEX",keys_ROLODEX)

return sms_entry