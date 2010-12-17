
local SENSOR_COLOR = "FF000000"

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

local fan_speed    = 0

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

local fan_on = true

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

local function fan_blow( seconds )

    if fan_on then
    
        if fan_speed < 1 then
        
            fan_speed = math.min( fan_speed + 0.25 * seconds , 1 )
            
        end

        for _ , ball in pairs( balls_in_fan ) do
        
            ball:apply_force( { 0 , - G * FAN_FORCE * ball.mass * fan_speed } , { fan.x , ball.y } )
            
        end
        
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

    for _ , ball in pairs( balls_in_sucker ) do
    
        local force = - G * SUCKER_FORCE * ball.mass
        
        if not sucker_on then
            force = - force
        end
    
        ball:apply_force( { 0 , force  } , ball.position )
        
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
        density = 40,
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
    
    if ball and sucker_on then
    
        pusher:apply_linear_impulse( { 4000 , 0 } , pusher.position )

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

            pusher.x = pusher_start_x + PUSHER_DISTANCE
            
            pusher.linear_velocity = { 0 , 0 }
            
            push_it = false
        
        end
    
    elseif vx < 0 then
    
        if pusher.x <= pusher_start_x then
        
            pusher.linear_velocity = { 0 , 0 }
            
            pusher.x = pusher_start_x
--[[            
            local t = Timer( 4000 )
            function t.on_timer()
                sucker_on = true
                return false
            end
            t:start()
]]
            sucker_on = true
            
            push_it = false
            
        end
    
    end
    
end

table.insert( step_functions , pusher_push )

screen:add( pusher_sensor , pusher )

-------------------------------------------------------------------------------
--[[

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

]]

-------------------------------------------------------------------------------
-- Now, some balls

local ball_image = Image{ src = "lottery/assets/ball.png" }

screen:add( ball_image )
ball_image:hide()

local BALL_COUNT = 18 -- Too many balls may need a stronger fan
local BALL_POSITION = { 390 * 2 , 204 * 2 }

local function make_ball( i )

    local text =
    
        Text
        {
            text = tostring( i ),
            position = { 10 , 10 },
            color = "000000D0",
            font = "DejaVu Mono bold 70px",
        }
    
    local result = 

        Group
        {
            children =
            {
                Clone
                {
                    source = ball_image,
                }
                ,
                text
            }
            ,
            extra =
            {
                number = i
            }
        }
        
    if i == 6 or i == 9 then
    
        result:add(
            Rectangle
            {
                color = "000000C0" ,
                x = text.x + 7 ,
                y = text.y + text.h - 10 ,
                size = { 18 , 6 }
            }
        )
    
    end
    
    return result
end        



for i = 1 , BALL_COUNT do

    local ball = physics:Body(

        make_ball( i ):set
        {
            position = BALL_POSITION,
        
        }
        ,
        {
            shape = physics:Circle( ball_image.w / 2 ),
            density = 1 ,
            friction = 0.1 ,
            bounce = 0.7,
            filter = { category = 1 , mask = { 0 , 1 } },
            angular_damping = 1,
            
        }
    )

    screen:add( ball )
    
    ball:show()

    balls[ ball.handle ] = ball
    
end

-------------------------------------------------------------------------------
-- Elevators
-- They are created hidden below the inbound pipe. A sensor detects when a ball
-- sits in the corner for a bit and deploys the next elevator.

local ELEVATOR_POSITION = { 368 , 1066 }
local ELEVATOR_COUNT    = 4
local ELEVATOR_INTERVAL = 1 -- seconds

local elevator_image = Image{ src = "lottery/assets/elevator.png" }
screen:add( elevator_image )
elevator_image:hide()

local elevators = {}

local elevator_start_x = false

for i = 1 , ELEVATOR_COUNT do

    local elevator = physics:Body(
        
        Clone
        {
            source = elevator_image,
            position = ELEVATOR_POSITION
        }
        ,
        {
            type = "dynamic",
            density = 100,
            friction = 1,
            fixed_rotation = true,
            filter = { group = -1 }
        }
    )
    
    screen:add( elevator )
    
    elevator:hide()
    
    elevators[ elevator ] = true
    
    if not elevator_start_x then
    
        elevator_start_x = elevator.x
        
    end
    
end

local ELEVATOR_SENSOR_POSITION = { 366 , 1000 }
local ELEVATOR_SENSOR_SIZE     = { 10 , 20 }

