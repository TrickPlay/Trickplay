
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

for state,func in pairs(add_key_events) do
    
    STATE:add_state_change_function(nil,state,
        
        function()
            
            for c,player_ball in pairs(active_controllers) do
                
                func(c,player_ball)
                
            end
            
        end
    )
    
end


--------------------------------------------------------------------------------
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

for state,func in pairs(add_touch_events) do
    
    STATE:add_state_change_function(nil,state,
        
        function()
            
            for c,player_ball in pairs(active_controllers) do
                
                func(c,player_ball)
                
            end
            
        end
    )
    
end

--------------------------------------------------------------------------------
local setup_controller

setup_controller  = function( c )
    
    if not c.has_keys and not c.has_touches then
        
        print("A Controller without keys or touches has attempted to connect. It is being ignored")
        
        return
        
    end
    
    local player = PLAYER:new_player()
    
    if player then
        
        active_controllers[c] = player.ball
        
        print("Player connected")
        
        if c.has_touches then
            
            c:start_touches()
            
            if add_touch_events[STATE:current_state()] then
                add_touch_events[STATE:current_state()](c,player.ball)
            end
            
        else
            
            if add_key_events[STATE:current_state()] then
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

dolater(
    
    function()
        for i = 1 , # controllers.connected do
            
            setup_controller( controllers.connected[ i ] )
            
        end
        
        
        function controllers:on_controller_connected( c )
            
            setup_controller( c )
            
        end
    end
)





