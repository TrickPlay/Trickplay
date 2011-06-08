local obj = Group{opacity=0}

--VISUAL DATA
local bg = Image{
    src = "assets/message-center.png"
}

local title = Text{
    text  = "Default Title",
    font  = "DejaVu Condensed Bold 32px",
    color = "e8e8e8",
    x     = bg.w/2,
    y     = bg.h/2,
}


local message = Text{
    text  = "Default Title",
    font  = "DejaVu Condensed 32px",
    color = "e8e8e8",
    x     = bg.w/2,
    y     = bg.h/2,
}


obj:add(bg,title,sub_title,message)

obj.anchor_point = {bg.w/2,bg.h/2}

obj.position = {screen_w/2,screen_h/2}

--FUNCTIONS
function obj:set_fields(t)
    title.text   = t.title
    message.text = t.message
    
    if t.message == "" then
        title.anchor_point   = {title.w/2,  title.h/2}
        --message.anchor_point = {message.w/2,0}
    else
        title.anchor_point   = {title.w/2,  title.h+15}
        message.anchor_point = {message.w/2,5}
    end
    
end

function obj:focus_in()
    
    self:complete_animation()
    
    self:animate{
        
        duration = TRANS_DUR/2,
        
        opacity  = 255,
        
        on_completed = KEY_HANDLER.release,
        
    }
    
end

function obj:focus_out()
    
    self:complete_animation()
    
    self:animate{
        
        duration = TRANS_DUR/2,
        
        opacity  = 0,
        
        on_completed = KEY_HANDLER.release,
        
    }
    
end

--STATE CHANGES
obj.prev_state = "NIL"

GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		obj.prev_state = prev_state
        obj:focus_in()
	end,
	nil,
	"MODAL_MENU"
)
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
        obj:focus_out()
	end,
	"MODAL_MENU",
    nil
)

--KEYS
local keys = {
    [keys.OK] = function()
		
        KEY_HANDLER.hold()
		
		GLOBAL_STATE:change_state_to(obj.prev_state)
        
	end,
}

KEY_HANDLER:add_keys("MODAL_MENU",keys)

return obj