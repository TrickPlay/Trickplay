HELP_MENU_POSITION = {635, 744}
START_MENU_POSITION = {860, 766}
EXIT_MENU_POSITION = {1088, 743}

BETTING_BUTTON_POSITIONS = {
    FOLD = {655, 766},
    NEW_DEAL = {700, 911},
    EXIT = {1065, 911},
    HELP = {908,911},
    CALL = {810,766},
    BET = {971,743},
    UP = {994,744},
    DOWN = {994, 840}
}

ButtonView = Class(nil,
function(button_view, button_type, x, y, ...)
    if not type(button_type) == "string" then
        error("button_type must be a string", 2)
    end
    if type(x) ~= "number" or type(y) ~= "number" then
        error("must provide number values for x and y", 2)
    end
    
    if not assetman:has_image_of_name(button_type) then
        if button_type == "start_button" then
            assetman:load_image("assets/new_buttons/ButtonStart.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonStart-on.png",
                button_type.."_on")
        elseif button_type == "help_button" then
            assetman:load_image("assets/new_buttons/ButtonHelp.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonHelp-on.png",
                button_type.."_on")
        elseif button_type == "exit_button" then
            assetman:load_image("assets/new_buttons/ButtonExit.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonExit-on.png",
                button_type.."_on")
        elseif button_type == "new_deal_button" then
            assetman:load_image("assets/new_buttons/ButtonNewDeal.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonNewDeal-on.png",
                button_type.."_on")
        elseif button_type == "fold_button" then
            assetman:load_image("assets/new_buttons/ButtonFold.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonFold-on.png",
                button_type.."_on")
        elseif button_type == "call_button" then
            assetman:load_image("assets/new_buttons/ButtonCall.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonCall-on.png",
                button_type.."_on")
            assetman:load_image("assets/new_buttons/ButtonCheck.png", "check_button")
            assetman:load_image("assets/new_buttons/ButtonCheck-on.png",
               "check_button_on")
        elseif button_type == "bet_button" then
            assetman:load_image("assets/new_buttons/ButtonBet.png", button_type)
            assetman:load_image("assets/new_buttons/ButtonBet-on.png",
                button_type.."_on")
        else
            error("this button type is non-existant", 2)
        end
    end

    local button_clone = assetman:get_clone(button_type)
    local button_on_clone = assetman:get_clone(button_type.."_on")

    button_view.view = assetman:create_group({
        x = x,
        y = y,
        children = {button_clone, button_on_clone}
    })

    function button_view:on_focus()
        button_on_clone.opacity = 255
        button_clone.opacity = 0
    end

    function button_view:off_focus()
        button_on_clone.opacity = 0
        button_clone.opacity = 255
    end

    function button_view:hide()
        button_view.view:hide()
    end

    function button_view:show()
        button_view.view:show()
    end

    function button_view:add(object)
        button_view.view:add(object)
    end

    ---- some special ecceptions for call button
    if button_type == "call_button" then
        local check_button_clone = assetman:get_clone("check_button")
        local check_button_on_clone = assetman:get_clone("check_button_on")
        local check_button_group = assetman:create_group({name = "check_button_group"})
        local call_button_group = assetman:create_group({name = "call_button_group"})

        button_on_clone:unparent()
        button_clone:unparent()
        check_button_group:add(check_button_clone, check_button_on_clone)
        call_button_group:add(button_clone, button_on_clone)

        button_view.view:add(check_button_group, call_button_group)

        check_button_group:hide()

        function button_view:on_focus()
            button_on_clone.opacity = 255
            button_clone.opacity = 0
            check_button_on_clone.opacity = 255
            check_button_clone.opacity = 0
        end

        function button_view:off_focus()
            button_on_clone.opacity = 0
            button_clone.opacity = 255
            check_button_on_clone.opacity = 0
            check_button_clone.opacity = 255
        end

        function button_view:switch_button_type(button)
            if button == "check" then
                call_button_group:hide()
                check_button_group:show()
            elseif button == "call" then
                call_button_group:show()
                check_button_group:hide()
            else
                error("messed up", 2)
            end
        end
    end

end)
