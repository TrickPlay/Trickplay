GameState = Class(nil,
function(state, ctrl, camera)
    math.randomseed(os.time())
    local ctrl = ctrl
    
    game_timer = {
        start = 0,
        current = 0,
        prev = 0,
        stop = false,
        text = Text{
            text = "0:00",
            position = {1015, 301},
            font = MENU_FONT_BOLD,
            color = Colors.WHITE
        }
    }
    function game_timer:update()
        local min = math.floor(self.prev/60)
        local sec = self.prev - min*60
        if sec < 10 then
            self.text.text = tostring(min)..":0"..tostring(sec)
        else
            self.text.text = tostring(min)..":"..tostring(sec)
        end
    end
    --[[
        Private Variables
    --]]
    -- true if the game has not started yet
    local new_game = true
    -- true if the game was won and the auto-complete dialog already showed
    local game_won = false
    -- true if the game is won and the player must redeal to do anything
    local must_restart = false
    -- true if the player is in roaming mode
    local roaming = false
    -- da zombie
    local zombie = Zombie(camera)

    -- getters/setters
    function state:is_new_game() return new_game end
    function state:must_restart() return must_restart end
    function state:game_won() return game_won end

    function state:get_zombie() return zombie end

    function state:set_must_restart(bool)
        assert(type(bool)=="boolean")
        must_restart = bool
    end
    --[[
        If true the player can move anywhere.
        If false the player has a tile selected and must move to another tile
        which matches the selected one.
    --]]
    function state:is_roaming() return selected_tile == nil end


----------------- Initialization -------------


    function state:initialize()
        print("state initializing")
        new_game = true
        game_won = false
    end

    function state:build()
    end

    function state:reset()
        new_game = true
        game_won = false
        must_restart = false
        game_timer.start = 0
        game_timer.current = 0
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
