NOTIFICATION_TYPE_PLAY = "play"
NOTIFICATION_TYPE_MATCH_COMPLETED = "match_completed"
NOTIFICATION_TYPE_LEFT_MATCH = "left_match"

PlayNotification = { }

PlayNotification.new = 
	function ( match_id, role, state )
		return { type = NOTIFICATION_TYPE_PLAY, match_id = match_id, role = role, state = state }		
	end
	
MatchCompletedNotification = { }

MatchCompletedNotification.new =
	function ( match_id )
		return { type = NOTIFICATION_TYPE_MATCH_COMPLETED, match_id = match_id }		
	end
	

LeftMatchNotification = { }

LeftMatchNotification.new = 
	function ( match_id, participant )
		return { type = NOTIFICATION_TYPE_LEFT_MATCH, match_id = match_id, participant = participant }		
	end
	
notification_queue = Queue.new( )

gameservice.on_participant_left =
	function ( gameservice, match_id, participant ) 
		Queue.push( notification_queue, LeftMatchNotification.new( match_id, participant.nick ) )
	end

gameservice.on_match_updated = 
	function ( gameservice, match_id, match_status, match_state ) 
		if match_status == "active" then
			Queue.push( 
					notification_queue,
					PlayNotification.new( match_id, match_state.next, match_state.opaque )
					)
		elseif match_state.terminate == true then
			Queue.push( notification_queue, MatchCompletedNotification.new( match_id ) )
		end
	end

gameservice.on_turn_received =
		function ( gameservice, match_id, from, turn_message )
			if turn_message.terminate == false then
				Queue.push( notification_queue, PlayNotification.new( match_id, turn_message.next_turn, turn_message.new_state ) )
			else
				Queue.push( notification_queue, MatchCompletedNotification.new( match_id ) )
			end
		end

	