RemoteCharacterSelectionController = Class(Controller,
function(ctrl, router, controller, ...)
    ctrl._base.init(ctrl, controller.router, RemoteComponents.CHOOSE_DOG)
    controller.router:attach(ctrl, RemoteComponents.CHOOSE_DOG)

    local x_ratio = controller.x_ratio
    local y_ratio = controller.y_ratio

    local view = controller.factory:Group()
    local dog_buttons = {}
    for i = 1,6 do
        local position = {
            (((i-1)%2)*(256+8)+60)*x_ratio,
            (math.floor((i-1)/2)*256+100)*y_ratio
        }
        local size = {256*x_ratio, 256*y_ratio}
        dog_buttons[i] = RemoteButton(controller, "dog_"..i, "chip_touch",
            position, size)
        view:add(dog_buttons[i].group)
        dog_buttons[i].focus.position = {
            dog_buttons[i].focus.x+(2*x_ratio),   
            dog_buttons[i].focus.y-(11*y_ratio)
        }
    end
    view:add(controller.factory:Image{
        src = "hdr_choose_dog",
        position = {95*x_ratio, 30*y_ratio},
        size = {450*x_ratio, 50*y_ratio}
    })
    controller.screen:add(view)
    
    function ctrl:init_character_selection(players)
        if not players then error("no players", 2) end
        local playing = {}
        for i,player in pairs(players) do
            local pos = player.dog_number
            dog_buttons[pos]:hide()
            playing[pos] = true
        end
        print("hereish")
        dumptable(playing)
        for i = 1,6 do
            if not playing[i] then
                dog_buttons[i]:show()
            end
        end
    end

    function ctrl:update_character_selection(player)
        local pos = player.dog_number
        dog_buttons[pos]:hide()
    end

    function ctrl:on_touch(event)
        local comp = event.controller.router:get_active_component()
        if comp ~= RemoteComponents.CHOOSE_DOG
        and comp ~= RemoteComponents.WAITING then
            return
        end

        local button = dog_buttons[event.pos]
        if event.controller == controller then
            button.callback = function()
                button:hide()
                if event.cb then event:cb() end
            end
            button:press()
        else
            button:hide()
        end
    end

    function ctrl:notify(event)
        if ctrl:is_active_component() then
            view:show()
        else
            view:hide()
        end
    end

    function ctrl:reset()
        for _,button in pairs(dog_buttons) do
            button:reset()
        end
    end

end)
