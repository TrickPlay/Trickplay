LENGTH_OF_SEPARATION = 400
OBJECT_START = 220

CollidableObject = Class(function(colldobj, ...)

    colldobj.images = {}
    colldobj.idles = {}

    function colldobj:delete()
        for i,image in ipairs(colldobj.images) do
            image:unparent()
            game:get_camera():remove(image)
            image.on_begin_contact = nil
        end
        for i,idle in ipairs(colldobj.idles) do
            gameloop:remove_idle(idle)
        end
    end

end)

local trampolene_image = Image{src = "assets/foreground/trampoline.png", opacity = 0}
screen:add(trampolene_image)
local Trampolene = Class(CollidableObject, function(tramp, number, ground, obj, ...)
    tramp._base.init(tramp)

    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local body = Rectangle{
        w = 480, h = 8,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-250
        },
        opacity = 0
    }
    local image = Clone{
        source = trampolene_image,
        position = {LENGTH_OF_SEPARATION*number + OBJECT_START, ground.y-ground.h/2-300}
    }
    table.insert(tramp.images, body)
    table.insert(tramp.images, image)

    screen:add(image, body)
    game:get_camera():add(image)
    game:get_camera():add(body)
    physics:Body(image, {type="static", density = 1, bounce = 10})
    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    game:get_audio_manager():play_file("TRAMPOLINE", 300)
                    return
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            game:get_audio_manager():play_file("TRAMPOLINE", 300)
        end
    end

end)


----------------- Desert ---------------------

--[[
local cactus_image_1 = Image{src = "assets/desert/cactus-1.png", opacity = 0}
local cactus_image_2 = Image{src = "assets/desert/cactus-2.png", opacity = 0}
local cactus_image_3 = Image{src = "assets/desert/cactus-3.png", opacity = 0}
local cactus_image_4 = Image{src = "assets/desert/cactus-4.png", opacity = 0}
screen:add(cactus_image_1, cactus_image_2, cactus_image_3, cactus_image_4)
local cacti_table = {cactus_image_1, cactus_image_2, cactus_image_3, cactus_image_4}
local Cacti = Class(CollidableObject, function(cacti, number, ground, obj, ...)
    cacti._base.init(cacti)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    --TODO: proper removal of this function from on_idle
    local function viscosity(bodies_in_contact)
        for _,body in pairs(bodies_in_contact) do
            body.linear_velocity[1] = body.linear_velocity[1]/40
            body.linear_velocity[2] = body.linear_velocity[2]/40
        end
    end

    for i = 1,4 do
        local image = Clone{
            source = cacti_table[math.random(4)],
            position = {
                i*200 + math.random(-40, 40),
                ground.y+ground.h/2 - 500 + math.random(-40, 40)
            },
        }
        table.insert(cacti.images, image)
        screen:add(image)
        game:get_camera():add(image)
    end
    for i = 1,4 do
        local image = cacti.images[i]
        local body = physics:Body(
            Rectangle{
                size = {image.w-50, image.h-50},
                position = {image.x+20, image.y+50}
            },
            {density = 1, bounce = 0, friction = 20, type = "static", sensor = true}
        )
        
        local bodies_in_contact = {}
        function body:on_begin_contact(contact)
            local handle = contact.other_body[self.handle]
            for _,body_part in pairs(obj) do
                if handle == body_part.handle then
                    bodies_in_contact[handle] = body_part
                end
            end

            if not gameloop:idle_added(viscosity) then
                gameloop:add_idle(viscosity, {bodies_in_contact})
            end
        end

        function body:on_end_contact(contact)
            local handle = contact.other_body[self.handle]
            for _,body_part in pairs(obj) do
                if handle == body_part.handle then
                    bodies_in_contact[handle] = nil
                end
            end
        end

        table.insert(cacti.images, body)
        screen:add(body)
        game:get_camera():add(body)
    end

end)
--]]

---------------- Moon --------------------


