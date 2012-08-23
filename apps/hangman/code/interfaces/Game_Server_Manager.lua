
--------------------------------------------------------------------------------
-- The Game Server Object                                                     --
--------------------------------------------------------------------------------
local Game_Server = {}

-- the following two variables are assigned by the gameservice callback functions

local gameservice_available = false
local gameservice_error_response = nil

local props = {
		screen_name = nil,
		on_connection = nil
}

local do_callbacks =
	function ()
		if props.on_connection == nil then
			return
		end
		print("do_callbacks")
		if gameservice_available then
			props.on_connection( true )
		elseif gameservice_error_response then
			props.on_connection( false )
		else
			print("gameservice_available == false/nil and gameservice_error_response == false/nil")
            return
		end
		props.on_connection = nil

	end

local on_ready =
	function ( gameservice, app_id )
		gameservice_available = true
        print ("gameservice is available")
		do_callbacks()
	end

local on_error =
	function ( gameservice, response_status )
		print( "failed to connect with gameservice. status_code = "
				.. response_status.status_as_string
				.. ", error_message = '"
				.. response_status.error_message
				.. "'"
				)
		gameservice_error_response = response_status
		do_callbacks()
	end


local app_id = { name = app.id, version = app.version }


local game_name = app.id

local game_id = { app_id = app_id, name = game_name }

print("game name:   '"..game_name.."'")

local game_id_urn = "urn:xmpp:mug:tp:" .. app_id.name .. ":" .. "1" .. ":" .. game_name

local matches = { }

local convert_to_participant_id =
	function ( participant )
		if type( participant ) ~= "table" then
			return ""
		end

		return from.id .. "_" .. from.nick
	end

local on_match_started =
	function ( gameservice, match_id, from )

        print("on_match_started",gameservice, match_id, from)

		if matches[match_id] == nil then
			return
		end

		if matches[match_id].id == from.id then
			if matches[match_id].state ~= nil then
				-- set the state of the match
				--gameservice:update_state( match_id, matches[match_id].state, false )
                print("Send Turn")
                gameservice:send_turn( match_id, matches[match_id].state, false, nil )
            else
                print("NOT SENDING TURN")
			end
			callback = matches[match_id].callback
			matches[match_id].callback = nil
			if callback ~= nil then
				callback( matches[match_id] )
			end
		end

	end

local on_turn_received =
	function ( gameservice, match_id, from, turn_message )

        print("on_turn_received",gameservice, match_id, from, turn_message)
        dumptable(turn_message)


        if all_seshs[match_id] then

            if turn_message.terminate then

                all_seshs[match_id]:abort(turn_message.new_state)

            else

                all_seshs[match_id]:sync_callback(turn_message.new_state)

            end

        end
	end

local on_participant_joined =
	function ( gameservice, match_id, from, item )

        print("on_participant_joined",gameservice, match_id, from, item)
        dumptable(item)
        dumptable(from)

        if  all_seshs[match_id] then
            all_seshs[match_id].opponent_name = from.nick
            all_seshs[match_id]:update_views()
        end
        --[[
 on_participant_joined userdata: 0x20b8668 room4@mug.gameservice.trickplay.com table: 0x2132e70 table: 0x2132ec0
 table: 0x2132ec0
 {
   "jid" = "72b05536-e30d-11e1-9c3d-109add46f936@gameservice.trickplay.com"
   "nick" = ""
   "affiliation" = "none"
   "role" = "p2"
 }

        --]]


	end

local on_participant_left =
	function ( gameservice, match_id, participant )

        print("on_participant_left",gameservice, match_id, participant)
        dumptable(participant)

	end

local on_match_updated =
	function ( gameservice, match_id, match_status, match_state )
        print("on_match_updated",gameservice, match_id, match_status, match_state)


        if  matches[match_id] == nil then

            print("WARNING. Updating a match that was not in the table. Match id: ",match_id)

            if match_status == "completed" or match_status == "aborted" then
                print("Received update for a aborted/completed match that I was not tracking. Ignoring")
                return
            end
            matches[match_id] = {}
            --matches[match_id].id = in_room_id
            --matches[match_id].nick = g_user.name
            matches[match_id].match_id = match_id

        elseif match_status == "aborted" then

            all_seshs[match_id]:abort(match_state.opaque)

            return

        end

        matches[match_id].match_state  = match_state
        matches[match_id].match_status = match_status
        dumptable(matches[match_id])
        if all_seshs[match_id] then all_seshs[match_id]:sync_callback(match_state.opaque) end

	end

