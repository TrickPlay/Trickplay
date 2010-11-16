-------------------------------------------------------------------------------

local ground = Rectangle
{
    color = "00FF00",
    size  = { screen.w , 30 },
    position = { 0 , screen.h - 30 }
}

ground = physics:Body( ground , 
{
    type = "static",
    density = 1,
    friction = 0.5,
    bounce = 0.1
} )

screen:add( ground )

-------------------------------------------------------------------------------

local bumper

bumper = physics:Body(
        Rectangle
        {
            color = "00FF00",
            size = { screen.h * 1.2 , screen.h / 4 },
        },
        {
            type = "static"
        })

bumper.position = { 0 , screen.h / 2 }
bumper.angle = 75

screen:add( bumper )


bumper = physics:Body(
        Rectangle
        {
            color = "00FF00",
            size = { screen.h * 1.2 , screen.h / 4 },
        },
        {
            type = "static"    
        })

bumper.position = { screen.w , screen.h / 2 }
bumper.angle = -75

screen:add( bumper )

-------------------------------------------------------------------------------

local POLE_HEIGHT = 800

local pole = Rectangle
{
    color = "473232",
    size = { 30 , POLE_HEIGHT },
    position = { screen.w / 2 - 15 , screen.h - ( POLE_HEIGHT + ground.h ) }
}

screen:add( pole )

pole = physics:Body( pole , 
{
    density = 1,
    type = "static",
    filter = { category = 1 }
})

-------------------------------------------------------------------------------

local PADDLE_HEIGHT = POLE_HEIGHT / 2 

local paddle = physics:Body(
    Rectangle
    {
        color = "FFFFFF",
        size = { 30 , PADDLE_HEIGHT }
    },
    {
        density = 0.8,    
    } )

paddle.position = { pole.x , pole.y - POLE_HEIGHT / 2 }
paddle.angle = 90

paddle:PrismaticJoint( pole , { 0 , 0 } , { 0 , 1 } ,

    {
        enable_limit = true,
        lower_translation = 0 ,
        upper_translation = POLE_HEIGHT ,
        enable_motor = false,
        motor_speed = 1,
        max_motor_force = 1000
    }
)

screen:add( paddle )

-------------------------------------------------------------------------------

local BLOCK_COUNT = 20

local GLOBE_SCALE = 0.2
local globe = Image{ src = "images/globe.png" , opacity = 0 }
screen:add( globe )

for i = 1 , BLOCK_COUNT do

    local block = physics:Body(
        Clone
        {
            source = globe ,
            opacity = 255,
            scale = { GLOBE_SCALE , GLOBE_SCALE },
            position = { screen.w / BLOCK_COUNT * i  , - 50 }
        },
        {
            type = "dynamic",
            density = 2,
            bounce = 0.8,
            shape = physics:Circle( ( globe.w / 2 ) * GLOBE_SCALE ),
            filter = { category = 3 , mask = { 0 , 2 , 3 } }
        })
    
    screen:add( block )
end

-------------------------------------------------------------------------------

if false then

    function idle.on_idle()
    
        physics:step()
        physics:draw_debug( 255 )
        
    end
    
else

    physics:start()
    
end
