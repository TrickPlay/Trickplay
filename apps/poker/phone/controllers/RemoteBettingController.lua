RemoteBettingController = Class(Controller,
function(ctrl, router, controller, ...)
    ctrl._base.init(ctrl, controller.router, RemoteComponents.BETTING)
    controller.router:attach(ctrl, RemoteComponents.BETTING)

    local x_ratio = controller.x_ratio
    local y_ratio = controller.y_ratio

    local view = controller.factory:Group()

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

    local betting_buttons = {
        fold = RemoteButton(
            controller, nil, "fold_button_on_touch",
            {74*x_ratio, 592*y_ratio}, {145*x_ratio, 55*y_ratio}
        ),
        call = RemoteButton(
            controller, nil, "call_button_on_touch",
            {261*x_ratio, 592*y_ratio}, {145*x_ratio, 55*y_ratio}
        ),
        check = RemoteButton(
            controller, nil, "call_button_on_touch",
            {261*x_ratio, 592*y_ratio}, {154*x_ratio, 55*y_ratio}
        ),
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

    view:add(buttons, wooden_bar)
    for k,button in pairs(betting_buttons) do
        view:add(button.group)
    end

    controller.screen:add(view)

    blah = betting_buttons

    function ctrl:on_touch(event)
    end

    function ctrl:notify(event)
        if ctrl:is_active_component() then
            view:show()
        else
            view:hide()
        end
    end

    function ctrl:reset()
        for _,button in pairs(betting_buttons) do
            button:reset()
        end
    end

end)
