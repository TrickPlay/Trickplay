local srcs = {}
for i = 1 , # COLORS do
    local color = COLORS[i]
    srcs[ color ] = Image{ src = string.format( "assets/spheres/sphere-%s.png" ,     color ) }
    clone_sources_layer:add( srcs[ color ] )
end

srcs[ NEUTRAL ] = Image{ src = "assets/spheres/sphere-neutral.png" }


clone_sources_layer:add( srcs[ NEUTRAL ] )


local neutral_spheres = 0 -- how many are left


local physics_props =
{
    shape = physics:Circle( ( srcs[ NEUTRAL ].w / 2 ) - SPHERE_PAD ),
    friction        = SPHERE_FRICTION,
    density         = SPHERE_DENSITY,
    bounce          = SPHERE_BOUNCE,
    linear_damping  = SPHERE_LINEAR_DAMPING,
    angular_damping = SPHERE_ANGULAR_DAMPING,
}

function make_sphere()
    
    neutral_spheres = neutral_spheres + 1
    
    local sphere = Clone{ source = srcs[ NEUTRAL ] }
    
    local e = sphere.extra
    
    function e:switch( color )
        
        self.source = srcs[ color ]
        
        if color ~= NEUTRAL then
            
            self.extra.color = color
            
            neutral_spheres = neutral_spheres - 1
            
            if neutral_spheres == 0 then
                
                --reset_balls()
                
                --end_level()
                STATE:change_state_to("ROUND_OVER")
                
            end
            
        end
        
    end
    
    sphere = physics:Body( sphere , physics_props )
    
    SCORE_ITEM_HANDLES[ sphere.handle ] = sphere
    
    return sphere
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
        
    end
)

STATE:add_state_change_function(nil,"ROUND_OVER",
    
    function()
        
        for k , sphere in pairs( SCORE_ITEM_HANDLES ) do
            
            add_step_func(
                
                200 ,
                
                function( p )    sphere.opacity = 255*(1-p)   end ,
                
                function(   )
                    
                    sphere:unparent()
                    
                    SCORE_ITEM_HANDLES[sphere] = nil
                    
                end
                
            )
            
        end
        
        G_spheres = {}
        
    end
)


return make_sphere