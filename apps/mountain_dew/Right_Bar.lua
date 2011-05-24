local right_bar = Group{name = "RIGHT BAR"}

local bg = Image{src = "assets/right/all.png"}


local selector_old = Image{src = "assets/right/focus.png",x=bg.w/2+24}
selector_old.anchor_point = {selector_old.w/2,selector_old.h}
selector_old.opacity = 0

local selector_new = Clone{source = selector_old,opacity = 0,x=bg.w/2+24}
selector_new.anchor_point = {selector_new.w/2,selector_new.h}

local buttons = {
    950,
    1026
}

local curr_focus = 1

right_bar.focus_out = function(self,index,duration)
    
    assert(index > 0 and index <= #buttons)
    
    selector_old.y = buttons[index]
    
    selector_old:complete_animation()
    
    selector_old.opacity = 255
    
    selector_new.opacity = 0
    
    selector_old:animate{
        duration = duration,
        mode     = "EASE_OUT_CIRC",
        opacity  = 0
    }
    
end

right_bar.focus_in = function(self,index,duration)
    
    assert(index > 0 and index <= #buttons)
    
    selector_new.y = buttons[index]
    
    selector_new:complete_animation()
    
    selector_new:animate{
        duration = duration,
        mode     = "EASE_OUT_CIRC",
        opacity  = 255,
		on_completed = KEY_HANDLER.release
    }
    
end
right_bar.prev_state = "NIL"
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		right_bar.prev_state = prev_state
        right_bar:focus_in(curr_focus,TRANS_DUR)
	end,
	nil,
	"RIGHT_BUTTONS"
)
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
        right_bar:focus_out(curr_focus,TRANS_DUR)
	end,
	"RIGHT_BUTTONS",
    nil
)
local keys = {
    [keys.Up] = function()
        if curr_focus > 1 then
            
			KEY_HANDLER.hold()
			
            right_bar:focus_out(curr_focus,TRANS_DUR)
            
            curr_focus = curr_focus - 1
            
            right_bar:focus_in(curr_focus,TRANS_DUR)
            
        end
    end,
    [keys.Down] = function()
        if curr_focus < #buttons then
            
			KEY_HANDLER.hold()
			
            right_bar:focus_out(curr_focus,TRANS_DUR)
            
            curr_focus = curr_focus + 1
            
            right_bar:focus_in(curr_focus,TRANS_DUR)
            
        end
    end,
    [keys.Left] = function()
        
		KEY_HANDLER.hold()
		
		GLOBAL_STATE:change_state_to(right_bar.prev_state)
		
    end
}

KEY_HANDLER:add_keys("RIGHT_BUTTONS",keys)

right_bar:add(bg,logo,selector_old,selector_new)

right_bar.x = screen_w - bg.w

return right_bar