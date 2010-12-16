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
    -- a table containing the positions of all available tiles
    local positions = nil
    -- the class for all the tiles with functions
    local tiles_class = nil
    -- current selected tile to be compared with another tile for elimination
    local selected_tile = nil
    -- a table containing the two tiles that were last removed from the board
    -- tiles can be restored by pressing undo
    local last_tiles = nil
    -- a table containing two tiles currently hinted too
    local hint_tiles = nil
    -- true if the game has not started yet
    local new_game = true
    -- number of games started
    local games_started = 0
    -- true if the game was won and the auto-complete dialog already showed
    local game_won = false
    -- number of games won
    local games_won = 0
    -- true if the game is won and the player must redeal to do anything
    local must_restart = false
    -- true if the player is in roaming mode
    local roaming = false
    -- the Layout determines layout of mahjong game
    local layout = nil
    -- the number of the layout among layouts
    local layout_number = nil

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
    function state:get_current_layout() return layout_number end
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
        --print("state initializing")
        new_game = true
        game_won = false
        
        -- Get all the tiles in the game
        tiles_class = Tiles()
        tiles = tiles_class:get_tiles()
        matches = tiles_class:get_matches()
    end

    function state:reset()
        new_game = true
        game_won = false
        must_restart = false
        game_timer.start = 0
        game_timer.current = 0
        last_tiles = nil
        selected_tile = nil

        tiles_class:restore_order()
        tiles_class:reset()
        game_menu:remove_tile_images()
    end

    function state:save()
        settings.grid = grid
    end

    function state:build_layout(number)
        assert(number or layout_number)
        if number ~= nil then
            assert(type(number) == "number")
            layout_number = number
        end
        layout = Layout(tiles_class, layout_number)
        grid = layout:get_grid()
    end

    function state:load_layout()
        if not settings.grid then return false end 

        layout = Layout(tiles_class, nil, true)
        grid = layout:get_grid()
        return true
    end

    function state:shuffle()
        local switch = nil
        local temp = {}
        last_tiles = nil

        
        tiles_class:reset()

        for tile,position in pairs(positions) do
            table.insert(temp, position)
        end

        for i,position in ipairs(temp) do
            rand_pos = temp[math.random(#temp)]
            rand_tile = grid[rand_pos[1]][rand_pos[2]][rand_pos[3]]
            tile = grid[position[1]][position[2]][position[3]]
            assert(tile:is_a(Tile))
            assert(rand_tile:is_a(Tile))
            
            tile.position, rand_tile.position = rand_pos, position
            grid[rand_pos[1]][rand_pos[2]][rand_pos[3]],
            grid[position[1]][position[2]][position[3]]
                =
            grid[position[1]][position[2]][position[3]],
            grid[rand_pos[1]][rand_pos[2]][rand_pos[3]]

        end
        game_menu:remove_tile_images()
    end

    function state:set_tile_tables()
        state:set_tile_quadrants()
        state:find_selectable_tiles()
        state:find_matching_tiles()
        state:find_top_tiles()
        state:find_drawn_tiles()
    end

    function state:build_test()
        -- Sets up the game grid the player moves across
        local index = 1
        grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        grid[1][1][1] = tiles[1]
        grid[5][4][2] = tiles[2]
        grid[8][10][1] = tiles[3]
        grid[5][4][1] = tiles[4]
    end

    function state:build_two_tile_test()
        local index = 1
        grid = {}
        for i = 1,GRID_WIDTH do
            grid[i] = {}
            for j = 1,GRID_HEIGHT do
                grid[i][j] = {}
            end
        end

        grid[10][10][1] = tiles[1]
        grid[12][9][2] = tiles[2]
    end

    --[[
        The grid is set into quadrants, i.e., a tile at [1][1][1] will cover
        [1][2][1], [2][1][1], and [2][2][1] as well since each section represents
        one-quarter of a tile. This data structure allows for more complex tile
        placings.
    --]]
    function state:set_tile_quadrants()
        positions = {}
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    if grid[i][j][k] and not grid[i][j][k].set then
                        grid[i][j][k].position = {i,j,k}
                        positions[grid[i][j][k]] = {i,j,k}
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

    local function check_top(x, y, z)
        return grid[x][y][z+1]
               and grid[x+1] and grid[x+1][y] and grid[x+1][y][z+1]
               and grid[x][y+1] and grid[x][y+1][z+1]
               and grid[x+1][y+1] and grid[x+1][y+1][z+1]
    end
    local function check_right(x, y, z)
        return grid[x+2] and (grid[x+2][y] and (grid[x+2][y][z] or grid[x+2][y][z+1]))
               and (grid[x+2][y+1] and (grid[x+2][y+1][z] or grid[x+2][y+1][z+1]))
    end

    local function check_bottom(x, y, z)
        return grid[x][y+2] and (grid[x][y+2][z] or grid[x][y+2][z+1])
               and grid[x+2] and grid[x+2][y+2] and (grid[x+2][y+2][z]
               or grid[x+2][y+2][z])
    end

    function state:find_drawn_tiles()
        for i = 1,GRID_WIDTH do
            for j = 1,GRID_HEIGHT do
                for k = 1,GRID_DEPTH do
                    -- tile exists
                    if grid[i][j][k] and (not grid[i-1]
                    or grid[i][j][k] ~= grid[i-1][j][k])
                    and (not grid[i][j-1] or grid[i][j][k] ~= grid[i][j-1][k]) then
                        if check_right(i, j, k) and check_bottom(i, j, k)
                        and check_top(i, j, k) then
                            if not grid[i][j][k].group then
                                print("grid...", grid[i][j][k])
                                dumptable(grid[i][j][k])
                            end
                            grid[i][j][k].group:hide()
                        else
                            if not grid[i][j][k].group then
                                print("grid...", grid[i][j][k])
                                dumptable(grid[i][j][k])
                            end
                            grid[i][j][k].group:show()
                        end
                    end
                end
            end
        end
    end

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
                            table.insert(top_tiles, grid[x][y][z])
                        end
                    end
                end
            end
        end

        add_to_key_handler(keys.t, function()
            for k,v in ipairs(top_tiles) do
                if is_key_hint_on(keys.t) then
                    v:show_red()
                else
                    v:hide_red()
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
            if tile.focus.green.opacity == 0 then tile:show_green()
            else tile:hide_green()
            end
        end
    end

    function state:undo()
        if not last_tiles then return false end

        local tile_2 = table.remove(last_tiles)
        local tile_1 = table.remove(last_tiles)
        local position_1 = tile_1.position
        local position_2 = tile_2.position

        grid[position_1[1]][position_1[2]][position_1[3]] = tile_1
        grid[position_2[1]][position_2[2]][position_2[3]] = tile_2

        tile_1:reset()
        tile_2:reset()

        local temp = {tile_1, tile_2}
        if not last_tiles[1] then last_tiles = nil end

        return temp

    end

    function state:hint()
        local tile_1 = nil
        local tile_2 = nil
        for _,tile in pairs(matching_tiles) do
            if not tile_1 then
                tile_1 = tile
            elseif tile:is_a_match(tile_1) then
                tile_2 = tile
            end
        end

        if tile_1 then
            game:get_presentation():sparkle(tile_1.group.x+20, tile_1.group.y+30, 4)
            game:get_presentation():sparkle(tile_2.group.x+20, tile_2.group.y+30, 4)
        end

        hint_tiles = {tile_1, tile_2}
    end

    function state:click(selector)
        if new_game then
            new_game = false
            games_started = games_started + 1
        end

        local x = selector.x
        local y = selector.y
        local z = selector.z

        local tile = grid[x][y][z]

        -- if its a selectable piece
        if not selected_tile and selection_grid[tile] then
            -- select the piece
            selected_tile = tile
            game_menu:add_tile_image(
                Clone{source = tile.images[tile.current][tile.height]},
                Clone{source = tile.glyph})
            tile:show_green()
        elseif selection_grid[tile] and selected_tile
        and selected_tile:is_a_match(tile) then
            local counter = 0
            local temp = selected_tile

            tile:show_green()
            tile:hide_yellow()
            local interval_1 = {opacity = Interval(tile.focus.green.opacity, 0)}
            local interval_2 = {opacity = Interval(temp.focus.green.opacity, 0)}

            gameloop:add(tile.focus.green, 600, nil, interval_1)
            gameloop:add(temp.focus.green, 600, nil, interval_2)
            
            game_menu:add_tile_image(
                Clone{source = tile.images[tile.current][tile.height]},
                Clone{source = tile.glyph})

            ctrl:get_presentation():tile_bump(tile.group, temp.group)

            if hint_tiles and hint_tiles[1] ~= tile and hint_tiles[2] ~= tile then
                hint_tiles[1]:hide_green()
                hint_tiles[2]:hide_green()
            end

            if not last_tiles then last_tiles = {} end
            table.insert(last_tiles, tile)
            table.insert(last_tiles, selected_tile)
            state:remove_tile(tile)
            state:remove_tile(selected_tile)
            selected_tile = nil

            state:find_selectable_tiles()
            state:find_top_tiles()
            state:find_matching_tiles()
        elseif tile == selected_tile then
            selected_tile:hide_green()
            game_menu:remove_tile_images()
            selected_tile = nil
        else
            tile:show_yellow()
            tile.focus.yellow.opacity = 50
            tile:show_red()
            tile.focus.red.opacity = 255
            mediaplayer:play_sound("assets/audio/match-bad.mp3")
            local interval = {opacity = Interval(tile.focus.red.opacity, 0)}
            gameloop:add(tile.focus.red, 200, nil, interval, nil, 
                function()
                    tile.focus.yellow.opacity = 255
                    tile:hide_red()
                end)
        end
    end

    function state:remove_tile(tile)
        tile.null = true
        local position = tile.position
        --tile.group:unparent()

        grid[position[1]][position[2]][position[3]] = nil
        grid[position[1]+1][position[2]][position[3]] = nil
        grid[position[1]][position[2]+1][position[3]] = nil
        grid[position[1]+1][position[2]+1][position[3]] = nil

        tile.set = false
        positions[tile] = nil
    end

    function state:check_for_win()
        selected_tile = nil
        self:find_top_tiles()
        if #top_tiles == 0 then
            games_won = games_won + 1
            game_won = true
            must_restart = true
            last_tiles = nil
            game:get_presentation():show_end_game()
            router:set_active_component(Components.MENU)
            router:notify()
        else
            router:set_active_component(Components.NO_MOVES_DIALOG)
            router:notify()
        end
    end

end)
