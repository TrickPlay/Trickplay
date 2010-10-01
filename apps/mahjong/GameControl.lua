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
    local selector = {x = 2, y = 1, z = 1}
    local prev_selector = nil

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
        state:build_mahjong()
        pres:display_ui()
        state:set_tile_quadrants()
        state:find_selectable_tiles()
        state:find_top_tiles()
--        state:build_test()
        grid = state:get_grid()

    end

    function ctrl:reset_game()
        router:set_active_component(Components.GAME)
        router:notify()

        ctrl:set_selector({x = 1, y = 1})
        prev_selector = nil
        state:reset()
        state:build_mahjong()
        pres:reset()
        state:set_tile_quadrants()
        grid = state:get_grid()
    end


------------- Functions Passed to State ----------


    function ctrl:hint() state:check_remaining_moves(true) end
    function ctrl:undo() state:undo() end


------------- Control Functionality --------------


    function ctrl:return_pressed()
        local was_roaming = state:is_roaming()
        local still_roaming = state:click(selector)
        -- short circuit, checks to see if state changed from roaming to
        -- not roaming during click, thus game must know where it picked
        -- up a card from in order to put it back to its previous spot
        if was_roaming == not still_roaming then
            if was_roaming then
                prev_selector = {}
                prev_selector.x = selector.x
                prev_selector.y = selector.y
            else
                increase_moves() --this is global in "MenuView.lua"/should change

                prev_selector = nil

                if state:get_stock():is_empty() and state:get_waste():is_empty() then
                    state:check_for_win()
                end
            end
        end
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

        local x = selector.x
        local y = selector.y
        local z = selector.z
        local old_tile = grid[x][y][z]
        local z = 1
        local new_tile = nil

        if 0 ~= dir[1] and grid[x+dir[1]] and grid[x+dir[1]][y][z] then
            x = x + dir[1]
            if grid[x-dir[1]][y][z] == grid[x][y][z]
            and grid[x+dir[1]] and grid[x+dir[1]][y][z] then
                x = x + dir[1]
            end
        elseif 0 ~= dir[2] and grid[x][y+dir[2]] and grid[x][y+dir[2]][z] then
            y = y + dir[2]
            if grid[x][y-dir[2]][z] == grid[x][y][z]
            and grid[x][y+dir[2]] and grid[x][y+dir[2]][z] then
                y = y + dir[2]
            end
        end
        while grid[x][y][z+1] do z = z + 1 end

        if old_tile ~= grid[x][y][z] then new_tile = grid[x][y][z] end

        ---[[
        if not new_tile then
            local dist = nil
            --arbitrarily high value
            local closest_dist = 10000
            print("selector")
            dumptable(selector)
            for _,tile in pairs(top_grid) do--selection_grid) do
                -- check against comparing tiles in the wrong direction
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
                    dist = math.sqrt((tile.position[1]-x)^2 + (tile.position[2]-y)^2)
                    if dist < closest_dist and dist ~= 0 then
                        closest_dist = dist
                        new_tile = tile
                    end
                    dumptable(tile.position)
                end
            end
            print("new_tile")
        end
        --]]

        if new_tile then
            selector.x = new_tile.position[1]
            selector.y = new_tile.position[2]
            selector.z = new_tile.position[3]
            pres:move_focus()
        end
    end

end)
