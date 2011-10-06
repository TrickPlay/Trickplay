GamePresentation = Class(nil,
function(pres, ctrl, camera)
    local ctrl = ctrl
    local camera = camera


------------ Load the Assets -------------

    local STAR_WIDTH = 400
    local STAR_HEIGHT = 400
    local stars = Image{
        src = "assets/background/star-tile.jpg",
        w = 1920+STAR_WIDTH*2+100, h = 1080+STAR_HEIGHT*2+100, tile = {true, true}
    }
    stars.anchor_point = {stars.w/2, stars.h/2}
    stars.position = {screen.w/2, screen.h/2}

    SHOOTER_POSITION = {200, 700}
    local shooter = Group{position = {200, 700}}
    local shooter_body = Image{src = "assets/shooter/body.png"}
    local shooter_arms = Image{src = "assets/shooter/arms.png"}
    local blam = Image{src = "assets/shooter/blam.png", x = -110, y = -200,
        opacity = 0}
    local gun_blast = Image{src = "assets/shooter/gun-blast.png", x = 130, y = 22,
        opacity = 0}
    local total_gun = Group{children = {gun_blast, shooter_arms}, x = 139-51, y = 82}
    shooter_arms.anchor_point = {shooter_arms.w/2, 0}
    shooter:add(blam, shooter_body, total_gun)

    local distance_backdrop = Image{
        src = "assets/meter-bkgd.png",
        position = {1482, 26},
        size = {411, 52}
    }
    local distance_x = Text{
        markup = '<span letter_spacing = "-2024">Distance: 0</span>',
        position = {1500, 40},
        font = DEFAULT_FONT,
        color = Colors.BLACK
    }
    local distance_y = Text{
        markup = '<span letter_spacing = "-2024">Height: 0ft</span>',
        position = {1720, 40},
        font = DEFAULT_FONT,
        color = Colors.BLACK
    }

    local height_ui = Group{
        position = {1800, 200}
    }
    for i = 1,4 do
        height_ui:add(
            Rectangle{
                size = {40, 60},
                y = 60*(i-1),
                color = 32^i
            }
        )
    end
    local height_bar = Rectangle{
        size = {40, 10},
        color = Colors.RED,
        y = 60*4
    }
    height_ui:add(height_bar)

    local ui = Group()
    ui:add(distance_backdrop, distance_x, distance_y)--, height_ui)

    screen:add(ui)

------------- Physics stuff ---------------

    local distance = 0
    local max_height = 0

    ---------- Ground --------------------
    GROUND_HEIGHT = 100

    local ground = Rectangle{
        size = {screen.w*2, GROUND_HEIGHT},
        color = Colors.PERU,
        position = {screen.w/2, screen.h - GROUND_HEIGHT/2},
        opacity = 0
    }
    ground.anchor_point = {ground.w/2, ground.h/2}

    GROUND_POSITION = Utils.deepcopy(ground.position)

    screen:add(ground)
    camera:add(ground)
    camera:set_x_movement(ground, false)
    physics:Body(ground, {type = "static", friction = 1, bounce = .4})


    ----------------- Zombie -------------------------

    local zombie = nil
    local chest = nil

    ----------------- Gun ----------------------------


    local bullets = {}
    local bullet = Rectangle{w = 4, h = 4, opacity = 0, color = Colors.ERASER_RUST}
    screen:add(bullet)
    local function make_bullets()
        for _,bullet in ipairs(bullets) do
            camera:remove(bullet)
            screen:remove(bullet)
            bullet.on_begin_contact = nil
        end

        bullets = {}
        local clone
        for i = 1,10 do
            clone = Clone{
                source = bullet,
                name = "bullet",
                position = {shooter.x + 3*i + 98, shooter.y + shooter_arms.y + 145}
            }
            table.insert(bullets, clone)
            screen:add(clone)
            camera:add(clone)
            physics:Body(clone, {density = 50, bounce = .2, awake = false})
        end
    end
    make_bullets()


------------- Other Vars ----------------------


    local collidable_objects
    local scenemng
    local audiomng
    local bullet_theta = 0


------------- Getters/Setters -----------------


    function pres:get_ground() return ground end


