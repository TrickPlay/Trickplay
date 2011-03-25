SplashController = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.SPLASH)
    router:attach(ctrl, Components.SPLASH)

    local view = SplashView(ctrl)

    function ctrl:on_key_down(k)
        router:set_active_component(Components.CHARACTER_SELECTION)
        router:notify()
        ctrlman:choose_dog()
    end

    function ctrl:notify(event) view:update(event) end

end)
