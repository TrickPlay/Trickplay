SplashView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local splash = Image{
        src = "assets/splash-logo.png",
        position = {screen.width/2, screen.height/2},
    }
    splash.anchor_point = {splash.width/2, splash.height/2}

    view.ui=Group{name="splash_ui", position={0,0}}
    view.ui:add(splash)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(SplashController(self))
    end

    local splash_timer = nil
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.SPLASH then
            if not splash_timer then
                splash_timer = Timer()
                splash_timer.interval = 7
                splash_timer.on_timer = function()
                    splash_timer:stop()
                    splash_timer.on_timer = nil
                    splash_timer = nil
                    controller:on_key_down(keys.Return)
                end
                splash_timer:start()
            end

            self.ui.opacity = 255
            self.ui:raise_to_top()
            for i,dog in ipairs(DOGS) do
                dog.opacity = 255
            end
            for i,glow in ipairs(DOG_GLOW) do
                glow.opacity = 0
            end
        else
            if splash_timer then
                splash_timer:stop()
                splash_timer.on_timer = nil
                splash_timer = nil
            end

            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
