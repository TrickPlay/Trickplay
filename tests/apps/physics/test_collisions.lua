
math.randomseed( os.time() )

-------------------------------------------------------------------------------
-- Add invisible walls

physics:Body{ size = { 2 , screen.h } , position = { -1 , screen.h / 2 } }
physics:Body{ size = { 2 , screen.h } , position = { screen.w + 1 , screen.h / 2 } }
physics:Body{ size = { screen.w , 2 } , position = { screen.w / 2 , -1 } }
physics:Body{ size = { screen.w , 2 } , position = { screen.w / 2 , screen.h + 1 } }

-------------------------------------------------------------------------------

local ball_colors = {}

local function make_ball( color , filter )

    local BALL_SIZE  = math.random( 50 , 100 )
    local HB = BALL_SIZE / 2
    
    local ball = Canvas{ size = { BALL_SIZE , BALL_SIZE } }
    
    ball:begin_painting()
    ball:arc( HB , HB , HB , 0 , 360 )
    ball:set_source_color( color )
    ball:fill()
    ball.op = "CLEAR"
    ball:arc( HB , HB , HB - 15 , 0 , 360 )
    ball:fill()
    ball:finish_painting()

    ball = physics:Body
    {
        source = ball:set
        {
            position =
            {
                math.random( BALL_SIZE / 2 , screen.w - BALL_SIZE / 2 ) ,
                math.random( BALL_SIZE / 2 , screen.h - BALL_SIZE / 2 )
            }
        },
        shape = physics:Circle( BALL_SIZE / 2 ),
        dynamic = true,
        density = 1,
        friction = 0,
        bounce = 1,
        filter = filter
    }
    
    -- Give the ball an initial velocity and some damping
    
    ball.linear_damping = 0.01
    
    ball.linear_velocity = { math.random( 5 , 10 ) , math.random( 5 , 10 ) }
    
    screen:add( ball.source )
    
    ball_colors[ ball.handle ] = color
    
    return ball
end

-- Using collision filters to make balls of the same color NOT collide

-- Using groups
-- Fixtures in the same group collide if their group is positive, and
-- don't collide if the group is negative. If the groups are different,
-- the category bits and mask determine if they collide. 

-- Using category and masks
-- Each category sets a bit and each mask sets a bit to collide with.
-- So, red balls are in category 1, and they only collide with categories
-- 0 (walls) , 2 (green balls) and 3 (blue balls).
--
-- When no filter is set, the default group is 0, the default category is 0
-- which means the first bit is set, and the default mask is ALL.

local BALL_COUNT = 4

local balls = {}

for i = 1 , BALL_COUNT do
    table.insert( balls ,
        make_ball( "FF0000" ,
            { group = -1 }
            --{ category = 1 , mask = { 0 , 2 , 3 } }
    ) )
end

for i = 1 , BALL_COUNT do
    table.insert( balls ,
        make_ball( "00FF00" ,
            { group = -2 }
            --{ category = 2 , mask = { 0 , 1 , 3 } }
    ) )
end

for i = 1 , BALL_COUNT do
    table.insert( balls ,
        make_ball( "0000FF" ,
            { group = -3 }
            --{ category = 3 , mask = { 0 , 1 , 2 } }
        ) )
end

local caption = Text
{
    font = "DejaVu Sans Mono 30px",
    color = "FFFFFF",
    text = "Balls of the same color do not collide",
    position = { 300 , 300 }
}

screen:add( caption )

caption = physics:Body{ source = caption , dynamic = true , density = 10 , friction = 0 , bounce = 1 }

function physics.on_begin_contact( physics , point , body_a , fixture_a , body_b , fixture_b )

    local other
    
    if body_a == caption.handle then
        other = body_b
    elseif body_b == caption.handle then
        other = body_a
    end
    
    if other then
        caption.source.color = ball_colors[ other ] or "FFFFFF"
    end

end

-------------------------------------------------------------------------------
-- No gravity

physics.gravity = { 0 , 0 }



screen:show()

if false then

    local ret = keys.Return

    function screen.on_key_down( screen , key )
        if key == ret then
            physics:step()
        end
    end

else

    physics:start()
    
    local timer = Timer( 1000 )
    
    function timer.on_timer()

        local vx , vy
        local ball
        for i = 1 , # balls do
            ball = balls[ i ]
            vx , vy = unpack( ball.linear_velocity )
            vx = math.abs( vx )
            vy = math.abs( vy )
            if ( vx == 0 or vy == 0 ) then
                ball:apply_force( ball.position[ 1 ] , ball.position[ 2 ] , math.random( 2 , 6 ) , math.random( 2 , 6 ) )
            end
        end
        
    end
    
    timer:start()
    
end

