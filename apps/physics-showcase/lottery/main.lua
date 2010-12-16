
local SENSOR_COLOR = "FF000010"

-------------------------------------------------------------------------------
-- Start with the hopper. We create a single static body that is invisible
-- and add edge fixtures for its outline

screen:add( Image{ src = "lottery/assets/background.jpg" , scale = { 2 , 2 } , position = { 0 , 0 } } )

local outside_points =
{
    { 364,44 },{ 364,1056 },
    { 1352,1024 },{ 1646,730 },
    { 1646,230 },{ 1500,84 },
    { 1028,84 },{ 1028,382 },
    { 988,442 },{ 988,488 },
    { 972,488 },{ 972,438 },
    { 1012,378 },{ 1012,188 },
    { 904,188 },{ 826,266 },
    { 826,192 },{ 680,46 },
    { 364,44 }
}

local inside_points =
{
    { 456,136 },{ 456,964 },
    { 1310,934 },{ 1554,690 },
    { 1554,270 },{ 1460,176 },
    { 1112,176 },{ 1112,382 },
    { 1152,442 },{ 1152,488 },
    { 1168,488 },{ 1168,438 },
    { 1128,378 },{ 1128,188 },
    { 1216,188 },{ 1412,384 },
    { 1412,696 },{ 1216,892 },
    { 904,892 },{ 708,696 },
    { 708,384 },{ 734,358 },
    { 734,230 },{ 640,136 },
    { 456,136 }
}

local hopper = physics:Body(

    Group
    {
        position = { 0 , 0 } ,
        size = screen.size
    }
    ,
    {
        type = "static"
    }
)

hopper:remove_all_fixtures()

screen:add( hopper )

local xo = - hopper.w / 2
local yo = - hopper.h / 2

local function create_edges( points )

    for i = 1 , # points - 1 do
    
        local p1 = { unpack( points[ i ] ) }
        local p2 = { unpack( points[ i + 1 ] ) }
        
        p1[ 1 ] = p1[ 1 ] + xo
        p1[ 2 ] = p1[ 2 ] + yo
        
        p2[ 1 ] = p2[ 1 ] + xo
        p2[ 2 ] = p2[ 2 ] + yo
        
        hopper:add_fixture
        {
            shape = physics:Edge( p1 , p2 ) ,
            friction = 0.1,
            filter = { group = -1 }
        }
    end

end

create_edges( inside_points )
create_edges( outside_points )

-------------------------------------------------------------------------------

-- A table of the balls, keyed by handle

local balls = {}

-- A table of functions that have to run every step

local step_functions = {}

-- Y part of gravity

local G = physics.gravity[ 2 ]

-------------------------------------------------------------------------------
-- Now, the fan
-- The fan is a static sensor that sits at the bottom of the hopper. It tracks
-- the balls that are in contact with it and applies a force to all of them
-- every step.

local FAN_POSITION = { 454 * 2 , 428 * 2 }
local FAN_SIZE     = { 154 * 2 , 40 }

local FAN_FORCE    = 25.06 -- in Gs

local fan = physics:Body(

    Rectangle
    {
        color = SENSOR_COLOR,
        position = FAN_POSITION,
        size = FAN_SIZE
    }
    ,
    {
        type = "static",
        sensor = true
    }
)

local balls_in_fan = {}

function fan:on_begin_contact( contact )

    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
        balls_in_fan[ ball.handle ] = ball
    end
    
end

function fan:on_end_contact( contact )

    local handle = contact.other_body[ self.handle ]
    
    balls_in_fan[ handle ] = nil
    
end

local function fan_blow()

    for _ , ball in pairs( balls_in_fan ) do
    
        ball:apply_force( { 0 , - G * FAN_FORCE * ball.mass } , { fan.x , ball.y } )
        
    end

end

table.insert( step_functions , fan_blow )

screen:add( fan )

-------------------------------------------------------------------------------
-- The sucker is a static sensor that sits at the mouth of the outgoing tube
-- and pushes a ball upward

local SUCKER_POSITION = { 514 * 2 , 240 }
local SUCKER_SIZE     = { 42 * 2 , 180 }

local SUCKER_FORCE    = 5

local sucker_on = true

local sucker = physics:Body(

    Rectangle
    {
        color = SENSOR_COLOR,
        size = SUCKER_SIZE,
        position = SUCKER_POSITION
    }
    ,
    {
        type = "static",
        sensor = true
    }
)

local balls_in_sucker = {}

function sucker:on_begin_contact( contact )
    
    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
    
        balls_in_sucker[ ball.handle ] = ball
        
    end
    
end

function sucker:on_end_contact( contact )
    local handle = contact.other_body[ self.handle ]    
    balls_in_sucker[ handle ] = nil    
end

local function sucker_suck()

    if sucker_on then

        for _ , ball in pairs( balls_in_sucker ) do
        
            ball:apply_force( { 0 , - G * SUCKER_FORCE * ball.mass } , ball.position )
            
        end
        
    end
    
end

table.insert( step_functions , sucker_suck )

screen:add( sucker )

-------------------------------------------------------------------------------
-- The pusher has two parts, a sensor that detects when a ball has reached the
-- top of the outgoing tube and the actual pusher. It also turns the sucker
-- on and off. The pusher itself is dynamic so it has to sit on a "shelf" and
-- slide to the right and left.

local PUSHER_SENSOR_POSITION = { 1027 , 88 }
local PUSHER_SENSOR_SIZE     = { 80 , 20 }

local pusher_sensor = physics:Body(

    Rectangle
    {
        color = SENSOR_COLOR,
        size = PUSHER_SENSOR_SIZE,
        position = PUSHER_SENSOR_POSITION
    }
    ,
    {
        type = "static",
        sensor = true
    }
)


