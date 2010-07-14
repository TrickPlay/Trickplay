
PlayerLayerConstants = {
    RIGHT = 1, LEFT = 2, UP = 3, DOWN = 4,
    walk = {},
    laser = {},
    image_defaults = {
        width  = 110,
        height = 130,
        x_rotation = {-30, 130, 0}
    },
    duration = 750
}

PlayerLayerConstants.DEFAULT_DIRECTION = PlayerLayerConstants.DOWN
PlayerLayerConstants.DEFAULT_DIR_INDEX = 1

PlayerLayerConstants.walk[1] = {

    [PlayerLayerConstants.RIGHT] = {
       "img/robot/Roboy/bot_right.png",
       "img/robot/Roboy/bot_right_leftfoot.png",
       "img/robot/Roboy/bot_right.png",
       "img/robot/Roboy/bot_right_leftfoot.png"
    },
    [PlayerLayerConstants.LEFT] = {
       "img/robot/Roboy/bot_left.png",
       "img/robot/Roboy/bot_left_rightfoot.png",
       "img/robot/Roboy/bot_left.png",
       "img/robot/Roboy/bot_left_rightfoot.png"
    },
    [PlayerLayerConstants.UP]   = {
       "img/robot/Roboy/bot_back.png",
       "img/robot/Roboy/bot_back_rightfoot.png",
       "img/robot/Roboy/bot_back.png",
       "img/robot/Roboy/bot_back_leftfoot.png"
    },
    [PlayerLayerConstants.DOWN] = {
       "img/robot/Roboy/bot_front.png",
       "img/robot/Roboy/bot_front_rightfoot.png",
       "img/robot/Roboy/bot_front.png",
       "img/robot/Roboy/bot_front_leftfoot.png"
    }
}

PlayerLayerConstants.walk[2] = {

    [PlayerLayerConstants.RIGHT] = {
       "img/robot/Barney/barney_right.png",
    },
    [PlayerLayerConstants.LEFT] = {
       "img/robot/Barney/barney_left.png",
    },
    [PlayerLayerConstants.UP]   = {
       "img/robot/Barney/barney_back.png",
    },
    [PlayerLayerConstants.DOWN] = {
       "img/robot/Barney/barney_front.png",
    }
}
PlayerLayerConstants.walk[3] = {

    [PlayerLayerConstants.RIGHT] = {
       "img/robot/Eve/eve_right.png",
    },
    [PlayerLayerConstants.LEFT] = {
       "img/robot/Eve/eve_left.png",
    },
    [PlayerLayerConstants.UP]   = {
       "img/robot/Eve/eve_back.png",
    },
    [PlayerLayerConstants.DOWN] = {
       "img/robot/Eve/eve_front.png",
    }
}

PlayerLayerConstants.walk[4] = {

    [PlayerLayerConstants.RIGHT] = {
       "img/robot/E-wall/ewall_right.png",
    },
    [PlayerLayerConstants.LEFT] = {
       "img/robot/E-wall/ewall_left.png",
    },
    [PlayerLayerConstants.UP]   = {
       "img/robot/E-wall/ewall_back.png",
    },
    [PlayerLayerConstants.DOWN] = {
       "img/robot/E-wall/ewall_front.png",
    }
}

--- lazer images

PlayerLayerConstants.laser[1] = {
    [PlayerLayerConstants.RIGHT] = "img/robot/Roboy/bot_right_lazer.png",
    [PlayerLayerConstants.LEFT]  = "img/robot/Roboy/bot_left_lazer.png",
    [PlayerLayerConstants.UP]    = "img/robot/Roboy/bot_back_lazer.png",
    [PlayerLayerConstants.DOWN]  = "img/robot/Roboy/bot_front_lazer.png"
}

PlayerLayerConstants.laser[2] = {
    [PlayerLayerConstants.RIGHT] = "img/robot/Barney/barney_right_lazer.png",
    [PlayerLayerConstants.LEFT]  = "img/robot/Barney/barney_left_lazer.png",
    [PlayerLayerConstants.UP]    = "img/robot/Barney/barney_back_lazer.png",
    [PlayerLayerConstants.DOWN]  = "img/robot/Barney/barney_front_lazer.png"
}

PlayerLayerConstants.laser[3] = {
    [PlayerLayerConstants.RIGHT] = "img/robot/Eve/eve_right_lazer.png",
    [PlayerLayerConstants.LEFT]  = "img/robot/Eve/eve_left_lazer.png",
    [PlayerLayerConstants.UP]    = "img/robot/Eve/eve_back_lazer.png",
    [PlayerLayerConstants.DOWN]  = "img/robot/Eve/eve_front_lazer.png"
}

