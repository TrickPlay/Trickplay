
local globe_image = Image
{
    src = "images/globe.png",
    position = { 100 , 0 },
    scale = { 0.5 , 0.5 },
}

globe = physics:Body
{
    source = globe_image,
    
    -- Instead of taking the default rectangular-shaped fixture, we
    -- add our own shape
    
    shape = physics:Circle( globe_image.w / 2 * globe_image.scale[ 1 ] ),
    
    dynamic = true,
    density = 1.0,
    bounce = 0.8,
    friction = 0.1
}

-- Start it out spinning

globe.angular_velocity = -1000

-------------------------------------------------------------------------------
           
local ground = physics:Body
{
    source = Rectangle
    {
        color = "00FF0066" ,
        size = { screen.w , 100 } ,
        position = { screen.w / 2 , screen.h - 150 } ,
        anchor_point = { screen.w / 2 , 50 },
        z_rotation = { 10 , 0 , 0  }
    },
    
    friction = 0.9
}


screen:add( globe.source , ground.source )

-------------------------------------------------------------------------------
-- Add invisible bumpers on the left and right of the screen
-- Note that these do not have actors attached to them.

physics:Body{ size = { 2 , screen.h } , position = { -1 , screen.h / 2 } }
physics:Body{ size = { 2 , screen.h } , position = { screen.w + 1 , screen.h / 2 } }

-------------------------------------------------------------------------------

screen:show()

if false then

    local ret = keys.Return
    
    function screen.on_key_down( screen , key )
        if key == ret then
            physics:step()
        end
    end

else

    function idle.on_idle( idle , seconds )
        physics:step( seconds )
    end
    
end
