

-------------------------------------------------------------------------------
-- Top bar

local top = Rectangle
{
    size = { screen.w / 2 , 50 } ,
    color = "FFFFFF" ,
    position = { screen.w / 4 , screen.h / 3 - 50 }
}

screen:add( top )

local top_body = physics:Body( top , { type = "static" } )

-------------------------------------------------------------------------------
-- Ropes

local ROPE_COUNT = 7
local ROPE_WIDTH = 8

local crates = {}

local W = top.w / ROPE_COUNT
local CW = W * 0.9

print( "Top Size, Position:", top.w, ",", top.h, "...", top.x, ",", top.y )

for i = 1 , ROPE_COUNT do

    local rope = Rectangle
    {
        size = { ROPE_WIDTH , screen.h / 3 },
        color = "0000FF",
        x = top.x - top.w / 2 + ( W * ( i - 1 ) ) + ( W / 2 ),
        y = top.y ,
    }

print( "Rope Size, Position:", rope.w, ",", rope.h, "...", rope.x, ",", rope.y )

    local crate = Rectangle
    {
        size = { CW , CW },
        color = "00FF00",
        x = rope.x + ( rope.w / 2 ) - ( CW / 2 ),
        y = rope.y + rope.h - ( CW / 2 )
    }

print( "Crate Size, Position:", crate.w, ",", crate.h, "...", crate.x, ",", crate.y )

    screen:add( crate , rope )

    -- Create the bodies

    local rope_body = physics:Body( rope , { friction = 0 , density = 0.1 , awake = false } )

    local crate_body = physics:Body( crate , { friction = 0.1 , density = 0.8 , bounce = 0.9 , awake = false , fixed_rotation = true } )

    -- Join the rope to the top

    top_body:RevoluteJoint( rope_body ,	{ rope.x , rope.y - rope.h / 2 } ,
        {
            enable_limit = true ,
            lower_angle = -90,
            upper_angle = 90,
            enable_motor = false
        } )

    -- Join the rope to the crate

    rope_body:RevoluteJoint( crate_body , { rope.x , rope.y + rope.h  / 2 } )

    -- Now, create a distance join between the crate and the top

	top_body:DistanceJoint( { rope.x , rope.y - rope.h / 2 } , crate_body , { rope.x , rope.y + rope.h  / 2 } )


    -- Store the crate body

    table.insert( crates , crate_body )

end

screen:show()

physics:start()

function screen.on_key_down( screen , key )

    if key == keys.Return then

        local crate = crates[ 1 ]

        crate:apply_linear_impulse( { -50 , 0 } , crate.position )

    end

end