------------- Game Flow Functions ------------------


    function pres:display_ui()
        audiomng = game:get_audio_manager()

        game:get_state():set_ground(ground)

        zombie = game:get_zombie()
        zombie:draw()
        zombie:make_physics()
        chest = zombie:get_chest()
        camera:set_focus(chest)

        screen:add(shooter)
        camera:add(shooter)
       
        collidable_objects = CollidableObjects(ground, zombie)

        scenemng = SceneManager(camera, collidable_objects)
        scenemng:start()

        pres:show_stars()
    end

    function pres:reset()
        distance = 0
        max_height = 0
        bullet_theta = 0

        -- put the ground in the correct place
        ground.position = Utils.deepcopy(GROUND_POSITION)
        
        -- zombie stuff
        --zombie:delete()
        zombie = game:new_zombie()
        zombie:draw()
        zombie:make_physics()
        chest = zombie:get_chest()

        -- shooter
        pres:reset_shooter()

        -- other
        camera:set_focus(chest)
        camera:start()

        distance_x.markup = '<span letter_spacing = "-2024">Distance: 0ft</span>'
        distance_y.markup = '<span letter_spacing = "-2024">Height: 0ft</span>'

        collidable_objects:delete()
        collidable_objects = CollidableObjects(ground, zombie)

        scenemng:reset(collidable_objects)
        scenemng:start()
        
        pres:show_stars()

    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end
        stars:lower_to_bottom()
    end

    function pres:move(dir)
        if -1 == dir[2] then
            chest:apply_linear_impulse({0, -45}, chest.position)
        elseif 1 == dir[2] then
            chest:apply_linear_impulse({0, 45}, chest.position)
        elseif 1 == dir[1] then
            chest:apply_linear_impulse({35, 0}, chest.position)
        elseif -1 == dir[1] then
            chest:apply_linear_impulse({-35, 0}, chest.position)
        else
            error("shouldn't be here")
        end
    end

    local function new_stars()
        if stars.x > screen.w/2 + STAR_WIDTH
        or stars.x < screen.w/2 - STAR_WIDTH then
            stars.x = screen.w/2
        end
        if stars.y > screen.h/2 + STAR_HEIGHT
        or stars.y < screen.h/2 - STAR_HEIGHT then
            stars.y = screen.h/2
        end
    end

    function pres:show_stars()
        if not stars.parent then
            screen:add(stars)
        end
        camera:add(stars)
        gameloop:add_idle(new_stars)
        stars:lower_to_bottom()
    end

    local x_ref = shooter.x + shooter_arms.x
    local y_ref = shooter.y + shooter_arms.y
    function pres:move_gun(dir)
        bullet_theta = Utils.clamp(-26, bullet_theta + dir[2], 0)
        total_gun.z_rotation = {
            bullet_theta,
            0,
            0
        }

        local r
        for i,bullet in ipairs(bullets) do
            r = math.sqrt((bullet.x-(x_ref+95))^2 + (bullet.y - (y_ref+150))^2)
            bullet.x = r*math.cos(bullet_theta*DEGREE_TO_RAD) + x_ref + 95
            bullet.y = r*math.sin(bullet_theta*DEGREE_TO_RAD) + y_ref + 150
        end
    end

    function pres:reset_shooter()
        distance_backdrop:show() distance_x:show() distance_y:show()
        blam.opacity = 0
        gun_blast.opacity = 0
        shooter.position = Utils.deepcopy(SHOOTER_POSITION)
        total_gun.z_rotation = {
            bullet_theta,
            0,
            0
        }
        make_bullets()
        shooter:raise_to_top()
    end

    function pres:set_distance(dist)
        distance = dist[1]
        max_height = math.max(dist[2],max_height)

        distance_x.markup = '<span letter_spacing = "-2024">Distance: '..string.format("%.0f", distance)..'ft</span>'
        distance_y.markup = '<span letter_spacing = "-2024">Height: '..string.format("%.0f", max_height)..'ft</span>'

        --height_bar.y = Utils.clamp(0, (ground.y-chest.y)*60/screen.h, 60*4)
        --height_bar.y = 60*4-height_bar.y
    end

    function pres:shoot()
        disable_kbd()
        audiomng:play_file("assets/audio/ShotgunFire_with_Echo.mp3", 200)
        local timer = Timer()
        timer.interval = 300
        function timer:on_timer()
            timer:stop()
            timer.on_timer = nil

            blam.opacity = 255
            gun_blast.opacity = 255
            for i,bullet in ipairs(bullets) do
                bullet:apply_linear_impulse(
                    {50*math.cos(bullet_theta*DEGREE_TO_RAD),
                    50*math.sin(bullet_theta*DEGREE_TO_RAD)},
                    {bullet.x, bullet.y}
                )
                function bullet:on_begin_contact(contact)
                    for k,part in pairs(zombie:get_zombie_parts()) do
                        if contact.other_body[bullet.handle] == part.handle then
                            game:get_physics_monitor():check_velocity(chest)
                            chest:apply_linear_impulse({300, -50}, {part.x, part.y})
                        end
                    end
                end
            end
        end
        timer:start()
    end

    function pres:show_end_game(router)
        distance_backdrop:hide() distance_x:hide() distance_y:hide()
        EndGame(router, distance, max_height)
        router:set_active_component(Components.GAME_OVER)
    end

    function pres:hide_end_game()
    end

end)