PlayerLayerConstants.laser[4] = {
    [PlayerLayerConstants.RIGHT] = "img/robot/E-wall/ewall_right_lazer.png",
    [PlayerLayerConstants.LEFT]  = "img/robot/E-wall/ewall_left_lazer.png",
    [PlayerLayerConstants.UP]    = "img/robot/E-wall/ewall_back_lazer.png",
    [PlayerLayerConstants.DOWN]  = "img/robot/E-wall/ewall_front_lazer.png"
}

PlayerLayerConstants.surge_movie = {

    {"img/animations/electric/power_animation_1.png", 100},
    {"img/animations/electric/power_animation_2.png", 100},
    {"img/animations/electric/power_animation_3.png", 100},
    {"img/animations/electric/power_animation_4.png", 100},
    {"img/animations/electric/power_animation_5.png", 100},
    {"img/animations/electric/power_animation_6.png", 100},
    {"img/animations/electric/power_animation_7.png", 100},
    {"img/animations/electric/power_animation_8.png", 100},
    {"img/animations/electric/power_animation_9.png", 100},
    {"img/animations/electric/power_animation_10.png", 100},
    {"img/animations/electric/power_animation_11.png", 100}
}

PlayerLayer = class(GridLayer, function(self, ...)

    GridLayer.init(self, BoardLayerConstants.duration,
                         BoardLayerConstants.grid_width, 
                         BoardLayerConstants.grid_height,
                         BarneyConstants.rows, 
                         BarneyConstants.cols, ...)

    self._class_name = "PlayerLayer" 

    self.animation_group = Group{
        x = self.group.x,
        y = self.group.y,
        width  = self.group.width,
        height = self.group.height,
        z = self.group.z
    }

    self.parent_group:add(self.animation_group)

    self.player_image = {}

    -- add surge movie

end)

