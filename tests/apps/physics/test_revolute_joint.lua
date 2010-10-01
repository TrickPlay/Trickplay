

-------------------------------------------------------------------------------
-- Top bar

local top = Rectangle
{
    size = { screen.w / 2 , 50 } ,
    color = "FFFFFF" ,
    position = { screen.w / 4 , screen.h / 3 - 50 }
}

screen:add( top )

local top_body = physics:Body{ source = top }

-------------------------------------------------------------------------------
-- Ropes

local ROPE_COUNT = 7
local ROPE_WIDTH = 8

local crates = {}

local W = top.w / ROPE_COUNT
local CW = W * 0.9

for i = 1 , ROPE_COUNT do

    local rope = Rectangle
    {
        size = { ROPE_WIDTH , screen.h / 3 },
        color = "0000FF",
        x = top.x - top.w / 2 + ( W * ( i - 1 ) ) + ( W / 2 ),
        y = top.y ,
    }
    
    
    local crate = Rectangle
    {
        size = { CW , CW },
        color = "00FF00",
        x = rope.x + ( rope.w / 2 ) - ( CW / 2 ),
        y = rope.y + rope.h - ( CW / 2 )
    }
    
    
    screen:add( crate , rope )
    
    -- Create the bodies

    local rope_body = physics:Body{ source = rope , dynamic = true , friction = 0 , density = 0.1 , awake = false }

    local crate_body = physics:Body{ source = crate , dynamic = true , friction = 0.1 , density = 0.8 , bounce = 0.9 , awake = false }
    
    crate_body.fixed_rotation = true
    
    -- Join the rope to the top
    
    physics:RevoluteJoint( top_body , rope_body , { rope.x , rope.y - rope.h / 2 } ,
        {
            enable_limit = true ,
            lower_angle = -90,
            upper_angle = 90,
            enable_motor = false
        } )
    
    -- Joing the rope to the crate
    
    physics:RevoluteJoint( rope_body , crate_body , { rope.x , rope.y + rope.h  / 2 } )
    
    -- Now, create a distance join between the crate and the top
    
    physics:DistanceJoint( top_body , { rope.x , rope.y - rope.h / 2 } , crate_body , { rope.x , rope.y + rope.h  / 2 } ) 
    
    -- Store the crate body
    
    table.insert( crates , crate_body )
    
end

screen:show()


local s = Stopwatch()
local f = 1 / 60;

function idle.on_idle()
    if s.elapsed_seconds >= f then
        physics:step()
        s:start()
    end    
end

function screen.on_key_down( screen , key )

    if key == keys.Return then
    
        local crate = crates[ 1 ]

        local x , y = unpack( crate.position )
        
        crate:apply_linear_impulse( -50 , 0 , x , y )
        
    end

end