RemoteBettingController = Class(Controller,
function(ctrl, router, controller, ...)
    ctrl._base.init(ctrl, controller.router, RemoteComponents.BETTING)
    controller.router:attach(ctrl, RemoteComponents.BETTING)

    local x_ratio = controller.x_ratio
    local y_ratio = controller.y_ratio

    local view = controller.factory:Group()
    local betting_buttons_view = controller.factory:Group()

    local buttons = controller.factory:Image{
        src = "buttons",
        y = 500*y_ratio,
        size = {640*x_ratio, 247*y_ratio}
    }
    local wooden_bar = controller.factory:Image{
        src = "wooden_bar",
        position = {0, (6*115+86)*y_ratio},
        size = {640*x_ratio, 95*y_ratio}
    }

    local continue_button = RemoteButton(
        controller, "continue_button", "continue_button_on",
        {640/2*x_ratio, (870/2 + 100)*y_ratio}, {216*x_ratio, 59*y_ratio}
    )
    continue_button.group.anchor_point = {
        216/2*x_ratio, 59/2*y_ratio
    }

    local check_button = RemoteButton(
        controller, "check_button_off_touch", "check_button_on_touch",
        {257*x_ratio, 592*y_ratio}, {154*x_ratio, 55*y_ratio}
    )
    local call_button = RemoteButton(
        controller, nil, "call_button_on_touch",
        {261*x_ratio, 592*y_ratio}, {145*x_ratio, 55*y_ratio}
    )

    local betting_buttons = {
        fold = RemoteButton(
            controller, nil, "fold_button_on_touch",
            {74*x_ratio, 592*y_ratio}, {145*x_ratio, 55*y_ratio}
        ),
        call = call_button,
        bet = RemoteButton(
            controller, nil, "bet_button_on_touch",
            {447*x_ratio, 592*y_ratio}, {108*x_ratio, 55*y_ratio}
        ),
        plus = RemoteButton(
            controller, nil, "plus_button_on_touch",
            {481*x_ratio, 514*y_ratio}, {35*x_ratio, 34*y_ratio}
        ),
        minus = RemoteButton(
            controller, nil, "minus_button_on_touch",
            {481*x_ratio, 692*y_ratio}, {35*x_ratio, 34*y_ratio}
        )
    }

    local wooden_buttons = {
        exit = controller.factory:Image{
            src = "exit_button",
            position = {40*x_ratio, 793*y_ratio},
            size = {124*x_ratio, 62*y_ratio}
        },
        new_game = controller.factory:Image{
            src = "new_game_button",
            position = {238*x_ratio, 793*y_ratio},
            size = {164*x_ratio, 62*y_ratio}
        },
        help = controller.factory:Image{
            src = "help_button",
            position = {475*x_ratio, 793*y_ratio},
            size = {124*x_ratio, 62*y_ratio}
        }
    }

    local folded_text = controller.factory:Image{
        src = "folded_text",
        position = {0, 870*y_ratio/2},
        size = {640*x_ratio, 86*y_ratio},
        anchor_point = {0, 86*y_ratio/2}
    }
    folded_text:hide()

    betting_buttons_view:add(buttons, check_button.group, betting_buttons.fold.group,
        betting_buttons.call.group, betting_buttons.bet.group,
        betting_buttons.plus.group, betting_buttons.minus.group)
    view:add(betting_buttons_view, wooden_bar, wooden_buttons.exit,
        wooden_buttons.new_game, wooden_buttons.help, folded_text, continue_button.group)

    check_button:hide()

    controller.screen:add(view)

    local card1, card2
    function ctrl:set_hole_cards(hole)
        if card1 then card1:unparent() end
        if card2 then card2:unparent() end

        card1 = controller.factory:Image{
            src = getCardImageName(hole[1]),
            position = {60*x_ratio, 70*y_ratio},
            size = {300*x_ratio, 390*y_ratio}
        }
        card2 = controller.factory:Image{
            src = getCardImageName(hole[2]),
            position = {280*x_ratio, 90*y_ratio},
            size = {300*x_ratio, 390*y_ratio}
        }
        view:add(card1, card2)
        a_card1 = card1
        a_card2 = card2
    end

    continue_button.callback = function()
        continue_button:reset()
        screen:on_key_down(keys.OK)
    end
    function ctrl:end_hand()
        continue_button:show()
        continue_button.group:raise_to_top()
        betting_buttons_view:hide()
    end

    function ctrl:fold()
        folded_text:show()
        betting_buttons_view:hide()

        card1:animate{
            x = 60*x_ratio-200*x_ratio,
            y = 70*y_ratio-200*y_ratio,
            z_rotation = 30,
            duration = 800
        }
        card2.z_rotation = {0, 250*x_ratio, 0}
        card2:animate{
            x = 280*x_ratio+200*x_ratio,
            y = 90*y_ratio-200*y_ratio,
            z_rotation = -30,
            duration = 800
        }
    end

    function ctrl:call_or_check(string)
        if string == "check" then
            betting_buttons.call = check_button
            check_button:show()
            check_button:reset()
            call_button:hide()
        else
            betting_buttons.call = call_button
            call_button:show()
            call_button:reset()
            check_button:hide()
        end
    end

    function ctrl:on_touch(event)
        if event.controller == controller then
            local button_name = event.pos
            local button = betting_buttons[button_name]
            if button then
                button.callback = function()
                    button:reset()
                    if event.cb then event:cb() end
                end
                if button_name == "fold" then
                    local lambda = button.callback
                    button.callback = function()
                        ctrl:fold()
                        lambda()
                    end
                end
                button:press()
            elseif button_name == "continue" then
                continue_button:press()
                if event.cb then event:cb() end
            end
        end
    end

    function ctrl:notify(event)
        if ctrl:is_active_component() then
            betting_buttons_view:show()
            folded_text:hide()
            continue_button:hide()
            view:show()
        else
            betting_buttons_view:show()
            folded_text:hide()
            view:hide()
        end
    end

    function ctrl:reset()
        for _,button in pairs(betting_buttons) do
            button:reset()
        end
    end

end)
