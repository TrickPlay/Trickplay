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
local screen_border = Image { src = "assets/robot-part/screen/FrameUI.png", width = screen.w, height = screen.h }
local well_done     = Image { src = "assets/robot-part/Well_Done.png" }
well_done.anchor_point = { well_done.w/2, well_done.h/2 }
well_done.position  = { screen.w/2, screen.h/2 }
well_done.scale = { 2, 2 }
well_done:hide()

screen:add(background)
screen:add(robot,girl_in_white,girl_in_black)
screen:add(score_gauge)
screen:add(screen_border)
screen:add(well_done)

screen:show()

-- A little hack, since the play_sound can't loop yet -- the music is just under 29 seconds long
mediaplayer:play_sound("assets/robot-part/audio/BG_Music.mp3")
local bg_music_loop = Timer {
                                interval = 29000,
                                on_timer = function()
                                    mediaplayer:play_sound("assets/robot-part/audio/BG_Music.mp3")
                                end,
                            }
bg_music_loop:start()

local DELAY_TIME = 120

function screen:on_key_down(key)
    if(key == keys.Right) then
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

local function show_well_done()
    well_done:show()
    well_done:animate({
                        duration = 1000,
                        mode = "EASE_IN_EXPO",
                        opacity = 0,
                        scale = { 3, 3 },
                        on_completed = function()
                            well_done:hide()
                            well_done.scale = { 2, 2 }
                            well_done.opacity = 255
                        end,
                    })
end

function robot.extra.score_callback()
    background:jiggle(150)
    score_gauge:set_score((score_gauge.score % 100) + 100/8)
    show_well_done()
end

function check_collision(a,b)
    local a = a.collision_sensor
    local a_tp = a.transformed_position
    local a_ts = a.extra.transformed_size
    local min_x_a = a_tp[1]
    local max_x_a = min_x_a + a_ts[1]
    local min_y_a = a_tp[2]
    local max_y_a = min_y_a + a_ts[2]

    local b = b.collision_sensor
    local b_tp = b.transformed_position
    local b_ts = b.extra.transformed_size
    local min_x_b = b_tp[1]
    local max_x_b = min_x_b + b_ts[1]
    local min_y_b = b_tp[2]
    local max_y_b = min_y_b + b_ts[2]
    
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

-- Cache the transformed_size to save those calls in on_idle
local function ts_store()
    robot.collision_sensor.extra.transformed_size = robot.collision_sensor.transformed_size
    girl_in_white.collision_sensor.extra.transformed_size = girl_in_white.collision_sensor.transformed_size
    girl_in_black.collision_sensor.extra.transformed_size = girl_in_white.collision_sensor.extra.transformed_size
end
dolater(ts_store)

function idle:on_idle(secs)
    if(girl_in_white.interactive and check_collision(robot,girl_in_white)) then
        girl_in_white:knock_down()
        robot:collision()
    end
    
    if(girl_in_black.interactive and check_collision(robot,girl_in_black)) then
        girl_in_black:knock_down()
        robot:collision()
    end
end
