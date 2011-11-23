Zombie = Class(function(zombie, camera, ...)

    CHEST_POSITION = {900, 700}

    -- create the chest
    local chest = Image{
        src = "assets/zombie/shirt.png",
        position = Utils.deepcopy(CHEST_POSITION)
    }
    CHEST_HEIGHT = chest.h
    CHEST_WIDTH = chest.w
    chest.anchor_point = {chest.w/2, chest.h/2}

    -- create the torso
    local torso = Image{
        src = "assets/zombie/pants-top.png",
        position = {chest.x - 50, chest.y + 33},
    }


    -- create the head
    local head = Image{
        src = "assets/zombie/head.png",
        position = {chest.x-CHEST_WIDTH + 81, chest.y-CHEST_HEIGHT/2-40},
    }
    head.anchor_point = {head.w/2, head.h/2}

    -- create the left_upper_arm
    local left_arm = Image{
        src = "assets/zombie/arm-left.png",
        position = {chest.x - CHEST_WIDTH/2 - 3, chest.y + 8},
    }
    left_arm.anchor_point = {left_arm.w/2, left_arm.h/2}
    -- create the left_upper_arm
    local left_hand = Image{
        src = "assets/zombie/hand-left.png",
        position = {
            left_arm.x-left_arm.w/2-4,
            left_arm.y-left_arm.h/2+88
        }
    }

    -- create the right_upper_arm
    local right_arm = Image{
        src = "assets/zombie/arm-right.png",
        position = {chest.x + CHEST_WIDTH/2 - 10, chest.y-12},
    }
    right_arm.anchor_point = {right_arm.w/2, right_arm.h/2}

    -- create the right lower arm
    local right_hand = Image{
        src = "assets/zombie/hand-right.png",
        position = {
            right_arm.x-right_arm.w/2+14,
            right_arm.y-right_arm.h/2+57
        }
    }

    -- create the right_leg
    local right_leg = Image{
        src = "assets/zombie/leg-right.png",
        position = {chest.x + CHEST_WIDTH/2 - 57, torso.y + 55},
    }

    -- create the left_leg
    local left_leg = Image{
        src = "assets/zombie/leg-left.png",
        position = {chest.x - CHEST_WIDTH/2 - 58, torso.y + 57},
    }

    local zombie_drawn = false
    function zombie:draw()
        screen:add(
            right_leg, left_leg, torso, chest, head, right_hand, right_arm,
            left_arm, left_hand
        )
        camera:add(torso)
        camera:add(chest)
        camera:add(head)
        camera:add(left_arm)
        camera:add(right_arm)
        camera:add(right_hand)
        camera:add(left_hand)
        camera:add(right_leg)
        camera:add(left_leg)
        zombie_drawn = true
    end

    function zombie:delete()
        camera:remove(torso)
        camera:remove(chest)
        camera:remove(head)
        camera:remove(left_arm)
        camera:remove(right_arm)
        camera:remove(right_hand)
        camera:remove(left_hand)
        camera:remove(right_leg)
        camera:remove(left_leg)
        
        screen:remove(
            right_leg, left_leg, torso, right_hand, left_hand,
            left_arm, right_arm, chest, head
        )

        right_leg = nil
        left_leg = nil
        torso = nil
        right_hand = nil
        left_hand = nil
        left_arm = nil
        right_arm = nil
        chest = nil
        head = nil

        zombie_drawn = false
    end

    function zombie:make_physics()
        if not zombie_drawn then error("zombie must be drawn first", 2) end

        -- create chest body
        physics:Body(chest, {friction = .1, density = 8.1, bounce = 1.8,
            awake = false, filter = {group = -2}})

        -- create the torso body
        physics:Body(torso, {friction = .1, density = 5, bounce = .9,
            awake = false})

        -- join the torso to the chest
        chest:RevoluteJoint(torso, {chest.x - 5, chest.y + 40},
            {enable_limit = true, lower_angle = -45, upper_angle = 45})
        
        --create head body
        physics:Body(head, {friction = 1, density = 10, bounce = .5,
            awake = false, shape = physics:Circle(head.w/2, {0, -10})})

        -- joint the head to the chest
        chest:RevoluteJoint(head, {chest.x - 5, chest.y-CHEST_HEIGHT/2 + 10})

        -- create left_upper_arm body
        physics:Body(left_arm, {friction = 1, density = 10, bounce = .2,
            awake = false})

        -- joint the left_upper_arm to the chest
        chest:RevoluteJoint(left_arm, {chest.x - CHEST_WIDTH/2 + 9, chest.y-28})
        
        -- create the left_lower_arm body
        physics:Body(left_hand, {friction = 1, density = 10, bounce = .2,
            angular_damping = 10, awake = false, filter = {group = -2}})
        
        -- joint the left_lower_arm to the left_upper_arm
        left_arm:RevoluteJoint(left_hand,
            {left_hand.x-2, left_hand.y-40})

        -- create right_upper_arm body
        physics:Body(right_arm,{friction = 1, density = 10, bounce = .2,
            awake = false})

        -- joint the right_upper_arm to the chest
        chest:RevoluteJoint(right_arm, {chest.x + CHEST_WIDTH/2 - 26, chest.y-33})

        -- create the right_lower_arm body
        physics:Body(right_hand, {friction = 1, density = 10, bounce = .2,
            angular_damping = 10, awake = false, filter = {group = -2}})

        -- joint the right_lower_arm to the right_upper_arm
        right_arm:RevoluteJoint(right_hand,
            {right_hand.x+11, right_hand.y-38})
        
        -- create right_leg body
        physics:Body(right_leg,{friction = 1, density = 10, bounce = .5,
            awake = false})

        -- joint the right_leg to the chest
        torso:RevoluteJoint(right_leg, {right_leg.x - 2, right_leg.y - 26})

        -- create left_leg body
        physics:Body(left_leg,{friction = 1, density = 10, bounce = .5,
            awake = false})

        -- joint the left_leg to the chest
        torso:RevoluteJoint(left_leg, {left_leg.x+28, left_leg.y-32})

    end

    function zombie:get_chest()
        return chest
    end

    function zombie:get_zombie_parts()
        return {
            head = head,
            chest = chest,
            torso = torso,
            right_hand = right_hand,
            left_hand = left_hand,
            right_arm = right_arm,
            left_arm = left_arm,
            right_leg = right_leg,
            left_leg = left_leg
        }
    end
end)
