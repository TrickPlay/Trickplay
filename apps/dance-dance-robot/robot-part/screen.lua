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


local DELAY_TIME = 120
local GOAL_COUNT = 8
local MAX_COUNT_SCORE = GOAL_COUNT
local score = 0
local isEnd = false

local snd_puck_bad = "/assets/robot-part/audio/puck_bad-1.mp3"
local snd_good_effect = "/assets/robot-part/audio/"

function screen:on_key_down(key)
    if(key == keys.OK) then
        background:jiggle(150)
        score_gauge:set_score((score_gauge.extra.score+10) % 110 )
    elseif(key == keys.Right) then
        girl_in_black:move(key)
        dolater(DELAY_TIME, girl_in_white.move, girl_in_white, key)
    elseif(key == keys.Left) then
        girl_in_white:move(key)
        dolater(DELAY_TIME, girl_in_black.move, girl_in_black, key)
    elseif(key == keys.Down) then
        girl_in_white:roll()
        girl_in_black:roll()
    end
end