local MOON_SIZE  = 200
local moon_image = Image{src = "assets/foreground/moon.png", opacity = 0}
screen:add(moon_image)
local Moon = Class(CollidableObject, function(moon, number, ground, obj, ...)
    moon._base.init(moon)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local image = Clone{
        source = moon_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-1200
        },
    }
    table.insert(moon.images, image)
    screen:add(image)
    game:get_camera():add(image)
    physics:Body(image, {density = 1, bounce = 1, awake = false,
        shape = physics:Circle(MOON_SIZE/2)})
    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                local audio = true
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-7}, {v.x, v.y})
                    if audio then
                        game:get_audio_manager():play_file("HIT", 300)
                        audio = false
                    end
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            obj:apply_linear_impulse({25,-7}, {obj.x, obj.y})
            game:get_audio_manager():play_file("HIT", 300)
        end
    end

end)


-------------------- Plastic Bag -------------------


local BAG_SIZE  = 50
local bag_image = Image{src = "assets/foreground/plastic-bag.png", opacity = 0}
screen:add(bag_image)
local Bag = Class(CollidableObject, function(bag, number, ground, obj, ...)
    bag._base.init(bag)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local image = Clone{
        source = bag_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-BAG_SIZE
        },
    }
    table.insert(bag.images, image)
    screen:add(image)
    game:get_camera():add(image)
    physics:Body(image, {density = .1, bounce = 1, awake = false,
        shape = physics:Circle(BAG_SIZE/2)})
    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    game:get_audio_manager():play_file("HIT", 300)
                    return
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            game:get_audio_manager():play_file("HIT", 300)
        end
    end

end)


----------------------- Balloons ----------------


local BALLOON_SIZE = 100
local balloon_image = Image{src = "assets/foreground/balloons.png", opacity = 0}
screen:add(balloon_image)
local Balloon = Class(CollidableObject, function(balloon, number, ground, obj, ...)
    balloon._base.init(balloon, number, ground, ...)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local image = Clone{
        source = balloon_image,
        position = {LENGTH_OF_SEPARATION*number + OBJECT_START, ground.y-800}
    }
    table.insert(balloon.images, image)

    screen:add(image)
    game:get_camera():add(image)
    physics:Body(image, {density = 1, bounce = 2, awake = false,
        shape = physics:Circle(BALLOON_SIZE/2, {0, -70})})
    image:add_fixture({density = 1, bounce = 2, awake = false,
        shape = physics:Circle(BALLOON_SIZE/2, {50, -80})})
    image:add_fixture({density = 1, bounce = 2, awake = false,
        shape = physics:Circle(BALLOON_SIZE/2, {-50, -100})})

    table.insert(balloon.idles, function()
        if image.y > ground.y-800 then
            image:apply_linear_impulse({0,-7}, {image.x, image.y})
        end
    end)
    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                local audio = true
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-17}, {v.x, v.y})
                    if audio then
                        game:get_audio_manager():play_file("HIT", 300)
                        audio = false
                    end
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            obj:apply_linear_impulse({25,-17}, {obj.x, obj.y})
            game:get_audio_manager():play_file("HIT", 300)
        end
    end
    gameloop:add_idle(balloon.idles[1])

end)


----------------- Trash --------------------

local TRASH_SIZE = 80
-- trash can
local trash_back_image = Image{
    src = "assets/foreground/trashcans/trash-can-back.png",
    opacity = 0
}
trash_back_image.anchor_point = {trash_back_image.w/2, trash_back_image.h/2}
local trash_front_image  = Image{
    src = "assets/foreground/trashcans/trash-can-front.png",
    opacity = 0
}
trash_front_image.anchor_point = {trash_front_image.w/2, trash_front_image.h/2}
local lid_image = Image{src = "assets/foreground/trashcans/trash-lid.png", opacity = 0}
screen:add(trash_back_image, trash_front_image, lid_image)
lid_image:hide()
trash_back_image:hide()
trash_front_image:hide()
-- trash
local trash_bag_image = Image{src = "assets/foreground/trashcans/trash-bag.png",
    opacity = 0}
