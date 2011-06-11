RemoteWaitingRoomController = Class(Controller,
function(ctrl, router, controller, ...)
    ctrl._base.init(ctrl, controller.router, RemoteComponents.WAITING)
    controller.router:attach(ctrl, RemoteComponents.WAITING)

    local x_ratio = controller.x_ratio
    local y_ratio = controller.y_ratio

    local view = controller.factory:Group()
    controller.screen:add(view)

    local waiting_text = controller.factory:Image{
        src = "waiting_text",
        position = {0, 0},
        size = {640*x_ratio, 86*y_ratio}
    }
    view:add(waiting_text)
    for i = 1,6 do
        view:add(controller.factory:Image{
            src = "player_"..i,
            position = {0, ((i-1)*115+86)*y_ratio},
            size = {640*x_ratio, 115*y_ratio}
        })
    end
    view:add(controller.factory:Image{
        src = "wooden_bar",
        position = {0, (6*115+86)*y_ratio},
        size = {640*x_ratio, 95*y_ratio}
    })
    view:add(controller.factory:Image{
        src = "start_button",
        position = {(320-206/2)*x_ratio, (6*115+106)*y_ratio},
        size = {206*x_ratio, 62*y_ratio}
    })

    local ready_labels = {}
    local human_labels = {}
    local comp_labels = {}
    local click_labels = {}
    for i = 1,6 do
        ready_labels[i] = controller.factory:Image{
            src = "ready_label",
            position = {167*x_ratio, ((i-1)*115+86+60)*y_ratio},
            size = {122*x_ratio, 34*y_ratio}
        }
        human_labels[i] = controller.factory:Image{
            src = "human_label",
            position = {330*x_ratio, ((i-1)*115+86+60)*y_ratio},
            size = {122*x_ratio, 34*y_ratio}
        }
        comp_labels[i] = controller.factory:Image{
            src = "comp_label",
            position = {330*x_ratio, ((i-1)*115+86+60)*y_ratio},
            size = {196*x_ratio, 34*y_ratio}
        }
        click_labels[i] = controller.factory:Image{
            src = "click_label",
            position = {167*x_ratio, ((i-1)*115+86+60)*y_ratio},
            size = {196*x_ratio, 34*y_ratio}
        }
        view:add(ready_labels[i], human_labels[i], comp_labels[i], click_labels[i])
    end

    function ctrl:initialize_waiting_room(players)
        if not players then error("no players", 2) end
        local playing = {}
        for i,player in pairs(players) do
            local pos = player.dog_number
            click_labels[pos]:hide()
            ready_labels[pos]:show()
            if player.is_human then
                human_labels[pos]:show()
                comp_labels[pos]:hide()
            else
                human_labels[pos]:hide()
                comp_labels[pos]:show()
            end
            playing[pos] = true
        end
        for i = 1,6 do
            if not playing[i] then
                click_labels[i]:show()
                human_labels[i]:hide()
                comp_labels[i]:hide()
                ready_labels[i]:hide()
            end
        end
    end

    function ctrl:update_waiting_room(player)
        local pos = player.dog_number
        click_labels[pos]:hide()
        ready_labels[pos]:show()
        if player.is_human then
            human_labels[pos]:show()
        else
            comp_labels[pos]:show()
        end
    end

    function ctrl:on_touch(event)
    end

    function ctrl:notify(event)
        if ctrl:is_active_component() then
            ctrl:initialize_waiting_room(
                router:get_controller(Components.CHARACTER_SELECTION):get_players()
            )
            view:show()
        else
            view:hide()
        end
    end

    function ctrl:reset()
    end

end)
