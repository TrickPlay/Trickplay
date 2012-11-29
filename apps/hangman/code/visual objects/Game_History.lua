
local game_hist = Group{name = "Game History", x = 49, y = 756}

local make_frame
local game_server
local loaded = false

local function make_flash_text_animation(object,shadow)
    
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
            {
                source = shadow, name   = "scale",
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
            {
                source = shadow, name   = "scale",
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
        shadow.text = next_num
        
        --object.anchor_point = {object.w/2,object.h/2}
        
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





local wins, losses, wins_s, losses_s, make_frame

function game_hist:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    make_frame  = t.make_frame  or error( "must pass make_frame",  2 )
    game_server = t.game_server or error( "must pass game_server", 2 )
    box_w       = t.box_w       or 208
    box_h       = t.box_h       or 324
    
    local f = Clone{source = t.img_srcs.game_hist_bg }
    
    wins = Text{
        text  = "",
        color = { 60,204, 72},
        font  = g_font .. " bold 80px",
        alignment = "CENTER",
        wrap = true,
        w     = t.img_srcs.game_hist_bg.w,
        y     = 12,
        x     = -2,
    }
    
    wins_s = Text{
        text      = wins.text,
        color     = "000000",
        font      = wins.font,
        alignment = wins.alignment,
        wrap = true,
        w         = wins.w,
        x         = wins.x-2,
        y         = wins.y-2,
    }
    
    wins_caption = Text{
        text  = "Wins",
        color = "a7a7a7",
        alignment = "CENTER",
        wrap = true,
        w     = t.img_srcs.game_hist_bg.w,
        font  = g_font .. " Medium 40px",
        y     = wins.y+wins.h-7,
    }
    
    losses = Text{
        text  = "",
        color = {252,6,6},
        font  = g_font .. " bold 80px",
        alignment = "CENTER",
        wrap = true,
        w     = t.img_srcs.game_hist_bg.w,
        y     = 140,
        x     = -2,
    }
    
    losses_s = Text{
        text      = losses.text,
        color     = "000000",
        font      = losses.font,
        alignment = losses.alignment,
        wrap = true,
        w         = losses.w,
        x         = losses.x-2,
        y         = losses.y-2,
    }
    
    losses_caption = Text{
        text  = "Losses",
        color = "a7a7a7",
        font  = g_font .. " Medium 40px",
        alignment = "CENTER",
        wrap = true,
        w     = t.img_srcs.game_hist_bg.w,
        y     = losses.y+losses.h-12,
    }
    
    wins:move_anchor_point(        wins.w/2,    wins.h/2)    
    losses:move_anchor_point(    losses.w/2,  losses.h/2)  
    wins_s:move_anchor_point(    wins_s.w/2,  wins_s.h/2)  
    losses_s:move_anchor_point(losses_s.w/2,losses_s.h/2)
    
    
    
    wins.anim   = make_flash_text_animation(wins,wins_s)
    losses.anim = make_flash_text_animation(losses,losses_s)
    
    game_hist:add(
        f,
        wins_s,
        wins,
        Text{
            text      = wins_caption.text,
            color     = "000000",
            font      = wins_caption.font,
            alignment = wins_caption.alignment,
            wrap = true,
            w         = wins_caption.w,
            y         = wins_caption.y-2,
            x         = wins_caption.x-2,
        },
        wins_caption,
        losses_s,
        losses,
        Text{
            text      = losses_caption.text,
            color     = "000000",
            font      = losses_caption.font,
            alignment = losses_caption.alignment,
            wrap = true,
            w         = losses_caption.w,
            y         = losses_caption.y-2,
            x         = losses_caption.x-2,
        },
        losses_caption
    )
    
end


function game_hist:set_wins(score)
    
    if self        ~= game_hist then error("must use a colon",  2) end
    if type(score) ~= "number"  then error("must pass a number",2) end
    
    wins.anim:start(score)
    
    game_server:update_game_history(function() print("history updated") end)
    
end

function game_hist:set_losses(score)
    
    if self ~= game_hist then error("must use a colon",2) end
    if type(score) ~= "number" then error("must pass a number",2) end
    
    losses.anim:start(score)
    
    game_server:update_game_history(function() print("history updated") end)
    
end




return game_hist


