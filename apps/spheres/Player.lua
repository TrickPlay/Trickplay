PLAYER = {}

--------------------------------------------------------------------------------
local available_colors = {}

for _,color in ipairs(COLORS) do
    
    available_colors[color] = true
    
end

local function assign_color()
    
    for _,color in ipairs(COLORS) do
        
        if available_colors[color] then
            
            available_colors[ color ] = false
            
            return color
            
        end
        
    end
    
    return false
    
end

local function unassign_color(color)
    
    available_colors[ color ] = true
    
end


--------------------------------------------------------------------------------


function PLAYER:new_player()
    
    local color = assign_color()
    
    if color == false then return false end
    
    local player = {}
    
    player.ball  = PLAYER_BALLS[color]
    player.ring  = PLAYER_RINGS[color]
    player.score = PLAYER_SCORE[color]
    
    
    function player:join_game()
        
        player.ring:animate_in(
            function()
                
                player.ball.has_player = true
                
                player_balls_layer:add(player.ball)
                
                if STATE:current_state() == "GAME" then
                    player.ball:fade_in()
                end
                
                player.score:fade_in()
                
            end
        )
        
        
    end
    
    function player:leave_game()
        
        player.ball:fade_out_to(
            
            RING_START[color][1],
            RING_START[color][1],
            function()
                
                player.ball.has_player = false
                
                player.ball:unparent()
                --TODO turn off player.ball.on_step
                unassign_color(color)
                
            end
        )
            
        player.ring:animate_out()
        player.score:fade_out()
        
    end
    
    return player
end


STATE:add_state_change_function(nil,"COUNTDOWN",
    
    function()
        
        for _,color in ipairs(COLORS) do
            
            if not available_colors[color] then
                
                PLAYER_BALLS[color]:fade_out_to(
                    
                    SPAWN_LOCATION[color][1],
                    
                    SPAWN_LOCATION[color][2],
                    
                    function()
                        
                        PLAYER_BALLS[color].linear_velocity  = {0,0}
                        PLAYER_BALLS[color].angular_velocity = 0
                        
                    end
                    
                )
                
            end
            
        end
        
    end
)

STATE:add_state_change_function(nil,"GAME",
    
    function()
        
        for _,color in ipairs(COLORS) do
            
            if not available_colors[color] then
                
                PLAYER_BALLS[color]:fade_in()
                
            end
            
        end
        
    end
)