local trash_image = Image{src = "assets/foreground/trashcans/trash.png", opacity = 0}
screen:add(trash_bag_image, trash_image)
local Trash = Class(CollidableObject, function(trash, number, ground, obj, ...)
    trash._base.init(trash)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local can_front = Clone{
        source = trash_front_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-trash_front_image.h
        }
    }
    can_front.anchor_point = {can_front.w/2, can_front.h/2}
    local can_back = Clone{
        source = trash_back_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-trash_front_image.h-100
        }
    }
    can_back.anchor_point = {can_back.w/2, can_back.h/2}
    local lid = Clone{
        source = lid_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START - 90,
            ground.y - trash_front_image.h - 200
        }
    }
    table.insert(trash.images, can_front)
    table.insert(trash.images, can_back)
    screen:add(can_back)
    game:get_camera():add(can_back)
    table.insert(trash.images, lid)

    local bag_image = Clone{
        source = bag_image,
        position = {
            can_front.x,
            can_front.y
        },
        scale ={.7, .7}
    }
    bag_image.anchor_point = {bag_image.w/2, bag_image.h/2}
    local trash_image = Clone{
        source = trash_image,
        position = {
            can_front.x,
            can_front.y
        },
        scale = {.5, .5}
    }
    trash_image.anchor_point = {trash_image.w/2, trash_image.h/2}
    local trash_bag_image = Clone{
        source = trash_bag_image,
        position = {
            can_front.x,
            can_front.y
        },
        scale = {.5, .6}
    }
    trash_bag_image.anchor_point = {trash_bag_image.w/2, trash_bag_image.h/2}
    table.insert(trash.images, bag_image)
    table.insert(trash.images, trash_image)
    table.insert(trash.images, trash_bag_image)
    screen:add(bag_image)
    game:get_camera():add(bag_image)
    screen:add(trash_image)
    game:get_camera():add(trash_image)
    screen:add(trash_bag_image)
    game:get_camera():add(trash_bag_image)

    screen:add(can_front)
    game:get_camera():add(can_front)
    screen:add(lid)
    game:get_camera():add(lid)

    physics:Body(lid, {density = 1, bounce = 1, awake = false,
        shape = physics:Box({150, 30})})
    physics:Body(can_front, {density = 1, bounce = .1, awake = false, --type="static", 
        shape = physics:Box({20, 180}, {-50, 0})})
    can_front:add_fixture({density = 1, bounce = .5, awake = false, --type="static", 
        shape = physics:Box({110, 20}, {0, 90})})
    can_front:add_fixture({density = 1, bounce = .5, awake = false, --type="static", 
        shape = physics:Box({20, 180}, {50, 0})})
    physics:Body(can_back, {density = 1, bounce = .5, awake = false, sensor = true})
    can_front:RevoluteJoint(can_back, {can_back.x-can_back.w/2, can_back.y},
        {enable_limit = true, lower_angle = 0, upper_angle = 0})
    
    -- stuff in trash

    physics:Body(bag_image, {density = .1, bounce = .5, awake = false,
        shape = physics:Circle(BAG_SIZE*.7)})
    physics:Body(trash_bag_image, {density = .1, bounce = .5, awake = false,
        shape = physics:Circle(BAG_SIZE*.7)})
    physics:Body(trash_image, {density = .1, bounce = .5, awake = false,
        shape = physics:Circle(BAG_SIZE*.7)})

    function can_front:on_begin_contact(contact)
        can_front.on_begin_contact = nil

        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-17}, {v.x, v.y})
                    game:get_audio_manager():play_file("TRASH", 300)
                end
            end
        end

        bag_image:apply_linear_impulse({.5,-.5}, {bag_image.x, bag_image.y})
        trash_bag_image:apply_linear_impulse({0,-1},
            {trash_bag_image.x, trash_bag_image.y})
        lid:apply_linear_impulse({.5,-.5}, {lid.x, lid.y})
    end
    function lid:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    game:get_audio_manager():play_file("TRASH", 300)
                end
            end
        end
    end
    function can_back:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    game:get_audio_manager():play_file("TRASH", 300)
                end
            end
        end
    end

end)


--------------------- Hydrant ----------------


