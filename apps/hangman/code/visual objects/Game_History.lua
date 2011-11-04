
local game_hist = Group{name = "Game History", x = 100, y = 750}

local make_frame
local loaded = false

local function make_flash_text_animation(object)
    
    local animation = {}
    
    local up = Animator{
        duration   = 250,
        properties = {
            {
                source = object, name   = "color",
                keys   = {
                    {0.0,"LINEAR",       object.color},
                    {1.0,"EASE_IN_QUAD",{255,255,255}},
                }
            },
            {
                source = object, name   = "scale",
                keys   = {
                    {0.0,       "LINEAR",{1,  1  }},
                    {1.0,"EASE_IN_CUBIC",{1.2,1.2}},
                }
            },
        }
        
    }
    local dn = Animator{
        duration   = 250,
        properties = {
            {
                source = object, name   = "color",
                keys   = {
                    {0.0,"LINEAR",       {255,255,255}},
                    {1.0,"EASE_OUT_QUAD", object.color},
                }
            },
            {
                source = object, name   = "scale",
                keys   = {
                    {0.0,        "LINEAR",{1.2,1.2}},
                    {1.0,"EASE_OUT_CUBIC",{1,  1  }},
                }
            },
        }
        
    }
    
    local next_next_num = nil
    local next_num = ""
    function up.timeline.on_completed()
        
        object.text = next_num
        
        object.anchor_point = {object.w/2,object.h/2}
        
        dn:start()
        
    end
    function dn.timeline.on_completed()
        
        if next_next_num ~= nil then
            
            next_num = next_next_num
            
            next_next_num = nil
            
            up:start()
            
        end
        
    end
    function animation:is_playing()
        
        return up.timeline.is_playing or dn.timeline.is_playing
        
    end
    function animation:start(num)
        
        assert(type(num) == "number")
        
        if up.timeline.is_playing or dn.timeline.is_playing then
            
            next_next_num = num
            
        else
            
            next_num = num
            
            up:start()
            
        end
        
    end
    
    return animation
end





local wins, losses, make_frame

function game_hist:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    make_frame        = t.make_frame        or error( "must pass make_frame",        2 )
    box_w             = t.box_w             or 180
    box_h             = t.box_h             or 275
    
    local f = make_frame(0,0,box_w,box_h)
    
    wins = Text{
        text  = "",
        color = { 60,204, 72},
        font  = g_font .. " bold 48px",
        x     = box_w/2,
        y     = box_h/5,
    }
    
    wins_caption = Text{
        text  = "Wins",
        color = "ffffff",
        font  = g_font .. " Medium 30px",
        x     = box_w/2,
        y     = box_h*2/5,
    }
    
    losses = Text{
        text  = "",
        color = {252,6,6},
        font  = g_font .. " bold 48px",
        x     = box_w/2,
        y     = box_h/5 + box_h/2,
    }
    
    losses_caption = Text{
        text  = "Losses",
        color = "ffffff",
        font  = g_font .. " Medium 30px",
        x     = box_w/2,
        y     = box_h*2/5 + box_h/2,
    }
    
    wins.anchor_point           = {           wins.w/2,           wins.h/2 }
    wins_caption.anchor_point   = {   wins_caption.w/2,   wins_caption.h/2 }
    losses.anchor_point         = {         losses.w/2,         losses.h/2 }
    losses_caption.anchor_point = { losses_caption.w/2, losses_caption.h/2 }
    
    wins.anim   = make_flash_text_animation(wins)
    losses.anim = make_flash_text_animation(losses)
    
    game_hist:add(f,wins,wins_caption,losses,losses_caption)
    
end


function game_hist:set_wins(score)
    
    if self        ~= game_hist then error("must use a colon",  2) end
    if type(score) ~= "number"  then error("must pass a number",2) end
    
    wins.anim:start(score)
    
end

function game_hist:set_losses(score)
    
    if self ~= game_hist then error("must use a colon",2) end
    if type(score) ~= "number" then error("must pass a number",2) end
    
    losses.anim:start(score)
    
end




return game_hist