local PUSHER_POSITION = { 830 , 50 }
local PUSHER_DISTANCE = 100

local pusher = physics:Body(

    Image
    {
        src = "lottery/assets/pusher.png",
        position = PUSHER_POSITION
    }
    ,
    {
        type = "dynamic",
        density = 4,
        friction = 0,
        shape = physics:Box( { 190 , 140 } , { -55 , 0 } ),
        filter = { group = -1 }
    }
)


local pusher_floor = physics:Body(

    Rectangle
    {
        color = "00FF0000",
        x = PUSHER_POSITION[ 1 ],
        y = PUSHER_POSITION[ 2 ] + pusher.h,
        w = pusher.w,
        h = 10
    }
    ,
    {
        type = "static",
        friction = 0,
        filter = { category = 2 }
    }
)

screen:add( pusher_floor )

local push_it = false

function pusher_sensor:on_begin_contact( contact )
    
    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
    
        pusher:apply_linear_impulse( { 400 , 0 } , pusher.position )

        sucker_on = false

        push_it = true        
        
    end

end

local pusher_start_x = pusher.x

local function pusher_push( seconds )
    
    if not push_it then
        return
    end
    
    local vx , vy = unpack( pusher.linear_velocity )
    
    if vx > 0 then
    
        if pusher.x >= pusher_start_x + PUSHER_DISTANCE then

            pusher.linear_velocity = { - vx , 0 }
        
        end
    
    elseif vx < 0 then
    
        if pusher.x <= pusher_start_x then
        
            pusher.linear_velocity = { 0 , 0 }
            
            pusher.x = pusher_start_x
            
            sucker_on = true
            
            push_it = false
            
        end
    
    end
    
end

table.insert( step_functions , pusher_push )

screen:add( pusher_sensor , pusher )

-------------------------------------------------------------------------------


local GATE_POSITION = { 562 , 951 }

local gate = physics:Body(

    Image
    {
        src = "lottery/assets/door.png",
        position = GATE_POSITION,
    }
    ,
    {
        density = 16,
        friction = 0.5,
        bounce = 0,
        angular_damping = 1,
    }
)

gate:RevoluteJoint(
    hopper
    ,
    {
        GATE_POSITION[ 1 ] + gate.w / 2 ,
        GATE_POSITION[ 2 ]
    }
    ,
    {
        enable_limit = true,
        lower_angle = -90 ,
        upper_angle = 100
    }
)

local gate_open = false

local function hold_gate()
    if not gate_open then
        return
    end
    gate:apply_force( { -400 , 0 } , gate.position )
    
end

table.insert( step_functions , hold_gate )

screen:add( gate )



-------------------------------------------------------------------------------
-- Now, some balls

local ball_image = Image{ src = "lottery/assets/ball.png" }

screen:add( ball_image )
ball_image:hide()

local BALL_COUNT = 18 -- Too many balls may need a stronger fan
local BALL_POSITION = { 390 * 2 , 204 * 2 }

for i = 1 , BALL_COUNT do

    local ball = physics:Body(

        Group
        {
            position = BALL_POSITION,
            
            children =
            {
                Clone
                {
                    source = ball_image,
                }
                ,
                Text
                {
                    text = tostring( i ),
                    position = { 10 , 10 },
                    color = "000000",
                    font = "DejaVu Mono bold 70px",
                }
                
            }
        }
        ,
        {
            shape = physics:Circle( ball_image.w / 2 ),
            density = 0.5 ,
            friction = 0.1 ,
            bounce = 0.7,
            filter = { category = 1 , mask = { 0 , 1 } },
            angular_damping = 0.5,
            
        }
    )

    screen:add( ball )
    
    ball:show()

    balls[ ball.handle ] = ball
    
end

-------------------------------------------------------------------------------
-- Elevator(s)

local ELEVATOR_POSITION = { 368 , 1066 }
local ELEVATOR_SPEED    = 40 -- pixels per second
local ELEVATOR_COUNT    = 5
local ELEVATOR_INTERVAL = 5 -- seconds

local elevator_image = Image{ src = "lottery/assets/elevator.png" }
screen:add( elevator_image )
elevator_image:hide()

local elevators = {}

local function deploy_elevator()

    local elevator = physics:Body(
        Clone
        {
            source = elevator_image,
            position = ELEVATOR_POSITION
        }
        ,
        {
            type = "static",
            friction = 1,
        }
    )
    
    screen:add( elevator )
    
    elevators[ elevator ] = true

end

local function elevate( seconds )

    for elevator , _ in pairs( elevators ) do
    
        elevator.y = elevator.y - ELEVATOR_SPEED * seconds
        
        if elevator.y <= 60 then
        
            elevator.y = ELEVATOR_POSITION[ 2 ]
            elevator.angle = 0
        
        elseif elevator.y < 142 then
        
            elevator.angle = 20
            
        end
    
    end

end

table.insert( step_functions , elevate )

local count = 1

local t = Timer( ELEVATOR_INTERVAL * 1000 )

function t.on_timer()
    deploy_elevator()
    count = count + 1
    return count < ELEVATOR_COUNT
end

t:start()

deploy_elevator()

-------------------------------------------------------------------------------


screen:show()

function idle:on_idle( seconds )

    physics:step( seconds )
    
    for i = 1 , # step_functions do
    
        step_functions[ i ]( seconds )
        
    end
    
   --physics:draw_debug()
    
end

function screen.on_key_down( screen , k )
    if k == keys.Return then
        gate_open = not gate_open
    end
end