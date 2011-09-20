GameState = Class(nil,
function(state, ctrl, camera)
    math.randomseed(os.time())
    local ctrl = ctrl
    
    --[[
        Private Variables
    --]]
    -- true if the game has not started yet
    local new_game = true
    -- true if the game was won and the auto-complete dialog already showed
    local game_won = false
    -- true if the game is won and the player must redeal to do anything
    local must_restart = false
    -- da zombie
    local zombie = Zombie(camera)
    -- the ground, everything is relative to this
    local ground = nil

    -- getters/setters
    function state:is_new_game() return new_game end
    function state:must_restart() return must_restart end
    function state:game_won() return game_won end

    function state:get_zombie() return zombie end
    function state:new_zombie()
        zombie:delete()
        zombie = Zombie(camera)
        return zombie
    end
    function state:get_ground() return ground end
    function state:set_ground(the_ground) ground = the_ground end

    function state:set_must_restart(bool)
        assert(type(bool)=="boolean")
        must_restart = bool
    end


----------------- Initialization -------------


    function state:initialize()
        print("state initializing")
        new_game = true
        game_won = false
    end

    function state:build()
    end

    function state:check_game_over()
        local chest = zombie:get_chest()
        if chest.y >= ground.y - ground.h*2 - chest.h then
            return true
        end

        return false
    end

    function state:reset()
        new_game = true
        game_won = false
        must_restart = false
    end

--------------------- Functions ------------------


    function state:undo()
    end

    function state:hint()
    end

    function state:click(selector)
        if new_game then new_game = false end

        local x = selector.x
        local y = selector.y
        local z = selector.z

    end

    function state:check_for_win()
    end

end)
