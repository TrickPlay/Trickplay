PhysicsMonitor = Class(function(physmon, ...)

    function physmon:physics_on()
        if not gameloop then error("must have a Gameloop()", 2) end

        --gameloop:add_idle(physics.step, {physics})
        physics_enabled = true
    end

    function physmon:physics_off()
        if not gameloop then error("must have a Gameloop()", 2) end

        gameloop:remove_idle(physics.step)
        gameloop:remove_idle(physmon.check_velocity)
        physics_enabled = false
    end

    local game_over_counter = 0
    local count = 0
    local distance_traveled = {[1] = 0, [2] = 0}
    local v = 20
    function physmon:check_velocity(obj)
        if not physics_enabled then return end

        if obj.linear_velocity[1] < 0 then
            obj.linear_velocity = {obj.linear_velocity[1]/3, obj.linear_velocity[2]}
        end

        if obj.linear_velocity[1] + obj.linear_velocity[2] < .7
        and obj.linear_velocity[1] + obj.linear_velocity[2] > -.7 then
            game_over_counter = game_over_counter + 1
        else
            game_over_counter = 0
        end

        if game_over_counter > 150 then
            game:check_game_over()
            game_over_counter = 0
        end

        distance_traveled[1] = distance_traveled[1] + obj.linear_velocity[1]/60
        distance_traveled[2] = distance_traveled[2] - obj.linear_velocity[2]/60
        game:set_distance_traveled(distance_traveled)
        if not gameloop:idle_added(physmon.check_velocity) then
            gameloop:add_idle(physmon.check_velocity, {physmon, obj})
        end
    end
    
    function physmon:reset()
        physmon:physics_off()
        game_over_counter = 0
        distance_traveled = {[1] = 0, [2] = 0}
    end
end)
