

local lottery = Image{ src = "lottery/icon.jpg" }
local balloon = Image{ src = "balloon/icon.jpg" }

lottery.position = { screen.w / 4 - lottery.w / 2 , screen.h / 2 - lottery.h / 2 }
balloon.position = { ( screen.w / 4 ) * 3 - balloon.w / 2 , screen.h / 2 - balloon.h / 2 }

local focus = Rectangle
{
    color = "0000FF",
    w = lottery.w + 40,
    h = lottery.h + 40,
}

screen:add( focus , lottery , balloon )

local function set_focus( s )
    if s == "balloon" then
        focus.position = { balloon.x - 20 , balloon.y - 20 }
        focus.extra.focus = s
        g_focus = s
        balloon:unblur()
        balloon:saturate()
        lottery:blur()
        lottery:desaturate(0.8)
    elseif s == "lottery" then
        focus.position = { lottery.x - 20 , lottery.y - 20 }
        focus.extra.focus = s
        g_focus = s
        balloon:blur()
        balloon:desaturate(0.8)
        lottery:unblur()
        lottery:saturate()
    end
end

set_focus( g_focus or "lottery" )

local KEY_RIGHT = keys.Right
local KEY_LEFT  = keys.Left
local KEY_OK    = keys.Return

function screen:on_key_down( key )
    if key == KEY_RIGHT then
        if focus.extra.focus == "lottery" then
            set_focus( "balloon" )
        end
    elseif key == KEY_LEFT then
        if focus.extra.focus == "balloon" then
            set_focus( "lottery" )
        end
    elseif key == KEY_OK then
        screen:clear()
        screen.on_key_down = nil
        collectgarbage( "collect" )
        dofile( focus.extra.focus.."/main.lua" )
    end
        
end

screen:show()
