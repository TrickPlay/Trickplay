HelpScreen = Class(Controller, function(self, router, ...)
    local id = Components.HELP
    self._base.init(self, router, id)

    local controller = self

    local mask = Rectangle{
        color = Colors.BLACK,
        width = screen.width,
        height = screen.height,
        opacity = 60
    }
    local help_screen = Image{src = "assets/help.jpg", position = {676, 80}}
    local help_button = FocusableImage(996, 858,
        "assets/menus/button-large-off.png",
        "assets/menus/button-large-on.png",
        "Done"
    )
    help_button.text.y = help_button.text.y - 3
    local help_ui = Group{name="help_ui"}
    help_ui:add(mask, help_screen, help_button.group)
    screen:add(help_ui)

    local selector = 1

    function self:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            controller:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            if controller:is_active_component() then
                dialog_ui.opacity = 255
                print("fgsgsgfsg")
            else
                dialog_ui.opacity = 0
            end
        end
    end

    function controller:return_pressed()
        help_ui:unparent()
        help_ui = nil
        collectgarbage("collect")

        local lag_timer = Timer()
        lag_timer.interval = 250
        disable_event_listeners()
        function lag_timer:on_timer()
            lag_timer.on_timer = nil
            lag_timer:stop()
            lag_timer = nil

            router:set_active_component(Components.MENU)
            router:detach(controller, Components.HELP)
            enable_event_listeners()
        end
        lag_timer:start()
    end
    
    help_button.group.reactive     = true
    help_button.group.on_button_up = controller.return_pressed
    help_button.group.on_enter     = function()
        cursor.curr_focus_on  = help_button.on_focus_inst
        cursor.curr_focus_off = help_button.off_focus_inst
        cursor.curr_focus_p   = help_button
        help_button:on_focus_inst()
    end
    
    help_button.group.on_leave     = function()
        cursor.curr_focus_on  = nil
        cursor.curr_focus_off = nil
        help_button:off_focus_inst()
    end
    
    function controller:hide_focus()
        help_button:off_focus_inst()
    end
    
    function controller:restor_focus()
        help_button:on_focus_inst()
    end
        
    function controller:move_selector(dir)
    end
    
    if using_keys then help_button:on_focus_inst() end
end)
