GameCamera = Class(function(camera, ...)

    -- the item that the camera focuses on
    local focus = nil
    -- the items that the camera pays attention to, items are keys and values
    local actors = {}
    -- a metric used to determine whether the camera should shift or not
    local camera_change = {}
    -- limits specify the scope of the focus
    -- the camera must move to keep the focus with this scope
    local right_limit = screen.w - 100
    local left_limit = 100
    local top_limit = 100
    local bottom_limit = screen.h - 300
    local ground

    function camera:set_limits(left, right, top, bottom)
        if left then
            assert(type(left) == "number")
            if left > right_limit then
                error("left limit must be less than right", 2)
            end
            left_limit = left
        end
        if right then
            assert(type(right) == "number")
            if right < left_limit then
                error("right limit must be greater than left", 2)
            end
            right_limit = right
        end
        if top then
            assert(type(top) == "number")
            if top > bottom_limit then
                error("top limit must be less than bottom", 2)
            end
            top_limit = top
        end
        if bottom then
            assert(type(bottom) == "number")
            if bottom < top_limit then
                error("bottom limit must be greater than top", 2)
            end
            bottom_limit = bottom
        end
    end

    --[[
        Adds this item to the list of actors the camera pays attention to.
    --]]
    function camera:add(item)
        if type(item) ~= "userdata" then error("item needs to be userdata", 2) end
        if item.parent ~= screen then
            error("item must be added to the screen with screen as the parent", 2)
        end

        actors[item] = {item = item, x_movement = true, y_movement = true}
    end
    
    --[[
        Removes this item from the list of actors the camera pays attention to.
        If the item is not in the list of actors then does nothing.
    --]]
    function camera:remove(item)
        actors[item] = nil
    end

    function camera:set_x_movement(item, boolean)
        if type(boolean) == "boolean" then actors[item].x_movement = boolean end
    end

    function camera:set_y_movement(item, boolean)
        if type(boolean) == "boolean" then actors[item].y_movement = boolean end
    end

    function camera:set_focus(item)
        if type(item) ~= "userdata" then error("item needs to be userdata", 2) end
        if item.parent ~= screen then
            error("item must be added to the screen with screen as the parent", 2)
        end
        if not actors[item] then
            error("item must first be added to the camera before set as the focus", 2)
        end

        focus = item
        camera_change[1] = focus.x
        camera_change[2] = focus.y
    end

    local DAMPING_RATIO_X = 1
    local DAMPING_RATIO_Y = 1
    function camera:move_camera()
        if not focus then error("cannot move the camera without a focus", 2) end
        if not actors[focus] then error("focus must be added to actors", 2) end

        local delta
        if focus.y < top_limit then
            delta = focus.y - top_limit
            for i,actor in pairs(actors) do
                if actor.y_movement then
                    actor.item.y = actor.item.y - delta*DAMPING_RATIO_Y
                end
            end
        elseif focus.y > bottom_limit
          and not (focus.y > ground.y - 300) then
            delta = focus.y - bottom_limit
            for i,actor in pairs(actors) do
                if actor.y_movement then
                    actor.item.y = actor.item.y - delta*DAMPING_RATIO_Y
                end
            end
        end

        if focus.x < left_limit then
            delta = focus.x - left_limit
            for i,actor in pairs(actors) do
                if actor.x_movement then
                    actor.item.x = actor.item.x - delta*DAMPING_RATIO_X
                end
            end
        elseif focus.x > right_limit then
            delta = focus.x - right_limit
            for i,actor in pairs(actors) do
                if actor.x_movement then
                    actor.item.x = actor.item.x - delta*DAMPING_RATIO_X
                end
            end
        end

    end

    SHAKE_AMOUNT = 40
    SHAKE_TIME = .1
    local total_sec = 0
    local x_change = 0
    local shake
    function shake(duration, seconds)
        if total_sec > duration then
            if x_change > 0 then
                for i, actor in pairs(actors) do
                    actor.item.x = actor.item.x - SHAKE_AMOUNT
                end
                x_change = x_change - SHAKE_AMOUNT
            elseif x_change < 0 then
                for i, actor in pairs(actors) do
                    actor.item.x = actor.item.x + SHAKE_AMOUNT
                end
                x_change = x_change + SHAKE_AMOUNT
            else
                total_sec = 0
                gameloop:remove_idle(shake)
                return
            end
        elseif total_sec*10%2 < 1 then
            for i,actor in pairs(actors) do
                actor.item.x = actor.item.x - SHAKE_AMOUNT
            end
            x_change = x_change - SHAKE_AMOUNT
        else
            for i,actor in pairs(actors) do
                actor.item.x = actor.item.x + SHAKE_AMOUNT
            end
            x_change = x_change + SHAKE_AMOUNT
        end
        total_sec = total_sec + seconds
    end
    function camera:shake(duration)
        gameloop:add_idle(shake, {duration})
    end

    function camera:start()
        if not gameloop then error("must have a Gameloop()", 2) end

        gameloop:add_idle(camera.move_camera, {camera})
        ground = game:get_ground()
    end
    
    function camera:stop()
        if not gameloop then error("must have a Gameloop()", 2) end

        gameloop:remove_idle(camera.move_camera)

    end


    -- print number of actors
    add_to_key_handler(keys.f, function()
        local i = 0
        for k,v in pairs(actors) do
            i = i + 1
        end
        print("number of actors", i)
    end)

end)