function PlayerLayer:movePlayer(player, old_row, old_col, new_row, new_col, callback)

    --assert(callback, "no callback passed to PlayerLayer:movePlayer")
    --assert((old_row == new_row) or (old_col == new_col), "invalid move!")

    local PLC = PlayerLayerConstants

    local move_direction

    if old_col == new_col then
        move_direction = new_row > old_row and PlayerLayerConstants.DOWN or PlayerLayerConstants.UP
    else move_direction = new_col > old_col and PlayerLayerConstants.RIGHT or PlayerLayerConstants.LEFT
    end

    local walk_image_src = PlayerLayerConstants.walk[player][move_direction]

    local old_image = self:get(old_row, old_col)
    if not old_image then
        local default_src = PLC.walk[player][PLC.DEFAULT_DIRECTION][PLC.DEFAULT_DIR_INDEX]
        old_image = self:insert(default_src, old_row, old_col, PLC.image_defaults)
    end
    self:remove(old_row, old_col)

    local dest_x, dest_y = self:calculateXY(old_image, new_row, new_col)
    local old_x, old_y = old_image.x, old_image.y

    local x_distance, y_distance = dest_x - old_x, dest_y - old_y

    local properties = {x = old_x, y = old_y, width = old_image.width, height = old_image.height}

    Utils.mixin(properties, PLC.image_defaults)

    local walk_images = {}
    for i, image_src in ipairs(walk_image_src) do
        local image = Images:load(image_src, properties)
        self.group:add(image)
        image:hide()
        walk_images[#walk_images+1] = image
    end
    

    local timeline = Timeline{
        duration = PlayerLayerConstants.duration,
        on_new_frame = function(timeline, elapsed, progress) 
            self:animateWalk(timeline, elapsed, progress, player, walk_images, old_x, old_y, x_distance, y_distance)
        end,
        on_completed = function(timeline)
            self:walkCallback(timeline, player,  walk_images, new_row, new_col) 
            -- notify control/model that animation is complete
            if callback then callback() end
        end
    }

    timeline:start()
end

function PlayerLayer:animateWalk(timeline, elapsed, progress, player, walk_images, old_x, old_y, x_distance, y_distance)

    assert(player, "no player passed to animate walk!")
    assert(type(walk_images) == 'table', "need table of walking image")
    assert(old_x and old_y and x_distance and y_distance,
           "no destination parameters passed")

    local current_image = walk_images[math.ceil(progress*#walk_images)]
    for i,image in ipairs(walk_images) do
        image:hide()
        image.x = old_x + x_distance*progress
        image.y = old_y + y_distance*progress
    end
    current_image:show()
end

function PlayerLayer:walkCallback(timeline, player,  walk_images, new_row, new_col)

    local PLC = PlayerLayerConstants
    
    --local image = self:get(new_row, new_col)
    --if image then self:remove(new_row, new_col) end

    for i,image in ipairs(walk_images) do
        image:unparent()
    end

    local default_image = PLC.walk[player][PLC.DEFAULT_DIRECTION][PLC.DEFAULT_DIR_INDEX]
    self:insert(default_image, new_row, new_col, PLC.image_defaults)
end

function PlayerLayer:animateTransport(player, from_row, from_col, to_row, to_col, callback)

    local PLC = PlayerLayerConstants

    local default_image_src = PLC.walk[player][PLC.DEFAULT_DIRECTION][PLC.DEFAULT_DIR_INDEX]

    self:animate({
        duration = 75,
        opacity = 0,
        on_completed = function()
            callback()
        end
    }, from_row, from_col)

end

function PlayerLayer:rotateRows(callback)
    local callback_num = #self.rotate_timeline_callbacks + 1
    self.rotate_timeline_callbacks[callback_num] = function()
        callback()
        self.rotate_timeline_callbacks[callback_num] = nil
        assert(not self.rotate_timeline_callbacks[callback_num+1], "callback added when clearing!")
    end
    GridLayer.rotateRows(self)
end

function PlayerLayer:animateKillPlayer(player, row, col)
    local image = self:get(row, col)
    if not image then
        print(self._class_name .. ": animateKillPlayer - WARNING - trying to delete guy that's no longer on the board")
        return
    end
    
    -- animate player falling off the board
    local old_y = image.y
    local fall_distance = self.group.height - image.y + image.height + 150
    local timeline = Timeline{
        duration = 200,
        on_new_frame = function(timeline, elapsed, progress)
            image.y = old_y + progress * fall_distance
        end,
        on_completed = function()
           -- self:remove(row, col)
        end
    }
    timeline:start()
end

function PlayerLayer:animateSaw(attacking_row, attacking_col, callback)

    local player_image = self:get(attacking_row, attacking_col)
    assert(player_image, self._class_name .. " : animateSaw - invalid row: " .. attacking_row .. " col: " .. attacking_col)
    local player_rotation = player_image.x_rotation

    local duration = 2000

    local height = 500
    local width  = 500

    local start_x = 75
    local start_y = -650
    local end_x = 1000
    local end_y = 1080


    local saw_image = Images:load("img/animations/saw_cropped.png", {
        height = height,
        width  = width,
        x = start_x,
        y = start_y,
        z = 1
    })

    self.animation_group:add(saw_image)
    local timeline = Timeline{
        duration = duration,
        on_started = function(timeline)
            player_image.x_rotation = {0, player_rotation[2], player_rotation[3]}
        end,
        on_new_frame = function(timeline, elapsed, progress)
            saw_image.x = start_x + progress * end_x
            saw_image.y = start_y + progress * end_y
            local prev_degrees = saw_image.z_rotation[1]
            saw_image.z_rotation = {prev_degrees+25,saw_image.y,saw_image.x}
        end,
        on_completed = function(timeline)
            player_image.x_rotation = player_rotation
            saw_image:unparent()
            callback()
        end
    }
    timeline:start()
end

function PlayerLayer:animateLaser(player, attacking_row, attacking_col, callback)
    
    local PLC = PlayerLayerConstants

    assert(1 <= player and player <= 4, self._class_name .. " : animateLaser - invalid player: " .. player)

    local player_image = self:get(attacking_row, attacking_col)
    assert(player_image, self._class_name .. " : animateLaser - invalid row: " .. attacking_row .. " col: " .. attacking_col)

    local laser_images_src = PLC.laser[player]

    local laser_properties = {
        x = player_image.x,
        y = player_image.y,
        width  = player_image.width,
        height = player_image.height
    }

    local laser_images = {}

    for i,laser_src in ipairs(laser_images_src) do
        local image = Images:load(laser_src, laser_properties)
        laser_images[#laser_images+1] = image
        self.group:add(image)
        image:hide()
    end

    local direction_count = 1
    local timer = Timer{
        interval = .4,
        on_timer = function(timer)
            if 1 == direction_count then
                player_image:hide()
            end

            if direction_count > 4 then

                player_image:show()

                timer:stop()
                callback()
            end

            for i,v in ipairs(laser_images) do
                if i ~= direction_count then
                    v:hide()
                else
                    v:show()

                    local beam_properties = {color = "#FF001E"}
                    local beam_thick = 6
                    local beam_duration = 800

                    local board_y = -self.grid_height * self.num_rotations
                    local board_height = BarneyConstants.rows * self.grid_height

                    if i == PLC.RIGHT then
                        beam_properties.x = player_image.x + player_image.width
                        beam_properties.width = self.group.width - beam_properties.x

                        beam_properties.y = player_image.y + player_image.height/2
                        beam_properties.height = beam_thick
                    elseif i == PLC.LEFT then
                        beam_properties.x = 0
                        beam_properties.width = player_image.x - beam_properties.x

                        beam_properties.y = player_image.y + player_image.height/2
                        beam_properties.height = beam_thick
                    elseif i == PLC.UP then
                        beam_properties.x = player_image.x + player_image.width/2
                        beam_properties.width  = beam_thick

                        beam_properties.y = board_y
                        beam_properties.height = player_image.y - beam_properties.y
                    elseif i == PLC.DOWN then
                        beam_properties.x = player_image.x + player_image.width/2
                        beam_properties.width  = beam_thick

                        beam_properties.y = player_image.y + player_image.height
                        beam_properties.height = board_y + board_height - beam_properties.y
                    else 
                        assert(false, self._class_name .. " : animateLaser - invalid direction " .. i)
                    end
                    --play sound
                    mediaplayer:play_sound("sounds/laser.wav")
                    local beam = Rectangle(beam_properties)
                    self.group:add(beam)
                    beam:animate{
                        duration = beam_duration,
                        opacity = 0,
                        on_completed = function()
                            beam:unparent()
                        end
                    }
                end
            end

            direction_count = direction_count + 1
        end

    }:start()
end

function PlayerLayer:animateSurge(attacking_row, attacking_col, callback)

    local player_image = self:get(attacking_row, attacking_col)

    Utils.makeMovie(PlayerLayerConstants.surge_movie, 
                    { x = player_image.x - 110,
                      y = player_image.y - 240
                    },
                    self.group,
                    callback):start()
end

function PlayerLayer:animateWater(targets,callback)
    local pl = boardView.skew_layers.player_layer
    local water_images = {
        {"img/animations/water/wateranimation_1.png",100},
        {"img/animations/water/wateranimation_2.png",100},
        {"img/animations/water/wateranimation_3.png",100},
        {"img/animations/water/wateranimation_4.png",100},
        {"img/animations/water/wateranimation_5.png",100},
        {"img/animations/water/wateranimation_6.png",100},
        {"img/animations/water/wateranimation_7.png",100},
        {"img/animations/water/wateranimation_8.png",100},
        {"img/animations/water/wateranimation_9.png",100},
        {"img/animations/water/wateranimation_10.png",100},
        {"img/animations/water/wateranimation_11.png",100},
        {"img/animations/water/wateranimation_12.png",100}
    }
    local water_properties = {}   
    local pipe_img = Images:load("img/animations/pipelines.png")
    local water_g = Group()
    water_g.x = -70
    water_g.y=-pl.grid_height * pl.num_rotations - 1000
    water_g:add(pipe_img)
    pl.group:add(water_g)

    local function droplets()
        --print("\n\n\nfuckin water")
        for i = 1,#targets do
            --print("drop at",targets[i].x,targets[i].y)
            local w_prop = {}
            --w_prop.x, w_prop.y = 100*targets[i].x, targets[i].y
            w_prop.x, w_prop.y = self.grid_width  * (targets[i].x), self.grid_height * (targets[i].y - self.num_rotations+1)
            w_prop.y = w_prop.y - 130 - self.grid_height
            w_prop.x = w_prop.x - 110
            w_prop.y = w_prop.y - 240
    
            Utils.makeMovie(water_images, w_prop,self.group, callback):start()
        end
        local function pipes_up()
            local function del()
                water_g:hide()
                water_g:unparent()
                water_g = nil
            end
            water_g:animate{duration = 1000, y = water_g.y-374,on_completed = del}
        end
        water_g:animate{duration = 1000, y = water_g.y- 1, on_completed = pipes_up}
    end
    
    water_g:animate{duration = 1000, y = water_g.y+375,on_completed = droplets}

end
