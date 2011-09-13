--[[
        This file defines the whole screen for the robot evasion section of the game
        This surrounds the elements of the game, penetrates them, and binds them together.
        There are basically 5 elements to this part of the game:
        1. Girl dressed in white
        2. Girl dressed in black
        3. Jumping robot tractor man
        4. Score gauge
        5. Background image
        6. Screen border
        
        Each of those is broken out into its own file that implements its behaviors, except the border which is just a static image.  Those behaviors are then controlled from here.
]]--

local girl_factory  = dofile("robot-part/generic-girl.lua")
local girl_in_white = dofile("robot-part/girl-in-white.lua")(girl_factory)
local girl_in_black = dofile("robot-part/girl-in-black.lua")(girl_factory)
 robot         = dofile("robot-part/robot.lua")
local score_gauge   = dofile("robot-part/score-gauge.lua")
local background    = dofile("robot-part/background.lua")
local screen_border = Image { src = "/assets/robot-part/screen/FrameUI.png", width = screen.w, height = screen.h }

screen:add(background)
screen:add(girl_in_white,girl_in_black,robot)
screen:add(score_gauge)
screen:add(screen_border)

screen:show()

function screen:on_key_down(key)
    if(key == keys.OK) then
        background:jiggle(150)
        score_gauge:set_score((score_gauge.extra.score+10) % 110 )
    elseif(key == keys.Right) then
        girl_in_white:go_to_state('run1')
        girl_in_black:go_to_state('run1')
    elseif(key == keys.Left) then
        girl_in_white:go_to_state('runToStop1')
        girl_in_black:go_to_state('runToStop1')
    elseif(key == keys.Down) then
        girl_in_white:go_to_state('roll1')
        girl_in_black:go_to_state('knockdown1')
    end
end
