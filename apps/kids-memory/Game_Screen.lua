--umbrella group for all members of the splash screen
local game_screen = Group{}
--back icon
local back_button = Image{src="assets/button-back.png",x=28,y=870}
local back_focus  = Image{src="assets/focus-back-btn.png",x=28,y=870}

--background
game_screen:add(Image{src="assets/background-game.jpg",scale={2,2}})
screen:add(game_screen)
game_screen:hide()

--the Focus indicator, and its index-position
local focus = Image{src="assets/focus-square-tiles.png"}
focus.anchor_point      = {focus.w/2,focus.h/2}

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
game_screen:add(back_focus,back_button,focus,focus_next,board)
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
            index = index%#tile_faces + 1
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
    back_sel = false
    first_selected   = nil
    game_screen:show()
    back_focus.opacity=0
    focus.opacity=255
    focus.x, focus.y = x_y_from_index(1,1)
    focus_i = {1,1}
end

function game_fade_out()
    game_screen:hide()
end
--[[
local focus_tl = Timeline{duration=200}
local ani_mode = Alpha{timeline=focus_tl,mode="EASE_OUT_CIRC"}

local function anim_focus(targ_x,targ_y)
    if focus_tl.is_playing then
        focus_tl:stop()
        focus_tl:on_completed()
    end
    
    
    local curr_x = focus.x
    local curr_y = focus.y
    function focus_tl:on_new_frame(_,p)
        local p = ani_mode.alpha
        focus.x = curr_x + (targ_x-curr_x)*p
        focus.y = curr_y + (targ_y-curr_y)*p
    end
    function focus_tl:on_completed()
        
        focus.x = targ_x
        focus.y = targ_y
        
    end

    focus_tl:start()
end
local function corner_get_focus()
    if focus_tl.is_playing then
        focus_tl:stop()
        focus_tl:on_completed()
    end
    
    function focus_tl:on_new_frame(_,p)
        back_focus.opacity = 255*p
        focus.opacity = 255*(1-p)
    end
    function focus_tl:on_completed()
        
        focus.opacity = 0
        back_focus.opacity = 255
        
    end
    focus_tl:start()
end
local function corner_lose_focus()
    if focus_tl.is_playing then
        focus_tl:stop()
        focus_tl:on_completed()
        
    end
    
    function focus_tl:on_new_frame(_,p)
        back_focus.opacity = 255*(1-p)
        focus.opacity = 255*(p)
    end
    function focus_tl:on_completed()
        
        focus.opacity = 255
        back_focus.opacity = 0
        --focus_tl = nil
    end
    focus_tl:start()
end
--]]
local anim_focus = {
    duration = {200},
    mode   = {"EASE_OUT_CIRC"},
    setup  = function(self)
        self.curr_x = focus.x
        self.curr_y = focus.y
    end,
    stages = {
        function(self,delta,p)
            focus.x = self.curr_x + (self.targ_x-self.curr_x)*p
            focus.y = self.curr_y + (self.targ_y-self.curr_y)*p
        end
    }
}
local corner_get_focus = {
    duration = {200},
    stages = {
        function(self,delta,p)
            back_focus.opacity = 255*(p)
            focus.opacity = 255*(1-p)
        end
    }
}

local corner_lose_focus = {
    duration = {200},
    stages = {
        function(self,delta,p)
            back_focus.opacity = 255*(1-p)
            focus.opacity = 255*(p)
        end
    }
}

------------------------
---- key handler
------------------------

local board_key_handler = {
    [keys.OK] = function()
        if game_state.board[focus_i[1]][focus_i[2]] == 0 or
           game_state.board[focus_i[1]][focus_i[2]] == nil then
            return
        elseif first_selected == nil then
            local next
            next   = game_state.board[focus_i[1]][focus_i[2]]
            if next.flip(nil) then
                first_selected = next
            end
            
        else -- second selected
            if game_state.board[focus_i[1]][focus_i[2]].flip(first_selected) then
            first_selected = nil
            end
        end
    end,
    [keys.Up] = function()
        if focus_i[2] > 1 then
            focus_i[2] = focus_i[2] - 1
            --anim_focus( x_y_from_index(focus_i[1],focus_i[2]) )
            anim_focus.targ_x, anim_focus.targ_y = x_y_from_index(focus_i[1],focus_i[2])
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            --focus.y    = 200*focus_i[2]
            back_sel   = false
        end
    end,
    [keys.Down] = function()
        if focus_i[2] < board_spec[game_state.difficulty][4] then
            focus_i[2] = focus_i[2] + 1
            --focus.y    = 200*focus_i[2]
            --anim_focus( x_y_from_index(focus_i[1],focus_i[2])
            anim_focus.targ_x, anim_focus.targ_y = x_y_from_index(focus_i[1],focus_i[2])
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            --)
        end
    end,
    [keys.Right] = function()
        if focus_i[1] < board_spec[game_state.difficulty][5] then
            focus_i[1] = focus_i[1] + 1
            --anim_focus( x_y_from_index(focus_i[1],focus_i[2]))
            anim_focus.targ_x, anim_focus.targ_y = x_y_from_index(focus_i[1],focus_i[2])
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            --focus.x = 200*focus_i[1]
        end
    end,
    [keys.Left] = function()
        if focus_i[1] >1 then
            focus_i[1] = focus_i[1] - 1
            --anim_focus( x_y_from_index(focus_i[1],focus_i[2]))
            anim_focus.targ_x, anim_focus.targ_y = x_y_from_index(focus_i[1],focus_i[2])
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            --focus.x = 200*focus_i[1]
        else
            --table.insert(animate_list,corner_get_focus)
            animate_list[corner_get_focus]=corner_get_focus
            --corner_get_focus()
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
        --table.insert(animate_list,corner_lose_focus)
        animate_list[corner_lose_focus]=corner_lose_focus
        --corner_lose_focus()
    end,
}

game_on_key_down = function(key)
    
    if back_sel and back_button_key_handler[key] then
        back_button_key_handler[key]()
    elseif not back_sel and board_key_handler[key] then
        board_key_handler[key]()
    else
        print("Game Screen Key handler does not support the key "..key)
    end
end