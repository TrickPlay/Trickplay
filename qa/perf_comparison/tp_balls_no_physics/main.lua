math.randomseed( os.time() )

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

local Test_name = Text {  position = { 30, 20 },
			font = "Sans 50px",
			text = "Trickplay Ball Collisions with no Physics Engine",
			color = "FFFFFF",
}

screen:add ( Test_name )


local ball_colors = {}

local function make_ball( color )

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
    ball.position = {    math.random( BALL_SIZE / 2 , screen.w - BALL_SIZE / 2 ),
			 math.random( BALL_SIZE / 2 , screen.h - BALL_SIZE / 2 )
		    }
    ball.speedx = math.random()*9
    ball.speedy = math.random()*9
           
    screen:add( ball )
    

    
    return ball
end

local BALL_COUNT = 20

local balls = {}

for i = 1 , BALL_COUNT do
  table.insert( balls ,
        make_ball( "FF0000" ))
end

for i = 1 , BALL_COUNT do
  table.insert( balls ,
        make_ball( "00FF00" ))
end

for i = 1 , BALL_COUNT do
  table.insert( balls ,
        make_ball( "0000FF" ))
end

total_balls_val.text  = BALL_COUNT * 3

 
local timer = Timer( 1 )

function timer.on_timer()
	local ball
	for i = 1 , # balls do
	   	ball = balls[ i ]
		ball.x = ball.x - ball.speedx
  		ball.y = ball.y - ball.speedy

		if ball.x < 30 then
			ball.x = 30
			ball.speedx = -ball.speedx
		end
		if ball.y < 30 then
			ball.y = 30
			ball.speedy = -ball.speedy
		end
		if ball.x > screen.w - 30 then
			ball.x = screen.w - 30
			ball.speedx = -ball.speedx
		end
		if ball.y > screen.h - 30 then
			ball.y = screen.h - 30
			ball.speedy = -ball.speedy
		end
	end

	for i = 1 , # balls do
		ballA = balls [ i ]
		for j = i + 1 , # balls -1 do
			ballB = balls [ j ]
			dx = ballB.x - ballA.x
			dy = ballB.y - ballA.y
			dist = math.sqrt ( dx*dx+dy*dy )
			if ( dist<25 ) then
				solveBalls(ballA, ballB)
			else

			end
		end
	end
	

end


function solveBalls(ballA, ballB)
	x1 = ballA.x
	y1 = ballA.y
	dx = ballB.x-x1
	dy = ballB.y-y1
	dist = math.sqrt ( dx*dx+dy*dy )
	radius = 25
	normalX = dx/dist
	normalY = dy/dist
	midpointX = (x1+ballB.x)/2
	midpointY = (y1+ballB.y)/2
	ballA.x = midpointX-normalX*radius
	ballA.y = midpointY-normalY*radius
	ballB.x = midpointX+normalX*radius
	ballB.y = midpointY+normalY*radius
	
	dVector = (ballA.speedx-ballB.speedx)*normalX+(ballA.speedy-ballB.speedy)*normalY
	dvx = dVector*normalX
	dvy = dVector*normalY
	ballA.speedx = ballA.speedx - dvx
	ballA.speedy = ballA.speedy - dvy
	ballB.speedx = ballB.speedx + dvx
	ballB.speedy = ballB.speedy + dvy
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

screen:show()

