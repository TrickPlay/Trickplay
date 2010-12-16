Layouts = {
    ANCHOR = 1,
    CROWN = 2,
    FISH = 3,
    CUBE = 4,
    CLUB = 5,
    ARENA = 6,
    TURTLE = 7
}
--[[
Layouts = {
    CUBE = 1,
    CLUB = 2,
    ARENA = 3,
    TURTLE = 4,
    BULL = 5
}
--]]
Layouts.LAST = -1
for _,__ in pairs(Layouts) do
    Layouts.LAST = Layouts.LAST + 1
end

NUMBER_OF_TILES = {
    [Layouts.CUBE] = 64,
    [Layouts.CLUB] = 144,
    [Layouts.ARENA] = 144,
    [Layouts.TURTLE] = 144,
    [Layouts.CROWN] = 116,
    [Layouts.ANCHOR] = 98,
    [Layouts.FISH] = 128
}

LAYOUT_NAMES = {
    [Layouts.CUBE] = "Cube (Hard)",
    [Layouts.CLUB] = "Club (Normal)",
    [Layouts.ARENA] = "Arena (Easy)",
    [Layouts.TURTLE] = "Turtle (Classic)",
    [Layouts.CROWN] = "Crown (Easy)",
    --[Layouts.BULB] = "Light Bulb (Normal)",
    [Layouts.ANCHOR] = "Anchor (Hard)",
    [Layouts.FISH] = "Fish (Easy)"
}