local elevator_sensor = physics:Body(
    
    Rectangle
    {
        color = SENSOR_COLOR,
        position = ELEVATOR_SENSOR_POSITION,
        size = ELEVATOR_SENSOR_SIZE
    }
    ,
    {
        type = "static",
        sensor = true
    }
)

screen:add( elevator_sensor )

local elevator_sensor_time = Stopwatch()
elevator_sensor_time:stop()

function elevator_sensor:on_begin_contact( contact )
    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
        elevator_sensor_time:start()
    end
end

function elevator_sensor:on_end_contact( contact )
    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
        elevator_sensor_time:stop()
    end
end

local elevators_on = false

local function elevate()

    -- If the sensor has been active long enough, deploy one elevator
    
    if elevators_on then
    
        if elevator_sensor_time.elapsed_seconds >= ELEVATOR_INTERVAL then
        
            for elevator , _ in pairs( elevators ) do
            
                if not elevator.is_visible then
                
                    elevator:show()
                    
                    elevator_sensor_time:start()
                    
                    break
                    
                end
                
            end
        
        end
        
    end

    -- Now, push all the visible elevators up. If they reach the top, they are
    -- hidden until they are re-deployed. Near the top of the tube, they tilt
    -- to push the ball out.
    
    for elevator , _ in pairs( elevators ) do
    
        if elevator.is_visible then
    
            if elevator.y < 60 then
                            
                elevator:hide()
                
                elevator.x = elevator_start_x
                
                elevator.y = ELEVATOR_POSITION[ 2 ]
                
                elevator.linear_velocity = { 0 , 0 }
                
                elevator.angle = 0
                
            elseif elevator.y < 142 then
            
                elevator.angle = 20
                
            end
        
            if elevator.is_visible then
            
                elevator.x = elevator_start_x
                
                local vx , vy = unpack( elevator.linear_velocity )
                
                if vy > - G * 0.4 then
            
                    elevator:apply_force( { 0 , - G * 2.05 * elevator.mass } , elevator.position )
                
                end
                
            end
        end
        
    end
        
end    

table.insert( step_functions , elevate )

-------------------------------------------------------------------------------
-- Sensors to track how many balls are out.

local out_sensor = physics:Body(
    Rectangle
    {
        color = SENSOR_COLOR,
        position = { 1580 , 286 },
        size = { 40 , 40 }
    }
    ,
    {
        type = "static",
        sensor = true
    }
)

local in_sensor = physics:Body(
    Rectangle
    {
        color = SENSOR_COLOR,
        position = { 732 , 162 },
        size = { 40 , 40 }
    }
    ,
    {
        type = "static",
        sensor = true
    }
)


in_sensor.angle = -45

screen:add( out_sensor , in_sensor )

--[[
local count_text = Text
{
    font = "DejaVu Mono bold 90px",
    color = "FFFFFF",
    text = "0",
    position = { 1540 , 922 }
}

screen:add( count_text )
]]

local balls_out = 0

local chosen_group = Group{ position = { 120 , 140 } }

function out_sensor:on_begin_contact( contact )

    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
    
        balls_out = balls_out + 1
    
        local count = # chosen_group.children
    
        if count == 6 then
        
            chosen_group:clear()
            
            count = 0
            
        end
        
        chosen_group:add(
        
            make_ball( ball.extra.number ):set
            {
                x = 0,
                y = ( ball.h + 20 ) * count
            }
        )
        
        if balls_out < 6 then
        
            pusher:apply_linear_impulse( { -1000 , 0 } , pusher.position )
        
            push_it = true
            
        else
        
            elevators_on = true
            
            fan_on = false
                        
        end
    
    end

end

screen:add( chosen_group )


function in_sensor:on_begin_contact( contact )

    local ball = balls[ contact.other_body[ self.handle ] ]
    
    if ball then
        
        local vx , vy = unpack( ball.linear_velocity )
        
        if vy < 0 then
            
            ball:apply_linear_impulse( { 0 , 10 } , ball.position )
            
        else
        
            balls_out = balls_out - 1
            
            if balls_out == 0 then
            
                pusher:apply_linear_impulse( { -1000 , 0 } , pusher.position )
            
                push_it = true
                
                elevators_on = false
                
                local t = Timer( 3000 )
                function t.on_timer()
                    fan_speed = 0
                    fan_on = true
                    return false
                end
                t:start()
                
            
            end
        
        end
    
    end

end


-------------------------------------------------------------------------------

screen:show()

function idle:on_idle( seconds )

    physics:step( seconds )
    
    for i = 1 , # step_functions do
    
        step_functions[ i ]( seconds )
        
    end
    
   --physics:draw_debug()
    
end

