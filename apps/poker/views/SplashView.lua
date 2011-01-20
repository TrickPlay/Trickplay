SplashView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local splash

    view.ui=Group{name="splash_ui", position={0,0}}

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(SplashController(self))
        --[[
        for k,controller in pairs(controllers.connected) do
            controller:set_ui_background("splash")
        end
        --]]
    end

    local splash_timer = nil
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.SPLASH then
            splash = Image{
                src = "assets/splash-logo.png",
                position = {screen.width/2, screen.height/2},
            }
            splash.anchor_point = {splash.width/2, splash.height/2}
            view.ui:add(splash)

            if not splash_timer then
                splash_timer = Timer()
                splash_timer.interval = 7000
                splash_timer.on_timer = function()
                    splash_timer:stop()
                    splash_timer.on_timer = nil
                    splash_timer = nil
                    controller:on_key_down(keys.Return)
                end
                splash_timer:start()
            end

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
            if splash then
                splash:unparent()
                splash = nil
            end
        end
    end

end)
