
local margin = 100

local function random_placement()
    
    return {
        
        x = math.random( margin , screen_w - margin ),
        y = math.random( margin , screen_h - margin ),
        
        linear_velocity = {
            
            math.random( SPHERE_START_VELOCITY_MIN , SPHERE_START_VELOCITY_MAX ) ,
            math.random( SPHERE_START_VELOCITY_MIN , SPHERE_START_VELOCITY_MAX )
            
        }
    }
    
end

STATE:add_state_change_function(nil,"GAME",
    
    function()
        
        for i, ball in ipairs(  formations[math.random(1,#formations)]  ) do
            
            local sphere = make_sphere()
            
            
            sphere:set{
                x = ball.x,  
                y = ball.y,  
                linear_velocity = {
                    ball.vx, 
                    ball.vy  
                }
            }
            
            
            objects_layer:add( sphere )
            
        end
        
        --PLAYER_BALL_CLASS.launch_balls()
        
    end
)


STATE:add_state_change_function(nil,"ROUND_OVER",
    
    function()
        
        --dolater(1000,PLAYER_BALL_CLASS.return_players_to_corners)
        
        dolater(2000,function() STATE:change_state_to("COUNTDOWN") end)
        
    end
)





