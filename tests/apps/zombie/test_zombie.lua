local actors = {}

---------- Ground --------------------

local ground = Rectangle{
    size = {screen.w, 50},
    color = "FF0000",
    position = {0, screen.h - 50}
}

screen:add(ground)
table.insert(actors, ground)

local ground_body = physics:Body(ground, {type = "static", friction = 1})


---------- Bodies ------------------

CHEST_WIDTH = 25
CHEST_HEIGHT = 50

-- create the chest
local chest = Rectangle{
    size = {CHEST_WIDTH, CHEST_HEIGHT},
    color = "0000FF",
    position = {900, 500}
}
chest.anchor_point = {chest.w/2, chest.h/2}

screen:add(chest)
table.insert(actors, chest)

local chest_body = physics:Body(chest, {friction = .1, density = 1, bounce = .7,
    awake = true})

-- create the head
local head = Rectangle{
    size = {30, 30},
    color = "00FF00",
    position = {chest.x, chest.y-25-15},
    z_rotation = {45, 30, 30}
}
head.anchor_point = {head.w/2, head.h/2}

screen:add(head)
table.insert(actors, head)

local head_body = physics:Body(head, {friction = .1, density = 1, bounce = .7,
    awake = true})

-- joint the head to the chest

chest_body:RevoluteJoint(head_body, {chest.x, chest.y-CHEST_HEIGHT/2})

-- create the left_arm
local left_arm = Rectangle{
    size = {8, 30},
    color = "00FF00",
    position = {chest.x - CHEST_WIDTH/2 - 8, chest.y},
    z_rotation = {30, 4, 15}
}
left_arm.anchor_point = {left_arm.w/2, 0}

screen:add(left_arm)
table.insert(actors, left_arm)

local left_arm_body = physics:Body(left_arm, {friction = .1, density = 1, bounce = .7,
    awake = true})

-- joint the left_arm to the chest

chest_body:RevoluteJoint(left_arm_body, {chest.x - CHEST_WIDTH/2, chest.y})

-- create the right_arm
local right_arm = Rectangle{
    size = {8, 30},
    color = "00FF00",
    position = {chest.x + CHEST_WIDTH/2 + 8, chest.y},
    z_rotation = {-30, 4, 15}
}
right_arm.anchor_point = {right_arm.w/2, 0}

screen:add(right_arm)
table.insert(actors, right_arm)

local right_arm_body = physics:Body(right_arm,{friction = .1, density = 1, bounce = .7,
    awake = true})

-- joint the right_arm to the chest

chest_body:RevoluteJoint(right_arm_body, {chest.x + CHEST_WIDTH/2, chest.y})

-- create the right_leg
local right_leg = Rectangle{
    size = {8, 30},
    color = "00FF00",
    position = {chest.x + CHEST_WIDTH/2 + 8, chest.y + CHEST_HEIGHT/2},
    z_rotation = {-30, 4, 15}
}
right_leg.anchor_point = {right_leg.w/2, 0}

screen:add(right_leg)
table.insert(actors, right_leg)

local right_leg_body = physics:Body(right_leg,{friction = .1, density = 1, bounce = .7,
    awake = true})

-- joint the right_leg to the chest

chest_body:RevoluteJoint(right_leg_body, {chest.x+CHEST_WIDTH/2, chest.y+CHEST_HEIGHT/2})

-- create the left_leg
local left_leg = Rectangle{
    size = {8, 30},
    color = "00FF00",
    position = {chest.x - CHEST_WIDTH/2 - 8, chest.y+CHEST_HEIGHT/2},
    z_rotation = {30, 4, 15}
}
left_leg.anchor_point = {left_leg.w/2, 0}

screen:add(left_leg)
table.insert(actors, left_leg)

local left_leg_body = physics:Body(left_leg,{friction = .1, density = 1, bounce = .7,
    awake = true})

-- joint the left_leg to the chest

chest_body:RevoluteJoint(left_leg_body, {chest.x-CHEST_WIDTH/2, chest.y+CHEST_HEIGHT/2})

screen:show()
--physics:start()


----------------- Trampolene ---------------------


local tramp = Rectangle{w = 200, h = 8, position = {chest.x, ground.y-ground.h/2}}
tramp.anchor_point = {tramp.w, tramp.h}
screen:add(tramp)
table.insert(actors, tramp)
local tramp_body = physics:Body(tramp, {type="static", friction = 1, density = 1, bounce = 3})


idle.limit = 1/60
local camera_change = {chest.x, chest.y}
function idle:on_idle(seconds)
    physics:step(seconds)
--    physics:draw_debug()
    camera_change[1] = camera_change[1] - chest.x
    camera_change[2] = camera_change[2] - chest.y
    if chest.y < 100 or chest.y > screen.h - 100 then
        for i,actor in ipairs(actors) do
            actor.y = actor.y + camera_change[2]
        end
    end

    if chest.x < 100 or chest.x > screen.w - 100 then
        for i,actor in ipairs(actors) do
            actor.x = actor.x + camera_change[1]
        end
    end

    camera_change = {chest.x, chest.y}
end

function screen:on_key_down(k)
    if k == keys.Up then
        chest:apply_linear_impulse({0, -5}, chest.position)
    elseif k == keys.Down then
        chest:apply_linear_impulse({0, 5}, chest.position)
    elseif k == keys.Right then
        chest:apply_linear_impulse({5, 0}, chest.position)
    else
        chest:apply_linear_impulse({-5, 0}, chest.position)
    end
end
