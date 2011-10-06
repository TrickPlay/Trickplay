if not GameState then dofile("GameState.lua") end
if not GamePresentation then dofile("GamePresentation.lua") end

GameControl = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.GAME)
    router:attach(ctrl, Components.GAME)

    local state = GameState(ctrl)
    local pres = GamePresentation(ctrl)

    local grid = state:get_grid()
    -- the position of the focus
    local selector = {x = 1, y = 1, tableau_index = 1}
    local prev_selector = nil
    local undo_orig_selector = nil
    local undo_latest_selector = nil

    -- getters/setters
    function ctrl:get_router() return router end
    function ctrl:get_presentation() return pres end
    function ctrl:get_state() return state end

    function ctrl:is_active_component()
        return Components.GAME == router:get_active_component()
    end
    function ctrl:get_waste() return state:get_waste() end
    function ctrl:get_foundations() return state:get_foundations() end
    function ctrl:get_tableau() return state:get_tableau() end
    function ctrl:get_stock() return state:get_stock() end
    function ctrl:get_backup_stock() return state:get_backup_stock() end
    function ctrl:get_grid() return state:get_grid() end
    function ctrl:get_collection() return state:get_collection() end
    function ctrl:get_selector() return selector end
    function ctrl:get_prev_selector() return prev_selector end
    function ctrl:get_undo_orig_selector() return undo_orig_selector end
    function ctrl:get_undo_latest_selector() return undo_latest_selector end
    function ctrl:set_undo_orig_selector(position) undo_orig_selector = position end
    function ctrl:set_undo_latest_selector(position) undo_latest_selector = position end
    function ctrl:is_new_game() return state:is_new_game() end
    function ctrl:set_selector(position, cb)
        if not position then error("need a position", 2) end
        if not position.x then error("need position.x", 2) end
        if not position.y then error("need position.y", 2) end
        if not position.tableau_index then error("need position.tableau_index", 2) end
        selector = Utils.deepcopy(position)
        pres:move_focus(nil,cb)
    end
    function ctrl:set_selector_and_move(position, cb)
        assert(position)
        assert(position.x)
        assert(position.y)
        assert(position.tableau_index)
        selector = Utils.deepcopy(position)
        pres:move_focus(selector,cb)
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
        pres:display_ui()
        state:build_klondike()
--        state:build_test()
--        state:build_ace_king_test()
        grid = state:get_grid()
        if settings.score and not state:is_new_game() then
            set_score(settings.score)
        end
        if settings.moves and not state:is_new_game() then
            set_moves(settings.moves)
        end
    end

    function ctrl:reset_game()
        router:set_active_component(Components.GAME)
        router:notify()

        ctrl:set_selector_and_move({x = 1, y = 1, tableau_index = 1})
        set_score(0)
        set_moves(0)
        prev_selector = nil
        undo_orig_selector = nil
        undo_latest_selector = nil
        state:reset()
        pres:reset()
        state:build_klondike()
--        state:build_test()
--        state:build_ace_king_test()
        grid = state:get_grid()
    end


    -- positions on the grid
    GridRows = {
        DECKS = 1,
        TABLEAUS = 2
    }
    GridCols = {
        {
            STOCK = 1,
            WASTE = 2,
            NIL = 3,
            FOUNDATION_1 = 4,
            FOUNDATION_2 = 5,
            FOUNDATION_3 = 6,
            FOUNDATION_4 = 7,
        },
        {
            TABLEAU_1 = 1,
            TABLEAU_2 = 2,
            TABLEAU_3 = 3,
            TABLEAU_4 = 4,
            TABLEAU_5 = 5,
            TABLEAU_6 = 6,
            TABLEAU_7 = 7,
        }
    }


------------- Functions Passed to State ----------


    function ctrl:hint() state:check_remaining_moves(true) end
    function ctrl:undo() state:undo() end
    function ctrl:auto_complete() state:auto_complete() end


