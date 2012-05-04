local background = Rectangle { size = { screen.w, screen.h }, color = "000000" }
screen:add ( background )

local fps_current_lbl = Text { text = "Current FPS: ",
				position = { 100, 100 },
				font = "Sans 40px",
				color = "FFFFFF"
				}
local fps_average_lbl = Text { text = "Average FPS: ",
				position = { 100, 140 },
				font = "Sans 40px",
				color = "FFFFFF"
				}
local total_balls_lbl = Text { text = "Total Balls: ",
				position = { 100, 180 },
				font = "Sans 40px",
				color = "FFFFFF"
				}
local fps_current_val = Text { text = "0",
				position = { 350, 100 },
				font = "Sans 40px",
				color = "FFFFFF"
				}
local fps_average_val = Text { text = "0",
				position = { 350, 140 },
				font = "Sans 40px",
				color = "FFFFFF"
				}
local total_balls_val = Text { text = "0",
				position = { 350, 180 },
				font = "Sans 40px",
				color = "FFFFFF"
				}

local screen_size_lbl = Text { text = "Screen size: ",
                               position = { 100, 220 },
                               font = "Sans 40px" ,
                               color = "FFFFFF"
                             }

local screen_size_txt = Text { text = screen.display_size[1]..", "..screen.display_size[2],
                               position = { 350, 220 },
                               font = "Sans 40px",
                               color = "FFFFFF"
                             }

screen:add(fps_current_lbl, fps_average_lbl, fps_current_val, fps_average_val, total_balls_lbl, total_balls_val, screen_size_lbl, screen_size_txt)


math.randomseed( os.time() )

-------------------------------------------------------------------------------
-- Add invisible walls

screen:add( 
    physics:Body( Group{ size = { 2 , screen.h } , position = { -2 , 0 } } , { type = "static" } ),
    physics:Body( Group{ size = { 2 , screen.h } , position = { screen.w , 0 } } , { type = "static" } ),
    physics:Body( Group{ size = { screen.w , 2 } , position = { 0 , -2 } } , { type = "static" } ),
    physics:Body( Group{ size = { screen.w , 2 } , position = { 0 , screen.h } } , { type = "static" } ) )

-------------------------------------------------------------------------------

local Test_name = Text {  position = { 30, 20 },
			font = "Sans 50px",
			text = "Trickplay Ball Collisions using Physics Engine",
			color = "FFFFFF",
}

screen:add ( Test_name )

local ball_colors = {}

local function make_ball( color , filter )

    local BALL_SIZE  = 50
    local HB = BALL_SIZE / 2
    
    local ball = Canvas{ size = { BALL_SIZE , BALL_SIZE } }
    
    ball:begin_painting()
    ball:arc( HB , HB , HB , 0 , 360 )
    ball:set_source_color( color )
    ball:fill()
    ball:fill()
    ball:finish_painting()

	ball = ball:Image()
    ball = physics:Body(
    
        ball,
        {
            position =
            {
                math.random( BALL_SIZE / 2 , screen.w - BALL_SIZE / 2 ) ,
                math.random( BALL_SIZE / 2 , screen.h - BALL_SIZE / 2 )
            },
            
            shape = physics:Circle( BALL_SIZE / 2 ),
            density = 1,
            friction = 0,
            bounce = 1,
            filter = filter,
    
            -- Give the ball an initial velocity and some damping
        
            linear_damping = 0.01,    
            linear_velocity = { math.random( 5 , 10 ) , math.random( 5 , 10 ) },
        }
    )
    
    
    screen:add( ball )
    
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

local BALL_COUNT = 20

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

total_balls_val.text  = BALL_COUNT * 3

-------------------------------------------------------------------------------
-- No gravity

physics.gravity = { 0 , 0 }

screen:show()

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
	--    if ( vx == 0 or vy == 0 ) then
	--        print( "DEAD BALL!" )
	--        ball:apply_linear_impulse( { math.random( 2 , 6 ) , math.random( 2 , 6 ) } , ball.position )
	--    end
	end

end

local frame_count = 0
local total_frame_count = 0
local timer_count = 0

function timerEventHandler()
	fps_current_val.text = 1000 * frame_count/5000
	frame_count = 0
	timer_count = timer_count + 1
	fps_average_val.text = 1000 * total_frame_count/(timer_count * 5000)
	if timer_count > 6 then
		timer:stop()
	end
end		

timer_fps = Timer( {interval = 5000, on_timer = timerEventHandler} )

local fps_timeline = Timeline {	duration = 30000,
				loop = true,
	on_new_frame = function (self, msecs, progress)
		frame_count = frame_count + 1
		total_frame_count = total_frame_count + 1
	end
}
fps_timeline:start()
timer:start()
timer_fps:start()


