if not GameState then dofile("GameState.lua") end
if not GamePresentation then dofile("GamePresentation.lua") end

GameControl = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.GAME)
    router:attach(ctrl, Components.GAME)

    local state = GameState(ctrl)
    local pres = GamePresentation(ctrl)

    local grid = nil
    -- the position of the focus
    local selector = {x = 1, y = 1, z = 1}
    local prev_selector = {x = 1, y = 1, z = 1}

    -- getters/setters
    function ctrl:get_router() return router end
    function ctrl:get_presentation() return pres end
    function ctrl:get_state() return state end

    function ctrl:is_active_component()
        return Components.GAME == router:get_active_component()
    end
    function ctrl:get_grid() return state:get_grid() end
    function ctrl:get_selector() return selector end
    function ctrl:get_prev_selector() return prev_selector end
    function ctrl:is_new_game() return state:is_new_game() end
    function ctrl:game_won() return state:game_won() end
    function ctrl:get_current_tile_image()
        return state:get_tiles_class():get_current_tile_image()
    end
    function ctrl:set_selector(position)
        if not position   then error("need a position", 2) end
        if not position.x then error("need position.x", 2) end
        if not position.y then error("need position.y", 2) end
        selector = Utils.deepcopy(position)
    end
    function ctrl:is_roaming() return state:is_roaming() end

    function ctrl:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            ctrl:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            pres:update(event)
        elseif event:is_a(ResetEvent) then
            ctrl:reset_game()
        end
    end

    -- public functions
    function ctrl:initialize_game(args)

        state:initialize(args)
        ---[[
        if not state:load_layout() then
            state:build_layout(Layouts.TURTLE)
        end
        --]]
        --state:build_layout(Layouts.CROWN)
        --state:build_layout(Layouts.ANCHOR)
        --state:build_layout(Layouts.FISH)
        --state:build_layout(Layouts.ARENA)
        --state:build_layout(Layouts.BULL)
        --state:build_layout(Layouts.CUBE)
        --state:build_test()
        --state:build_two_tile_test()
        state:set_tile_tables()
        grid = state:get_grid()

        pres:display_ui()
        screen:show()

        ctrl:reset_selector()

        add_to_key_handler(keys.h, state.show_matching_tiles)
        add_to_key_handler(keys.r, ctrl.reset_game)
        add_to_key_handler(keys.s, ctrl.shuffle_game)
        add_to_key_handler(keys.u, ctrl.undo_move)
        add_to_key_handler(keys.y, function() pres:sparkle(200, 200, 12) end)

    end

    function ctrl:reset_game(number)
        --print("game resetting")
        if not number then
            router:set_active_component(Components.GAME)
        end

        if state:must_restart() then pres:hide_end_game() end

        state:reset()
        state:build_layout(number)
        --state:build_test()
        --state:build_two_tile_test()
        state:set_tile_tables()
        grid = state:get_grid()

        -- check for at least one playable move
        local i = 0
        for _,__ in pairs(state:get_matching_tiles()) do
            i = i + 1
        end
        if i < 2 then ctrl:reset_game(number) end

        pres:display_ui()
        pres:reset()

        selector = {x = 1, y = 1, z = 1}
        ctrl:reset_selector()
        pres:move_focus()

        router:notify()
    end

    local loops = 0
    function ctrl:shuffle_game()
        --print("game re-shuffling")
        state:reset()
        state:shuffle()
        state:set_tile_tables()
        grid = state:get_grid()

        -- check for at least one playable move
        local i = 0
        for _,__ in pairs(state:get_matching_tiles()) do
            i = i + 1
        end
        if i < 2 and loops < 10 then
            loops = loops + 1
            ctrl:shuffle_game()
        end

        loops = 0

        pres:display_ui()
        pres:reset()

        selector = {x = 1, y = 1, z = 1}
        ctrl:reset_selector()
        pres:move_focus()
        router:notify(NotifyEvent())
    end

    function ctrl:save() state:save() end

    function ctrl:undo_move()
        local last_tiles = state:undo()
        if not last_tiles then return end
        state:set_tile_tables()
        grid = state:get_grid()

        pres:display_ui()
        pres:reset()
        pres:show_undo(last_tiles)

        ctrl:reset_selector()
        pres:move_focus()
        router:notify(NotifyEvent())
    end


------------- Functions Passed to State ----------


    function ctrl:hint() state:check_remaining_moves(true) end
    function ctrl:undo() state:undo() end


