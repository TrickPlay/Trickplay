if not GameState then dofile("GameState.lua") end
if not GamePresentation then dofile("GamePresentation.lua") end

GameControl = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.GAME)
    router:attach(ctrl, Components.GAME)
    game = ctrl

    local audiomng = AudioManager()
    local physmon = PhysicsMonitor()
    local camera = GameCamera()
    local state = GameState(ctrl, camera)
    local pres = GamePresentation(ctrl, camera)

    -- the position of the focus
    local selector = {x = 1, y = 1, z = 1}

    -- getters/setters
    function ctrl:get_router() return router end
    function ctrl:get_presentation() return pres end
    function ctrl:get_state() return state end
    function ctrl:get_physics_monitor() return physmon end
    function ctrl:get_camera() return camera end
    function ctrl:get_audio_manager() return audiomng end

    function ctrl:get_zombie() return state:get_zombie() end
    function ctrl:new_zombie() return state:new_zombie() end
    function ctrl:get_ground() return pres:get_ground() end
    function ctrl:set_distance_traveled(dist)
        --state:set_distance(dist)
        pres:set_distance(dist)
    end

    function ctrl:is_active_component()
        return Components.GAME == router:get_active_component()
    end
    function ctrl:get_selector() return selector end
    function ctrl:is_new_game() return state:is_new_game() end
    function ctrl:set_selector(position)
        if not position then error("need a position", 2) end
        if not position.x then error("need position.x", 2) end
        if not position.y then error("need position.y", 2) end
        selector = Utils.deepcopy(position)
    end

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
        state:build()

        camera:set_limits(400, 1000, nil, nil)
        camera:start()
        physmon:physics_on()

        pres:display_ui()
        screen:show()

        add_to_key_handler(keys.r, ctrl.reset_game)
        add_to_key_handler(keys.s, function() camera:shake(5) end)

        enable_kbd()
    end

    function ctrl:check_game_over() 
        if state:check_game_over() then
            game:stop()
            gameloop:remove_idle(physmon.check_velocity)
            print("games over yo")
            pres:show_end_game(router)
        end
    end

    function ctrl:stop()
        physmon:physics_off()
        camera:stop()
    end

    function ctrl:reset_game()
        print("game resetting")
        router:set_active_component(Components.GAME)

        gameloop:clear_idle()

        state:reset()

        physmon:reset()
        pres:reset()
        physmon:physics_on()

        selector = {x = 1, y = 1, z = 1}

        enable_kbd()
        router:notify()
    end

    function ctrl:undo_move()
    end


------------- Control Functionality --------------


    function ctrl:return_pressed()
        pres:shoot()
    end

    function ctrl:back_pressed()
    end

    move_zombie = false
    add_to_key_handler(keys.m, function() move_zombie = not move_zombie end)
    function ctrl:move(dir)
        assert(dir)
        if move_zombie then
            pres:move(dir)
        else
            pres:move_gun(dir)
        end
    end

end)
