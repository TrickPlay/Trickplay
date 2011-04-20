SplashController = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.SPLASH)
    router:attach(ctrl, Components.SPLASH)

    local view = SplashView(ctrl)
    local splash_timer = Timer()

    function ctrl:on_key_down(k)
        router:set_active_component(Components.CHARACTER_SELECTION)
        router:notify()
        ctrlman:choose_dog({})
        if splash_timer then
            splash_timer:stop()
            splash_timer.on_timer = nil
            splash_timer = nil
        end
    end

    function ctrl:notify(event) view:update(event) end

    -- This will get rid of the splash screen after 7 seconds
    splash_timer.interval = 7000
    function splash_timer:on_timer()
        splash_timer:stop()
        splash_timer.on_timer = nil
        splash_timer = nil
        ctrl:on_key_down(keys.Return)
    end
    splash_timer:start()

end)
