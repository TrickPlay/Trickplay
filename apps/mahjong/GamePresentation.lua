GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl


------------ Load the Assets -------------


    local backgrounds = {
    }
    local current_background = Image{src=backgrounds[2], name="background"}
    local background = Group()
    background:add(current_background)
    background.anchor_point = {current_background.w/2, current_background.h/2}
    background.position = {1920/2, 1080/2}

    local tiles = {
        "assets/tiles/TileWoodLg.png",
        "assets/tiles/TilePlasticLg.png"
    }

    local focus = Rectangle{width = 110, height = 140,
        position = GridPositions[2][1][1]
    }

    local grid_group = Group{position = {440, 60}}
    
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
        -- left edgei
        --[[
        grid[1][4][1].group.position = Utils.deepcopy(GridPositions[1][4][1])
        grid[1][4][1].group.y = grid[1][4][1].group.y + 50
        grid_group:add(grid[1][4][1].group)
        --]]
        -- everything in the middle
        for k = 1,5 do
            for i = 1,30 do
                for j = 1,16 do
                    if grid[i][j][k] then
                        grid[i][j][k].group.position =
                            Utils.deepcopy(GridPositions[i][j][k])
                        grid_group:add(grid[i][j][k].group)
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
                        grid[i][j][k].depth.opacity = 180-180*((k-1)/4)
                        print(grid[i][j][k].depth.opacity)
                    end
                end
            end
        end

        grid_group:add(focus)

        screen:show()
    end

    function pres:reset()
        print("pres:reset() not yet implemented")
    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end
    end

    function pres:move_focus()
        local selector = ctrl:get_selector()

        local position = GridPositions[selector.x][selector.y][selector.z]
        focus.x = position[1]
        focus.y = position[2]
    end

    function pres:choose_focus()
    end

    function pres:end_game_animation()
    end

end)
