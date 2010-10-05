GameState = Class(nil,function(state, ctrl)
    math.randomseed(os.time())
    local ctrl = ctrl
    

    game_timer = {
        start = 0,
        current = 0,
        prev = 0,
        stop = false,
        text = Text{
            text = "0:00",
            position = {1015, 301},
            font = MENU_FONT_BOLD,
            color = Colors.WHITE
        }
    }
    function game_timer:update()
        local min = math.floor(self.prev/60)
        local sec = self.prev - min*60
        if sec < 10 then
            self.text.text = tostring(min)..":0"..tostring(sec)
        else
            self.text.text = tostring(min)..":"..tostring(sec)
        end
    end
    --[[
        Private Variables
    --]]
    -- the game grid
    local grid = nil
    -- a grid containing available tiles to select
    local selection_grid = nil
    -- a table that contains the matching tiles, pairs(matching_tiles) reveals
    -- all tiles which have a match not necessarilly in any order, the key is also
    -- the value
    local matching_tiles = nil
    -- a grid containing the tiles at the top
    local top_grid = nil
    -- a table where a tile tile is a key to the same tile, holds top tiles
    local top_tiles = nil
    -- all the tile objects stored in a table
    local tiles = nil
    -- a table which contains matching tiles organized by indexing into the suit
    -- and number, i.e. matches[tile.suit][tile.number]
    local matches = nil
    -- the class for all the tiles with functions
    local tiles_class = nil
    -- current selected tile to be compared with another tile for elimination
    local selected_tile = nil
    -- true if the game has not started yet
    local new_game = true
    -- true if the game was won and the auto-complete dialog already showed
    local game_won = false
    -- true if the game is won and the player must redeal to do anything
    local must_restart = false
    -- true if the player is in roaming mode
    local roaming = false

    -- getters/setters
    function state:get_grid() return grid end
    function state:get_selection_grid() return selection_grid end
    function state:get_matching_tiles() return matching_tiles end
    function state:get_top_grid() return top_grid end
    function state:get_top_tiles() return top_tiles end
    function state:get_tiles() return tiles end
    function state:get_matches() return matches end
    function state:get_tiles_class() return tiles_class end
    function state:get_selected_tile() return selected_tile end
    function state:is_new_game() return new_game end
    function state:must_restart() return must_restart end
    function state:game_won() return game_won end

    function state:set_must_restart(bool)
        assert(type(bool)=="boolean")
        must_restart = bool
    end
    --[[
        If true the player can move anywhere.
        If false the player has a tile selected and must move to another tile
        which matches the selected one.
    --]]
    function state:is_roaming() return selected_tile == nil end


----------------- Initialization -------------


    function state:initialize()
        print("state initializing")
        new_game = true
        game_won = false
        
        -- Get all the tiles in the game
        tiles_class = Tiles()
        tiles_class:shuffle()
        tiles = tiles_class:get_tiles()
        matches = tiles_class:get_matches()
    end

    function state:reset()
        new_game = true
        game_won = false
        must_restart = false
        game_timer.start = 0
        game_timer.current = 0

        tiles_class:shuffle()
        tiles_class:reset()
    end

    function state:build_mahjong()
        -- Sets up the game grid the player moves across
        local index = 1
        grid = {}
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

    end

    --[[
        The grid is set into quadrants, i.e., a tile at [1][1][1] will cover
        [1][2][1], [2][1][1], and [2][2][1] as well since each section represents
        one-quarter of a tile. This data structure allows for more complex tile
        placings.
    --]]
    function state:set_tile_quadrants()
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] and not grid[i][j][k].set then
                        grid[i][j][k].position = {i,j,k}
                        grid[i+1][j][k] = grid[i][j][k]
                        grid[i][j+1][k] = grid[i][j][k]
                        grid[i+1][j+1][k] = grid[i][j][k]
                        grid[i][j][k].set = true
                    end
                end
            end
        end
    end


