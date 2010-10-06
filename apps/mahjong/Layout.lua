Layouts = {
    TURTLE = 1,
    CLUB = 2
}
Layouts.LAST = -1
for _,__ in pairs(Layouts) do
    Layouts.LAST = Layouts.LAST + 1
end

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
    
    [Layouts.CLUB] = function()
        local grid = {}

        print("CLUB LAYOUT NOT YET CREATED")

        return grid
    end
}

Layout = Class(function(layout, number, tiles, ...)

    assert(number)
    assert(tiles)
    if type(tiles) ~= "table" then error("tiles must be a table of tiles", 2) end
    if type(number) ~= "number" then error("number must be a number", 2) end
    if number < 1 or number > Layouts.LAST then
        error("number must be between 1 and "..Layouts.LAST.." inclusive", 2)
    end

    local grid = layout_functions[number](tiles)

    function layout:get_grid() return grid end

    function layout:change_grid(number)
        assert(number)
        if type(number) ~= "number" then error("number must be a number", 2) end
        if number < 1 or number > Layouts.LAST then
            error("number must be between 1 and "..Layouts.LAST.." inclusive", 2)
        end

        grid = layout_functions[number](tiles)
    end

end)
