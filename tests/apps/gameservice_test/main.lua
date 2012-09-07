dofile("queue.lua")
dofile("notification.lua")

--[[ sample code to test json serialization and deserialization of guess game state
local gs = "{\"guessGameState\":{\"attempts\":0,\"guess\":-1,\"low\":0,\"high\":9,\"won\":false}}"

local gg = json:parse ( gs )
dumptable ( gg )
print ( json:stringify( gg ) )
exit( )
--]]

local GAME_STATE_NOT_READY = "not_ready"
local GAME_STATE_READY = "ready"
local GAME_STATE_ASSIGN_MATCH_PENDING = "assign_match_pending"
local GAME_STATE_ASSIGN_MATCH_DONE = "assign_match_done"
local GAME_STATE_JOIN_MATCH_PENDING = "join_match_pending"
local GAME_STATE_JOIN_MATCH_DONE = "join_match_done"
local GAME_STATE_PLAY = "play"

-- the following two variables are assigned by the gameservice callback functions
local match_id
local join_role

local game_state = GAME_STATE_NOT_READY
local prev_game_state = GAME_STATE_NOT_READY


local setGameState = 
	function ( new_state ) 
		if  new_state == game_state then
			print ( " new_state == game_state. skipping ")
		else 
			print ( "game_state changing from " .. game_state .. " to " .. new_state )
			prev_game_state = game_state
			game_state = new_state
		end
	end

local app_id = { name = app.name, version = app.version }

local game_name = "guessgame"
	
local game_id = "urn:xmpp:mug:tp:" .. app_id.name .. ":" .. "1" .. ":" .. game_name

print ("game_id is " .. game_id)

local on_ready = 
	function ( gameservice, app_id ) 
		setGameState( GAME_STATE_READY )
	end

local on_error = 
	function ( gameservice, response_status )
		print( "gameservice failed on open_app. exiting..." )
		dumptable( response_status )
		exit( )
	end

gameservice.on_ready =  on_ready 
gameservice.on_error = on_error

local on_assign_match_completed = 
	function ( gameservice, response_status, match_request, new_match_id )
		dumptable ( response_status )
		if response_status.status == 0 then
			match_id = new_match_id
			setGameState( GAME_STATE_ASSIGN_MATCH_DONE )
		else
			print( "assign match failed. cannot continue" )
			exit( )
		end
	end

--gameservice.on_assign_match_completed = on_assign_match_completed

local doStart = 
	function ( )
		local match_request = 
		{ 
			game_id = game_id, 
			free_role = true,
			nick = "p2",
			new_match = false,
		}
		
		setGameState( GAME_STATE_ASSIGN_MATCH_PENDING )
		gameservice:assign_match( match_request, on_assign_match_completed )	
	end

local on_join_match_completed =
	function ( gameservice, response_status, match_id, from, item )
		if response_status.status == 0 then
			setGameState( GAME_STATE_JOIN_MATCH_DONE )
			join_role = item.role
		else
			print( "join match failed. cannot continue" )
			exit( )
		end
	end
	
-- gameservice.on_join_match_completed = on_join_match_completed

local doJoinMatch = 
	function ( )
		if match_id == nil then 
			print( " Inside doJoinMatch(). match_id is nil. fatal error. exiting" )
			exit()
		else		
			print( " assigned match_id = " .. match_id )
			setGameState( GAME_STATE_JOIN_MATCH_PENDING )
			gameservice:join_match( match_id, "p2", true, on_join_match_completed )
		end
	end
		
local play = 
	function ( match_id, state ) 

		print( "current state:" .. state )
		--	guessGameAsJSON("{\"guessGameState\":{\"attempts\":0,\"guess\":-1,\"low\":0,\"high\":9,\"won\":false}}");
		
		local gg = json:parse(state);

		local range = gg.guessGameState.high - gg.guessGameState.low + 1;
		local myguess = math.random( range ) - 1
		gg.guessGameState.guess = gg.guessGameState.low + myguess
			    
		print( "guess: " .. gg.guessGameState.guess )
		gameservice:send_turn( match_id, json:stringify( gg ), false );
	end
	
local doPlay = 
	function ( )
		setGameState( GAME_STATE_PLAY )
		notification = Queue.pop( notification_queue );
		if notification == nil then
			print ( " notification queue is empty ")
			return
		end
		
		if match_id ~= notification.match_id then
			return;
		end
		
		if notification.type == NOTIFICATION_TYPE_PLAY then
			if notification.role == join_role then
				play( match_id, notification.state );
			end
		elseif notification.type == NOTIFICATION_TYPE_MATCH_COMPLETED then
			print( "match completed." )
			exit();
		end
	end


local doGameLoop = 
	function ( idle, numSeconds )
	
		if game_state ~= prev_game_state then
			print( "Inside doGameLoop. game_state changed. from " .. prev_game_state .. " to " .. game_state)
			prev_game_state = game_state
		end
		
		if game_state == GAME_STATE_READY then
			doStart()
		elseif game_state == GAME_STATE_ASSIGN_MATCH_DONE then
			doJoinMatch()
		elseif game_state == GAME_STATE_JOIN_MATCH_DONE or game_state == GAME_STATE_PLAY then
			doPlay()
		end
	end

idle.limit = 1.0

idle.on_idle = doGameLoop

--[[
local game = {
		app_id = { app.name, app.version },
		name = "guess_number",
		turn_policy = "roundrobin",
		game_type = "correspondence",
		roles = {
				{"player1"},
				{"player2"},
		},
		min_players_to_start = 1,
		abort_when_player_leaves = true,
}
--]]
