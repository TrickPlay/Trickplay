
local lock = {timer=true,anim=true}
GameControl = {}
local dim = Rectangle{w=screen.w,h=screen.h,color="000000",opacity=0}
screen:add(dim)
local win_anim = nil
-- defaults (these should probably never change)

local ControlConstants = {
    state  = { init = 1, start = 2, switch = 3, move = 4, wait = 5, shutdown = 6, clear = 7, skip = 8, help=9},
    magic_3     =  { 2,   7,   6,   9,   5,   1,   4,   3,   8   },
    rev_magic_3 =  { [2]=1, [7]=2, [6]=3, [9]=4, [5]=5, [1]=6, [4]=7, [3]=8, [8]=9 },
    player_icon = { "X", "O"},
    play = {invalid = 1, win = 2, no = 3, tie = 4},
    speeds = {400, 300, 250, 200},
    win_rounds = 6
}


local splashImg = Image
{
				src = "/assets/SplashScreen.jpg",
				opacity = 255,
				y = 0,
}	
local startbutton = Image
{
	src = "assets/start-button.png",
x=800,y=650,
					
}
local splash = Group{name="splash",anchor_point = {0,1080},z=6
}
splash:add(splashImg,startbutton)
screen:add(splash)

function GameControl:show_splash()
		if win_anim then
			win_anim:stop()
			win_anim:on_completed()
			win_anim = nil
		end
	--	lock.anim = false
		splash:raise_to_top()
		splash:animate({ 
			duration = 700, 
			y = screen.h, 
			mode = "EASE_IN_OUT_SINE", 
			on_completed = function() 
				dim.opacity=0 
				lock.anim = true
			end 
		})
		local child = screen:find_child("end session text")
        if child ~= nil then child:unparent() end

end


function GameControl:hide_splash()
	splash:complete_animation()
--lock.anim = false
	local t = Timeline
	{
		duration = 1000,
		direction = "FORWARD",
		loop = false
	}
	dim.opacity = 0
	local button_old_x = startbutton.x
	local button_old_y = startbutton.y
	local button_new_x = startbutton.x+30
	local button_new_y = startbutton.y+20
	function t.on_new_frame(t,msecs)
	dim.opacity = 0
		if msecs <= 150 then
			local p = (msecs)/(150)
			startbutton.x = button_old_x + (button_new_x - button_old_x)*p
			startbutton.y = button_old_y + (button_new_y - button_old_y)*p
		elseif msecs <= 300 then
			local p = (msecs-150)/(150)
			startbutton.x = button_new_x + (button_old_x - button_new_x)*p
			startbutton.y = button_new_y + (button_old_y - button_new_y)*p
		elseif msecs <= 500 then
		else
			local p = (msecs-500)/(t.duration-500)
			splash.y = 1080*(1-p)
			
		end
	end
	function t.on_completed()
		splash.y = 0
		startbutton.x = button_old_x
		startbutton.y = button_old_y
		lock.anim = true
	end
	t:start()


end

function GameControl:start_session()
	
    self.round_count = 0 
    self.wins = {0, 0}
    
    --self.free_spaces = {}

    self.player_moves = {{}, {}}
    
    self.player_wins  = { 0, 0 }

    self.history = {{}, {}}
end

function GameControl:start_round()
    
    self.board = {}
    for i=1,9 do
        table.insert(self.board, " ")
        self.free_spaces[i] = true
    end

    self.round_count = self.round_count + 1
    self.move_count = 0

    self.player = math.random(1,2)

    self.player_moves[1] = {}
    self.player_moves[2] = {}

    ClearPlayField()
	NewPlayField()

    -- update view
    self.print_move_text(self.player)
end

function GameControl:get_win_positions(moves, index)

    local win_positions = {}
    local index_val = ControlConstants.rev_magic_3[index]
    for i=1, #moves do
        for j=i+1, #moves do
            if moves[i] + moves[j] + ControlConstants.magic_3[index] == 15 then
                return {ControlConstants.rev_magic_3[moves[i]], ControlConstants.rev_magic_3[moves[j]], index}
            end
        end
    end
    return false
end

function GameControl.print_move_text(player)
    local other_player = player == 1 and 2 or 1
    StatusText:pressToMove(ControlConstants.player_icon[other_player])
end