local layout_functions = {
    [Layouts.TURTLE] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        -- Bottom layer
        for i = 7,22,2 do
            for j = 1,15,2 do
                grid[i][j][1] = tiles[index]
                index = index + 1
            end
        end
        grid[3][1][1] = tiles[index]
        index = index + 1
        grid[5][1][1] = tiles[index]
        index = index + 1
        grid[23][1][1] = tiles[index]
        index = index + 1
        grid[25][1][1] = tiles[index]
        index = index + 1
        grid[3][15][1] = tiles[index]
        index = index + 1
        grid[5][15][1] = tiles[index]
        index = index + 1
        grid[23][15][1] = tiles[index]
        index = index + 1
        grid[25][15][1] = tiles[index]
        index = index + 1
        for j = 5,11,2 do
            grid[5][j][1] = tiles[index]
            index = index + 1
            grid[23][j][1] = tiles[index]
            index = index + 1
        end
        for j = 7,9,2 do
            grid[3][j][1] = tiles[index]
            index = index + 1
            grid[25][j][1] = tiles[index]
            index = index + 1
        end
        -- left outer edge  (redundancy so moving to the left from [2][4][1] and
        -- [2][5][1] is equilvalent)
        grid[1][8][1] = tiles[index]
        index = index + 1
        -- right outer edge
        grid[27][8][1] = tiles[index]
        index = index + 1
        grid[29][8][1] = tiles[index]
        index = index + 1

        -- Second from bottom layer
        for i = 9,19,2 do
            for j = 3,13,2 do
                grid[i][j][2] = tiles[index]
                index = index + 1
            end
        end
        -- Third
        for i = 11,17,2 do
            for j = 5,11,2 do
                grid[i][j][3] = tiles[index]
                index = index + 1
            end
        end
        -- Fourth
        for i = 13,15,2 do
            for j = 7,9,2 do
                grid[i][j][4] = tiles[index]
                index = index + 1
            end
        end
        -- Top Piece
        grid[14][8][5] = tiles[index]
        index = index + 1

        return grid
    end,

    [Layouts.CLUB] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        -- Center
        for i = 13,17,2 do
            for j = 1,11,2 do
                for k = 1,2 do
                    grid[i][j][k] = tiles[index]
                    index = index + 1
                end
            end
        end
        -- top left/right side of the top leaf
        for j = 3,5,2 do
            for k = 1,2 do
                grid[11][j][k] = tiles[index]
                index = index + 1
                grid[19][j][k] = tiles[index]
                index = index + 1
            end
        end
        -- Bottom center stuff
        for k = 1,2 do
            grid[13][13][k] = tiles[index]
            index = index + 1
            grid[17][13][k] = tiles[index]
            index = index + 1
        end
        -- Very Bottom stuff
        for i = 13,17,2 do
            for k = 1,2 do
                grid[i][15][k] = tiles[index]
                index = index + 1
            end
        end
        for k = 1,2 do
            grid[15][13][k] = tiles[index]
            index = index + 1
        end
        -- Left/Right leaves
        -- center part of the left/right leafs
        for i = 5,9,2 do
            for j = 7,13,2 do
                for k = 1,2 do
                    grid[i][j][k] = tiles[index]
                    index = index + 1
                    grid[i+16][j][k] = tiles[index]
                    index = index + 1
                end
            end
        end
        -- most left/right tiles
        for j = 9,11,2 do
            for k = 1,2 do
                grid[3][j][k] = tiles[index]
                index = index + 1
                grid[19][j][k] = tiles[index]
                index = index + 1
            end
        end
        -- right/left side tiles on the left/right leaf
        for j = 9,11,2 do
            for k = 1,2 do
                grid[11][j][k] = tiles[index]
                index = index + 1
                grid[27][j][k] = tiles[index]
                index = index + 1
            end
        end
        -- Top Layers
        -- left/center/right
        for i = 6,8,2 do
            for j = 9,11,2 do
                for k = 3,4 do
                    -- left
                    grid[i][j][k] = tiles[index]
                    index = index + 1
                    -- center
                    grid[i+8][j-7][k] = tiles[index]
                    index = index + 1
                    -- right
                    grid[i+16][j][k] = tiles[index]
                    index = index + 1
                end
            end
        end

        return grid
    end,

    [Layouts.ARENA] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end
        
        -- Top left/right triangle
        for i = 1,9,2 do
            for j = 1,7,2 do
                for k = 1,(12-i-j)/2 do
                    if k < 1 then break end
                    -- left
                    grid[i+2][j+1][k] = tiles[index]
                    index = index + 1
                    -- right
                    grid[28-i][j+1][k] = tiles[index]
                    index = index + 1
                end
            end
        end
        -- Bottom left/right triangle
        for i = 1,9,2 do
            for j = 1,5,2 do
                for k = 1,(12-i-j)/2 do
                    if k < 1 then break end
                    -- left
                    grid[i+2][15-j][k] = tiles[index]
                    index = index + 1
                    -- right
                    grid[28-i][15-j][k] = tiles[index]
                    index = index + 1
                end
            end
        end

        --Center strip
        for j = 3,11,2 do
            grid[15][j+1][1] = tiles[index]
            index = index + 1
        end
        grid[15][4][2] = tiles[index]
        index = index + 1
        grid[15][8][2] = tiles[index]
        index = index + 1
        grid[15][12][2] = tiles[index]
        index = index + 1

        grid[13][4][1] = tiles[index]
        index = index + 1
        grid[13][8][1] = tiles[index]
        index = index + 1
        grid[13][12][1] = tiles[index]
        index = index + 1
        grid[17][4][1] = tiles[index]
        index = index + 1
        grid[17][8][1] = tiles[index]
        index = index + 1
        grid[17][12][1] = tiles[index]
        index = index + 1

        return grid
    end,
--[[
    [Layouts.BULL] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        for j = 1,3,2 do
            -- top left corner
            grid[1][j][1] = tiles[index]
            index = index + 1
            -- edged to the right just above
            grid[2][j+1][2] = tiles[index]
            index = index + 1
            -- mirror image on opposite side
            grid[27][j][1] = tiles[index]
            index = index + 1
            -- edged to the right just above
            grid[26][j+1][2] = tiles[index]
            index = index + 1
        end

        grid[2][5][1] = tiles[index]
        index = index + 1
        grid[26][5][1] = tiles[index]
        index = index + 1

        for i = 3,5,2 do
            -- left side
            grid[i+1][6][1] = tiles[index]
            index = index + 1
            grid[i][6][2] = tiles[index]
            index = index + 1
            -- right side
            grid[i+19][6][1] = tiles[index]
            index = index + 1
            grid[i+20][6][2] = tiles[index]
            index = index + 1
        end



        return grid
    end,
--]]
    [Layouts.CUBE] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        for i = 11,17,2 do
            for j = 5,11,2 do
                for k = 1,4 do
                    grid[i][j][k] = tiles[index]
                    index = index + 1
                end
            end
        end

        return grid
    end,

    [Layouts.CROWN] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        for k = 1,2 do
            -- top
            grid[8][1][k] = tiles[index]
            index = index + 1
            grid[15][1][k] = tiles[index]
            index = index + 1
            grid[22][1][k] = tiles[index]
            index = index + 1
            grid[9][3][k] = tiles[index]
            index = index + 1
            grid[11][3][k] = tiles[index]
            index = index + 1
            grid[14][3][k] = tiles[index]
            index = index + 1
            grid[16][3][k] = tiles[index]
            index = index + 1
            grid[19][3][k] = tiles[index]
            index = index + 1
            grid[21][3][k] = tiles[index]
            index = index + 1

            for i = 10,20,2 do
                grid[i][5][k] = tiles[index]
                index = index + 1
            end
            for i = 11,19,2 do
                grid[i][7][k] = tiles[index]
                index = index + 1
            end

            --right
            grid[21][9][k] = tiles[index]
            index = index + 1
            grid[28][9][k] = tiles[index]
            index = index + 1
            grid[17][11][k] = tiles[index]
            index = index + 1
            grid[20][11][k] = tiles[index]
            index = index + 1
            grid[22][11][k] = tiles[index]
            index = index + 1
            grid[25][11][k] = tiles[index]
            index = index + 1
            grid[27][11][k] = tiles[index]
            index = index + 1

            for i = 16,26,2 do
                grid[i][13][k] = tiles[index]
                index = index + 1
            end
            for i = 17,25,2 do
                grid[i][15][k] = tiles[index]
                index = index + 1
            end

            --left
            grid[2][9][k] = tiles[index]
            index = index + 1
            grid[9][9][k] = tiles[index]
            index = index + 1
            grid[15][9][k] = tiles[index]
            index = index + 1
            grid[3][11][k] = tiles[index]
            index = index + 1
            grid[5][11][k] = tiles[index]
            index = index + 1
            grid[8][11][k] = tiles[index]
            index = index + 1
            grid[10][11][k] = tiles[index]
            index = index + 1
            grid[13][11][k] = tiles[index]
            index = index + 1
            grid[15][11][k] = tiles[index]
            index = index + 1

            for i = 4,14,2 do
                grid[i][13][k] = tiles[index]
                index = index + 1
            end
            for i = 5,13,2 do
                grid[i][15][k] = tiles[index]
                index = index + 1
            end
        end

        return grid
    end,
--[[
    [Layouts.BULB] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        grid[13][1][1] = tiles[index]
        index = index + 1
        grid[15][1][1] = tiles[index]
        index = index + 1

        grid[12][3][1] = tiles[index]
        index = index + 1
        grid[14][3][1] = tiles[index]
        index = index + 1
        grid[16][3][1] = tiles[index]
        index = index + 1

        for i = 10,18,2 do
            for j = 5,7,2 do
                grid[i][j][1] = tiles[index]
                index = index + 1
            end
        end

        return grid
    end,
--]]
    [Layouts.ANCHOR] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end
       
        for k = 1,3 do
            -- left side
            grid[4][6][k] = tiles[index]
            index = index + 1
            grid[3][8][k] = tiles[index]
            index = index + 1
            grid[5][8][k] = tiles[index]
            index = index + 1
            grid[4][10][k] = tiles[index]
            index = index + 1
            grid[5][12][k] = tiles[index]
            index = index + 1
            grid[7][13][k] = tiles[index]
            index = index + 1
            grid[9][14][k] = tiles[index]
            index = index + 1
            grid[11][15][k] = tiles[index]
            index = index + 1
            grid[13][15][k] = tiles[index]
            index = index + 1
            -- center
            for j = 6,16,2 do
                grid[15][j][k] = tiles[index]
                index = index + 1
            end
            grid[11][7][k] = tiles[index]
            index = index + 1
            grid[13][7][k] = tiles[index]
            index = index + 1
            grid[17][7][k] = tiles[index]
            index = index + 1
            grid[19][7][k] = tiles[index]
            index = index + 1
            -- right side
            grid[26][6][k] = tiles[index]
            index = index + 1
            grid[27][8][k] = tiles[index]
            index = index + 1
            grid[25][8][k] = tiles[index]
            index = index + 1
            grid[26][10][k] = tiles[index]
            index = index + 1
            grid[25][12][k] = tiles[index]
            index = index + 1
            grid[23][13][k] = tiles[index]
            index = index + 1
            grid[21][14][k] = tiles[index]
            index = index + 1
            grid[19][15][k] = tiles[index]
            index = index + 1
            grid[17][15][k] = tiles[index]
            index = index + 1
        end
        
        for k = 1,2 do
            grid[9][8][k] = tiles[index]
            index = index + 1
            grid[21][8][k] = tiles[index]
            index = index + 1
            for j = 2,4,2 do
                grid[13][j][k] = tiles[index]
                index = index + 1
                grid[17][j][k] = tiles[index]
                index = index + 1
            end
            grid[15][1][k] = tiles[index]
            index = index + 1
        end
        
        return grid
    end,

    [Layouts.FISH] = function(tiles)
        local index = 1
        local grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        -- top fish built from left to right
        for k = 1,2 do
            grid[3][3][k] = tiles[index]
            index = index + 1
            for j = 2,6,2 do
                grid[5][j][k] = tiles[index]
                index = index + 1
            end
            grid[7][1][k] = tiles[index]
            index = index + 1
            grid[7][5][k] = tiles[index]
            index = index + 1
            grid[7][7][k] = tiles[index]
            index = index + 1
            for j = 1,7,2 do
                grid[9][j][k] = tiles[index]
                index = index + 1
            end
            for j = 1,7,2 do
                grid[11][j][k] = tiles[index]
                index = index + 1
            end
            grid[13][1][k] = tiles[index]
            index = index + 1
            grid[13][3][k] = tiles[index]
            index = index + 1
            grid[13][7][k] = tiles[index]
            index = index + 1
            for j = 2,6,2 do
                grid[15][j][k] = tiles[index]
                index = index + 1
            end
            grid[17][3][k] = tiles[index]
            index = index + 1
            grid[17][5][k] = tiles[index]
            index = index + 1
            grid[19][4][k] = tiles[index]
            index = index + 1
            grid[21][3][k] = tiles[index]
            index = index + 1
            grid[21][5][k] = tiles[index]
            index = index + 1
            grid[23][2][k] = tiles[index]
            index = index + 1
            grid[23][6][k] = tiles[index]
            index = index + 1
            grid[25][1][k] = tiles[index]
            index = index + 1
            grid[25][7][k] = tiles[index]
            index = index + 1
        end
        grid[1][4][1] = tiles[index]
        index = index + 1
        grid[3][5][1] = tiles[index]
        index = index + 1
        grid[13][5][1] = tiles[index]
        index = index + 1
        grid[23][4][1] = tiles[index]
        index = index + 1

        --bottom fish
        for k = 1,2 do
            grid[3][9][k] = tiles[index]
            index = index + 1
            grid[5][10][k] = tiles[index]
            index = index + 1
            grid[7][11][k] = tiles[index]
            index = index + 1
            grid[9][12][k] = tiles[index]
            index = index + 1
            grid[7][13][k] = tiles[index]
            index = index + 1
            grid[5][14][k] = tiles[index]
            index = index + 1
            grid[3][15][k] = tiles[index]
            index = index + 1
            
            grid[11][11][k] = tiles[index]
            index = index + 1
            grid[11][13][k] = tiles[index]
            index = index + 1
            for j = 10,14,2 do
                grid[13][j][k] = tiles[index]
                index = index + 1
            end
            grid[15][9][k] = tiles[index]
            index = index + 1
            grid[15][11][k] = tiles[index]
            index = index + 1
            grid[15][15][k] = tiles[index]
            index = index + 1
            for j = 9,15,2 do
                grid[17][j][k] = tiles[index]
                index = index + 1
            end
            for j = 9,15,2 do
                grid[19][j][k] = tiles[index]
                index = index + 1
            end
            grid[21][9][k] = tiles[index]
            index = index + 1
            grid[21][13][k] = tiles[index]
            index = index + 1
            grid[21][15][k] = tiles[index]
            index = index + 1
            for j = 10,14,2 do
                grid[23][j][k] = tiles[index]
                index = index + 1
            end
            grid[25][11][k] = tiles[index]
            index = index + 1
        end
        grid[27][12][1] = tiles[index]
        index = index + 1
        grid[25][13][1] = tiles[index]
        index = index + 1
        grid[5][12][1] = tiles[index]
        index = index + 1
        grid[15][13][1] = tiles[index]
        index = index + 1
        
        return grid
    end,
}

