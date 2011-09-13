--[[ A generic girl has states.  She moves through the states in an animated way.  When input events happen, she jumps to some other state from which she then proceeds ]]--


local GIRL_ANIMATION_FRAME_RATE = 100
local GIRL_MOVE_DISTANCE = 300

-- This table tracks the state transitions -- from a given current frame for the girl, which comes next by default?
-- User input or collision events can jump us to another position in the table, but we'll automate from there.
local animation_states = {
    idle1 = "idle2",
    idle2 = "idle3",
    idle3 = "idle1",
    
    knockdown1 = "knockdown2",
    knockdown2 = "knockdown3",
    knockdown3 = "knockdown4",
    knockdown4 = "knockdownToStand1",
    
    knockdownToStand1 = "idle1",
    
    roll1 = "rollToStand1",
    
    rollToStand1 = "rollToStand2",
    rollToStand2 = "run1",
    
    run1 = "run2",
    run2 = "run3",
    run3 = "run4",
    run4 = "run5",
    run5 = "run6",
    run6 = "run1",
    
    runToStop1 = "runToStop2",
    runToStop2 = "idle1",
}

local animation_ticker = Timer ( GIRL_ANIMATION_FRAME_RATE )

local girl_animation_list = {}

function animation_ticker:on_timer()
    for the_girl,current_frame in pairs(girl_animation_list) do
        -- hide the old frame
        the_girl.extra.images[current_frame]:hide()
        -- Iterate to the next frame
        current_frame = animation_states[current_frame]
        -- show that one
        the_girl.extra.images[current_frame]:show()
        -- save it for next iteration
        girl_animation_list[the_girl] = current_frame
    end
end

local girl_move = function(girl, direction)
    local left_right = 0
    if(direction == keys.Left) then
        if(girl.y_rotation[1] == 0) then
            girl:find_child("collision_sensor").y_rotation = { 180, girl:find_child("collision_sensor").w/2, 0 }
            girl.y_rotation = { 180, 0, 0 }
            girl.extra.target_x = girl.x
        end
        left_right = -1
    else
        if(girl.y_rotation[1] == 180) then
            girl:find_child("collision_sensor").y_rotation = { 0, girl:find_child("collision_sensor").w/2, 0 }
            girl.y_rotation = { 0, 0, 0 }
            girl.extra.target_x = girl.x
        end
        left_right = 1
    end

    girl.extra.target_x = math.min(math.max(girl.target_x+(left_right*GIRL_MOVE_DISTANCE),girl.MIN_X),girl.MAX_X)

    if(not girl_animation_list[girl]:find("run%d")) then
        girl:go_to_state("run1")
    end
    -- one running frame per 1/20th of the screen width traveled
    local duration = 1+ GIRL_ANIMATION_FRAME_RATE*20 * math.abs(girl.x-girl.target_x)/screen.w
    girl:animate({ duration = duration, x = girl.target_x, on_completed = function() girl:go_to_state("runToStop1") end })
end

local girl_roll = function(girl)
    local left_right = 0
    if(girl.y_rotation[1] == 0) then
        left_right = 1
    else
        left_right = -1
    end

    girl.extra.target_x = math.min(math.max(girl.target_x+(left_right*GIRL_MOVE_DISTANCE),girl.MIN_X),girl.MAX_X)

    if(not girl_animation_list[girl]:find("roll")) then
        girl:go_to_state("roll1")
    end
    -- one running frame per 1/20th of the screen width traveled
    local duration = 1+ GIRL_ANIMATION_FRAME_RATE*20 * math.abs(girl.x-girl.target_x)/screen.w
    girl:animate({ duration = duration, x = girl.target_x, on_completed = function() girl:go_to_state("runToStop1") end })
end

animation_ticker:start()

local girl_factory = function(images)
    -- Make a new group for the girl
    local the_girl = Group()
    the_girl.extra = { images = {} }

    -- Load all the images for this girl
    for k,v in pairs(animation_states) do
        local img = Image { name = k, src = images[k] }
        the_girl.extra.images[k] = img
        img:move_anchor_point(img.w/2, img.h)
        the_girl:add(img)
        img:hide()
    end

    the_girl:add( Rectangle {
                                name = "collision_sensor",
                                size = { 200, 500 },
                                position = { -100, -500 },
                                color = { 198, 28, 111 },
                                opacity = 0,
                            }
            )

    -- Hook up movement functions
    the_girl.extra.move = girl_move
    the_girl.extra.roll = girl_roll

    -- Start the girl in idle position 1 and schedule her for animation
    the_girl.extra.images.idle1:show()
    girl_animation_list[the_girl] = "idle1"

    -- And let her control her own destiny
    the_girl.extra.go_to_state = function(girl, new_state)
        girl.extra.images[girl_animation_list[girl]]:hide()
        girl_animation_list[girl] = new_state
        girl.extra.images[new_state]:show()
        animation_ticker:stop()
        animation_ticker:start()
    end


    the_girl.scale = { 1/2, 1/2 }

    the_girl.extra.MIN_X = screen.w * 1/10
    the_girl.extra.MAX_X = screen.w * 9/10
    the_girl.extra.target_x = 0

    return the_girl
end

return girl_factory
