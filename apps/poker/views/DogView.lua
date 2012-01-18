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

    local default_dog = dog_clone
    local default_glow = dog_glow_clone

    local pressed = false

    function dog_view:edit_images(image)
        if dog_clone ~= default_dog or dog_glow_clone ~= default_glow then
            error("Call reset_images first")
        end

        -- load in the frame assets
        local image_name = "frame"
        local glow_image_name = "frame_glow"
        if not assetman:has_image_of_name(image_name) then
            assetman:load_image("assets/camera/frame-focus-off.png",
                image_name)
        end
        if not assetman:has_image_of_name(glow_image_name) then
            assetman:load_image("assets/camera/frame-focus-on.png",
                glow_image_name)
        end
    
        image.anchor_point = {image.w/2, image.h/2}

        -- remove the current dog assets from the screen
        dog_clone:unparent()
        dog_glow_clone:unparent()

        -- add the new ones
        dog_clone = assetman:get_clone(image_name)
        image.x = dog_clone.w/2
        image.y = dog_clone.h/2
        image.clip = {
            image.w/2 - (dog_clone.w/2-32),
            image.h/2 - (dog_clone.h/2-33),
            212,
            169
        }
        dog_clone = assetman:create_group({
            name = "dog_"..tostring(dog_number).."_frame",
            children = {image, dog_clone}
        })
        dog_glow_clone = assetman:get_clone(glow_image_name)

        dog_clone.opacity = default_dog.opacity
        dog_glow_clone.opacity = default_glow.opacity

        dog_view.view:add(dog_clone)
        dog_view.view:add(dog_glow_clone)
    end

    function dog_view:reset_images()
        if dog_clone == default_dog and  dog_glow_clone == default_glow then
            return
        end
        if dog_clone == default_dog or dog_glow_clone == default_glow then
            error("error changing images led to inconsistant DogView state")
        end

        -- get rid of the changed images
        dog_clone.children[1]:unparent()
        dog_clone:dealloc()
        dog_glow_clone:dealloc()
        
        -- set the current state of the images to the default images
        default_dog.opacity = dog_clone.opacity
        default_glow.opacity = dog_glow_clone.opacity

        -- reset to the default images
        dog_clone = default_dog
        dog_glow_clone = default_glow

        dog_view.view:add(dog_glow_clone)
        dog_view.view:add(dog_clone)
    end

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
        self:reset_images()

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
