
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

local CHAIN_LENGTH = POLE_HEIGHT * 1.2
local LINKS = 60
local LINK_WIDTH = 20
local LINK_COLOR = "FFFFFF"

local last_link = pole

for i = 1 , LINKS do

    local link = Rectangle
    {
        color = LINK_COLOR,
        size = { LINK_WIDTH , CHAIN_LENGTH / LINKS },
    }
    
    link.anchor_point = link.center
    link.z_rotation = { 90 , 0 , 0 }
    
    link.x = pole.x + link.h / 2 + ( ( link.h ) * ( i - 1 ) )
    link.y = pole.y - pole.h / 2 

    screen:add( link )
    
    link = physics:Body( link , 
    {
        density = 2,
        friction = 0.1,
        bounce = 0.5,
        filter = { category = 2 , mask = { 0 , 3 } }
    })

    link:RevoluteJoint( last_link , { link.x - link.w / 2 , link.y } ,
    {
        enable_limit = true,
        lower_angle = -90,
        upper_angle = 90
    }
    )
    
    last_link = link
end

-------------------------------------------------------------------------------

local BLOCK_COUNT = 10

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
            density = 0.2,
            bounce = 0.8,
            shape = physics:Circle( ( globe.w / 2 ) * GLOBE_SCALE ),
            filter = { category = 3 , mask = { 0 , 2 , 3 } }
        })
        
    
    screen:add( block )
end

-------------------------------------------------------------------------------

physics.gravity = { 0 , 6 }

function idle.on_idle()

    physics:step()
    --physics:draw_debug( 255 )
    
end