DialogBox = Class(Controller, function(self, string, id, router, note, ...)
    assert(id == Components.NO_MOVES_DIALOG or id == Components.AUTO_COMPLETE_DIALOG)
    self._base.init(self, router, id)

    local controller = self

    Options = {

    }

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
        src = "assets/menus/dialog-box.png",
    }
    dialog_box.anchor_point = {dialog_box.width/2, dialog_box.height/2}
    local dialog_text = Text{
        text = string,
        position = {dialog.width/2, dialog.height/2-70},
        font = MENU_FONT_BOLD,
        color = Colors.WHITE
    }
    dialog_text.anchor_point = {dialog_text.width/2, dialog_text.height/2}
    local dialog_note = Text{
        text = note,
        position = {dialog.width/2, dialog.height/2-40},
        font = MENU_FONT,
        color = Colors.WHITE
    }
    dialog_note.anchor_point = {dialog_note.width/2, dialog_note.height/2}

    dialog:add(dialog_box, dialog_text)
    if note then dialog:add(dialog_note) end

    local button_off = Image{src = "assets/buttons/button-5-[off].png", opacity=0}
    local button_on = Image{src = "assets/buttons/button-5-[on].png", opacity=0}
    screen:add(button_off, button_on)

    local first_text = Text{
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local second_text = Text{
        font = MENU_FONT,
        color = Colors.WHITE
    }
    if id == Components.NO_MOVES_DIALOG then
        first_text.text = "Continue"
        second_text.text = "New Deal"
    else
        first_text.text = "No"
        second_text.text = "Yes"
    end 

    local focusable_items = {
        FocusableImage(-300,-10,Clone{source=button_off},
                       Clone{source=button_on},first_text),
        FocusableImage(10,-10,Clone{source=button_off},
                       Clone{source=button_on},second_text)
    }

    for i,item in ipairs(focusable_items) do
        dialog:add(item.group)
    end
    local dialog_ui = Group()
    dialog_ui:add(mask, dialog)
    screen:add(dialog_ui)

    local selector = 1

    function self:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            controller:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            if controller:is_active_component() then
                dialog_ui.opacity = 255
                for i,item in ipairs(focusable_items) do
                    if i == selector then
                        item:on_focus()
                        item.text.color = Colors.BLACK
                    else
                        item:off_focus()
                        item.text.color = Colors.WHITE
                    end
                end
            else
                dialog_ui.opacity = 0
            end
        end
    end

    function controller:run_callback()
        if id == Components.NO_MOVES_DIALOG then
            if selector == 1 then
                router:set_active_component(Components.GAME)
                router:notify()
            elseif selector == 2 then
                router:delegate(ResetEvent(), Components.GAME)
            else
                error("selector not in a correct position")
            end
        elseif id == Components.AUTO_COMPLETE_DIALOG then
            if selector == 1 then
                router:set_active_component(Components.GAME)
                router:notify()
            elseif selector == 2 then
                router:set_active_component(Components.MENU)
                router:notify()
                game:auto_complete()
                game:get_state():set_must_restart(true)
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