local HYDRANT_SIZE = 10
local hydrant_image = Image{src = "assets/foreground/hydrant/hydrant.png", opacity = 0}
local hydrant_broken_image = Image{
    src = "assets/foreground/hydrant/hydrant-broken.png",
    opacity = 0
}
local water_image = Image{
    src = "assets/foreground/hydrant/hydrant-water-spout.jpg",
    opacity = 0
}
local water_top_image = Image{
    src = "assets/foreground/hydrant/hydrant-water-top.jpg",
    opacity = 0
}
screen:add(hydrant_image, hydrant_broken_image, water_image, water_top_image)
hydrant_image:hide()
hydrant_broken_image:hide()
water_image:hide()
water_top_image:hide()
local Hydrant = Class(CollidableObject, function(hydrant, number, ground, obj, ...)
    hydrant._base.init(hydrant, number, ground, ...)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local the_hydrant = Clone{
        source = hydrant_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-hydrant_image.h-60
        }
    }
    local hydrant_broken = Clone{
        source = hydrant_broken_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-hydrant_image.h
        }
    }
    local spout = Clone{
        source = water_top_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START - 150,
            ground.y-hydrant_image.h - 500
        },
        opacity = 0
    }
    local water = Clone{
        source = water_image,
        position = {
            -10,
            415
        },
        opacity = 0
    }
    local hydrant_group = Group{
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-water.h-80
        }
    }
    hydrant_group.clip = {0, -water.h-50, water.w, water.h+480}
    table.insert(hydrant.images, hydrant_group)
    table.insert(hydrant.images, the_hydrant)
    table.insert(hydrant.images, hydrant_broken)
    table.insert(hydrant.images, spout)
    hydrant_group:add(water)
    screen:add(hydrant_group, the_hydrant, hydrant_broken, spout)
    game:get_camera():add(hydrant_group)
    game:get_camera():add(the_hydrant)
    game:get_camera():add(hydrant_broken)
    game:get_camera():add(spout)

    hydrant_broken:hide()
    physics:Body(hydrant_group, {type = "static", density = 1, bounce = 1, sensor = true})

    local function splash()
        water.opacity = 255
        gameloop:add(water, 300, nil, {["y"] = Interval(water.y, 15)}, nil,
            function() spout.opacity = 255 end)
    end

    function hydrant_group:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    the_hydrant.opacity = 0
                    splash()
                    splash = function() end
                    hydrant_broken:show()
                    v:apply_linear_impulse({5,-200}, {v.x, v.y})
                end
            end
        end
    end

end)


---------------------- Bird ------------------


local birds = {
    {
        Image{src = "assets/foreground/Bird1_01.png", opacity = 0},
        Image{src = "assets/foreground/Bird1_02.png", opacity = 0},
        Image{src = "assets/foreground/Bird1_03.png", opacity = 0}
    },
    {
        Image{src = "assets/foreground/Bird2_01.png", opacity = 0},
        Image{src = "assets/foreground/Bird2_02.png", opacity = 0},
        Image{src = "assets/foreground/Bird2_03.png", opacity = 0}
    }
}
for i,bird in ipairs(birds[1]) do
    screen:add(bird)
    bird:hide()
end
for i,bird in ipairs(birds[2]) do
    screen:add(bird)
    bird:hide()
end
local Bird = Class(CollidableObject, function(bird, number, ground, obj, ...)
    bird._base.init(bird, number, ground, ...)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local bird_number = math.random(2)
    local images = {
        Clone{
            source = birds[bird_number][1],
        },
        Clone{
            source = birds[bird_number][2],
        },
        Clone{
            source = birds[bird_number][3],
        }
    }
    local group = Group{
        children = {images[1], images[2], images[3]},
        position = {LENGTH_OF_SEPARATION*number + OBJECT_START, ground.y-800}
    }
    table.insert(bird.images, group)

    images[2]:hide()
    images[3]:hide()

    screen:add(group)
    game:get_camera():add(group)
    physics:Body(group, {density = 1, bounce = .1, awake = false, --type = "static",
        shape = physics:Box({images[1].w-30, images[1].h-20}, {5,20})})

    table.insert(bird.idles, function()
        if group.y > ground.y-800 then
            group:apply_linear_impulse({0,-2}, {group.x, group.y})
        end
    end)
    local function animate_fall()
        group.on_begin_contact = nil
        gameloop:remove_idle(bird.idles[1])
        local counter = 1
        local a_timer = Timer()
        a_timer.interval = 300
        function a_timer:on_timer()
            images[counter]:hide()
            counter = counter+1
            images[counter]:show()
            if counter > 2 then
                a_timer:stop()
                a_timer.on_timer = nil
            end
        end
        a_timer:start()
    end
    function group:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-17}, {v.x, v.y})
                    game:get_audio_manager():play_file("BIRD", 300)
                    animate_fall()
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            obj:apply_linear_impulse({25,-17}, {obj.x, obj.y})
            game:get_audio_manager():play_file("BIRD", 300)
            animate_fall()
        end
    end
    gameloop:add_idle(bird.idles[1])

