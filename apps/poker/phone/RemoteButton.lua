RemoteButton = Class(nil,
function(button, controller, image_src, focus_src, position, size)
    -- This is the function that gets called when the button is pressed
    button.callback = nil

    local group = controller.factory:Group()
    button.group = group

    local image = controller.factory:Image{
        src = image_src,
        position = position,
        size = size
    }

    local focus = controller.factory:Image{
        src = focus_src,
        position = position,
        size = size
    }
    button.focus = focus
    focus:hide()

    group:add(image, focus)

    function button:press()
        local button_timer = Timer()
        button_timer.interval = 500
        function button_timer:on_timer()
            self.on_timer = nil
            self:stop()
            focus:hide()
            if button.callback then button:callback() end
        end
        focus:show()
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
