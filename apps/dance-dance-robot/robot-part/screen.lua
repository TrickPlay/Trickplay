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
local robot         = dofile("robot-part/robot.lua")
local score_gauge   = dofile("robot-part/score-gauge.lua")
local background    = dofile("robot-part/background.lua")
local screen_border = Image { src = "/assets/robot-part/screen/FrameUI.png", width = screen.w, height = screen.h }

screen:add(background)
screen:add(girl_in_white,girl_in_black,robot)
screen:add(score_gauge)
screen:add(screen_border)

screen:show()

local DELAY_TIME = 120

function screen:on_key_down(key)
    if(key == keys.OK) then
        background:jiggle(150)
        score_gauge:set_score((score_gauge.score+10) % 110 )
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

function check_collision(a,b)
    local a = a:find_child("collision_sensor")
    local min_x_a = a.transformed_position[1]
    local max_x_a = min_x_a + a.transformed_size[1]
    local min_y_a = a.transformed_position[2]
    local max_y_a = min_y_a + a.transformed_size[2]

    local b = b:find_child("collision_sensor")
    local min_x_b = b.transformed_position[1]
    local max_x_b = min_x_b + b.transformed_size[1]
    local min_y_b = b.transformed_position[2]
    local max_y_b = min_y_b + b.transformed_size[2]
    
    if( min_x_a > max_x_b ) then
        -- A is fully to the right of b
        return false
    elseif( max_x_a < min_x_b ) then
        -- A is fully to the left of b
        return false
    elseif( min_y_a > max_y_b ) then
        -- A is fully above b
        return false
    elseif( max_y_a < min_y_b ) then
        -- A is fully below b
        return false
    else
        return true
    end
end

function idle:on_idle(secs)
    if(girl_in_white.interactive and check_collision(robot,girl_in_white)) then
        girl_in_white:knock_down()
    end
    
    if(girl_in_black.interactive and check_collision(robot,girl_in_black)) then
        girl_in_black:knock_down()
    end
end
