GamePresentation = Class(nil,
function(pres, ctrl, camera)
    local ctrl = ctrl
    local camera = camera


------------ Load the Assets -------------


    local backgrounds = {
        ""
    }
    local current_background = Image{src=backgrounds[1], name="background"}
    local background = Group()
    background:add(current_background)
    --background.anchor_point = {current_background.w/2, current_background.h/2}
    --background.position = {1920/2, 1080/2}

    local distance = Text{
        text = "0",
        position = {1700, 40},
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR
    }

    local ui = Group()
    ui:add(background, distance)

    screen:add(ui)

------------- Physics stuff ---------------


    ---------- Ground --------------------
    GROUND_HEIGHT = 101

    local ground = Rectangle{
        size = {screen.w*2, GROUND_HEIGHT},
        color = Colors.PERU,
        position = {screen.w/2, screen.h - 101}
    }
    ground.anchor_point = {ground.w/2, 0}

    screen:add(ground)
    camera:add(ground)
    camera:set_x_movement(ground, false)
    physics:Body(ground, {type = "static", friction = 1, bounce = .4})

    ----------------- Zombie -------------------------

    local zombie = nil
    local chest = nil

    ----------------- Gun ----------------------------


    local bullets = {}
    local bullet = Rectangle{w = 4, h = 4, opacity = 0}
    screen:add(bullet)
    local clone
    for i = 1,10 do
        clone = Clone{
            source=bullet,
            position = {3*i + 490, CHEST_POSITION[2] - 3*i + 400}
        }
        table.insert(bullets, clone)
        screen:add(clone)
        camera:add(clone)
        physics:Body(clone, {density = 50, bounce = .2, awake = false})
    end


    ----------------- Trampolene ---------------------

--[[
    local tramp = Rectangle{w = 200, h = 8, position = {chest.x+70, ground.y-ground.h/2}}
    tramp.anchor_point = {tramp.w, tramp.h}
    screen:add(tramp)
    camera:add(tramp)
    physics:Body(tramp, {type="static", friction = 1, density = 1, bounce = 3})
--]]

    local collidable_objects


------------- Layout Mutators -----------------


    function change_background(background_number)
        assert(background)
        assert(type(background_number) == "number")
        current_background:unparent()
        current_background = nil
        current_background = Image{
            src=backgrounds[background_number],
            name="background"
        }
        background:add(current_background)
    end

   
------------- Game Flow Functions ------------------


    function pres:display_ui()
        zombie = game:get_zombie()
        zombie:draw()
        zombie:make_physics()
        chest = zombie:get_chest()
        camera:set_focus(chest)
        
        collidable_objects = CollidableObjects(ground, zombie:get_zombie_parts())
        
        --gameloop:add(chest, 100000, nil, {x = Interval(chest.x, 10000)})
        --game:get_physics_monitor():check_velocity(chest)
    end

    function pres:reset()
    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end
        
        local selector = ctrl:get_selector()
        local comp = router:get_active_component()

        if game:get_state():must_restart() then return end
        if comp ~= Components.GAME then
        else
        end
    end

    function pres:move(dir)
        if -1 == dir[2] then
            chest:apply_linear_impulse({0, -5}, chest.position)
        elseif 1 == dir[2] then
            chest:apply_linear_impulse({0, 5}, chest.position)
        elseif 1 == dir[1] then
            chest:apply_linear_impulse({5, 0}, chest.position)
        elseif -1 == dir[1] then
            chest:apply_linear_impulse({-5, 0}, chest.position)
        else
            error("shouldn't be here")
        end
    end

    function pres:set_distance(dist)
        distance.text = string.format("%.2f", dist)
    end

    function pres:shoot()
        for i,bullet in ipairs(bullets) do
            bullet:apply_linear_impulse({50, -50}, {bullet.x, bullet.y})
            function bullet:on_begin_contact(contact)
                if contact.other_body[bullet.handle] == chest.handle then
                    game:get_physics_monitor():check_velocity(chest)
                end
            end
        end
    end

    function pres:choose_focus()
    end

    local end_game_image
    function pres:show_end_game()
        end_game_image = Image{
            src="",
            position={screen.width/2, screen.height/2}
        }
        end_game_image.anchor_point = {end_game_image.width/2, end_game_image.height/2}

        screen:add(end_game_image)
        mediaplayer:play_sound("")
    end

    function pres:hide_end_game()
        end_game_image:unparent()
        end_game_image = nil
        collectgarbage("collect")
    end
end)
