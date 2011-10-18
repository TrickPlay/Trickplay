HelpScreen = Class(Controller, function(self, router, ...)
    local id = Components.HELP
    self._base.init(self, router, id)

    local controller = self

    local mask = Canvas{
        size = {1882, 920}
    }
    mask:begin_painting()
    mask:set_source_color("92D88B")
    mask:round_rectangle(0, 0, 1882, 920, 15)
    mask:set_source_radial_pattern(
        20+mask.w/2, 140+mask.h, 50,
        20+mask.w/2, 140+mask.h, 900
    )
    mask:add_source_pattern_color_stop(0, "92D88B")
    mask:add_source_pattern_color_stop(1, "00601B")
    mask:fill()
    mask:finish_painting()
    if mask.Image then
        mask = mask:Image()
    end
    mask.position = {20, 140}
    local border_mask = Canvas{
        size = {1894, 932}
    }
    border_mask:begin_painting()
    border_mask:set_source_color("FFFFFF")
    border_mask:round_rectangle(0, 0, 1894, 932, 15)
    border_mask:fill()
    border_mask:finish_painting()
    if border_mask.Image then
        border_mask = border_mask:Image()
    end
    border_mask.position = {14, 134}
    border_mask.opacity = 128

    local text_left = Text{
        text = "Your goal is to stack cards in descending numerical order "..
                "and alternating suit colors.\n\nUse arrow keys to navigate the "..
                "board. Press ENTER to: 1) move a card or a stack of cards from "..
                "one row stack to another 2) move a card from either the deck "..
                "or a row stack to a suit stack 3) move aces to the\nfree spaces "..
                "at the upper right of the screen. ",
        position = {100, 215},
        size = {800, 340},
        font = "DejaVu Sans 32px",
        color = Colors.WHITE,
        wrap = true
    }
    local text_right = Text{
        text = "The face up card on the deck is always available for play. "..
                "If a stack is empty you can move a king, along with any cards "..
                "that might be in its stack, to it.\n\nWhen you have made all "..
                "available plays on the board, click the deck to turn over more "..
                "cards. Once you draw through the entire deck it may be recycled "..
                " and used again. ",
        position = {1005, 215},
        size = {800, 340},
        font = "DejaVu Sans 32px",
        color = Colors.WHITE,
        wrap = true
    }
    local help_button = FocusableImage(
        970, 970,
        Image{src = "assets/buttons/button-5-[on].png"},
        nil,
        Text{text = "Done", font = "DejaVu Sans Condensed normal 32px", color = Colors.BLACK}
    )
    help_button.group.anchor_point = {help_button.group.w/2, help_button.group.h/2}
    help_button.text.y = help_button.text.y
    local left_image = Image{
        src = "assets/help/HelpTableau.png",
        position = {280, 560}
    }
    local center_image = Image{
        src = "assets/help/HelpKing.png",
        position = {1005, 560}
    }
    local right_image = Image{
        src = "assets/help/HelpDeck.png",
        position = {1390, 560}
    }
    local help_ui = Group{name="help_ui"}
    help_ui:add(
        border_mask, mask, help_button.group, text_left, text_right,
        center_image, right_image, left_image
    )
    screen:add(help_ui)

    local selector = 1

    function self:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            controller:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            if controller:is_active_component() then
                help_ui.opacity = 255
            else
                help_ui.opacity = 0
            end
        end
    end

    function controller:run_callback()
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

    function controller:move_selector(dir)
    end

end)