gameservice.on_ready              = on_ready
gameservice.on_error              = on_error
gameservice.on_match_started      = on_match_started
gameservice.on_turn_received      = on_turn_received
gameservice.on_participant_joined = on_participant_joined
gameservice.on_participant_left   = on_participant_left
gameservice.on_match_updated      = on_match_updated

function Game_Server:get_screen_name()

    return props.screen_name

end
function Game_Server:set_screen_name(screen_name)

    if type(screen_name) ~= "string" then
        error("Expects string. Received "..type(screen_name),2)
    end

    props.screen_name = screen_name

end
function Game_Server:get_user_id()

    return gameservice.user_id

end
function Game_Server:init(t)
    if type(t) ~= "table" then
        error("Invalid parameter. must pass a table", 2)
    end

    props.screen_name      = t.screen_name      or error("Must pass in a screen_name",2)
    props.on_connection = t.on_connection or error("Must pass in a on_connection", 2)

	do_callbacks()
end

local check_gameservice_is_available =
	function ( )
		if gameservice_available == false then
			error("failed to service this request. connection to gameservice is not available", 2)
		end
	end

function Game_Server:register_game(game_config, on_register_game_completed)
	print("register game called")
	check_gameservice_is_available( )
	gameservice:register_game(
        game_config,
        function ( gameservice, response_status )
        	print("register game completed")
            on_register_game_completed ( true )
        end
    )
end

function Game_Server:launch_wildcard_session(session, callback)

    --[[ TODO
    this function gets called after the user creates the word for a new game

    so, create the match & send_turn, allowing any opponent to join
    --]]


	check_gameservice_is_available( )

	if session == nil then error("must pass session",2) end

	local on_join_match_completed =
		function ( gameservice, response_status, match_id, from, item )
			if ( response_status.status ~= 0 ) then
				--let the client know that we failed to join match that was previously assigned to us
				callback( false )
				return
			end

			if matches[match_id] == nil then
				matches[match_id] = { }
			end

			matches[match_id].id = from.id
			matches[match_id].nick = from.nick
			matches[match_id].match_id = match_id
			matches[match_id].role = item.role

			-- callback( matches[match_id] )
			-- start and play turn too
			gameservice:start_match( match_id )
			matches[match_id].callback = callback
			matches[match_id].state = session.opaque_state
		end

	local on_assign_match_completed =
		function ( gameservice, response_status, match_request, new_match_id )
			if ( response_status.status ~= 0 ) then
				--let the client know that a new match cannot be created
				callback( false )
				return
			end

			gameservice:join_match(
					new_match_id, props.screen_name, "p1", on_join_match_completed
			)
		end

	match_request = {
			game_id = game_id_urn,
			free_role = false,
			role = "p1",
			new_match = true,
			nick = props.screen_name
		}
	gameservice:assign_match( match_request, on_assign_match_completed )

end

function Game_Server:update_game_history(callback)
    --[[
        this function updates the Win Loss Record of the logged in user
    --]]


	check_gameservice_is_available( )

    print("wins = ".. g_user.wins, "losses = "..g_user.losses)
    gameservice:update_user_game_data(
    		game_id, base64_encode(json:stringify{wins = g_user.wins, losses = g_user.losses}), callback
    )

end

function Game_Server:get_game_history(callback)
    --[[
        this function gets the Win Loss Record of the logged in user
    --]]


	check_gameservice_is_available( )

    gameservice:get_user_game_data(
    		game_id,
            function(gameservice, response_status, game_data )

                callback( json:parse( base64_decode(  game_data.opaque  ) ) )

            end
    )

end

