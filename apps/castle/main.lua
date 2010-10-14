
-------------------------------------------------------------------------------
-- Ground

local ground = Rectangle
{
    color = "006600" ,
    size = { screen.w , 100 } ,
    position = { 0 , screen.h - 100 }
    
}

screen:add( ground )

physics:Body{ source = ground , friction = 0.5 , type = "static" }

-------------------------------------------------------------------------------
-- Edges



local left_edge = Group{ size = { 2 , screen.h } , position = { -2 , 0 } }
screen:add( left_edge )
physics:Body{ source = left_edge , type = "static" }

local right_edge = Group{ size = { 2 , screen.h } , position = { screen.w , 0 } }
screen:add( right_edge )
physics:Body{ source = right_edge , type = "static" }

-- Top edge is inactive at first so we can drop stuff from above it

local top_edge_actor = Group{ size = { screen.w , 2 } , position = { 0 , -2 } }
local top_edge = physics:Body{ source = top_edge_actor , type = "static" }

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
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE }
        
    plank = make_plank()
    plank:set{ position = { LEFT + 200 , floor - wood.h / 2  } }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE }
    
    plank = make_plank( 90 )
    plank:set{ position = { LEFT + 100 , floor - wood.h - wood.w / 2 } }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE }

    plank = make_plank( 30 )
    plank.position = { LEFT + 20 , floor - wood.h * 1.5 - wood.w / 2 - 10 }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }
    
    plank = make_plank( -30 )
    plank.position = { LEFT + 180 , floor - wood.h * 1.5 - wood.w / 2 - 10 }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }


    plank = make_plank( 90 )
    plank.position = { LEFT + 100 , floor - wood.h * 2.1 }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }

    
    plank = make_plank()
    plank:set{ position = { LEFT  , floor - wood.h * 2.65  } }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }
    
    
    plank = make_plank()
    plank:set{ position = { LEFT + 200 , floor - wood.h * 2.65  } }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }


    plank = make_plank( 90 )
    plank.position = { LEFT + 100 , floor - wood.h * 3.2 }
    screen:add( plank )
    physics:Body{ source = plank , density = DENSITY , friction = FRICTION , bounce = BOUNCE , awake = false }

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
        awake = true
    }
    
    return crate_body
    
end

-------------------------------------------------------------------------------

screen:show()

-------------------------------------------------------------------------------

local crate = drop_crate()

-------------------------------------------------------------------------------

local n
local ret = keys.Return

idle.limit = 1.0 / 60.0

function screen.on_key_down( screen , key )

    if key == ret then
    
        screen.on_key_down = nil

        function idle.on_idle( )
            
            physics:step()    
            
            -- Once the crate has settled down, we can start

            if not crate.awake then
            
                crate.source.color = "FFFFFF"
                
                idle.on_idle = nil
                
                -- Close the top edge so stuff doesn't fly off the screen
                
                screen:add( top_edge_actor )
                
                -- Attach key handler
                
                function screen.on_key_down( screen , key )
                
                    if key == ret then
                    
                        local old_key_down = screen.on_key_down
                    
                        screen.on_key_down = nil
                        
                        crate.source.color = "FF0000"
                    
                        -- Give the crate a push
                        
                        local p = crate.position
                                        
                        crate:apply_linear_impulse( { 300 , 400 } , p )
                        
                        crate:apply_torque( 9000 )
                        
                        -- Now, spin until the crate settles down again
                        
                        function idle.on_idle()
                        
                            physics:step()
                        
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