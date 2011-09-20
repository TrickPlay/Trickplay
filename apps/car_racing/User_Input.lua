--TV REMOTE DEFAULT CONTROLLER

assert(STATES         ~= nil,  "The STATES table no longer exists, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.LOADING ~= nil,"LOADING is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.SPLASH  ~= nil, "SPLASH is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.PLAYING ~= nil,"PLAYING is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.PAUSED  ~= nil, "PAUSED is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.CRASH   ~= nil,  "CRASH is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")

--add key handler tables to the corresponding State
Game_State.states[STATES.LOADING].keys = {}
Game_State.states[STATES.SPLASH ].keys = {
    [keys.OK] = function()
		splash:press()
	end,
}
Game_State.states[STATES.PAUSED ].keys = {
    [keys.RED] = function()
		Game_State:change_state_to(STATES.PLAYING)
	end,
}
Game_State.states[STATES.CRASH  ].keys = {}
Game_State.states[STATES.PLAYING].keys = {
    
    --Brake
	[keys.Down] = function()
		io.throttle_position = -10
	end,
	
    --Turn Left
	[keys.Left] = function()
		io.turn_impulse = io.turn_impulse - .4
		if io.turn_impulse < -1 then io.turn_impulse = -1 end
	end,
	
    --Turn Right
	[keys.Right] = function()
		io.turn_impulse = io.turn_impulse + .4
		if io.turn_impulse > 1 then io.turn_impulse = 1 end
	end,
	
    --Pause
	[keys.RED] = function()
		
		Game_State:change_state_to(STATES.PAUSED)
	end,
    
	--[[ Spawns an oncoming car, used for debugging
	[keys.a] = function()
		table.insert(other_selfs,make_self(road.newest_segment,end_point,-100,true))
		world.selfs:add(other_selfs[#other_selfs])
		ccc = other_selfs[#other_selfs]
		other_selfs[#other_selfs]:lower_to_bottom()
	end
    --]]
}


--make sure all states
for state_name,state_value in pairs(STATES) do
    assert(
        
        Game_State.states[state_value].keys ~= nil,
        
        "State "..state_name.." was not given a key table, update \"User_Input.lua\""
    )
end

--socket to key_handler
do 
    local keys
    
    Game_State:add_state_change_function(function(old_state,new_state)
        keys = Game_State.states[new_state].keys
    end)
    
    function screen:on_key_down(k)
        if keys[k] then keys[k]() end
    end
end







--SMART PHONE/TABLET CONTROLLERS




--flat is 0,0

--tilting the top downward -> 0,1
    -- contineuing to face down is -> 0,0
        --contineuing to bottom down is -> 0,-1
--tilting the bottom downward -> 0,-1
    -- contineuing to face down is -> 0,0
        --contineuing to bottom down is -> 0,-1
        
--right down is 1,0
--left down is -1,0

function controllers.on_controller_connected( controllers , controller )
    
    if controller.ui_size[1] == 435 then
        controller:declare_resource("splash","iphone_assets/ipod-start.png")
        controller:declare_resource("bg",    "iphone_assets/ipod.png")
		
        print("Connected IPOD")
    elseif controller.ui_size[1] == 640 then
        controller:declare_resource("splash","iphone_assets/iphone-start.png")
        controller:declare_resource("bg",    "iphone_assets/iphone.png")
		
        print("Connected IPHONE")
    else
        controller:declare_resource("splash","iphone_assets/ipad-start.png")
        controller:declare_resource("bg",    "iphone_assets/ipad.png")
        
        print("Connected IPAD")
    end
	
	if Game_State.current_state() == STATES.LOADING or
		Game_State.current_state() == STATES.SPLASH then
		
		controller:set_ui_background("splash","STRETCH")
		
		Game_State:add_state_change_function(
			function(old_state,new_state)
				controller:set_ui_background("bg","STRETCH")
			end,
			STATES.SPLASH,
			STATES.PLAYING
		)
	else
		controller:set_ui_background("bg","STRETCH")
	end
    
    
    if controller.has_accelerometer then
        
        Game_State.states[STATES.PLAYING].on_accelerometer = function( controller , x , y , z )
			io.turn_impulse = -y
        end
        
        Game_State:add_state_change_function(
            function(old_state,new_state)
                if Game_State.states[new_state].on_accelerometer then
                    controller.on_accelerometer = Game_State.states[new_state].on_accelerometer
                else
                    controller.on_accelerometer = nil
                end
            end
        )
        
        
        controller:start_accelerometer( "L" , 20/1000 )
    end
    
    if controller.has_touches then
        
        Game_State.states[STATES.PLAYING].on_touch_down = function( controller, finger, x, y )
            
			if x > controller.ui_size[1]*2/3 then
			else
				io.throttle_position = -10
			end
        end
        Game_State.states[STATES.PLAYING].on_touch_move = function( controller, finger, x, y )
            io.throttle_position = -10
        end
        Game_State:add_state_change_function(
            function(old_state,new_state)
                if Game_State.states[new_state].on_touch_down then
                    controller.on_touch_down = Game_State.states[new_state].on_touch_down
                else
                    controller.on_touch_down = nil
                end
                
                if Game_State.states[new_state].on_touch_down then
                    controller.on_touch_move = Game_State.states[new_state].on_touch_move
                else
                    controller.on_touch_move =  nil
                end
            end
        )
        
        
        controller:start_touches()
    end

end

for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end

