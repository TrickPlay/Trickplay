SplashView = Class(nil, 
function(view, ctrl, ...)

    view.ui = assetman:create_group({name = "splash_ui"})
    assetman:load_image("assets/splash-logo.png", "splash")
    local splash = assetman:get_clone("splash")
    splash.position = {screen.width/2, screen.height/2}
    splash.anchor_point = {splash.width/2, splash.height/2}
    view.ui:add(splash)
    screen:add(view.ui)

    function view:update(event)
        if not event:is_a(NotifyEvent) then return end

        local comp = router:get_active_component()
        if comp == Components.SPLASH then
            view.ui.opacity = 255
        else
            view.ui.opacity = 0
        end
    end

end)
