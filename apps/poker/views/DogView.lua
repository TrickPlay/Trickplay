DOG_POSITIONS = {
    [1] = {97, 740},
    [2] = {69, 74},
    [3] = {488, 8},
    [4] = {1191, 27},
    [5] = {1528, 116},
    [6] = {1356, 568}
}

DogView = Class(nil,
function(dog_view, dog_number, ...)
    assert(dog_number > 0 and dog_number <= 6)

    local image_name = "dog_"..tostring(dog_number)
    local glow_image_name = "dog_glow_"..tostring(dog_number)
    if assetman:has_image_of_name(image_name) then
        error("dog already exists", 2)
    end
    if assetman:has_image_of_name(glow_image_name) then
        error("dog glow already exists", 2)
    end

    assetman:load_image("assets/new_dogs/dog-"..dog_number..".png",
        image_name)
    assetman:load_image("assets/new_dogs/dog-"..dog_number.."-focus.png",
        glow_image_name)

    local dog_clone = assetman:get_clone(image_name)
    local dog_glow_clone = assetman:get_clone(glow_image_name)
    dog_view.view = assetman:create_group({
        name = "dog_"..tostring(dog_number),
        position = DOG_POSITIONS[dog_number],
        children = {dog_glow_clone, dog_clone}
    })

    local pressed = false

    function dog_view:off_focus()
        dog_glow_clone.opacity = 120
        if not pressed then
            dog_clone.opacity = 0
        end
    end

    function dog_view:on_focus()
        dog_glow_clone.opacity = 255
        dog_clone.opacity = 255
    end

    function dog_view:pressed()
        dog_clone.opacity = 255
        pressed = true
    end

    function dog_view:reset()
        dog_view.view:complete_animation()
        dog_clone:complete_animation()
        dog_glow_clone:complete_animation()

        pressed = false
        dog_view:off_focus()
        dog_clone.opacity = 0
    end

    function dog_view:dim()
        dog_clone:animate{opacity = 50, duration = 300}
        dog_glow_clone:animate{opacity = 0, duration = 300}
    end

    function dog_view:fade_out()
        dog_clone:animate{opacity = 0, duration = 300}
        dog_glow_clone:animate{opacity = 0, duration = 300}
    end

    function dog_view:fade_in()
        dog_clone:animate{opacity = 255, duration = 300}
    end

    function dog_view:glow_off()
        dog_glow_clone.opacity = 0
    end

    function dog_view:glow_on()
        dog_glow_clone.opacity = 255
    end

end)
