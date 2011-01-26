--umbrella group for all members of the splash screen
local images = Group{}
--back icon
local back_button = Rectangle{w=100,h=100, color="000000",x=30,y=900}
--background
images:add(Rectangle{w=screen_w,h=screen_h,color="aba43f"})
screen:add(images)
images:hide()

--the Focus indicator, and its index-position
local focus = Rectangle{name="focus",w=100,h=100,color="FFFFFF",x=200,y=200}
local focus_i = {1,1}

--container for the tiles
local board = Group{}

--positioning info
local spacing   =  50
local tile_size = 150

--local global for storing the first tile that was selected
local first_selected   = nil

--size of the board, based on difficulty
local num_tiles = {
    {2,4},
    {3,6},
    {4,6}
}

--function that determines the position of a tile based on its index
local function x_y_from_index(i,j)

    local x, y, index
    
    --X POSITION
    --odd num cols
    if num_tiles[game_state.difficulty][2]%2 == 1 then
        index = i - (num_tiles[game_state.difficulty][2]/2+.5)
        if index > 0 then
            x = screen_w/2 + (index)*(spacing+tile_size)
        else
            x = screen_w/2 + (index)*(spacing+tile_size)
        end
    --even num cols
    else
        index = i - num_tiles[game_state.difficulty][2]/2
        
        if index > 0 then
            x = screen_w/2 + spacing/2 + tile_size/2 + (index-1)*(spacing+tile_size)
        else
            x = screen_w/2 - spacing/2 - tile_size/2 + (index)*(spacing+tile_size)
        end
    end
    
    --Y POSITION
    --odd num rows
    if num_tiles[game_state.difficulty][1]%2 == 1 then
        
        index = j - (num_tiles[game_state.difficulty][1]/2+.5)
        
        if index > 0 then
            y = screen_h/2 + (index)*(spacing+tile_size)
        else
            y = screen_h/2 + (index)*(spacing+tile_size)
        end
    --even num rows
    else
        index = j - num_tiles[game_state.difficulty][1]/2
        if index > 0 then
            y = screen_h/2 + spacing/2 + tile_size/2 + (index-1)*(spacing+tile_size)
        else
            y = screen_h/2 - spacing/2 - tile_size/2 + (index)*(spacing+tile_size)
        end
    end
    return x,y
end
local back_sel = false
images:add(back_button,board,focus)
function game_fade_in(previous_board)
    board:clear()
    
    game_state.tot = num_tiles[game_state.difficulty][1] * num_tiles[game_state.difficulty][2]
    game_state.board_size = {num_tiles[game_state.difficulty][1], num_tiles[game_state.difficulty][2]}
    
    if previous_board == nil then
        local options = {}
        for i = 1, num_tiles[game_state.difficulty][2] do
            game_state.board[i] = {}
            for j = 1, num_tiles[game_state.difficulty][1] do
                options[#options+1] = {i,j}
            end
        end
        local placement_order = {}
        while #options > 0 do
            placement_order[#placement_order+1] = table.remove(options,math.random(1,#options))
        end
        local t
        for i = 1, #placement_order do
            local index = math.ceil(i/2)
            index = index%4 + 1
            t = Tile(index, {placement_order[i][1] , placement_order[i][2]})
            --t.group.position={200*placement_order[i][1],200*placement_order[i][2]}
            t.group.x, t.group.y = x_y_from_index(placement_order[i][1],placement_order[i][2])
            board:add(t.group)
            game_state.board[ placement_order[i][1] ][ placement_order[i][2] ] = t
        end
    else
        local t
        for i = 1, #previous_board do
            game_state.board[i] = {}
            for j = 1, #previous_board[i] do
                if previous_board[i][j] ~= 0 and previous_board[i][j] ~= nil then
                    t = Tile(previous_board[i][j], {i,j})
                    --t.group.position={200*i,200*j}
                    t.group.x, t.group.y = x_y_from_index(i,j)
                    board:add(t.group)
                    game_state.board[ i ][ j ] = t
                else
                    game_state.board[ i ][ j ] = 0
                    game_state.tot = game_state.tot - 1
                end
            end
        end
    end
    images:show()
    back_sel = false
    first_selected   = nil
    
    focus.x, focus.y = x_y_from_index(1,1)
    focus_i = {1,1}
end
function game_fade_out()
    images:hide()
end

------------------------
---- key handler
------------------------

local board_key_handler = {
    [keys.OK] = function()
        if game_state.board[focus_i[1]][focus_i[2]] == 0 or
           game_state.board[focus_i[1]][focus_i[2]] == nil then
            return
        elseif first_selected == nil then
            
            print(game_state.board[focus_i[1]][focus_i[2]])
            first_selected   = game_state.board[focus_i[1]][focus_i[2]]
            first_selected.flip(nil)
            
        else -- second selected
            game_state.board[focus_i[1]][focus_i[2]].flip(first_selected)
            first_selected = nil
        end
    end,
    [keys.Up] = function()
        if focus_i[2] > 1 then
            focus_i[2] = focus_i[2] - 1
            focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
            --focus.y    = 200*focus_i[2]
            back_sel   = false
        end
    end,
    [keys.Down] = function()
        if focus_i[2] < num_tiles[game_state.difficulty][1] then
            focus_i[2] = focus_i[2] + 1
            --focus.y    = 200*focus_i[2]
            focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
        else
            focus.y  = back_button.y
            focus.x  = back_button.x
            back_sel = true
        end
    end,
    [keys.Right] = function()
        if focus_i[1] < num_tiles[game_state.difficulty][2] then
            focus_i[1] = focus_i[1] + 1
            focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
            --focus.x = 200*focus_i[1]
        end
    end,
    [keys.Left] = function()
        if focus_i[1] >1 then
            focus_i[1] = focus_i[1] - 1
            focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
            --focus.x = 200*focus_i[1]
        else
            focus.y = back_button.y
            focus.x = back_button.x
            back_sel = true
        end
    end,
}

back_button_key_handler = {
    [keys.OK] = function()
        game_state.in_game = false
        give_keys("SPLASH")
    end,
    [keys.Up] = function()
        back_sel   = false
        focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
    end,
    [keys.Right] = function()
        back_sel = false
        focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
    end,
}

game_on_key_down = function(key)
    
    if back_sel and back_button_key_handler[key] then
        back_button_key_handler[key]()
    elseif board_key_handler[key] then
        board_key_handler[key]()
    else
        print("Game Screen Key handler does not support the key "..key)
    end
end