Layouts = {
    TURTLE = 1,
    CLUB = 2,
    ARENA = 3,
    BULL = 4,
    CUBE = 5
}
Layouts.LAST = -1
for _,__ in pairs(Layouts) do
    Layouts.LAST = Layouts.LAST + 1
end

NUMBER_OF_TILES = {144, 144, 144, 80, 64}

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
    
    [Layouts.CUBE] = function(tiles)
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
            -- edged to the right right above
            grid[2][j+1][2] = tiles[index]
            index = index + 1
        end

        grid[2][5][1] = tiles[index]
        index = index + 1

        for i = 3,5,2 do
            grid[i+1][6][1] = tiles[index]
            index = index + 1
            grid[i][6][2] = tiles[index]
            index = index + 1
        end

        return grid
    end,

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
    end
}

Layout = Class(function(layout, number, tiles_class, ...)

    assert(number)
    assert(tiles_class)
    if not tiles_class.is_a or not tiles_class:is_a(Tiles) then
        error("tiles must be a table of tiles", 2)
    end
    if type(number) ~= "number" then error("number must be a number", 2) end
    if number < 1 or number > Layouts.LAST then
        error("number must be between 1 and "..Layouts.LAST.." inclusive", 2)
    end

    tiles_class:shuffle(NUMBER_OF_TILES[number])
    local grid = layout_functions[number](tiles_class:get_tiles())

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