end)


-------------------- TNT ---------------


local tnt_image = Image{
    src = "assets/foreground/tnt/tnt-plunger.png",
    opacity = 0
}
local expl_back = Image{
    src = "assets/foreground/tnt/tnt-explosion-back.png",
    opacity = 0
}
local expl_front = Image{
    src = "assets/foreground/tnt/tnt-explosion-front.png",
    opacity = 0
}
screen:add(tnt_image, expl_front, expl_back)
local TNT = Class(CollidableObject, function(tnt, number, ground, obj, ...)
    tnt._base.init(tnt)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local image = Clone{
        source = tnt_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-tnt_image.h
        },
    }
    local front = Clone{
        source = expl_front,
        position = {image.x, image.y},
        opacity = 0
    }
    local back = Clone{
        source = expl_back,
        position = {image.x, image.y},
        opacity = 0
    }
    image.anchor_point = {image.w/2, image.h/2}
    front.anchor_point = {front.w/2, front.h/2}
    back.anchor_point = {back.w/2, back.h/2}
    
    table.insert(tnt.images, image)
    table.insert(tnt.images, front)
    table.insert(tnt.images, back)
    screen:add(image, back, front)
    game:get_camera():add(image)
    game:get_camera():add(back)
    game:get_camera():add(front)
    physics:Body(image, {density = .1, bounce = 1, awake = false, sensor = true})

    local explode
    function explode()
        game:get_audio_manager():play_file("TNT", 300)
        image.opacity = 0
        front.opacity = 255
        back.opacity = 255
        gameloop:add(front, 300, nil,
            {["z_rotation"] = {Interval(0, 500), Interval(0,0), Interval(0,0)}},
            true
        )
        gameloop:add(back, 300, nil,
            {["z_rotation"] = {Interval(0, -500), Interval(0,0), Interval(0,0)}},
            true
        )
        gameloop:add(back, 300, nil,
            {["scale"] = {Interval(1, 2), Interval(1,2)}},
            true
        )
        explode = function() end
    end
    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-500}, {v.x, v.y})
                    explode()
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            obj:apply_linear_impulse({25,-500}, {obj.x, obj.y})
            explode()
        end
    end

    image:lower_to_bottom()

end)


------------------------ Windmill --------------------


local ROTOR_SIZE = 30
local blade_image = Image{src = "assets/foreground/windmill/windmill-blade.png",
    opacity = 0}
local tower_image = Image{src = "assets/foreground/windmill/windmill-tower.png",
    opacity = 0}
screen:add(blade_image, tower_image)
local Windmill = Class(CollidableObject, function(windmill, number, ground, obj, ...)
    windmill._base.init(windmill)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local tower = Clone{
        source = tower_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-tower_image.h-200
        }
    }

    screen:add(tower)
    game:get_camera():add(tower)
    table.insert(windmill.images, tower)

    tower = physics:Body(tower, {density = 1, type = "static", sensor = true})

    local blade = physics:Body(Clone{source = blade_image},
        {density = .8, shape = physics:Circle(ROTOR_SIZE, {4, 85})})
    blade:add_fixture({density = 10, bounce = 2,
        shape = physics:Box({270, 15}, {110, 117}, 20)})
    blade:add_fixture({density = 10, bounce = 2,
        shape = physics:Box({270, 15}, {-110, 117}, -15)})
    blade:add_fixture({density = 10, bounce = 2,
        shape = physics:Box({270, 15}, {5, -50}, 90)})

    blade.position = {tower.x, tower.y - tower.h/2 - 85}

    blade:RevoluteJoint(tower, {tower.x , tower.y - tower.h/2},
        {enable_motor = true, motor_speed  = -500, max_motor_torque = 1000})

    screen:add(blade)
    game:get_camera():add(blade)
    table.insert(windmill.images, blade)

    blade:lower_to_bottom()
    tower:lower_to_bottom()
 
