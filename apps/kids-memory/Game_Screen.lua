--umbrella group for all members of the splash screen
local images = Group{}
local first_selected   = nil
local back_button = Rectangle{w=100,h=100, color="000000",x=30,y=900}
images:add(Rectangle{w=screen_w,h=screen_h,color="aba43f"})
screen:add(images)
images:hide()


local focus = Rectangle{name="focus",w=100,h=100,color="FFFFFF",x=200,y=200}
local focus_i = {1,1}
--container for the tiles
local board = Group{}

--size of the board, based on difficulty
local num_tiles = {
    {2,4},
    {3,6},
    {4,6}
}
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
            t = Tile(math.ceil(i/2), {placement_order[i][1] , placement_order[i][2]})
            t.group.position={200*placement_order[i][1],200*placement_order[i][2]}
            board:add(t.group)
            game_state.board[ placement_order[i][1] ][ placement_order[i][2] ] = t
            --t.parent = {placement_order[i][1] , placement_order[i][2]}
        end
    else
        local t
        for i = 1, #previous_board do
            game_state.board[i] = {}
            for j = 1, #previous_board[i] do
                if previous_board[i][j] ~= 0 and previous_board[i][j] ~= nil then
                    t = Tile(previous_board[i][j], {i,j})
                    t.group.position={200*i,200*j}
                    board:add(t.group)
                    game_state.board[ i ][ j ] = t
                    --t.parent = {placement_order[i][1] , placement_order[i][2]}
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
    focus.y = 200
    focus.x = 200
    focus_i = {1,1}
end
function game_fade_out()
    images:hide()
end



local key_handler = {
    [keys.OK] = function()
        if back_sel then
            give_keys("SPLASH")
        elseif first_selected == nil then
            if game_state.board[focus_i[1]][focus_i[2]] ~= 0 and game_state.board[focus_i[1]][focus_i[2]] ~= nil then
                print(game_state.board[focus_i[1]][focus_i[2]])
                first_selected   = game_state.board[focus_i[1]][focus_i[2]]
                first_selected.flip(nil)
            end
        else -- second selected
            game_state.board[focus_i[1]][focus_i[2]].flip(first_selected)
            first_selected = nil
        end
    end,
    [keys.Up] = function()
        if back_sel then
            back_sel   = false
            focus.y    = 200*focus_i[2]
            focus.x    = 200*focus_i[1]
        elseif focus_i[2] > 1 then
            focus_i[2] = focus_i[2] - 1
            focus.y    = 200*focus_i[2]
            back_sel   = false
        end
    end,
    [keys.Down] = function()
        if focus_i[2] < num_tiles[game_state.difficulty][1] then
            focus_i[2] = focus_i[2] + 1
            focus.y    = 200*focus_i[2]
        elseif not back_sel then
            focus.y  = back_button.y
            focus.x  = back_button.x
            back_sel = true
        end
    end,
    [keys.Right] = function()
        if back_sel then
            back_sel = false
            focus.y = 200*focus_i[2]
            focus.x = 200*focus_i[1]
        elseif focus_i[1] < num_tiles[game_state.difficulty][2] then
            focus_i[1] = focus_i[1] + 1
            focus.x = 200*focus_i[1]
        end
    end,
    [keys.Left] = function()
        if focus_i[1] >1 then
            focus_i[1] = focus_i[1] - 1
            focus.x = 200*focus_i[1]
        elseif not back_sel then
            focus.y = back_button.y
            focus.x = back_button.x
            back_sel = true
        end
    end,
}

game_on_key_down = function(key)
    
    if key_handler[key] then
        key_handler[key]()
    else
        print("Splash Screen Key handler does not support the key "..key)
    end
end