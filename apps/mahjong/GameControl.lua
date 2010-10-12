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
    function ctrl:set_selector(position)
        if not position then error("need a position", 2) end
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
        state:build_layout(Layouts.TURTLE)
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

    end

    function ctrl:reset_game()
        print("game resetting")
        router:set_active_component(Components.GAME)
        router:notify()

        state:reset()
        --state:build_layout(Layouts.TURTLE)
        --state:build_layout(Layouts.CLUB)
        state:build_layout(Layouts.ARENA)
        --state:build_test()
        --state:build_two_tile_test()
        state:set_tile_tables()
        grid = state:get_grid()

        pres:display_ui()
        pres:reset()

        selector = {x = 1, y = 1, z = 1}
        ctrl:reset_selector()
        pres:move_focus()
    end

    function ctrl:shuffle_game()
        print("game re-shuffling")
        state:shuffle()
        state:shuffle()
        state:set_tile_tables()
        grid = state:get_grid()

        pres:display_ui()
        pres:reset()

        selector = {x = 1, y = 1, z = 1}
        ctrl:reset_selector()
        pres:move_focus()
        router:notify(NotifyEvent())
    end

    function ctrl:undo_move()
        local continue = state:undo()
        if not continue then return end
        state:set_tile_tables()
        grid = state:get_grid()

        pres:display_ui()
        pres:reset()

        ctrl:reset_selector()
        pres:move_focus()
        router:notify(NotifyEvent())
    end


------------- Functions Passed to State ----------


    function ctrl:hint() state:check_remaining_moves(true) end
    function ctrl:undo() state:undo() end


------------- Control Functionality --------------


    function ctrl:return_pressed()
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
                self:reset_selector()
            end
        end

        local counter = 0
        local matching_tiles = state:get_matching_tiles()
        for _,__ in pairs(matching_tiles) do
            counter = counter + 1
        end
        if counter <= 0 then
            print("game over")
            state:check_for_win()
        end
        print("pieces left =",counter)
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
            --print("x1",x)
            if top_grid[x-dir[1]][y][z] == top_grid[x][y][z]
            and top_grid[x+dir[1]] and top_grid[x+dir[1]][y][z] then
                x = x + dir[1]
            --print("x2",x)
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
            local dist = nil
            --arbitrarily high value
            local closest_dist = 10000
            --print("selector")
            --dumptable(selector)
            for _,tile in ipairs(top_tiles) do
                --dumptable(tile)
                -- check against comparing tiles in the wrong direction
                --[[
                if tile.position[1] == 15 and tile.position[2] == 7 then
                    dumptable(tile.position)
                    print("x = ", x)
                    print("y = ", y)
                end
                --]]
                if -1 == dir[1] and tile.position[1] >= x then
                    -- dont compare
                elseif 1 == dir[1] and tile.position[1] <= x then
                    -- dont compare
                elseif -1 == dir[2] and tile.position[2] >= y then
                    -- dont compare
                elseif 1 == dir[2] and tile.position[2] <= y then
                    -- dont compare
                else
                    -- Euclidean distance measure
                        -- check against comparing against current position
                    dist = math.sqrt((tile.position[1]-x)^2 + (tile.position[2]-y)^2
                        + (tile.position[3]-z)^2)
                    if dist < closest_dist and dist ~= 0 then
                        closest_dist = dist
                        new_tile = tile
                    end
                --    print("new_tile")
              --      dumptable(tile.position)
                end
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

end)
