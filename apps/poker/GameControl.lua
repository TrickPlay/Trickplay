dofile("GameState.lua")
dofile("GamePresentation.lua")
dofile("HandControl.lua")

GameControl = Class(nil,
function(ctrl, model, ...)
    model:attach(ctrl, Components.GAME)
    function ctrl:update() end

    local state = GameState(ctrl)
    local pres = GamePresentation(ctrl)
    local hand_ctrl = HandControl(ctrl)
    local model = model
    local in_hand = false

    local hands = 0

    local game_pipeline = {}
    local orig_game_pipeline = {
        function(ctrl)
            hand_ctrl:initialize()
            pres:update_blinds()
            enable_event_listener(TimerEvent{interval=1000})
            local continue = true
            return continue
        end,
        -- stage where we play through a hand
        function(ctrl, event)
            local continue = hand_ctrl:on_event(event)
            return continue
        end,
        -- clean hand
        function(ctrl)
            state:move_blinds()
            local continue = hand_ctrl:cleanup()
            enable_event_listener(TimerEvent{interval=1000})
            pres:finish_hand()
            hands = hands + 1
            return continue
        end,
        -- increase blinds
        function(ctrl)
            if hands % 4 == 0 then
                state:increase_blinds()
            end
            enable_event_listener(TimerEvent{interval=100})
            return true
        end
    }

    -- getters/setters
    function ctrl.get_players(ctrl) return state:get_players() end
    function ctrl.get_sb_qty(ctrl) return state:get_sb_qty() end
    function ctrl.get_bb_qty(ctrl) return state:get_bb_qty() end
    function ctrl.get_dealer(ctrl) return state:get_dealer() end
    function ctrl.get_sb_p(ctrl) return state:get_sb_p() end
    function ctrl.get_bb_p(ctrl) return state:get_bb_p() end
    function ctrl.get_deck(ctrl) return state:get_deck() end


    local function reset_pipeline()
        game_pipeline = {}
        for _, stage in ipairs(orig_game_pipeline) do
            table.insert(game_pipeline,stage)
        end
    end

    -- public functions
    function ctrl.initialize_game(ctrl, args)
        state:initialize(args)
        pres:display_ui()

        print("Game initializing")
        reset_pipeline()
        disable_event_listeners()
        enable_event_listener(TimerEvent{interval=1000})
    end

    function ctrl:reset()
        hand_ctrl:cleanup()
        hand_ctrl:reset()
        pres:return_to_main_menu(ctrl:human_still_playing(), true)
        enable_event_listener(KbdEvent())
        model:get_controller(Components.PLAYER_BETTING):reset()
        model:set_active_component(Components.CHARACTER_SELECTION)
        model:get_active_controller():reset()
        model:notify()
    end

    function ctrl.start_hand(ctrl)
        hand_ctrl:initialize()
    end

    function ctrl.on_key_down(ctrl, key)
        ctrl:on_event(KbdEvent{key=key})
    end

    function ctrl.game_won(ctrl)
        local players = ctrl:get_players()
        return #players == 1 or not ctrl:human_still_playing()
    end

    function ctrl.human_still_playing(ctrl)
        local players = ctrl:get_players()
        for _,player in ipairs(players) do
        if player.isHuman then return true end
        end

        return false
    end

    function ctrl.on_event(ctrl, event)
        assert(event:is_a(Event))
        if event:is_a(BetEvent) then
            print("GameControl:on_event(BetEvent)")
        elseif event:is_a(TimerEvent) then
            print("GameControl:on_event(TimerEvent)")
        elseif event:is_a(KbdEvent) then
            print("GameControl:on_event(KbdEvent)")
        else
            print("GameControl:on_event(Event)")
        end
        print(#game_pipeline, "entries left in game pipeline")
        disable_event_listeners()

        if ctrl:game_won() then
            hand_ctrl:cleanup()
            pres:return_to_main_menu(ctrl:human_still_playing())

            disable_event_listeners()
            local disable_events_timer = Timer()
            disable_events_timer.interval = 6000
            function disable_events_timer:on_timer()
                disable_events_timer:stop()
                disable_events_timer.on_timer = nil
                disable_events_timer = nil

                enable_event_listener(KbdEvent())

                model:set_active_component(Components.CHARACTER_SELECTION)
                model:get_active_controller():reset()
                model:notify()
            end
            disable_events_timer:start()

            return
        end

        if #game_pipeline == 0 then
            reset_pipeline()
        end


        local action = game_pipeline[1]
        local result = action(ctrl, event)
        if result then table.remove(game_pipeline, 1) end

    end

    function ctrl:handle_click()
        -- prevents crash from ControllerManager.controller:on_click()
    end

end)
