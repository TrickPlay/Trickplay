
-------------------------------------------------------------------------------

local ground = Rectangle
{
    color = "00FF00",
    size  = { screen.w , 30 },
    position = { 0 , screen.h - 30 }
}

ground = physics:Body
{
    source = ground,
    type = "static",
    density = 1,
    friction = 0.5,
    bounce = 0.1
}

screen:add( ground.source )

-------------------------------------------------------------------------------

local bumper

bumper = physics:Body
{
    source =
    
        Rectangle
        {
            color = "00FF00",
            size = { screen.h * 1.2 , screen.h / 4 },
        },
        
    type = "static"
    
}

bumper.position = { 0 , screen.h / 2 }
bumper.angle = 75

screen:add( bumper.source )


bumper = physics:Body
{
    source =
    
        Rectangle
        {
            color = "00FF00",
            size = { screen.h * 1.2 , screen.h / 4 },
        },
        
    type = "static"
    
}

bumper.position = { screen.w , screen.h / 2 }
bumper.angle = -75

screen:add( bumper.source )

-------------------------------------------------------------------------------

local POLE_HEIGHT = 800

local pole = Rectangle
{
    color = "473232",
    size = { 30 , POLE_HEIGHT },
    position = { screen.w / 2 - 15 , screen.h - ( POLE_HEIGHT + ground.source.h ) }
}

screen:add( pole )

pole = physics:Body
{
    source = pole,
    density = 1,
    type = "static",
    filter = { category = 1 }
}

-------------------------------------------------------------------------------

local PADDLE_HEIGHT = POLE_HEIGHT * 0.99

local paddle = physics:Body
{
    source = Rectangle
    {
        color = "FFFFFF",
        size = { 30 , PADDLE_HEIGHT }
    },
    
    density = 0.8,
    
}

paddle.position = { pole.x + PADDLE_HEIGHT / 2 , pole.y - POLE_HEIGHT / 2 }
paddle.angle = 90

paddle:RevoluteJoint( pole , { pole.x , pole.y - POLE_HEIGHT / 2  } ,
{
    enable_motor = true ,
    motor_speed  = -90,
    max_motor_torque = 1500
}
)

screen:add( paddle.source )


-------------------------------------------------------------------------------


local BLOCK_COUNT = 20

local GLOBE_SCALE = 0.2
local globe = Image{ src = "images/globe.png" , opacity = 0 }
screen:add( globe )

for i = 1 , BLOCK_COUNT do

    local block = physics:Body
    {
        source = Clone
        {
            source = globe ,
            opacity = 255,
            scale = { GLOBE_SCALE , GLOBE_SCALE },
            position = { screen.w / BLOCK_COUNT * i  , - 50 }
        },
        type = "dynamic",
        density = 2,
        bounce = 0.8,
        shape = physics:Circle( ( globe.w / 2 ) * GLOBE_SCALE ),
        filter = { category = 3 , mask = { 0 , 2 , 3 } }
    }
    
    screen:add( block.source )
end

-------------------------------------------------------------------------------

physics.gravity = { 0 , 10 }


if false then

    function idle.on_idle()
    
        physics:step()
        physics:draw_debug( 255 )
        
    end
    
else

    physics:start()
    
end
