--umbrella group for all members of the splash screen
local images = Group{}
--back icon
local back_button = Image{src="assets/button-back.png",x=28,y=870}
local back_focus  = Image{src="assets/focus-back-btn.png",x=28,y=870}
back_focus:hide()
--background
images:add(Image{src="assets/background-game.jpg",scale={2,2}})
screen:add(images)
images:hide()

--the Focus indicator, and its index-position
local focus = Image{src="assets/focus-square-tiles.png"}
local focus_next = Clone{source=focus}
focus.anchor_point      = {focus.w/2,focus.h/2}
focus_next.anchor_point = {focus.w/2,focus.h/2}
focus_next:hide()
local focus_i = {1,1}

--container for the tiles
local board = Group{}

--positioning info
local spacing   =  36

--local global for storing the first tile that was selected
local first_selected   = nil

--size of the board, based on difficulty

local board_spec = {
    --left_x, top_y, scale of tile, num_rows, num_cols
    {    534,    88,             1,        3,        4},
    {    667,    38,           .85,        4,        4},
    {    438,    56,            .8,        4,        6}
}

--function that determines the position of a tile based on its index
local function x_y_from_index(i,j)

    return     (board_spec[game_state.difficulty][1] +
         (i-.5)*board_spec[game_state.difficulty][3]*tile_size +
         (i- 1)*spacing),
               (board_spec[game_state.difficulty][2] +
         (j-.5)*board_spec[game_state.difficulty][3]*tile_size +
         (j- 1)*spacing)
end
local back_sel = false
images:add(back_button,back_focus,board,focus,focus_next)
function game_fade_in(previous_board)
    board:clear()
    
    game_state.tot = board_spec[game_state.difficulty][5] * board_spec[game_state.difficulty][4]
    game_state.board_size = {board_spec[game_state.difficulty][5], board_spec[game_state.difficulty][4]}
    
    if previous_board == nil then
        local options = {}
        for i = 1, board_spec[game_state.difficulty][5] do
            game_state.board[i] = {}
            for j = 1, board_spec[game_state.difficulty][4] do
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
            t.group.scale = {board_spec[game_state.difficulty][3],board_spec[game_state.difficulty][3]}
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
                    t.group.scale = {board_spec[game_state.difficulty][3],board_spec[game_state.difficulty][3]}
                    board:add(t.group)
                    game_state.board[ i ][ j ] = t
                else
                    game_state.board[ i ][ j ] = 0
                    game_state.tot = game_state.tot - 1
                end
            end
        end
    end
    focus.scale={board_spec[game_state.difficulty][3],board_spec[game_state.difficulty][3]}
    images:show()
    back_sel = false
    first_selected   = nil
    back_focus:hide()
    focus:show()
    focus.x, focus.y = x_y_from_index(1,1)
    focus_i = {1,1}
end
function game_fade_out()
    images:hide()
end

local function anim_focus()
    local tl = Timeline{duration=200}
    function tl:on_new_frame()
        local p = tl.progress
        focus_next.opacity = 255*p
        focus.opacity = 255*(1-p)
    end
    function tl:on_completed()
        
        focus.x = focus_next.x
        focus.y = focus_next.y
        focus.opacity = 255
        focus_next:hide()
    end
    focus_next.opacity=0
    focus_next:show()
    tl:start()
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
        print("second")
            game_state.board[focus_i[1]][focus_i[2]].flip(first_selected)
            first_selected = nil
        end
    end,
    [keys.Up] = function()
        if focus_i[2] > 1 then
            focus_i[2] = focus_i[2] - 1
            focus_next.x,focus_next.y = x_y_from_index(focus_i[1],focus_i[2])
            anim_focus()
            --focus.y    = 200*focus_i[2]
            back_sel   = false
        end
    end,
    [keys.Down] = function()
        if focus_i[2] < board_spec[game_state.difficulty][4] then
            focus_i[2] = focus_i[2] + 1
            --focus.y    = 200*focus_i[2]
            focus_next.x,focus_next.y = x_y_from_index(focus_i[1],focus_i[2])
            anim_focus()
        end
    end,
    [keys.Right] = function()
        if focus_i[1] < board_spec[game_state.difficulty][5] then
            focus_i[1] = focus_i[1] + 1
            focus_next.x,focus_next.y = x_y_from_index(focus_i[1],focus_i[2])
            anim_focus()
            --focus.x = 200*focus_i[1]
        end
    end,
    [keys.Left] = function()
        if focus_i[1] >1 then
            focus_i[1] = focus_i[1] - 1
            focus_next.x,focus_next.y = x_y_from_index(focus_i[1],focus_i[2])
            anim_focus()
            --focus.x = 200*focus_i[1]
        else
            back_focus:show()
            focus:hide()
            back_sel = true
        end
    end,
}

back_button_key_handler = {
    [keys.OK] = function()
        game_state.in_game = false
        give_keys("SPLASH")
    end,
    [keys.Right] = function()
        back_sel = false
        --focus.x,focus.y = x_y_from_index(focus_i[1],focus_i[2])
        back_focus:hide()
        focus:show()
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