------------- Control Functionality --------------


    function ctrl:return_pressed()
        if state:game_won() then
            pres:hide_end_game()
            ctrl:reset_game()
            return
        end

        local was_roaming = state:is_roaming()
        state:click(selector)
        local still_roaming = state:is_roaming()
        -- short circuit, checks to see if state changed from roaming to
        -- not roaming during click, thus game must know whether it picked
        -- up a tile
        if was_roaming == not still_roaming then
            if was_roaming then
            -- if no tile was deleted
            elseif grid[selector.x][selector.y][selector.z] then
                -- do nothing (for now)
            else
                --increase_moves() --this is global in "MenuView.lua"/should change
                state:find_drawn_tiles()
                self:reset_selector()
            end
        end

        local counter = 0
        local matching_tiles = state:get_matching_tiles()
        for _,__ in pairs(matching_tiles) do
            counter = counter + 1
        end
        if counter <= 0 then
            --print("game over")
            state:check_for_win()
        end
        --print("pieces left =",counter)
    end

    function ctrl:back_pressed()
        if not prev_selector then return end
        selector.x = prev_selector.x
        selector.y = prev_selector.y
        local temp_selector = Utils.deepcopy(prev_selector)
        pres:move_focus(temp_selector, function() state:return_card(temp_selector) end)
        prev_selector = nil
    end

    function ctrl:move_selector(dir)
        local selection_grid = state:get_selection_grid()
        local top_grid = state:get_top_grid()
        local top_tiles = state:get_top_tiles()

        local x = selector.x
        local y = selector.y
        local z = selector.z
        local old_tile = grid[x][y][z]
        local z = 1
        local new_tile = nil

        if 0 ~= dir[1] and top_grid[x+dir[1]] and top_grid[x+dir[1]][y][z] then
            x = x + dir[1]
            if top_grid[x-dir[1]][y][z] == top_grid[x][y][z]
            and top_grid[x+dir[1]] and top_grid[x+dir[1]][y][z] then
                x = x + dir[1]
            end
        elseif 0 ~= dir[2] and top_grid[x][y+dir[2]] and top_grid[x][y+dir[2]][z] then
            y = y + dir[2]
            if top_grid[x][y-dir[2]][z] == top_grid[x][y][z]
            and top_grid[x][y+dir[2]] and top_grid[x][y+dir[2]][z] then
                y = y + dir[2]
            end
        end
        while top_grid[x][y][z+1] do z = z + 1 end

        if old_tile ~= top_grid[x][y][z] then new_tile = top_grid[x][y][z] end

        ---[[
        -- if a tile could not be moved to directly move to the closest neighbor
        if not new_tile then
            x = selector.x
            y = selector.y
            z = selector.z
            local i = 1
            while i <= 2 do
                local dist = nil
                --arbitrarily high value
                local closest_dist = 10000
                local angle = nil
                for _,tile in ipairs(top_tiles) do
                    -- on first pass include spectral element
                    if i == 1 then
                        angle = math.atan((tile.position[2]-y)/(tile.position[1]-x))
                            * 180/math.pi
                    end
                    -- check against comparing tiles in the wrong direction
                    if -1 == dir[1] and (tile.position[1] >= x
                      or (angle and (angle < -60 or angle > 60))) then
                        -- dont compare
                    elseif 1 == dir[1] and (tile.position[1] <= x
                      or (angle and (angle < -60 or angle > 60))) then
                        -- dont compare
                    elseif -1 == dir[2] and (tile.position[2] >= y
                      or (angle and (angle > -30 and angle < 30))) then
                        -- dont compare
                    elseif 1 == dir[2] and (tile.position[2] <= y
                      or (angle and (angle > -30 and angle < 30))) then
                        -- dont compare
                    else
                        -- Euclidean distance measure
                            -- check against comparing against current position
                        dist = math.sqrt((tile.position[1]-x)^2
                            + (tile.position[2]-y)^2
                            + (tile.position[3]-z)^2)
                        if dist < closest_dist and dist ~= 0 then
                            closest_dist = dist
                            new_tile = tile
                        end
                    end
                end
                if new_tile then break end
                i = i + 1
            end
        end
        --]]

        if new_tile then
            prev_selector = Utils.deepcopy(selector)
            selector.x = new_tile.position[1]
            selector.y = new_tile.position[2]
            selector.z = new_tile.position[3]
            pres:move_focus()
        elseif -1 == dir[1] then
            router:set_active_component(Components.MENU)
            router:notify()
        end
        --[[
        print("selector")
        dumptable(selector)
        --]]
    end

    function ctrl:reset_selector()
        local top_tiles = state:get_top_tiles()

        local x = selector.x
        local y = selector.y
        local new_tile = nil

        local dist = nil
        --arbitrarily high value
        local closest_dist = 10000
        for _,tile in ipairs(top_tiles) do
            -- Euclidean distance measure
                -- check against comparing against current position
            dist = math.sqrt((tile.position[1]-x)^2 + (tile.position[2]-y)^2)
            if dist < closest_dist and dist ~= 0 then
                closest_dist = dist
                new_tile = tile
            end
        end
        if new_tile then
            prev_selector = nil
            selector.x = new_tile.position[1]
            selector.y = new_tile.position[2]
            selector.z = new_tile.position[3]
            pres:move_focus()
        end
    end

    function ctrl:hide_focus()
        pres:hide_focus()
    end

    function ctrl:restore_focus()
        pres:restore_focus()
    end

end)