Layout = Class(function(layout, tiles_class, number, load_game, ...)

    assert(number or load_game)
    assert(tiles_class)
    if not tiles_class.is_a or not tiles_class:is_a(Tiles) then
        error("tiles must be a table of tiles", 2)
    end

    local grid

    if number then
        if type(number) ~= "number" then error("number must be a number", 2) end
        if number < 1 or number > Layouts.LAST then
            error("number must be between 1 and "..Layouts.LAST.." inclusive", 3)
        end

        tiles_class:shuffle(NUMBER_OF_TILES[number])
        grid = layout_functions[number](tiles_class:get_tiles())
    else
        -- load game
        grid = settings.grid
        local matches = tiles_class:get_matches()
        local match_check = {}
        local tile
        local new_tile
        local count = 0
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] and (not grid[i-1]
                    or grid[i][j][k] ~= grid[i-1][j][k])
                    and (not grid[i][j-1] or grid[i][j][k] ~= grid[i][j-1][k]) then
                        tile = grid[i][j][k]
                        new_tile = matches[tile.suit][tile.number][1]
                        count  = count + 1
                        if match_check[new_tile] then
                            new_tile = matches[tile.suit][tile.number][2]
                            if match_check[new_tile] then
                                error("trying to access same tile three times")
                            end
                            match_check[new_tile] = true
                        end
                        grid[i][j][k] = new_tile
                    end
                end
            end
        end
    end

    function layout:get_grid() return grid end

    function layout:change_grid(number)
        assert(number)
        if type(number) ~= "number" then error("number must be a number", 2) end
        if number < 1 or number > Layouts.LAST then
            error("number must be between 1 and "..Layouts.LAST.." inclusive", 2)
        end

        grid = layout_functions[number](tiles_class:get_tiles())
    end

end)
