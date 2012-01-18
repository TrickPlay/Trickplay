SEAT_BUTTON_POSITIONS = {
    [1] = {480, 691},
    [2] = {480, 396},
    [3] = {674, 349},
    [4] = {1120, 349},
    [5] = {1308, 396},
    [6] = {1308, 691}
}

SeatButtonView = Class(nil,
function(seat_button, button_number, ...)
    assert(button_number > 0 and button_number <= 6)

    local button_image_name = "seat_button_"..button_number
    local button_on_image_name = "seat_button_on_"..button_number
    local button_seat_chosen_image_name = "seat_button_chosen_"..button_number
    local button_seat_chosen_on_image_name = "seat_button_chosen_on_"..button_number

    if not assetman:has_image_of_name(button_image_name) then
        assetman:load_image("assets/new_buttons/ButtonSeat.png", button_image_name)
    end
    if not assetman:has_image_of_name(button_on_image_name) then
        assetman:load_image("assets/new_buttons/ButtonSeat-on.png",
            button_on_image_name)
    end
    if not assetman:has_image_of_name(button_seat_chosen_image_name) then
        assetman:load_image("assets/new_buttons/ButtonSeatChosen.png",
            button_seat_chosen_image_name)
    end
    if not assetman:has_image_of_name(button_seat_chosen_on_image_name) then
        assetman:load_image("assets/new_buttons/ButtonSeatChosen-on.png",
            button_seat_chosen_on_image_name)
    end

    local button_clone = assetman:get_clone(button_image_name)
    local button_on_clone = assetman:get_clone(button_on_image_name, {opacity = 0})
    local button_seat_chosen_clone =
        assetman:get_clone(button_seat_chosen_image_name, {opacity = 0})
    local button_seat_chosen_on_clone =
        assetman:get_clone(button_seat_chosen_on_image_name, {opacity = 0})

    button_seat_chosen_clone.x = 10
    button_seat_chosen_clone.y = 10

    seat_button.view = assetman:create_group({
        name = "seat_button_"..button_number,
        x = SEAT_BUTTON_POSITIONS[button_number][1],
        y = SEAT_BUTTON_POSITIONS[button_number][2],
        children = {
            button_clone, button_on_clone,
            button_seat_chosen_clone, button_seat_chosen_on_clone
        }
    })

    local chosen = false
    local on_focus = false

    function seat_button:on_focus()
        button_clone.opacity = 0
        button_seat_chosen_clone.opacity = 0
        if chosen then
            button_on_clone.opacity = 0
            button_seat_chosen_on_clone.opacity = 255
        else
            button_on_clone.opacity = 255
            button_seat_chosen_on_clone.opacity = 0
        end

        on_focus = true
    end
    
    function seat_button:off_focus()
        button_on_clone.opacity = 0
        button_seat_chosen_on_clone.opacity = 0
        if chosen then
            button_clone.opacity = 0
            button_seat_chosen_clone.opacity = 255
        else
            button_clone.opacity = 255 
            button_seat_chosen_clone.opacity = 0
        end

        on_focus = false
    end

    function seat_button:pressed()
        chosen = true
        if on_focus then
            self:on_focus()
        else
            self:off_focus()
        end
    end

    function seat_button:reset()
        chosen = false
        self:off_focus()
    end

    function seat_button:hide()
        self.view:hide()
    end

    function seat_button:show()
        self.view:show()
    end

end)
