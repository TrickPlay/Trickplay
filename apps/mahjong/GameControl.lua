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
    local selector = {x = 1, y = 1}
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
--        state:build_test()
        grid = state:get_grid()

    end

    function ctrl:reset_game()
        router:set_active_component(Components.GAME)
        router:notify()

        ctrl:set_selector({x = 1, y = 1})
        prev_selector = nil
        state:reset()
        pres:reset()
        state:build_mahjong()
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
    end

end)
