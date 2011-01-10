GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl


------------ Load the Assets -------------


    local backgrounds = {
        "assets/Mahjong_bg1.jpg"
    }
    local current_background = Image{
        src=backgrounds[1],
        name="background",
        size = {1920, 1080}
    }
    local background = Group()
    background:add(current_background)
    --background.anchor_point = {current_background.w/2, current_background.h/2}
    --background.position = {1920/2, 1080/2}

    local tiles = {
        "assets/tiles/TileWoodLg.png",
        "assets/tiles/TilePlasticLg.png",
        "assets/tiles/TileMarbleLg.png"
    }

    local grid_group = Group{}--position = {460, 60}}
    
    ui = Group()
    ui:add(background, grid_group)

    screen:add(ui)


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
        local grid = ctrl:get_grid()
        local tile = nil
        local pos = nil

        -- draws diagonally
        local i
        local j
        local temp = 0
        for k = 1,GRID_DEPTH do
            temp = 0
            while temp + 1 <= GRID_WIDTH + GRID_HEIGHT do
                j = 1
                i = temp + 1
                temp = i
                if i > GRID_WIDTH then
                    j = j + i - GRID_WIDTH
                    i = GRID_WIDTH
                end
                while i >= 1 and j <= GRID_HEIGHT do
                    if grid[i][j][k] then
                        tile = grid[i][j][k]
                        pos = tile.position
                        tile.group.position =
                            Utils.deepcopy(GridPositions[pos[1]][pos[2]][pos[3]])
                        if tile.group.parent then --necessary for z position
                            tile.group:unparent()
                        end
                        grid_group:add(tile.group)
                    end
                    i = i - 1
                    j = j + 1
                end
            end
        end

        -- change the tile depth mask layer opacity based on the height of the tile
        for k = 1,GRID_DEPTH do
            for i = 1,GRID_WIDTH do
                for j = 1,GRID_HEIGHT do
                    if grid[i][j][k] then
                        --grid[i][j][k].depth.opacity = 255-255*((k-1)/4)
                        grid[i][j][k]:set_height(k)
                    end
                end
            end
        end

    end

    function pres:reset()
        local grid = ctrl:get_grid()
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] then
                        grid[i][j][k]:focus_reset()
                    end
                end
            end
        end
    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end
        
        local grid = ctrl:get_grid()
        if not grid then return end

        local selector = ctrl:get_selector()
        local comp = router:get_active_component()

        if game:get_state():must_restart() then return end
        if comp ~= Components.GAME then
            grid[selector.x][selector.y][selector.z]:hide_yellow()
        else
            grid[selector.x][selector.y][selector.z]:show_yellow()
        end
    end

    function pres:move_focus()
        local selector = ctrl:get_selector()
        local prev_selector = ctrl:get_prev_selector()

        local grid = ctrl:get_grid()
        if prev_selector then
            grid[prev_selector.x][prev_selector.y][prev_selector.z]:hide_yellow()
        end
        grid[selector.x][selector.y][selector.z]:show_yellow()

        local position = Utils.deepcopy(GridPositions[selector.x][selector.y][selector.z])
    end

    function pres:choose_focus()
    end

    function pres:tile_bump(tile_group_1, tile_group_2)
        
        tile_group_1:unparent()
        screen:add(tile_group_1)
        tile_group_2:unparent()
        screen:add(tile_group_2)

        local left_tile = nil
        local right_tile = nil
        
        if tile_group_1.x < tile_group_2.x then
            left_tile = tile_group_1
            right_tile = tile_group_2
        else 
            left_tile = tile_group_2
            right_tile = tile_group_1
        end

        local left_x = left_tile.x
        local left_y = left_tile.y

        local x_bump = true
        -- bump in y direction
        if left_tile.x >= right_tile.x - 2*TILE_WIDTH then
            x_bump = false
        -- bump in x direction
        elseif left_tile.y + TILE_HEIGHT - 59 > right_tile.y then
            x_bump = true
        end

        if x_bump then 
            left_x = left_tile.x + TILE_WIDTH - 47
        else -- y bump
            -- determine which is the bottom tile and set right to bottom
            --[[
            if left_tile.y > right_tile.y then
                right_tile, left_tile = left_tile, right_tile
                left_x = right_tile.x
            end
            --]]
            left_y = left_tile.y + TILE_HEIGHT - 59
        end

        local median = {
            x = (left_x + right_tile.x)*.5,
            y = (left_y + right_tile.y)*.5
        }

        local left_intervals_t = nil
        local left_durations = nil
        local right_intervals_t = nil
        local right_durations = nil
        
        if x_bump then
            left_x = median.x-1-TILE_WIDTH+16
            left_y = median.y
        else
            left_x = median.x-1-TILE_WIDTH+16
            left_y = median.y
        end
        
        left_tile.z = left_tile.z + 1
        local tile_group_interval = {
            ["x"] = Interval(left_tile.children[1].x, left_tile.children[2].x + 100),
            ["y"] = Interval(left_tile.children[1].y, left_tile.children[2].y + 100)
        }
        gameloop:add(left_tile.children[1], 200, nil, tile_group_interval)

        local left_intervals_t = {
            {
                ["x"] = Interval(left_tile.x, left_x),
                ["y"] = Interval(left_tile.y, left_y),
            },
            --[[
            {
                ["z"] = Interval(left_tile.z, left_tile.z + 20)
            }
            --]]
        }
        local left_durations = {300}--, 200}
        local from = {x = left_x, y = left_y}
        local to = {x = left_x-200, y = left_y}
        --[[
        table.insert(left_intervals_t, {
            ["x"] = SemiCircleInterval(nil, from, to, 0, 180, true, false),
            ["y"] = SemiCircleInterval(nil, from, to, 0, 180, false, true)
        })
        table.insert(left_durations, 700)
        --]]

        table.insert(left_intervals_t,
            {["opacity"]=Interval(255,0)})--, ["y"]=Interval(left_y,1200), })
        table.insert(left_durations, 400)

        right_tile.z = right_tile.z + 2
        tile_group_interval = {
            ["x"] = Interval(right_tile.children[1].x, right_tile.children[2].x + 100),
            ["y"] = Interval(right_tile.children[1].y, right_tile.children[2].y + 100)
        }
        gameloop:add(right_tile.children[1], 200, nil, tile_group_interval)

        local right_intervals_t = {
            {
                ["x"] = Interval(right_tile.x, median.x),
                ["y"] = Interval(right_tile.y, median.y),
                ["callback"] = function()
                    mediaplayer:play_sound("assets/audio/match-good.mp3")
                    pres:sparkle(median.x,median.y+50, 9)
                end
            },
            --[[
            {
                ["z"] = Interval(right_tile.z, right_tile.z + 20)
            }
            --]]
        }
        local right_durations = {300}--, 200}
        local from = {x = median.x, y = median.y}
        local to = {x = median.x+200, y = median.y}
        --[[
        table.insert(right_intervals_t, {
            ["x"] = SemiCircleInterval(nil, from, to, 0, 180, true, false),
            ["y"] = SemiCircleInterval(nil, from, to, 0, 180, false, true),
        })
        table.insert(right_durations, 700)
        --]]

        table.insert(right_intervals_t,
            {["opacity"]=Interval(255,0)})--, ["y"]=Interval(median.y,1200), })
        table.insert(right_durations, 400)
        gameloop:add_list(right_tile, right_durations, right_intervals_t,
            function()
                game_menu:remove_tile_images()
                right_tile:unparent()
            end)

        gameloop:add_list(left_tile, left_durations, left_intervals_t,
            function()
                game_menu:remove_tile_images()
                left_tile:unparent()
            end)

        game_menu:tile_bump()
    end

    local sparkle_base = Image{src = "assets/tiles/Sparkle.png", opacity = 0}
    screen:add(sparkle_base)
    function pres:sparkle(x, y, num_sparkles)
        local sparkles = {}
        local sparkles_strip = {}

        --each sparkle gets predefined params (with variance)
        local x_start = {}
        local y_start = {}
        local x_peak  = {}
        local y_peak  = {}
        local x_end   = {}
        local y_end   = {}

        local scale  = {}
        local stage_start = {}
        local stage_speed = {}
        local o_peak      = {}
        local t_start     = {}
        local t_peak      = {}
        local t_end       = {}

        local stage_timer = Timer() --timer for the sudo-rotation of the sparkle
        local sparkle_counter = 0
        for i = 1, num_sparkles do
            sparkles[i] = Group{opacity=0}
            sparkles_strip[i] = Clone{source = sparkle_base}
            sparkles[i].clip = {0,0,sparkles_strip[i].w/5,sparkles_strip[i].h}
            sparkles[i]:add(sparkles_strip[i])
       
            local x_dir = math.random(97,102)/100
            x_start[i] = math.random(-2,2)+x
            sparkles[i].x = x_start[i]
            y_start[i] = math.random(-2,2)+y
            sparkles[i].y = y_start[i]
            x_peak[i]  = x_start[i]*x_dir
            y_peak[i]  = y_start[i]-80+math.random(-5,5)
            x_end[i]   = x_peak[i]*x_dir
            y_end[i]   = y_peak[i]+90+math.random(-5,5)
       
            stage_start[i] = math.random(   1,   5) --initial start stage
            stage_speed[i] = math.random(  50, 100) --num of milliseconds between switches
           
            o_peak[i]  = math.random(170,255)
            t_start[i] = math.random(0,300)
            t_peak[i]  = 400 + math.random(-100,100)
            t_end[i]   = math.random(0,300) -- when, during the final 200 milliseconds,
                                            -- the opacity goes to 0
            screen:add(sparkles[i])
            sparkles[i]:raise_to_top()
            
            local intervals_1 = {
                ["x"] = Interval(x_start[i], x_peak[i]),
                ["y"] = Interval(y_start[i], y_peak[i]),
                ["opacity"] = Interval(0, o_peak[i])
            }
            local intervals_2 = {
                ["x"] = Interval(x_peak[i], x_end[i]),
                ["y"] = Interval(y_peak[i], y_end[i]),
                ["opacity"] = Interval(o_peak[i], 0)
            }
            gameloop:add(sparkles[i], t_peak[i]-t_start[i], nil, intervals_1, true,
                function()
                    gameloop:add(sparkles[i], 2000-t_end[i], nil, intervals_2, true,
                        function()
                            sparkles[i]:clear()
                            sparkles[i]:unparent()
                            sparkles[i] = nil
                            sparkle_counter = sparkle_counter + 1
                        end)
                end)
        end
        stage_timer.interval = 100
        local stage_counter = 0
        function stage_timer:on_timer()
            if sparkle_counter == num_sparkles then
                stage_timer:stop()
                stage_timer.on_timer = nil
                stage_timer = nil
                collectgarbage("collect")
                return
            end
            for i = 1,num_sparkles do
                stage = math.floor(stage_start[i] + stage_counter)%5+1
                sparkles_strip[i].x =  -1*(stage-1)*sparkles_strip[i].w/5
            end
            stage_counter = stage_counter + 1
        end
        stage_timer:start()
    end

    function pres:show_undo(last_tiles)
        last_tiles[1]:show_green()
        last_tiles[2]:show_green()
        local interval_1 = {["opacity"] = Interval(255, 0)}
        local interval_2 = {["opacity"] = Interval(255, 0)}

        gameloop:add(last_tiles[1].focus.green, 300, nil, interval_1)
        gameloop:add(last_tiles[2].focus.green, 300, nil, interval_2)
    end

    local end_game_image
    function pres:show_end_game()
        end_game_image = Image{
            src="assets/victory.png",
            position={190 + screen.width/2, screen.height/2}
        }
        end_game_image.anchor_point = {end_game_image.width/2, end_game_image.height/2}

        screen:add(end_game_image)
        mediaplayer:play_sound("assets/audio/victory-sound.mp3")
    end

    function pres:hide_end_game()
        end_game_image:unparent()
        end_game_image = nil
        collectgarbage("collect")
    end

end)
