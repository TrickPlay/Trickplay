
local function make_button_animations(unfocus_fades,unfocused,focused,passive)
    
    if type(passive) == "userdata" then
        
        return AnimationState{
            duration = 300,
            transitions = {
                {
                    source = "*",          target = "UNFOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity",   0},
                            {passive,   "opacity",   0},
                            {unfocused, "opacity", 255},
                        } or {
                            {focused,   "opacity",   0},
                            {passive,   "opacity",   0},
                        }
                },
                {
                    source = "*",        target = "FOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity", 255},
                            {passive,   "opacity",   0},
                            {unfocused, "opacity",   0},
                        } or {
                            {focused,   "opacity", 255},
                            {passive,   "opacity",   0},
                        }
                },
                {
                    source = "*",        target = "PASSIVE_FOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity",   0},
                            {passive,   "opacity", 255},
                            {unfocused, "opacity",   0},
                        } or {
                            {focused,   "opacity",   0},
                            {passive,   "opacity", 255},
                        }
                },
            }
        }
        
    elseif type(passive) == "number" then
        
        return AnimationState{
            duration = 300,
            transitions = {
                {
                    source = "*",          target = "UNFOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity",   0},
                            {unfocused, "opacity", 255},
                        } or {
                            {focused,   "opacity",   0},
                        }
                },
                {
                    source = "*",        target = "FOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity", 255},
                            {unfocused, "opacity",   0},
                        } or {
                            {focused,   "opacity", 255},
                        }
                },
                {
                    source = "*",        target = "PASSIVE_FOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity", passive*255},
                            {unfocused, "opacity",           0},
                        } or {
                            {focused,   "opacity", passive*255},
                        }
                },
            }
        }
        
    else
        
        return AnimationState{
            duration = 300,
            transitions = {
                {
                    source = "FOCUSED",          target = "UNFOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity",   0},
                            {unfocused, "opacity", 255},
                        } or {
                            {focused,"opacity",0},
                        }
                },
                {
                    source = "UNFOCUSED",        target = "FOCUSED", duration = 300,
                    keys = unfocus_fades and
                        {
                            {focused,   "opacity", 255},
                            {unfocused, "opacity",   0},
                        } or {
                            {focused,"opacity", 255},
                        }
                },
            }
        }
        
    end
    
end

local function make_button(t)
    
    if type(t.clone)           ~= "boolean"  then error("must give boolean  for 'clone'",           2) end
    if type(t.unfocus_fades)   ~= "boolean"  then error("must give boolean  for 'unfocus_fades'",   2) end
    if type(t.unfocused_image) ~= "userdata" then error("must give userdata for 'unfocused_image'", 2) end
    if type(t.focused_image)   ~= "userdata" then error("must give userdata for 'focused_image'",   2) end
    
    
    local button = Group{}
    
    
    local passive   = (clone and type(t.passive) == "userdata") and
        Clone{source = t.passive} or t.passive
        
    local focused   = t.clone and Clone{source =   t.focused_image} or   t.focused_image
    local unfocused = t.clone and Clone{source = t.unfocused_image} or t.unfocused_image
    
    button:add(
        unfocused,
        focused
    )
    
    if type(passive) == "userdata" then button:add(passive) end
    
    if t.text then
        
        local text = Text{
            text   = type(t.text) == "string" and t.text or error("text must be a string",2),
            font   = t.font  or error("if you give buttons a text, its going to want a font",2),
            color  = t.color or error("if you give buttons a text, its going to want a color",2),
        }
        text.anchor_point = {text.w/2,text.h/2}
        text.position     = {focused.w/2,focused.h/2}
        
        button:add(text)
        
    end
    
    focused.opacity = 0
    if type(passive) == "userdata" then passive.opacity = 0 end
    
    local animation = make_button_animations(t.unfocus_fades,unfocused,focused,passive)
    
    animation.state = "UNFOCUSED"
    
    function button:set_state(new_state)
        
        if     new_state == "FOCUSED" then
            
            if self.is_visible == false then return false end
            
            animation.state = "FOCUSED"
            
            return true
            
        elseif new_state == "UNFOCUSED" then
            
            animation.state = "UNFOCUSED"
            
        elseif new_state == "PASSIVE_FOCUSED" then
            
            animation.state = passive and "PASSIVE_FOCUSED" or "UNFOCUSED"
            
        else
            
            error("received invalid state",2)
            
        end
        
    end
    
    button.select = t.select_function or error("no select function given",2)
    
    return button
    
end

return make_button