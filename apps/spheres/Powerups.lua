
local srcs = {}
local num_power_ups = 0
local powerups = {}
--------------------------------------------------------------------------------
srcs.shrink = Image{src = "assets/power_ups/shrink.png" }
clone_sources_layer:add( srcs.shrink )


make_shrink = function(x,y)
    
    local instance = Clone{  source = srcs.shrink, x = x, y = y }
    
    local activated = false
    
    instance = physics:Body( instance , { type = "static" } )
    
    function instance:on_pre_solve_contact( contact )
        
        contact.enabled = false
        
        if activated then return end
        
        -- If we collied with a sphere and it has the same color as we do
        -- we disable the contact, so the sphere will pass right through us
        local player = PLAYER_HANDLES[ contact.other_body[ self.handle ] ]
        
        if player then
            
            activated = true
            
            
            
            dolater(function()
                
                player:shrink()
                
                instance:unparent()
                
                instance = nil
                
            end)
            
            num_power_ups = num_power_ups - 1
            
        end
        
    end
    
    
    objects_layer:add(instance)
    
    powerups[instance] = true
    
    num_power_ups = num_power_ups + 1
    
end
--------------------------------------------------------------------------------
srcs.enlarge = Image{src = "assets/power_ups/grow.png" }
clone_sources_layer:add( srcs.enlarge )

make_enlarge = function(x,y)
    
    local instance = Clone{  source = srcs.enlarge, x = x, y = y }
    
    local activated = false
    
    instance = physics:Body( instance , { type = "static" } )
    
    function instance:on_pre_solve_contact( contact )
        
        contact.enabled = false
        
        if activated then return end
        
        -- If we collied with a sphere and it has the same color as we do
        -- we disable the contact, so the sphere will pass right through us
        local player = PLAYER_HANDLES[ contact.other_body[ self.handle ] ]
        
        if player then
            
            activated = true
            
            
            
            dolater(function()
                
                player:enlarge()
                
                instance:unparent()
                
                instance = nil
                
            end)
            
            num_power_ups = num_power_ups - 1
            
            
        end
        
    end
    
    
    objects_layer:add(instance)
    
    powerups[instance] = true
    
    num_power_ups = num_power_ups + 1
    
end
--------------------------------------------------------------------------------
srcs.slow = Image{src = "assets/power_ups/slow_down.png" }
clone_sources_layer:add( srcs.slow )

make_slow = function(x,y)
    
    local instance = Clone{  source = srcs.slow, x = x, y = y }
    
    local activated = false
    
    instance = physics:Body( instance , { type = "static" } )
    
    function instance:on_pre_solve_contact( contact )
        
        contact.enabled = false
        
        if activated then return end
        
        -- If we collied with a sphere and it has the same color as we do
        -- we disable the contact, so the sphere will pass right through us
        local player = PLAYER_HANDLES[ contact.other_body[ self.handle ] ]
        
        if player then
            
            activated = true
            
            
            
            dolater(function()
                
                player:slow()
                
                instance:unparent()
                
                instance = nil
                
            end)
            
            num_power_ups = num_power_ups - 1
            
            
        end
        
    end
    
    
    objects_layer:add(instance)
    
    powerups[instance] = true
    
    num_power_ups = num_power_ups + 1
    
end
--------------------------------------------------------------------------------
srcs.fast = Image{src = "assets/power_ups/speed_up.png" }
clone_sources_layer:add( srcs.fast )

make_fast = function(x,y)
    
    local instance = Clone{  source = srcs.fast, x = x, y = y }
    
    local activated = false
    
    instance = physics:Body( instance , { type = "static" } )
    
    function instance:on_pre_solve_contact( contact )
        
        contact.enabled = false
        
        if activated then return end
        
        -- If we collied with a sphere and it has the same color as we do
        -- we disable the contact, so the sphere will pass right through us
        local player = PLAYER_HANDLES[ contact.other_body[ self.handle ] ]
        
        if player then
            
            activated = true
            
            
            
            dolater(function()
                
                player:fast()
                
                instance:unparent()
                
                instance = nil
                
            end)
            
            num_power_ups = num_power_ups - 1
            
            
        end
        
    end
    
    
    objects_layer:add(instance)
    
    powerups[instance] = true
    
    num_power_ups = num_power_ups + 1
    
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

local effects = {
    make_shrink,
    make_enlarge,
    make_slow,
    make_fast,
}

Timer{
    interval = 15000,
    on_timer = function()
        
        if num_power_ups > 1 or STATE:current_state() ~= "GAME" then return end
        
        effects[math.random(1,#effects)](
            math.random(100,screen_w - 100),
            math.random(100,screen_h - 100)
        )
        
    end
}

--------------------------------------------------------------------------------

STATE:add_state_change_function(nil,"ROUND_OVER",
    
    function()
        
        for p_up,_ in pairs( powerups ) do
            
            add_step_func(
                
                200 ,
                
                function( p )    p_up.opacity = 255*(1-p)   end ,
                
                function(   )
                    
                    p_up:unparent()
                    
                    powerups[p_up] = nil
                    
                end
                
            )
            
        end
        
        num_power_ups = 0
        
    end
)


