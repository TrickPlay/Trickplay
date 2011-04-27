

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

local function dummy() end

balloon.extra.blur = dummy
balloon.extra.unblur = dummy
balloon.extra.saturate = dummy
balloon.extra.desaturate = dummy
balloon.extra.pageturn = dummy

lottery.extra.blur = dummy
lottery.extra.unblur = dummy
lottery.extra.saturate = dummy
lottery.extra.desaturate = dummy
lottery.extra.pageturn = dummy

screen:add( focus , lottery , balloon )
lottery:pageturn(1.0)

local curl_timeline = Timeline { duration = 750 }
local balloon_on_fn = function(_,_,progress) balloon:pageturn(1-progress,85,24) lottery:pageturn(progress,85,24) end
local lottery_on_fn = function(_,_,progress) balloon:pageturn(progress,85,24) lottery:pageturn(1-progress,85,24) end

local function set_focus( s )
    if s == "balloon" then
        focus.position = { balloon.x - 20 , balloon.y - 20 }
        focus.extra.focus = s
        g_focus = s
        balloon:unblur()
--        balloon:saturate()
        lottery:blur()
--        lottery:desaturate(0.8)
        curl_timeline:rewind()
        curl_timeline.on_new_frame = balloon_on_fn
        curl_timeline:start()
    elseif s == "lottery" then
        focus.position = { lottery.x - 20 , lottery.y - 20 }
        focus.extra.focus = s
        g_focus = s
        balloon:blur()
--        balloon:desaturate(0.8)
        lottery:unblur()
--        lottery:saturate()
        curl_timeline:rewind()
        curl_timeline.on_new_frame = lottery_on_fn
        curl_timeline:start()
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
