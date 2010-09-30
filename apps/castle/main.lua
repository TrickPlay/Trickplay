
-------------------------------------------------------------------------------
-- Ground

local ground = Rectangle
{
    color = "006600" ,
    size = { screen.w , 100 } ,
    position = { 0 , screen.h - 100 }
}

screen:add( ground )

physics:Body{ source = ground , friction = 0.5 }

-------------------------------------------------------------------------------
-- Edges



local left_edge = Group{ size = { 2 , screen.h } , position = { -2 , 0 } }
screen:add( left_edge )
physics:Body{ source = left_edge }

local right_edge = Group{ size = { 2 , screen.h } , position = { screen.w , 0 } }
screen:add( right_edge )
physics:Body{ source = right_edge }

-- Top edge is inactive at first so we can drop stuff from above it

local top_edge = Group{ size = { screen.w , 2 } , position = { 0 , -2 } }
screen:add( top_edge )
top_edge = physics:Body{ source = top_edge , active = false}

-------------------------------------------------------------------------------
-- Castle

local function build_castle()

    local wood = Image{ src = "wood.jpg" , opacity = 0 }
    
    screen:add( wood )

    local function make_plank( rotation )
        return Clone
        {
            source = wood,
            opacity = 255,
            anchor_point = wood.center,
            z_rotation = { rotation or 0 , 0 , 0 }
        }
    end
    
    local LEFT = 1650
    
    local floor = ground.y - ground.h / 2

    local plank
    
    local DENSITY  = 1.0
    local FRICTION = 1.5
    local BOUNCE   = 0.0
    
    plank = make_plank()
    plank:set{ position = { LEFT , floor - wood.h / 2  } }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE }
        
    plank = make_plank()
    plank:set{ position = { LEFT + 200 , floor - wood.h / 2  } }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE }
    
    plank = make_plank( 90 )
    plank:set{ position = { LEFT + 100 , floor - wood.h - wood.w / 2 } }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE }

    plank = make_plank( 30 )
    plank.position = { LEFT + 20 , floor - wood.h * 1.5 - wood.w / 2 - 10 }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }
    
    plank = make_plank( -30 )
    plank.position = { LEFT + 180 , floor - wood.h * 1.5 - wood.w / 2 - 10 }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }


    plank = make_plank( 90 )
    plank.position = { LEFT + 100 , floor - wood.h * 2.1 }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }

    
    plank = make_plank()
    plank:set{ position = { LEFT  , floor - wood.h * 2.65  } }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }
    
    
    plank = make_plank()
    plank:set{ position = { LEFT + 200 , floor - wood.h * 2.65  } }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }


    plank = make_plank( 90 )
    plank.position = { LEFT + 100 , floor - wood.h * 3.2 }
    screen:add( plank )
    physics:Body{ source = plank , dynamic = true , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }

end

-------------------------------------------------------------------------------

build_castle()

-------------------------------------------------------------------------------

local function drop_crate()

    local crate = Rectangle
    {
        size = { 100 , 100 },
        position = { 100 , -100 },
        color = "FF0000"
    }
    
    screen:add( crate )
    
    local crate_body = physics:Body
    {
        source = crate,
        bounce = 0.2,
        density = 3.0,
        dynamic = true
    }
    
    return crate_body
    
end

-------------------------------------------------------------------------------

screen:show()

-------------------------------------------------------------------------------

local crate = drop_crate()

-------------------------------------------------------------------------------

local sw = Stopwatch()
local spf = 1 / 60
local n
local ret = keys.Return

function screen.on_key_down( screen , key )

    if key == ret then
    
        screen.on_key_down = nil

        function idle.on_idle( )
            
            if sw.elapsed_seconds < spf then return end
            
            physics:step()    
            sw:start()
            
            -- Once the crate has settled down, we can start
            
            if not crate.awake then
            
                crate.source.color = "FFFFFF"
                
                idle.on_idle = nil
                
                -- Close the top edge so stuff doesn't fly off the screen
                
                top_edge.active = true
                
                -- Attach key handler
                
                function screen.on_key_down( screen , key )
                
                    if key == ret then
                    
                        local old_key_down = screen.on_key_down
                    
                        screen.on_key_down = nil
                        
                        crate.source.color = "FF0000"
                    
                        -- Give the crate a push
                        
                        local p = crate.position
                                        
                        crate:apply_linear_impulse( 300 , 400 , p[1] , p[2] )
                        
                        crate:apply_torque( 9000 )
                        
                        -- Now, spin until the crate settles down again
                        
                        function idle.on_idle()
                        
                            if sw.elapsed_seconds < spf then return end
                            physics:step()
                            sw:start()
                        
                            -- When the crate is done, we change its color, and re-attach
                            -- the key handler, so you can give it another push
                            
                            if not crate.awake then
                                crate.source.color = "FFFFFF"
                                screen.on_key_down = old_key_down
                            end
                            
                        end
                    
                    end
                    
                end
                
            end
        end
    end
end