DialogDisplay = Class(function(dialog, string, interval, ...)
    assert(string)
    assert(interval)

    -- rectangular mask overlay
    local mask = Rectangle{
        color = Colors.BLACK,
        width = screen.width,
        height = screen.height,
        opacity = 0
    }
    local dialog = Group{
        position = {screen.width/2, screen.height/2},
        opacity = 0
    }
    dialog.anchor_point = {dialog.width/2, dialog.height/2}
    local dialog_box = Image{
        src = "assets/menus/dialog-box.png",
        y = 20
    }
    dialog_box.anchor_point = {dialog_box.width/2, dialog_box.height/2}
    local dialog_text = Text{
        text = string,
        position = {dialog.width/2, dialog.height/2},
        font = MENU_FONT_BOLD_BIG,
        color = Colors.WHITE
    }
    dialog_text.anchor_point = {dialog_text.width/2, dialog_text.height/2}

    dialog:add(dialog_box, dialog_text)
    screen:add(mask, dialog)

    -- lets the gameloop know something is animating so it
    --doesnt turn on the events
    local t = {value = 1}
    local intervals = {
        ["value"] = Interval(t.value, 100)
    }
    gameloop:add(t, interval + 400, nil, intervals)

    mask:animate{opacity = 60, duration = 200}
    dialog:animate{opacity = 255, duration = 200,
        on_completed = function ()

            local timer = Timer()
            timer.interval = interval
            timer.on_timer = function(timer)
                mask:animate{opacity = 0, duration = 200,
                    on_completed = function()
                        mask:unparent()
                        mask = nil
                    end}
                dialog:animate{opacity = 0, duration = 200,
                    on_completed = function()
                        dialog_text:unparent()
                        dialog_text = nil
                        dialog_box:unparent()
                        dialog_box = nil
                        dialog:unparent()
                        dialog = nil
                    end}

                timer.on_timer = nil
                timer = nil
            end

            timer:start()
        end
    }

end)