function Game_Server:update(session,callback)
    --[[
        this function is used to save game state, does not imply that this users turn is over
    --]]


    check_gameservice_is_available( )
    if session == nil then error("must pass session",2) end

    gameservice:update_state( session.match_id, session.opaque_state, false, callback )

end

function Game_Server:end_session(session,callback)
    --[[
        this function is used to end a match, (if a user loses the match, or times out)
    --]]

    check_gameservice_is_available( )
    if session == nil then error("must pass session",2) end

    gameservice:send_turn( session.match_id, session.opaque_state, true, callback )

end

function Game_Server:leave_match(session,callback)
    --[[
        this function is used to end a match, (if a user loses the match, or times out)
    --]]

    check_gameservice_is_available( )
    if session == nil then error("must pass session",2) end

    gameservice:leave_match( session.match_id, callback )

end

function Game_Server:respond(session,callback)
    --[[
        this function is send_turn, it also appears to update the gamestate
    --]]
    print("Game_Server:respond()")

    check_gameservice_is_available( )
    if session == nil then error("must pass session",2) end

    gameservice:send_turn( session.match_id, session.opaque_state, false, callback )

end

function Game_Server:get_session_state(match_id,callback)
    --[[
        gets the current state of a particular match
    --]]


    check_gameservice_is_available( )
    if match_id == nil then error("must pass id",2) end

    callback( matches[match_id] )
end

function Game_Server:get_a_wild_card_invite(callback)
    --[[
        call gameservice:assign_match with new_match = 'false'
    --]]


    check_gameservice_is_available( )


    local on_assign_match_completed =
		function ( gameservice, response_status, match_request, new_match_id )
			if ( response_status.status ~= 0 ) then
				--let the client know that a new match cannot be created
				callback( nil )
				return
			end

			callback( new_match_id )
		end
				--callback( matches[match_id] )

	match_request = {
			game_id = game_id_urn,
			role = "p2",
			new_match = false,
			nick = props.screen_name
		}
	gameservice:assign_match( match_request, on_assign_match_completed )

end
function Game_Server:accept_invite(invite_id, callback)
    --[[
        call gameservice:join_match ()
    --]]

    check_gameservice_is_available( )

    if invite_id == nil then error("must pass invite_id",2) end

	local on_join_match_completed =
		function ( gameservice, response_status, match_id, from, item )

			if ( response_status.status ~= 0 ) then
				--let the client know that we failed to join match that was previously assigned to us
				--callback( ??? )
				return
			end

			if matches[match_id] == nil then
				matches[match_id] = { }
			end

			matches[match_id].id = from.id
			matches[match_id].nick = from.nick
			matches[match_id].match_id = match_id
			matches[match_id].role = item.role


			callback( matches[match_id] )
		end

	gameservice:join_match(
			invite_id, props.screen_name, "p2", on_join_match_completed
			)

end

function Game_Server:get_match(id) return matches[id] end


function Game_Server:get_list_of_sessions(callback)
    --[[
        this function is used to get the list of matches that the player is currently involved in
    --]]


    check_gameservice_is_available( )
    local on_get_match_data_completed =
    	function ( gameservice, response_status, match_data )
    		print("received match data")
    		if match_data ~= nil and match_data.match_infos ~= nil then
    			print("match info is present")
				dumptable(match_data)
    			-- load the matches table with list of returned matches
    			for index, match in ipairs( match_data.match_infos ) do
                    if not( (match.match_status == "completed" or match.match_state.terminate) and matches[match.match_id] == nil) then
                        print("match",index,match)
                        if  matches[match.match_id] == nil then
                            matches[match.match_id] = { }
                            matches[match.match_id].id = match.in_room_id
                            matches[match.match_id].nick = match.nickname
                            matches[match.match_id].match_id = match.match_id
                        end

                        matches[match.match_id].match_state  = match.match_state
                        matches[match.match_id].match_status = match.match_status
                    else

                        Game_Server:leave_match(

                            { match_id = match.match_id },

                            function() print("left match") end

                        )
        			end
        		end
    		end
    		callback( matches )
    			dumptable(matches)
    		print("done parsing match data")
    	end

    gameservice:get_match_data( game_id, on_get_match_data_completed )

end

return Game_Server