end)


------------------------ Power Lines -------------------


local power_lines_image = Image{src = "assets/foreground/telephone-poles.png",
    opacity = 0}
screen:add(power_lines_image)
local Power = Class(CollidableObject, function(power, number, ground, obj, ...)
    power._base.init(power)
    if not number then error("must have a queue number", 3) end
    if not ground then error("must establish ground", 3) end

    local image = Clone{
        source = power_lines_image,
        position = {
            LENGTH_OF_SEPARATION*number + OBJECT_START,
            ground.y-ground.h/2-power_lines_image.h/2
        },
    }
    image.anchor_point = {image.w/2, image.h/2}
    
    table.insert(power.images, image)
    screen:add(image)
    game:get_camera():add(image)
    physics:Body(image, {density = .1, bounce = 3, awake = false, type = "static",
        sensor = true, shape = physics:Box({550, 100}, {80, -250})})

    function image:on_begin_contact(contact)
        if type(obj) == "table" then
            local audio = true
            for k,v in pairs(obj) do
                if contact.other_body[self.handle] == v.handle then
                    v:apply_linear_impulse({25,-25}, {v.x, v.y})
                    if audio then
                        audio = false
                        game:get_audio_manager():play_file("POWER_LINE", 300)
                    end
                end
            end
        elseif contact.other_body[self.handle] == obj.handle then
            obj:apply_linear_impulse({25,-25}, {obj.x, obj.y})
            game:get_audio_manager():play_file("POWER_LINE", 300)
        end
    end

    image:lower_to_bottom()

end)


Object_Types = {
    ---[[
    [1] = Trampolene,
    --[2] = Cacti,
    [2] = Moon,
    [3] = Bag,
    [4] = Balloon,
    [5] = Trash,
    [6] = Bird,
    [7] = TNT,
    [8] = Windmill,
    [9] = Power,
    [10] = Hydrant
}
--]]
Scene_Objects = {
    [Scenes.HOUSE_1] = {Object_Types[7], Object_Types[2], Object_Types[10]},
    [Scenes.HOUSE_2] = {Object_Types[5], Object_Types[5]},
    [Scenes.HOUSE_3] = {Object_Types[4], Object_Types[1]},
    [Scenes.FOREST_1] = {Object_Types[8], Object_Types[3]},
    [Scenes.FOREST_2] = {Object_Types[7], Object_Types[9], Object_Types[6]},
}
--
TOTAL_OBJECTS = 20

CollidableObjects = Class(function(colldobj, ground, zombie, ...)
    if not ground then error("must establish ground", 2) end

    local pieces = zombie:get_zombie_parts()

    function ground:on_begin_contact(contact)
        if type(pieces) == "table" then
            for k,v in pairs(pieces) do
                if contact.other_body[self.handle] == v.handle then
                    game:get_audio_manager():play_file("HIT", 300)
                    return
                end
            end
        end
    end

    local queue = {}
    function colldobj:delete()
        for i,obj in ipairs(queue) do
            obj:delete()
        end

        pieces = nil
    end

    function colldobj:check_obj()
        for i,image in ipairs(queue[1].images) do
            if image.x + image.w < -500 then
                colldobj:make_obj()
                return
            end
        end
    end

    function colldobj:get_objects(scene_number)
        local objs = {}
        ---[[
        for i,obj in ipairs(Scene_Objects[scene_number]) do
            table.insert(objs, obj(i, ground, pieces))
        end
        --]]

        --[[
        table.insert(
            objs, Object_Types[math.random(#Object_Types)](1, ground, pieces)
        )
        --colldobj.get_objects = function() return {} end
        --]]
        return objs
    end

end)

