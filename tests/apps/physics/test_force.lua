

physics.gravity = { 0 , 10 }


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

local bodies = {}

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
            density = 10,
            bounce = 0.8,
            angular_damping = 1,
            shape = physics:Circle( ( globe.w / 2 ) * GLOBE_SCALE ),
            filter = { category = 3 , mask = { 0 , 2 , 3 } }
        })
        
    
    screen:add( block )
    
    bodies[ block.handle ] = block
end

-------------------------------------------------------------------------------

turbine = physics:Body(
    
    Rectangle
    {
        color = "FFFFFF11",
        size  = { 300 , screen.h - 400 },
        x = screen.w / 2 - 150,
        y = 400
    }
    ,
    {
        type = "static",
        sensor = true
    }
    
)


screen:add( turbine )

turbine:lower_to_bottom()


local bodies_in_contact = {}

function turbine.on_begin_contact( turbine , contact )
    local handle = contact.other_body[ turbine.handle ]
    bodies_in_contact[ handle ] = bodies[ handle ]
end

function turbine.on_end_contact( turbine , contact )
    local handle = contact.other_body[ turbine.handle ]
    bodies_in_contact[ handle ] = nil
end

-------------------------------------------------------------------------------

idle.limit = 1/60

local g = physics.gravity[ 2 ]

function idle:on_idle( seconds )

    physics:step( seconds )
        
    if globe.x < -300 then
    
        globe.x = screen.w 
        
    end
    
    for _ , body in pairs( bodies_in_contact ) do

        body:apply_force( { 0 , - g * 1.06 * body.mass } , { turbine.x , body.y } )
    
    end
    
end