function GameControl:place_player_at_index(player, index)

    self.print_move_text(player)

    local moves = self.player_moves[player]

    -- update board
    local player_icon = ControlConstants.player_icon[player]
    self.board[index] = player_icon

    if self.move_count >= 5 then
        -- check for win
        local win_positions = self:get_win_positions(moves, index)
        if win_positions then 
            -- keep track of previous games
            local wins = self.player_wins[player] + 1
            self.player_wins[player] = wins
			
            -- update view
            SavePlayField(self.board, win_positions, wins, self.round_count)
			
            -- end of a session?
            if wins == ControlConstants.win_rounds then
                local winner = Image
                {
                    name="end session text",
                    src="assets/PieceHg".. player_icon.."C.png",
                    scale={1.4,1.4},
                }
                local winnertext = Image
                {   name="end of session text",
                	src ="assets/wins.png",
					opacity = 0,
                }	
                winner.position = {screen.w/2,-screen.h/2}
                winner.anchor_point={winner.w/2,winner.h/2}    
                
                winnertext.position = {screen.w/2,screen.h/2}
                winnertext.anchor_point={winnertext.w/2,winnertext.h/2}
				dim.opacity = 0
                screen:add(winner,winnertext)
                
                --winner:animate{duration=700,y=screen.h/2, mode = "EASE_IN_OUT_SINE"}
                --winnertext:animate{duration=700,y=screen.h/2 + 240, mode = "EASE_IN_OUT_SINE"}
				win_anim = Timeline
				{
					duration  = 1300,
					direction = "FORWARD",
					loop      = false
				}
				function win_anim.on_new_frame(t,msecs,p)
					dim.opacity = p*150
					if msecs <= 200 then
						PlayField.opacity = msecs/200*(255*.7-255) + 255
					elseif msecs <= 400 then
						local p = (msecs-200)/200
						winner.y = -screen.h/2 + screen.h*p
					elseif msecs <= 1000 then
						winner.y = screen.h/2
						
					elseif msecs > 1000 then
						winner.y = screen.h/2
						local p = (msecs-1000)/(t.duration-1000)
						winnertext.opacity = 255*p
					end
				end
				function win_anim.on_completed()
					win_anim=false
					winner.y = screen.h/2
					winnertext.opacity = 255
					dim.opacity = 150
				end
				dim:raise_to_top()
				winner:raise_to_top()
				winnertext:raise_to_top()
                win_anim:start()
				--ClearPlayField()
				return ControlConstants.state.clear
            else
                
                -- update view
                self.board = {}
			for i=1,9 do
				table.insert(self.board, " ")
				self.free_spaces[i] = true
			end
			
			
			self.round_count = self.round_count + 1
			self.move_count = 0
			
			self.player = math.random(1,2)
			
			self.player_moves[1] = {}
			self.player_moves[2] = {}
		        FuckPlayField()
				
                return ControlConstants.state.switch
            end
		end
	end

	if self.move_count == 9 then
         -- nobody won, dec round count!
        self.round_count = self.round_count - 1
				
                -- update view
                self.board = {}
			for i=1,9 do
				table.insert(self.board, " ")
				self.free_spaces[i] = true
			end
			
			
			self.round_count = self.round_count + 1
			self.move_count = 0
			
			self.player = math.random(1,2)
			
			self.player_moves[1] = {}
			self.player_moves[2] = {}
		    FuckPlayField()
        return ControlConstants.state.switch
    end
    moves[#moves+1] = ControlConstants.magic_3[index]
    self.free_spaces[index] = false

    return ControlConstants.state.switch
end

function GameControl.make_random_move_delegate(free_space_mask, placement_callback)
      
    local i, j
    local timer = Timer()
    local moving_piece
    local length
    local random_table
    local callback_player
	local running = false   -- is the timer running?

    local function get_random_free_spaces()
        local free_spaces = Utils.get_free_spaces(free_space_mask)
        return Utils.randomize_table(free_spaces)
    end

    local function start(player)

        assert(running == false, "trying to start 2 moving pieces!")

        callback_player = player
        -- place timer board
        StatusText:pressToDrop(ControlConstants.player_icon[player])

        TimerBoardShow(ControlConstants.player_icon[player])

        random_table = get_random_free_spaces()
        length = #random_table

        local col, row =  Utils.index_to_column_row(random_table[1])
        moving_piece = PlayFieldAddPiece(ControlConstants.player_icon[player], col, row)

        i, j = 0, 1
        timer:on_timer()
        timer:start()
		running = true
    end

    local function stop()
        -- only stop if running
        if not running then 
            return
        end

        timer:stop()

        placement_callback(callback_player, random_table[i])
        TimerBoardClear()

        PlayFieldFixPiece(moving_piece)

        -- reset interval speed
        timer.interval = ControlConstants.speeds[1]
        running = false
    end

    local function on_timer_callback(timer)
        
        i = (i % length) + 1 -- cycle to next position

        local col, row = Utils.index_to_column_row(random_table[i])

        -- update view
        PlayFieldMovePiece(moving_piece, col, row)

		prev_index = random_table[i]
        
        -- decrement timer board and speed up
        if i % length == 0 then
            TimerBoardTick()

            j = j + 1
            if j == #ControlConstants.speeds + 1 then
                stop()
            else
                timer.interval = ControlConstants.speeds[j]
            end
        end
    end
     
    timer.interval = ControlConstants.speeds[1]
    timer.on_timer = on_timer_callback

    return { start = start, stop = stop}
end



function GameControl:make_state_machine() 


	local state = {
		

    	[ControlConstants.state.init] = function() 
        	
			mediaplayer:play_sound("audio/Tic Tac Go Start Button.mp3")
        	self:start_session()
        	self:start_round()
        	self:hide_splash()
			
			
			
        	return ControlConstants.state.switch
    	end,

    	[ControlConstants.state.start] = function() 
			
			self:start_round()

            -- update view
        
        	return ControlConstants.state.switch
    	end,
    	
    	[ControlConstants.state.help] = function()
    	    local child = screen:find_child("help text")
            if child == nil then 
    	  		screen:add(Text{text="help text",color="ffffff",position={960,1580},font="DejaVu Sans 50px",name="help text"})

    	  	end
    	  	return ControlConstants.state.clear
    	end,

    	[ControlConstants.state.switch] = function() 
			
        	-- prepare for input
        	self.move_count = self.move_count + 1
			
        	-- switch player
        	self.player = self.player == 1 and 2 or 1
			
        	-- start move_timer
        	self.move_delegate.start(self.player)
			
        	return ControlConstants.state.move
    	end,
		
    	[ControlConstants.state.move] = function() 
        	self.move_delegate.stop()
			mediaplayer:play_sound("audio/Tic Tac Go Piece Placement.mp3")
			-- delegate callback will trigger next state change
        	return ControlConstants.state.wait
    	end,
		
    	[ControlConstants.state.shutdown] = function() 
			
        	exit()
    	end,

        [ControlConstants.state.skip] = function(next_state) 
            return next_state
    	end,
--[[
        [ControlConstants.state.wait] = function() 

            return ControlConstants.state.wait
    	end,
--]]
        [ControlConstants.state.clear] = function() 
            local child = screen:find_child("end of session text")
            if child ~= nil then child:unparent() end
            -- stop moving piece if already running
        	self.move_delegate.stop()

            ClearMiniBoards()

            ClearPlayField()
 			
 			GameControl:show_splash()

            return ControlConstants.state.init
    	end
	}

	state.set = function(new_state, ...)
        local new_state_args = {...}
        local new_state_func = state[new_state]
        state.state = function() return new_state_func(unpack(new_state_args)) end
        state.next()
	end
    
    state.next = function()
        local new_state_name = state.state()
        if new_state_name ~= ControlConstants.state.wait then
            state.state = state[new_state_name]
        end
    end

    return state
end
local stored_keys = nil
local single_press = Timer{interval=100}
function single_press:on_timer()
	if lock.timer and lock.anim then
		self:stop()
		screen.on_key_down = stored_keys	
	end
	lock.timer = true
end
function GameControl.make_control()
    self = GameControl

    self.free_spaces = {}

    self.move_delegate = self.make_random_move_delegate(self.free_spaces, function(player, index)  
        local result = self:place_player_at_index(player, index)
        self.state.set(ControlConstants.state.skip, result)
    end)

    self.state = self:make_state_machine()
    self.state.set(ControlConstants.state.clear)

    screen.on_key_down = function(screen, keyval)
	    screen.on_key_down = function()
			print("1")
			lock.timer = false
		end
		print("2")
		single_press:start()
        local key_actions = {
			
            [keys.Return] = function()
                -- update view
                StatusText:EnterButtonPressed()
                self.state.next()
            end,
			
            [keys.q] = function() 
                self.state.set(ControlConstants.state.shutdown)
            end,
			
            [keys.r] = function()
                self.state.set(ControlConstants.state.clear)
            end,
            [keys.h] = function()
               
                self.state.set(ControlConstants.state.help)
            end,
        }
		
		if keyval == keys.OK then keyval = keys.Return end
		if keyval == keys.BLUE then keyval = keys.r end
        if key_actions[keyval] then
            key_actions[keyval]()
        
        end
    end
end
GameControl.make_control()
stored_keys = screen.on_key_down

GameControl:show_splash()
