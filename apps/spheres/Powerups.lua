
-- Clone sources of the effects
local srcs  = {
    shrink  = Image{src = "assets/power_ups/shrink.png" },
    enlarge = Image{src = "assets/power_ups/grow.png" },
    slow    = Image{src = "assets/power_ups/slow_down.png" },
    fast    = Image{src = "assets/power_ups/speed_up.png" },
}

-- I need to be able to use math.random on the list of effects
-- make an indexed table
local effects = {}

for effect,img in pairs(srcs) do
    
    table.insert(effects,effect)
    
    clone_sources_layer:add(img)
    
end

local num_power_ups = 0 -- the number of power ups in the arena
local powerups = {}     -- the table of on-screen power ups

--------------------------------------------------------------------------------
-- Attempts to add a power up every 15 seconds
Timer{
    interval = 15000,
    on_timer = function()
        
        --only 2 power ups on screen at a time
        --doesn't add power ups if the games isn't happening
        if num_power_ups > 1 or STATE:current_state() ~= "GAME" then return end
        
        
        --the chosen power up
        local effect = effects[math.random(1,#effects)]
        
        
        ------------------------------------------------------------------------
        --the actual power up being added
        local instance = Clone{
            source     = srcs[effect],
            x          = math.random(100,screen_w - 100),
            y          = math.random(100,screen_h - 100)
        }
        
        instance = physics:Body( instance , { type = "static" } )
        
        --flag to ignore collisions after the initial collision
        local activated = false
        
        --when a collision happenes
        function instance:on_pre_solve_contact( contact )
            
            --don't bounce off each other
            contact.enabled = false
            
            --if a player already got the power up, ignore
            if activated then return end
            
            --check if the colliding object is a player
            local player = PLAYER_HANDLES[ contact.other_body[ self.handle ] ]
            
            if player then
                
                activated = true
                
                
                -- have to make the effect happen in a do later, messing with
                -- properties of physics bodies while the world is "locked"
                -- (i.e. during a collision callback) causes crashes
                dolater(function()
                    
                    --apply the power up to the player that collected it
                    player[effect](player)
                    
                    --remove the power up
                    instance:unparent()
                    
                    instance = nil
                    
                end)
                
                num_power_ups = num_power_ups - 1
                
            end
            
        end
        
        -- add the power up to the screen
        objects_layer:add(instance)
        
        
        powerups[instance] = true
        
        num_power_ups = num_power_ups + 1
        
    end
}

--------------------------------------------------------------------------------
-- if the round is over, then fade out the power ups
STATE:add_state_change_function(nil,"ROUND_OVER",
    
    function()
        
        --for each on screen power up
        for p_up,_ in pairs( powerups ) do
            
            --fade out
            add_step_func(
                
                200 ,
                
                function( p )    p_up.opacity = 255*(1-p)   end ,
                
                function(   )
                    --and remove
                    p_up:unparent()
                    
                    powerups[p_up] = nil
                    
                end
                
            )
            
        end
        
        num_power_ups = 0
        
    end
)