--------------------- Functions ------------------


    function state:find_top_tiles()
        top_grid = {}
        top_tiles = {}
        local x = nil
        local y = nil
        local z = nil
        local new_z = nil
        for i = 1,GRID_WIDTH do
            top_grid[i] = {}
            for j = 1,GRID_HEIGHT do
                top_grid[i][j] = {}
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] then
                        top_grid[i][j][k] = grid[i][j][k]
                        if not top_grid[grid[i][j][k]] then
                            x = i
                            y = j
                            z = k
                            new_z = z + 1
                            while new_z <= GRID_DEPTH do
                                if grid[i][j][new_z] then z = new_z end
                                new_z = new_z + 1
                            end
                            top_tiles[grid[x][y][z]] = grid[x][y][z]
                        end
                    end
                end
            end
        end

        add_to_key_handler(keys.t, function()
        --[[
            for i = 1,GRID_WIDTH do
                for j = 1,GRID_HEIGHT do
                    for k = 1,GRID_DEPTH do
                        if top_grid[i][j][k] then
                            if top_grid[i][j][k].focus.red.opacity == 255 then
                                top_grid[i][j][k].focus.red.opacity = 0
                            else
                                top_grid[i][j][k].focus.red.opacity = 255
                            end
                        end
                    end
                end
            end
        --]]
            for k,v in pairs(top_tiles) do
                if is_key_hint_on(keys.t) then
                    v.focus.red.opacity = 255
                else
                    v.focus.red.opacity = 0
                end
            end
        end)
    end

    function state:find_selectable_tiles()
        selection_grid = {}
        local x = nil
        local y = nil
        local z = nil
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] and not selection_grid[grid[i][j][k]] then
                        -- normalize to the upper left hand quadrant of the tile
                        x = grid[i][j][k].position[1]
                        y = grid[i][j][k].position[2]
                        z = grid[i][j][k].position[3]
                        if not (
                        -- 2 right
                        (grid[x+2] and (grid[x+2][y][z]
                        -- 2 right 1 down
                        or (grid[x+2][y+1] and grid[x+2][y+1][z])))
                        -- 1 left
                        and (grid[x-1] and (grid[x-1][y][z]
                        -- 1 left 1 down
                        or (grid[x-1][y+1] and grid[x-1][y+1][z])))
                        )

                        -- 1 higher (z)
                        and (not grid[x][y][z+1])
                        -- 1 right 1 higher
                        and (not grid[x+1] or not grid[x+1][y][z+1])
                        -- 1 down 1 higher
                        and (not grid[x][y+1] or not grid[x][y+1][z+1])
                        -- 1 right 1 down 1 higher
                        and (not grid[x+1][y+1][z+1]) then
                            selection_grid[grid[x][y][z]] = grid[x][y][z]
                        end
                    end
                end
            end
        end
    end

    function state:find_matching_tiles()
        matching_tiles = {}
        for _,tile in pairs(selection_grid) do
            if tile.suit == Suits.FLOWER or tile.suit == Suits.SEASON then
                for _,matching_number in ipairs(matches[tile.suit]) do
                    for _,match in ipairs(matching_number) do
                        if match ~= tile and selection_grid[match] then
                            matching_tiles[tile] = tile
                            matching_tiles[match] = match
                        end
                    end
                end
            else
                for _,match in ipairs(matches[tile.suit][tile.number]) do
                    if match ~= tile and selection_grid[match] then
                        matching_tiles[tile] = tile
                        matching_tiles[match] = match
                    end
                end
            end
        end
    end

    function state:show_matching_tiles()
        for _,tile in pairs(matching_tiles) do
            if tile.focus.green.opacity == 0 then tile.focus.green.opacity = 255
            else tile.focus.green.opacity = 0
            end
        end
    end

    function state:undo()
    end

    function state:check_remaining_moves(hint)
    end

    function state:click(selector)
        if new_game then new_game = false end

        local x = selector.x
        local y = selector.y
        local z = selector.z

        local tile = grid[x][y][z]

        if not selected_tile then
            -- if its a selectable piece
            if selection_grid[tile] then
                -- select the piece
                selected_tile = tile
                tile.focus.green.opacity = 255
            end
        else
            if selection_grid[tile] and selected_tile:is_a_match(tile) then
                self:remove_tile(tile)
                self:remove_tile(selected_tile)
                selected_tile = nil

                self:find_selectable_tiles()
                self:find_top_tiles()
                self:find_matching_tiles()
            elseif tile == selected_tile then
                selected_tile.focus.green.opacity = 0
                selected_tile = nil
            end
        end
    end

    function state:remove_tile(tile)
        tile.null = true
        local position = tile.position
        tile.group:unparent()

        grid[position[1]][position[2]][position[3]] = nil
        grid[position[1]+1][position[2]][position[3]] = nil
        grid[position[1]][position[2]+1][position[3]] = nil
        grid[position[1]+1][position[2]+1][position[3]] = nil
    end

    function state:check_for_win()
    end

end)
