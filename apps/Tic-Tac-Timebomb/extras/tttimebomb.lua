
-- defaults (these should probably never change)

local TTTDefaults = {
    states  = {"init", "start", "switch", "move", "shutdown" },
    magic_3     =  { 2,   7,   6,   9,   5,   1,   4,   3,   8   },
    rev_magic_3 =  { 2=1, 7=2, 6=3, 9=4, 5=5, 1=6, 4=7, 3=8, 8=9 },
    player_icon = {"X", "O"}
    plays = {"invalid", "win", "no", "tie" },
    start_speed = 0.3,
    win_rounds = 6
}

TTTDefaults.player_icon[TTTDefaults.player[0]] = "X"
TTTDefaults.player_icon[TTTDefaults.player[0]] = "O"

local Game = {}
 
--[[========================================================================
    Initialize game session 
--]]
function Game:init(kwargs)

    -- load defaults/constants
    local kwargs = kwargs or {}
    for k,v in pairs(TTTDefaults) do
        self["_" .. k] = kwargs[k] or TTTDefaults[k]
    end

    self.round_count = 0 
    self.wins = {0, 0}

    -- second timer
    self.round_timer = Timer()
    self.round_timer.interval = 1
    self.round_timer.on_timer = function(timer)
        self.round_time = self.round_time + 1
        print(self.round_time)
    end
    
end

function Game:start()
    if self.round_count == self
end


function init_game()

	if 

    -- refresh board
    board = {}
    free_spaces = {}

    for i=1,9 do
        table.insert(board, " ")
        table.insert(free_spaces, true)
    end

    print_board()
        
    -- another game
    round_count = round_count + 1
    move_count = 0

    first_player = math.random(1,2)

    selected_index = 0

    round_time = 0

    player_moves = {}
    player_moves[PLAYER_1] = {}
    player_moves[PLAYER_2] = {}
    
	NewPlayField()
end

--[[========================================================================
    Main Functions
--]]

-- Make a play
-- returns - `true`  if player won
--         - `false` if invalid move
--         - `nil`   if nothing happened
function play_at(index, player)

    assert(move_count >= 1)
    assert(move_count <= 9)

    local curr_player_moves = player_moves[player]

    if move_count >= 5 then
        -- check for human win
        local win_positions = get_win_positions(player_moves[player], index)
        if win_positions then 
			return WIN_PLAY, win_positions
		end
	end

	if move_count == 9 then
        return TIE_PLAY 
    end

    curr_player_moves[#curr_player_moves+1] = magic_3_square[index]
    free_spaces[index] = false

	return NO_PLAY
end

function make_moving_piece()
	local free_spaces = get_free_spaces(player_moves)
	local i = 1
	local random_table = randomize_table(free_spaces)
    print("random table [1] " .. random_table[1])
	move_timer = Timer()
	move_timer.interval = SELECT_SPEED
    moving_piece = PlayFieldAddPiece(PLAYER_ICONS[player], index_to_column_row(random_table[1]))

    local function on_move_timer(timer)
        selected_index = random_table[i]
		col, row = index_to_column_row(selected_index)
        PlayFieldMovePiece(moving_piece, col, row)
        i = (i % #free_spaces) + 1
    end
    
	move_timer.on_timer = on_move_timer

    on_move_timer()
	move_timer:start()
end

function print_board()

    local s=    

       "      1   2   3    \n"..
       "                   \n"..
       "  1   %s | %s | %s \n"..
       "     ---+---+---   \n"..
       "  2   %s | %s | %s \n"..
       "     ---+---+---   \n"..
       "  3   %s | %s | %s \n"
    
    print( string.format( s , unpack( board ) ) )
   
end

function shutdown()
end

screen.on_key_down = function(screen, keyval)
    key_actions = {
        [keys.space] = function()
            if STATE == INIT_STATE then
                start_game_session()
                init_game()
                STATE = SWITCH_STATE
            elseif STATE == START_STATE then
                init_game()
                STATE = SWITCH_STATE
            elseif STATE == SWITCH_STATE then
                -- prepare for input
                STATE = MOVE_STATE
                move_count = move_count + 1
                player = (move_count % 2 == (first_player-1)) and PLAYER_1 or PLAYER_2
                make_moving_piece()
                round_timer:start()
            elseif STATE == MOVE_STATE then
                move_timer:stop()
                round_timer:stop()
                PlayFieldFixPiece(moving_piece)
                local index = selected_index
                local move_result, win_table = play_at(index, player)
                local player_icon = PLAYER_ICONS[player]
                board[index] = player_icon
                print_board()
				if move_result == WIN_PLAY then
                    print(" PLAYER " .. player_icon .. " WINS!") 
                    -- keep track of previous games
                    game_wins[player] = game_wins[player] + 1
                    game_history[player][game_wins[player]] = shallow_copy(board)
                    STATE = START_STATE
                    SavePlayField(board, win_table, game_wins[player])
					ClearPlayField()
                elseif move_result == TIE_PLAY then
                     -- nobody won, dec round count!
                    round_count = round_count - 1
                    print(" TIE!") 
                    STATE = START_STATE
					ClearPlayField()
                else
                    STATE = SWITCH_STATE
                end
            end
        end,
        [keys.q] = function() 
            STATE = SHUTDOWN_STATE
            shutdown()
        end
    }
    if key_actions[keyval] then
        key_actions[keyval]()
    else
        print("UNKNOWN KEY: " .. keyval)
    end
end
