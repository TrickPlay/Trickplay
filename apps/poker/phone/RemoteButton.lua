RemoteButton = Class(nil,
function(button, controller, image_src, focus_src, position, size)
    -- This is the function that gets called when the button is pressed
    if not focus_src then error("No focus_src RemoteButton", 3) end
    button.callback = nil

    local image
    local focus

    local group = controller.factory:Group{size = controller.ui_size}
    button.group = group

    if image_src then
        image = controller.factory:Image{
            src = image_src,
            position = position,
            size = size
        }
    end
    button.image = image

    focus = controller.factory:Image{
        src = focus_src,
        position = position,
        size = size
    }
    button.focus = focus
    focus:hide()

    if image then group:add(image) end
    group:add(focus)

    function button:press()
        local button_timer = Timer()
        button_timer.interval = 200
        function button_timer:on_timer()
            self.on_timer = nil
            self:stop()
            focus:hide()
            if button.callback then button:callback() end
        end
        focus:show()
        controller:play_sound("click_sound", 1)
        button_timer:start()
    end

    function button:hide()
        group:hide()
    end

    function button:show()
        group:show()
    end

    function button:reset()
        group:show()
        focus:hide()
    end

end)
