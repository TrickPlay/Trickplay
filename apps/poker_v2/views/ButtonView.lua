HELP_MENU_POSITION = {635, 744}
START_MENU_POSITION = {860, 766}
EXIT_MENU_POSITION = {1088, 743}

FOLD_POSITION = {655, 766}
NEW_DEAL_POSITION = {700, 911}
EXIT_POSITION = {1065, 911}
HELP_POSITION = {908,911}
CALL_POSITION = {810,766}
BET_POSITION = {971,743}
UP_POSITION = {994,744}
DOWN_POSITION = {994, 840}


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

end)
