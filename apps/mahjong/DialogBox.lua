DialogBox = Class(Controller, function(self, string, id, router, note, ...)
    assert(id == Components.NO_MOVES_DIALOG or id == Components.NEW_MAP_DIALOG)
    self._base.init(self, router, id)

    local controller = self

    local mask = Rectangle{
        color = Colors.BLACK,
        width = screen.width,
        height = screen.height,
        opacity = 60
    }
    local dialog = Group{
        position = {screen.width/2, screen.height/2}
    }
    dialog.anchor_point = {dialog.width/2, dialog.height/2}
    local dialog_box = Image{
        src = "assets/dialog/dialog-scroll.png",
    }
    dialog_box.anchor_point = {dialog_box.width/2, dialog_box.height/2}
    local dialog_text = Text{
        text = string,
        position = {dialog.width/2, dialog.height/2-100},
        font = MENU_FONT,
        color = Colors.ERASER_RUST
    }
    dialog_text.anchor_point = {dialog_text.width/2, dialog_text.height/2}
    local dialog_note = Text{
        text = note,
        position = {dialog.width/2, dialog.height/2-40},
        font = DEFAULT_FONT,
        color = Colors.YELLOW
    }
    dialog_note.anchor_point = {dialog_note.width/2, dialog_note.height/2}

    dialog:add(dialog_box, dialog_text)
    if note then dialog:add(dialog_note) end

    local button_off = Image{src = "assets/dialog/button-small-off.png", opacity=0}
    local button_on = Image{src = "assets/dialog/button-small-on.png", opacity=0}
    screen:add(button_off, button_on)

    local first_text = Text{
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
    }
    local second_text = Text{
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
    }
    if id == Components.NO_MOVES_DIALOG then
        first_text.text = "Shuffle Tiles"
        second_text.text = "New Game"
    else
        first_text.text = "No"
        second_text.text = "Yes"
    end 

    local focusable_items = {
        FocusableImage(-200,-10,Clone{source=button_off},
                       Clone{source=button_on},first_text),
        FocusableImage(10,-10,Clone{source=button_off},
                       Clone{source=button_on},second_text)
    }
    first_text.x = first_text.x - 3
    first_text.y = first_text.y - 3
    second_text.x = second_text.x - 3
    second_text.y = second_text.y - 3

    for i,item in ipairs(focusable_items) do
        dialog:add(item.group)
    end
    local dialog_ui = Group()
    dialog_ui:add(mask, dialog)
    screen:add(dialog_ui)
    dialog_ui:hide()

    local selector = 1

    function self:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            controller:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            if controller:is_active_component() then
                dialog_ui.opacity = 255
                dialog_ui:show()
                for i,item in ipairs(focusable_items) do
                    if i == selector then
                        item:on_focus_inst()
                    else
                        item:off_focus_inst()
                    end
                end
            else
                dialog_ui.opacity = 0
                dialog_ui:hide()
            end
        end
    end

    function controller:return_pressed()
        if id == Components.NO_MOVES_DIALOG then
            if selector == 1 then
                game:shuffle_game()
                router:set_active_component(Components.GAME)
                router:notify()
            elseif selector == 2 then
                router:delegate(ResetEvent(), Components.GAME)
            else
                error("selector not in a correct position")
            end
        elseif id == Components.NEW_MAP_DIALOG then
            if selector == 1 then
                router:set_active_component(Components.MENU)
                router:notify()
                game_menu:move_layout()
            elseif selector == 2 then
                router:set_active_component(Components.MENU)
                game:reset_game(game_menu:get_controller():get_current_layout())
            else
                error("selector not in a correct position")
            end
        else
            error("not a known dialog_type")
        end
    end

    function controller:move_selector(dir)
        if 0 ~= dir[1] then
            if selector == 1 then selector = 2
            else selector = 1
            end
            self:update(NotifyEvent())
        end
    end

end)
