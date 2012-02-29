
--Clone sources for the player ball
local srcs = {}

for i = 1 , # COLORS do
    local color = COLORS[i]
    local t =
    {
        bulb    = Image{ src = string.format( "assets/bulbs/bulb-%s.png" ,         color ) },
        overlay = Image{ src = string.format( "assets/bulbs/bulb-%s-overlay.png" , color ) },
    }
    srcs[ color ] = t
    for k , v in pairs( t ) do
        clone_sources_layer:add( v )
    end
end

local player_balls = {}










local player_ball_physics_props =
    {
        shape           = physics:Circle( ( srcs[ COLORS[1] ].bulb.w / 2 ) - BULB_PAD ),
        friction        = BULB_FRICTION,
        density         = BULB_DENSITY,
        bounce          = BULB_BOUNCE,
        linear_damping  = BULB_LINEAR_DAMPING,
        angular_damping = BULB_ANGULAR_DAMPING
    }


local function make_player_ball( color )
    
    --visual pieces of the player balls
    local bulb = Clone{ source = srcs[ color ].bulb }
    local overlay = Clone{ source = srcs[ color ].overlay }
    
    local result = Group
    {
        name     = string.format( "%s-bulb" , color ),
        size     = bulb.size,
        children = { bulb , overlay },
        extra    = { color = color },
        opacity  = 0
    }
    
    
    -- continuous animation of the player ball
    do
        local oa = 0
        local za = { 0 , bulb.w / 2 , bulb.h / 2 }
        
        function result.extra.step( seconds )
            
            oa = (oa + BULB_OVERLAY_ROTATION_SPEED * seconds) % 360
            
            za[ 1 ] = oa
            
            overlay.z_rotation = za
            
        end
        
    end
    
    --physics stuff
    
    bulb = physics:Body( result , player_ball_physics_props )
    
    bulb.key_press_force = BULB_FORCE
    
    PLAYER_HANDLES[bulb.handle] = bulb
    
    function bulb:on_pre_solve_contact( contact )
        
        -- If we collied with a sphere and it has the same color as we do
        -- we disable the contact, so the sphere will pass right through us
        local sphere = SCORE_ITEM_HANDLES[ contact.other_body[ self.handle ] ]
        
        if sphere and sphere.extra.color == color then
            
            contact.enabled = false
            
        end
        
    end
    
    function bulb:on_begin_contact( contact )
        
        -- If we collide with a sphere that has no color, it becomes
        -- ours
        local sphere = SCORE_ITEM_HANDLES[ contact.other_body[ self.handle ] ]
        
        if sphere then
            
            local other_color = sphere.extra.color
            
            if other_color == nil then
                
                sphere:switch( color )
                
                PLAYER_SCORE[color]:add_score( 5 )
                
            end
            
        end
        
    end
    
    
    ----------------------------------------------------------------------------
    -- Public Methods used by the powerups that shrink & enlargen the player
    local return_to_normal_size = Timer{
        
        interval = 10000,
        
        on_timer = function(self)
            print("return")
            bulb:remove_fixture(bulb.fixtures[1].handle)
            
            bulb:add_fixture(player_ball_physics_props)
            
            bulb.scale = 1
            
            self:stop()
        end
    }
    
    return_to_normal_size:stop()
    
    function bulb:shrink()
        
        bulb:remove_fixture(bulb.fixtures[1].handle)
        
        bulb:add_fixture{
            shape           = physics:Circle( ( srcs[ COLORS[1] ].bulb.w *.75 / 2 ) - BULB_PAD ),
            friction        = BULB_FRICTION,
            density         = BULB_DENSITY,
            bounce          = BULB_BOUNCE,
        }
        
        bulb.scale = .75
        return_to_normal_size:stop()
        return_to_normal_size:start()
    end
    
    function bulb:enlarge()
        
        bulb:remove_fixture(bulb.fixtures[1].handle)
        
        bulb:add_fixture{
            shape           = physics:Circle( ( srcs[ COLORS[1] ].bulb.w *1.5 / 2 ) - BULB_PAD ),
            friction        = BULB_FRICTION,
            density         = BULB_DENSITY,
            bounce          = BULB_BOUNCE,
        }
        
        bulb.scale = 1.5
        
        return_to_normal_size:stop()
        return_to_normal_size:start()
    end
    
    
    
    ----------------------------------------------------------------------------
    -- Public Methods used by the powerups that speed up & slow down the player
    local return_to_normal_linear_damping = Timer{
        interval = 10000,
        on_timer = function(self)
            print("normal")
            bulb.key_press_force = BULB_FORCE
            
            self:stop()
        end,
    }
    
    return_to_normal_linear_damping:stop()
    
    function bulb:slow()
        print("slow")
        bulb.key_press_force = BULB_FORCE / 8
        
        return_to_normal_linear_damping:stop()
        return_to_normal_linear_damping:start()
    end
    function bulb:fast()
        
        bulb.key_press_force = BULB_FORCE * 8
        
        return_to_normal_linear_damping:stop()
        return_to_normal_linear_damping:start()
    end
    
    ----------------------------------------------------------------------------
    -- Public Methods for fading the player ball in and out
    
    local step_function
    
    function bulb:fade_out_to(x,y, callback)
        
        local xi = Interval( self.x , x )
        local yi = Interval( self.y , y )
        
        self.active = false
        
        add_step_func(
            
            RING_ANIMATE_IN_DURATION ,
            
            function( p )
                self.x = xi:get_value( p )
                self.y = yi:get_value( p )
                self.opacity = 255*(1-p)
            end ,
            
            callback
            
        )
        
        if step_function then step_functions[step_function] = nil end
        
    end
    
    function bulb:fade_in()
        
        bulb.position = SPAWN_LOCATION[ color ]
        
        
        self.active = true
        
        add_step_func(
            
            RING_ANIMATE_IN_DURATION ,
            
            function ( p )
                
                bulb.opacity = 255*p
                
            end
        )
        
        step_function = add_step_func( nil , bulb.extra.step )
        
        
    end
    
    
    
    return bulb
end


for _,color in ipairs(COLORS) do
    
    player_balls[color] = make_player_ball( color )
    
end

function shrink()
    
    local b = player_balls[RED]
    
    b:remove_fixture(b.fixtures[1].handle)
    
    b:add_fixture{
        shape           = physics:Circle( ( srcs[ COLORS[1] ].bulb.w *.75 / 2 ) - BULB_PAD ),
        friction        = BULB_FRICTION,
        density         = BULB_DENSITY,
        bounce          = BULB_BOUNCE,
        linear_damping  = BULB_LINEAR_DAMPING,
        angular_damping = BULB_ANGULAR_DAMPING
    }
    
    b.scale = .75
    
end



return player_balls
