GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl


------------ Load the Assets -------------


    local backgrounds = {
        "assets/Mahjong_bg1.jpg"
    }
    local current_background = Image{src=backgrounds[1], name="background"}
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
        -- left edge
        --[[
        grid[1][4][1].group.position = Utils.deepcopy(GridPositions[1][4][1])
        grid[1][4][1].group.y = grid[1][4][1].group.y + 50
        grid_group:add(grid[1][4][1].group)
        --]]
        -- everything in the middle
        local tile = nil
        local pos = nil
        for k = 1,GRID_DEPTH do
            for i = 1,GRID_WIDTH do
                for j = 1,GRID_HEIGHT do
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
                end
            end
        end
        --[[
        -- right edge
        grid[14][4][1].group.position = Utils.deepcopy(GridPositions[14][4][1])
        grid[14][4][1].group.y = grid[14][4][1].group.y + 50
        grid[15][4][1].group.position = Utils.deepcopy(GridPositions[15][4][1])
        grid[15][4][1].group.y = grid[15][4][1].group.y + 50
        -- top
        grid[7][4][5].group.position = Utils.deepcopy(GridPositions.TOP)
        grid_group:add(
            grid[14][4][1].group,
            grid[15][4][1].group,
            grid[7][4][5].group
        )
        --]]

        -- change the tile depth mask layer opacity based on the height of the tile
        for k = 1, GRID_DEPTH do
            for i = 1,GRID_WIDTH do
                for j = 1, GRID_HEIGHT do
                    if grid[i][j][k] then
                        grid[i][j][k].depth.opacity = 255-255*((k-1)/4)
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
            grid[selector.x][selector.y][selector.z].focus.yellow.opacity = 0
        else
            grid[selector.x][selector.y][selector.z].focus.yellow.opacity = 255
        end
    end

    function pres:move_focus()
        local selector = ctrl:get_selector()
        local prev_selector = ctrl:get_prev_selector()

        local grid = ctrl:get_grid()
        if prev_selector then
            grid[prev_selector.x][prev_selector.y][prev_selector.z].focus.yellow.opacity = 0
        end
        grid[selector.x][selector.y][selector.z].focus.yellow.opacity = 255

        local position = Utils.deepcopy(GridPositions[selector.x][selector.y][selector.z])
    end

    function pres:choose_focus()
    end

    function pres:tile_bump(tile_group_1, tile_group_2)
        --[[
        tile_group_1.z = tile_group_1.z + 1
        tile_group_2.z = tile_group_2.z + 1
        --]]
        
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
        
        local left_intervals_t = {
            {
                ["x"] = Interval(left_tile.x, left_x),
                ["y"] = Interval(left_tile.y, left_y),
            },
            {
                ["z"] = Interval(left_tile.z, left_tile.z + 20)
            }
        }
        local left_durations = {300, 200}
        local from = {x = left_x, y = left_y}
        local to = {x = left_x-200, y = left_y}
        table.insert(left_intervals_t, {
            ["x"] = SemiCircleInterval(nil, from, to, 0, 180, true, false),
            ["y"] = SemiCircleInterval(nil, from, to, 0, 180, false, true)
        })
        table.insert(left_durations, 700)

        table.insert(left_intervals_t,
            {["y"]=Interval(left_y,1200), ["opacity"]=Interval(255,0)})
        table.insert(left_durations, 400)

        right_tile.z = right_tile.z + 1

        local right_intervals_t = {
            {
                ["x"] = Interval(right_tile.x, median.x),
                ["y"] = Interval(right_tile.y, median.y),
            },
            {
                ["z"] = Interval(right_tile.z, right_tile.z + 20)
            }
        }
        local right_durations = {300, 200}
        local from = {x = median.x, y = median.y}
        local to = {x = median.x+200, y = median.y}
        table.insert(right_intervals_t, {
            ["x"] = SemiCircleInterval(nil, from, to, 0, 180, true, false),
            ["y"] = SemiCircleInterval(nil, from, to, 0, 180, false, true)
        })
        table.insert(right_durations, 700)

        table.insert(right_intervals_t,
            {["y"]=Interval(median.y,1200), ["opacity"]=Interval(255,0)})
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

    function pres:show_undo(last_tiles)
        last_tiles[1]:set_green()
        last_tiles[2]:set_green()
        local interval_1 = {["opacity"] = Interval(255, 0)}
        local interval_2 = {["opacity"] = Interval(255, 0)}

        gameloop:add(last_tiles[1].focus.green, 300, nil, interval_1)
        gameloop:add(last_tiles[2].focus.green, 300, nil, interval_2)
    end

    function pres:end_game_animation()
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
