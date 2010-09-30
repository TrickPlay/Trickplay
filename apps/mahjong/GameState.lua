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
    -- all the tile objects stored in a table
    local tiles = nil
    -- the class for all the tiles with functions
    local tiles_class = nil
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
    function state:get_tiles() return tiles end
    function state:get_tiles_class() return tiles_class end
    function state:is_new_game() return new_game end
    function state:must_restart() return must_restart end
    function state:game_won() return game_won end

    function state:set_must_restart(bool)
        assert(type(bool)=="boolean")
        must_restart = bool
    end
    --[[
        If true the player can move anywhere.
        If false the palyer has a collection of cards and can only move those
        cards to specific CardStack Objects.
    --]]
    function state:is_roaming() return roaming end


----------------- Initialization -------------


    function state:initialize()
        print("state initializing")
        new_game = true
        game_won = false
    end

    function state:reset()
        new_game = true
        game_won = false
        must_restart = false
        game_timer.start = 0
        game_timer.current = 0
    end

    function state:build_mahjong()
        -- Get all the tiles in the game
        tiles_class = Tiles()
        tiles_class:shuffle()
        tiles = tiles_class:get_tiles()

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
        print("final index", index)
        -- Top Piece
        grid[14][8][5] = tiles[index]
        index = index + 1

    end


--------------------- Functions ------------------


    function state:undo()
    end

    function state:check_remaining_moves(hint)
    end

    function state:click(selector)
        if new_game then new_game = false end

        local x = selector.x
        local y = selector.y

        if state:is_roaming() then
        else
        end

        return state:is_roaming()
    end

    function state:check_for_win()
    end

end)
