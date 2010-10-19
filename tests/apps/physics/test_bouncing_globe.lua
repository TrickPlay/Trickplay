
local globe_image = Image
{
    src = "images/globe.png",
    position = { 100 , 0 },
    scale = { 0.5 , 0.5 },
}

globe = physics:Body( globe_image , 
{
    -- Instead of taking the default rectangular-shaped fixture, we
    -- add our own shape
    
    shape = physics:Circle( globe_image.w / 2 * globe_image.scale[ 1 ] ),
    
    density = 1.0,
    bounce = 0.8,
    friction = 0.1
}
)

-- Start it out spinning

globe.angular_velocity = -1000

-------------------------------------------------------------------------------
           
local ground = physics:Body( 
    Rectangle
    {
        color = "00FF0066" ,
        size = { screen.w , 100 } ,
        position = { screen.w / 2 , screen.h - 150 } ,
        anchor_point = { screen.w / 2 , 50 },
        z_rotation = { 10 , 0 , 0  }
    },    
    {
        friction = 0.9,
        type = "static"
    })


screen:add( globe , ground )

-------------------------------------------------------------------------------
-- Add invisible bumpers on the left and right of the screen
-- Note that these do not have actors attached to them.

local left_bumper = physics:Body(
    Group
    {
        size = { 2 , screen.h },
        position = { -2 , 0 }
    },
    {
        type = "static" ,
    })
        
local right_bumper = physics:Body( 
    Group
    {
        size = { 2 , screen.h },
        position = { screen.w , 0 }
    },
    {
        type = "static",
    })

screen:add( right_bumper , left_bumper )

-------------------------------------------------------------------------------

local collision = Rectangle{ color = "FF0000" , size = { 10 , 10 } , anchor_point = { 5 , 5 } }

screen:add( collision )

collision:hide()

-------------------------------------------------------------------------------

screen:show()

if false then

    local ret = keys.Return
    
    function screen.on_key_down( screen , key )
        if key == ret then
            physics:step()
            physics:draw_debug()
        end
    end

else

    function screen.on_key_down( screen , key )
        if key == keys.space then
            if physics.running then
                physics:stop()
            else
                physics:start()
            end
        end
    end
    
    function globe:on_begin_contact( contact )
        dumptable( contact )
        collision.position = contact.point
        collision:show()
        --dumptable( globe.linear_velocity )
    end

    physics:start()
    
end
