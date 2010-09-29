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

    local focus = nil

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
        -- left edge
        grid[1][4][1].group.position = Utils.deepcopy(GridPositions[1][4][1])
        grid[1][4][1].group.y = grid[1][4][1].group.y + 40
        grid_group:add(grid[1][4][1].group)
        -- everything in the middle
        for k = 1,4 do
            for i = 2,13 do
                for j = 1,8 do
                    if grid[i][j][k] then
                        grid[i][j][k].group.position =
                            Utils.deepcopy(GridPositions[i][j][k])
                        grid_group:add(grid[i][j][k].group)
                    end
                end
            end
        end
        -- right edge
        grid[14][4][1].group.position = Utils.deepcopy(GridPositions[14][4][1])
        grid[14][4][1].group.y = grid[14][4][1].group.y + 40
        grid[15][4][1].group.position = Utils.deepcopy(GridPositions[15][4][1])
        grid[15][4][1].group.y = grid[15][4][1].group.y + 40
        -- top
        grid[7][4][5].group.position = Utils.deepcopy(GridPositions.TOP)
        grid_group:add(
            grid[14][4][1].group,
            grid[15][4][1].group,
            grid[7][4][5].group
        )

        screen:show()
    end

    function pres:reset()
        print("pres:reset() not yet implemented")
    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end
    end

    function pres:move_focus()
    end

    function pres:choose_focus()
    end

    function pres:end_game_animation()
    end

end)
