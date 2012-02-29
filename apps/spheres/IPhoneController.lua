
--------------------------------------------------------------------------------

--local spectators = {}

local active_controllers = {}

--------------------------------------------------------------------------------

local key_press_mt = {
    
    __index = function()
        
        print("invalid key")
        
        return function() end
        
    end
}

--------------------------------------------------------------------------------
-- The different sets of KEY PRESS events for different states of the app

local add_key_events = {
    
    ["SPLASH"] = function(c,player_ball)
        
        local key_press = {
            [keys.OK]      = function() STATE:change_state_to("GAME") end,
        }
        
        setmetatable(  key_press,   key_press_mt  )
        
        function c:on_key_down(key)    return key_press[key]()   end
        
    end,
    
    ["GAME"] = function(c,player_ball)
        
        
        local key_press = {
            [keys.Up]      = function() player_ball:apply_force( { 0 , - player_ball.key_press_force } , player_ball.position ) end,
            [keys.Down]    = function() player_ball:apply_force( { 0 ,   player_ball.key_press_force } , player_ball.position ) end,
            [keys.Left]    = function() player_ball:apply_force( { - player_ball.key_press_force , 0 } , player_ball.position ) end,
            [keys.Right]   = function() player_ball:apply_force( {   player_ball.key_press_force , 0 } , player_ball.position ) end,
        }
        
        setmetatable(  key_press,   key_press_mt  )
        
        function c:on_key_down(key)    return key_press[key]()   end
        
    end,
}


--------------------------------------------------------------------------------
-- The different sets of TOUCH events for different states of the app

local add_touch_events = {
    
    ["SPLASH"] = function(c,player_ball)
        
        function c:on_touch_up( f , x , y )
            
            STATE:change_state_to("GAME")
            
        end
        
    end,
    
    ["GAME"] = function(c,player_ball)
        
        
        local lx
        local ly
        
        local mx , my = unpack( c.input_size )
        local md = math.min( mx , my )
        
        local FORCE_MULT = 30
        
        function c:on_touch_down( f , x , y )     lx, ly = x, y     end
        
        function c:on_touch_up( f , x , y )
            
            if lx and ly then
                
                player_ball:apply_force(
                    
                    {
                        FORCE_MULT * player_ball.key_press_force * ( x - lx ) / md,
                        FORCE_MULT * player_ball.key_press_force * ( y - ly ) / md
                    } ,
                    
                    player_ball.position
                    
                )
                
                lx = nil
                ly = nil
                
            end
            
        end
        
    end,
}

--------------------------------------------------------------------------------
-- sets up the functions in the state machine to set the controller's event 
-- handlers to the appropriate function for the app's current state


for _,state in ipairs(STATE:states()) do
    
    --KEY EVENTS
    if add_key_events[state] then
        
        --the function from 'add_key_events' that will set up the event handler
        local func = add_key_events[state]
        
        STATE:add_state_change_function(nil,state,
            
            function()
                
                for c,player_ball in pairs(active_controllers) do
                    
                    func(c,player_ball)
                    
                end
                
            end
        )
        
    else
        
        --nil's the event handler if there is no function defined for this state
        STATE:add_state_change_function(nil,state,
            
            function()
                
                for c,player_ball in pairs(active_controllers) do
                    
                    c.on_key_down = nil
                    
                end
                
            end
        )
        
    end
    
    
    --TOUCH EVENTS
    if add_touch_events[state] then
        
        --the function from 'add_touch_events' that will set up the event handlers
        local func = add_touch_events[state]
        
        STATE:add_state_change_function(nil,state,
            
            function()
                
                for c,player_ball in pairs(active_controllers) do
                    
                    func(c,player_ball)
                    
                end
                
            end
        )
        
    else
        
        --nil's the event handler if there is no function defined for this state
        STATE:add_state_change_function(nil,state,
            
            function()
                
                for c,player_ball in pairs(active_controllers) do
                    
                    c.on_touch_down = nil
                    c.on_touch_up   = nil
                    
                end
                
            end
        )
        
    end
    
end

--------------------------------------------------------------------------------
-- The function that sets up controllers that connect to the App

local setup_controller  = function( c )
    
    if not c.has_keys and not c.has_touches then
        
        print("A Controller without keys or touches has attempted to connect. It is being ignored")
        
        return
        
    end
    
    --Attempts to join the game, receives false if all players were taken
    local player = PLAYER:new_player()
    
    if player then
        
        print("PLAYER CONNECTED")
        
        active_controllers[c] = player.ball
        
        if c.has_touches then
            
            c:start_touches()
            
            -- set up the event handler for the current state
            if  add_touch_events[STATE:current_state()] then
                add_touch_events[STATE:current_state()](c,player.ball)
            end
            
        else
            
            -- set up the event handler for the current state
            if  add_key_events[STATE:current_state()] then
                add_key_events[STATE:current_state()](c,player.ball)
            end
            
        end
        
        
        function c:on_disconnected()
            
            print( "PLAYER DISCONNECTED" )
            
            player:leave_game()
            
            active_controllers[c] = nil
            
        end
        
        player:join_game()
        
    else
        
        print("No Available Players")
        --[[
        table.insert(spectators,c)
        
        function c:on_disconnected()
            
            print( "Spectator Left" )
            
            for i,cc in ipairs(spectators) do
                
                if c == cc then
                    
                    table.remove(spectators,i)
                    
                end 
                
            end 
            
        end 
        --]]
    end 
    
end
--------------------------------------------------------------------------------

-- Connect existing controllers
for i = 1 , # controllers.connected do
    
    setup_controller( controllers.connected[ i ] )
    
end

-- call the setup function for every new controller
function controllers:on_controller_connected( c )
    
    setup_controller( c )
    
end
 