------------- Control Functionality --------------


    function ctrl:run_callback(cb)
        local was_roaming = state:is_roaming()
        local still_roaming = state:click(selector, cb)
        -- short circuit, checks to see if state changed from roaming to
        -- not roaming during click, thus game must know where it picked
        -- up a card from in order to put it back to its previous spot
        if was_roaming == not still_roaming then
            if was_roaming then
                prev_selector = {}
                prev_selector.x = selector.x
                prev_selector.y = selector.y
                prev_selector.tableau_index = selector.tableau_index
                -- corrects focus position to the card being dropped when back
                -- is pressed
                if grid[selector.x][selector.y].stack[selector.tableau_index] 
                  and selector.y == GridRows.TABLEAUS then
                    prev_selector.tableau_index = prev_selector.tableau_index + 1
                end
                pres:choose_focus()
            else
                local x = prev_selector.x
                local y = prev_selector.y
                local t_index = prev_selector.tableau_index
                local card = grid[x][y].stack[t_index-1]

                if card and not card:isFaceUp() then
                    card:flip()
                    state:set_undo_to_flip()
                else
                    state:set_undo_to_not_flip()
                end

                increase_moves() --this is global in "MenuView.lua"/should change
                mediaplayer:play_sound("assets/sounds/Card_Flip.mp3")

                if grid[x][y]:is_a(Waste) and state:get_deal_3() then
                    local waste = state:get_waste()
                    waste:move_out_top_cards()
                end
                undo_orig_selector = Utils.deepcopy(prev_selector)
                undo_latest_selector = Utils.deepcopy(selector)
                undo_latest_selector.tableau_index = selector.tableau_index + 1
                prev_selector = nil

                if state:get_stock():is_empty() and state:get_waste():is_empty() then
                    state:check_for_win()
                end

            end
        end
        if not state:game_won() and state:is_roaming() then
            state:save_game()
        end
    end

    function ctrl:back_pressed()
        if not prev_selector then return end
        selector.x = prev_selector.x
        selector.y = prev_selector.y
        selector.tableau_index = prev_selector.tableau_index
        local temp_selector = Utils.deepcopy(prev_selector)
        pres:move_focus(temp_selector, function() state:return_card(temp_selector) end)
        prev_selector = nil
    end

    function ctrl:move_selector(dir)
        -- if at the top and up is pressed and not holding a card then go to the menu
        if GridRows.DECKS == selector.y and dir[2] == -1  and state:is_roaming() then
            router:set_active_component(Components.MENU)
            router:notify()
            return
        end

        local function complete_move()
            local x = selector.x
            local y = selector.y
            local t_index = selector.tableau_index

            -- reset the t_index if in the upper region
            if GridRows.DECKS == y then t_index = 1 end

            selector.x = x
            selector.tableau_index = t_index

            --[[
            print("x = "..selector.x)
            print("y = "..selector.y)
            print("t_index = "..selector.tableau_index)
            print("dir[1] = "..dir[1])
            print("dir[2] = "..dir[2])
            --]]

            pres:move_focus()
        end

        if state:is_roaming() then
            ctrl:roam_selector(dir)
            complete_move()
        else
            local collection = state:get_collection()
            local x = selector.x + dir[1]
            if x > 7 then
                interval = {["x"] = Interval(collection.group.x, 2200)}
                gameloop:add(collection.group, 200, 0, interval, 
                    function()
                        collection.group.x = -200
                        ctrl:grid_selector(dir)
                        complete_move()
                    end)
            elseif x < 1 then
                interval = {["x"] = Interval(collection.group.x, -200)}
                gameloop:add(collection.group, 200, 0, interval, 
                    function()
                        collection.group.x = 2200
                        ctrl:grid_selector(dir)
                        complete_move()
                    end)
            else
                ctrl:grid_selector(dir)
                complete_move()
            end
        end

    end

    function ctrl:grid_selector(dir)
        assert(not state:is_roaming())

        local collection = state:get_collection()
        --print("not roaming mode")

        -- clamp between 1 and 7 which is the x coordinate space for the game grid
        local x = selector.x + dir[1]
        if x > 7 then
            x = 1
        elseif x < 1 then
            x = 7
        end
        local y = selector.y
        local t_index = selector.tableau_index

        -- if the focus is in the tableau region
        if y == GridRows.TABLEAUS then
            -- if the user is carrying a collection of more than one card
            if #collection.stack > 1 then
                -- can only move left or right which is already accounted for
            -- collection of one card
            elseif #collection.stack == 1 then
                -- the player can move up,
                -- but only into the foundations or waste if originally card
                -- picked was from waste (these 2nd two parts are handled later)
                y = Utils.clamp(GridRows.DECKS, y + dir[2], GridRows.TABLEAUS)
            else
                error("collection should not be 0 while not roaming!")
            end
        -- if the focus is in the deck region
        elseif y == GridRows.DECKS then
            -- can move down
            y = Utils.clamp(GridRows.DECKS, y + dir[2], GridRows.TABLEAUS)
        else
            error("not in coordinate space")
        end

        -- the player may only move a card into the
        -- foundation or the waste
        if y == GridRows.DECKS then
            x = Utils.clamp(GridCols[y].WASTE, x, GridCols[y].FOUNDATION_4)
        end

        -- correct for the empty space between the foundations and the waste
        if 0 ~= dir[1] and GridRows.DECKS == y and GridCols[y].NIL == x then
            x = x + dir[1]
        elseif 0 ~= dir[2] and GridRows.DECKS == y and GridCols[y].NIL == x then
            x = x + 1
        end
        
        -- card may only go to the waste if it came from the waste
        if y == GridRows.DECKS and x == GridCols[y].WASTE
          and not (prev_selector.x == x and prev_selector.y == y) then
            x = GridCols[y].FOUNDATION_1
        end

        -- should move to the top of every stack
        local stack = grid[x][y].stack
        selector.tableau_index = #stack
        -- set the new x, y
        selector.x = x
        selector.y = y
    end

    function ctrl:roam_selector(dir)
        assert(state:is_roaming())

        --print("is roaming mode")

        -- clamp between 1 and 7 which is the x coordinate space for the game grid
        local x = selector.x + dir[1]
        if x > 7 then x = 1 end
        if x < 1 then x = 7 end
        local y = selector.y
        local t_index = selector.tableau_index

        -- if the focus is in the tableau region
        if y == GridRows.TABLEAUS then
            local stack = grid[x][y].stack
            -- if focus is moving up
            if 0 > dir[2] then
                -- if no card or if the card moving to is flipped
                if not stack[t_index+dir[2]]
                  or not stack[t_index+dir[2]]:isFaceUp() then
                    -- move out of the tableau region
                    y = y + dir[2]
                else
                    -- index into the next card within the tableau
                    t_index = t_index + dir[2]
                end
            -- if focus is moving down
            elseif 0 < dir[2] then
                -- if no card
                if not stack[t_index+dir[2]] then
                    -- don't do anything
                else
                    -- move down
                    t_index = t_index + dir[2]
                end
            -- if focus is moving left or right
            elseif 0 ~= dir[1] then
                -- already moved in the x direction, just clamp t_index
                t_index = Utils.clamp(1, t_index, #stack)
            end
        -- if the focus is in the top region
        elseif y == GridRows.DECKS then
            -- you can only really move down
            y = Utils.clamp(GridRows.DECKS, y + dir[2], GridRows.TABLEAUS)
        else
            error("WTF? The coords are not even on the map!")
        end

        -- correct for the empty space between the foundations and the waste
        if 0 ~= dir[1] and GridRows.DECKS == y and GridCols[y].NIL == x then
            x = x + dir[1]
        elseif 0 ~= dir[2] and GridRows.DECKS == y and GridCols[y].NIL == x then
            x = x + 1
        end
        
        stack = grid[x][y].stack
        -- correct for position in the tableau
        if GridRows.TABLEAUS == y then
            -- if no cards or for some random reason the index is too high
            if #stack == 0 or not stack[t_index] then
                -- highlight empty space or first card depending on case
                t_index = 1
            end
            -- if cards but face down
            if #stack > 0 and not stack[t_index]:isFaceUp() then
                -- move to the first card that is face up
                while not stack[t_index]:isFaceUp() do
                    t_index = t_index + 1
                end
            end
        end

        selector.x = x
        selector.y = y
        selector.tableau_index = t_index

    end

end)
