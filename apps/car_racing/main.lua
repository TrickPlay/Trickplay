--print = function() end
screen:show()


math.randomseed(os.time())

--CONSTANTS
--	Global
pixels_per_mile = 70
lane_dist = 960*2/3
screen_w = screen.w
screen_h = screen.h
--	Local
local STRAFE_CAP      = 1300
local total_dead_time = 3


--Game State
current_state = {
	paused    = true,
	dead_time = 0,
	points    = 0,
	curr_path = {
		reference    = nil,
		remaining_dy = 0,
		remaining_dr = 0,
	},
	user_input = {
		throttle_position = 0,
		turn_impulse      = 0,
	}
}
road = {
	newest_segment = nil,
	curr_segment   = nil,
	oldest_segment = nil,
	segments       = {}
}
other_cars = {}
paused       = true
--crashed      = false --car
--car.dx = 960--car
local points = 0
local dead_time = 0
local curr_path = nil--path
local dy_remaining_in_path = 0--path
local dr_remaining_in_path = 0--path

throttle_position = 0
mph = 0
turn_impulse = 0


--End of Game Message
end_game = Group{x=screen_w/2,y=screen_h/2}
do
	local end_game_text = Text{
		text="You Crashed\n\nRestarting in 3",
		alignment="CENTER",
		font="Digital-7 80px",
		color="ffd652"
	}
	local end_game_backing=Rectangle{
		w=end_game_text.w+50,
		h=end_game_text.h+50,
		color="000000",
		opacity=255*.5
	}
	end_game_text.anchor_point={
		end_game_text.w/2,
		end_game_text.h/2
	}
	end_game_backing.anchor_point={
		end_game_backing.w/2,
		end_game_backing.h/2
	}
	end_game:add(end_game_backing,end_game_text)
	end_game.update = function(self,time_left)
		end_game_text = "You Crashed\n\nRestarting in "..time_left
	end
end
screen:add(end_game)

local idle_loop

--group that contains all of the clone sources
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()


--the speedometer and point-ometer
local hud = Group{name="hud"}
do
	local speedo = Image{src="assets/speedo.png",x=screen_w,y=screen_h}
	speedo.anchor_point={speedo.w,speedo.h}
	local mph_txt    = Text{text=    "000",font="Digital-7 60px",color="ffd652",x=1786,y= 986}
	local points_txt = Text{text="0000000",font="Digital-7 26px",color="ffa752",x=1653,y=1050}
	
	hud:add(speedo,mph_txt,points_txt)
	hud.update = function(self,mph,points)
		mph_txt.text = string.format("%03d",mph)
		points_txt.text = string.format("%07d",points)
	end
	hud:hide()
end

dofile(  "OtherCars.lua" )
dofile(   "Sections.lua" )
dofile(      "Level.lua" )
dofile( "controller.lua" )

screen:add(hud,splash)

--key handler
local keys = {
	--[[
	[keys.Up] = function()
		throttle_position = throttle_position + .2
		if throttle_position > 2 then throttle_position = 2 end
		
	end,--]]
	[keys.Down] = function()
		throttle_position = -10
		
	end,
	[keys.Left] = function()
		--if car.dx > -STRAFE_CAP then
		--	car.dx = car.dx - 100
		--end
		turn_impulse = turn_impulse - .4
		if turn_impulse < -1 then turn_impulse = -1 end
	end,
	[keys.Right] = function()
		--if car.dx < STRAFE_CAP then
		--	car.dx = car.dx + 100
		--end
		turn_impulse = turn_impulse + .4
		if turn_impulse > 1 then turn_impulse = 1 end
	end,
	[keys.RED] = function()
		if current_state.paused then
			idle.on_idle = idle_loop
		else
			idle.on_idle = nil
		end
		current_state.paused = not current_state.paused
	end,
	[keys.a] = function()
		table.insert(other_cars,make_car(road.newest_segment,end_point,-800,true))
		world.cars:add(other_cars[#other_cars])
		ccc = other_cars[#other_cars]
		other_cars[#other_cars]:lower_to_bottom()
	end
}
function screen:on_key_down(k)
	
	--[[if splash ~= nil then
		splash:unparent()
		splash = nil
		car:show()
		hud:show()
		world:add_next_section()
		road.curr_segment   = road.newest_segment
		road.oldest_segment = road.newest_segment
		road.newest_segment.prev_segment = road.newest_segment
		curr_path = road.segments[road.curr_segment]
		dy_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
		current_state.paused = false
		idle.on_idle = idle_loop
	else]]if not car.crashed then
		if keys[k] then keys[k]() end
	elseif dead_time > 2 then
		points = 0
		dead_time = 0
		world:reset()
		
		curr_path = road.segments[road.curr_segment]
		dy_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
	end
end


--acceleration rates for different speeds
local accel_rates = {
	30/1.71,
	60/4.13,
	100/9.02,
	200/24,
}
--current rate
local curr_accel_rate = accel_rates[1]
local braking_rate = 100/4.32
local damping_effect = 1000

--spawn counters and threshholds
local spawn_on_coming_car_timer  = 0
local spawn_on_coming_car_thresh = 1.25
local spawn_passing_car_timer    = 0
local spawn_passing_car_thresh   = 1.5*spawn_on_coming_car_thresh

--possible lane positions for spawned cars
local pos = {
	-lane_dist,
	-lane_dist/2,
	 lane_dist/2,
	 lane_dist
}

--upvals for the idle_loop
local lane3, lane4, rand, dy, dx

idle_loop = function(_,seconds)
	--increment the dead timer
	if car.crashed then
		dead_time = dead_time + seconds
		end_game:update(math.ceil(total_dead_time-dead_time))
		if dead_time > total_dead_time then
			points = 0
			dead_time = 0
			world:reset()
			
			curr_path = road.segments[road.curr_segment]
			dy_remaining_in_path = curr_path.dist
			dr_remaining_in_path = curr_path.rot
			return
		end
	end
	--move other cars
	for i = #other_cars,1,-1 do
		if other_cars[i]:move( seconds ) then
			table.remove( other_cars, i )
			print( "del" )
		end
	end
	
	spawn_on_coming_car_timer = spawn_on_coming_car_timer + seconds
	spawn_passing_car_timer   = spawn_passing_car_timer   + seconds
	
	if not car.crashed and car.v_y > 60*pixels_per_mile and spawn_passing_car_timer > spawn_passing_car_thresh then
		
		spawn_passing_car_timer = 0
		lane3 = false
		lane4 = false
		for i = #other_cars,1,-1 do
			if math.abs(other_cars[i].y -road.newest_segment.y) < 1200 then
				if other_cars[i].x == pos[3] then
					lane3 = true
					print(3)
				elseif other_cars[i].x == pos[4] then
					lane4 = true
					print(4)
				end
			end
		end
		
		if not(lane3 and lane4) then
			if lane3 then rand = pos[4]
			elseif lane4 then rand = pos[3]
			else rand = pos[math.random(3,4)]
			end
			table.insert(other_cars,
				make_car(
					road.newest_segment,
					{
						road.newest_segment.x,
						road.newest_segment.y,
						road.newest_segment.z_rotation[1]
					},
					rand
				)
			)
			world.cars:add(other_cars[#other_cars])
			other_cars[#other_cars]:lower_to_bottom()
		end
	end
	if not car.crashed and spawn_on_coming_car_timer > spawn_on_coming_car_thresh then
		spawn_on_coming_car_timer = 0
		table.insert(other_cars,make_car(road.newest_segment,end_point,pos[math.random(1,2)]))
		world.cars:add(other_cars[#other_cars])
        other_cars[#other_cars]:lower_to_bottom()
	end
	--Move the ground
	
	
	--assert(#path > 0)
	assert(road.curr_segment ~= nil)
	
	--distance covered this iteration
	dy = car.v_y*seconds
	dr = curr_path.rot*dy/curr_path.dist --relative to amount travelled
	
	
	
	--speed forward
	car.v_y = car.v_y + pixels_per_mile*curr_accel_rate*throttle_position*seconds--+collision_strength*math.cos(math.pi/180*collision_angle)
	--different accelerations for different speeds
	if     car.v_y > 200*pixels_per_mile then car.v_y = 200*pixels_per_mile
	elseif car.v_y > 100*pixels_per_mile then curr_accel_rate = accel_rates[4]
	elseif car.v_y >  60*pixels_per_mile then curr_accel_rate = accel_rates[3]
	elseif car.v_y >  60*pixels_per_mile then curr_accel_rate = accel_rates[3]
	elseif car.v_y >  30*pixels_per_mile then curr_accel_rate = accel_rates[2]
	elseif car.v_y >   0                 then curr_accel_rate = accel_rates[1]
	elseif car.v_y <   0                 then car.v_y = 0 end
	
	
	--car.v_y = mph*pixels_per_mile
	points = points + dy/pixels_per_mile
	hud:update(car.v_y/pixels_per_mile,points)
	
	tail_lights.opacity=0
	--[[if throttle_position > 0.05 then
		throttle_position = throttle_position - 1*seconds
	else]]if throttle_position < 2 then
		throttle_position = throttle_position + 20*seconds
		tail_lights.opacity=255
	else
		throttle_position = 2
	end
	
	
	
	--speed sideways
	car.v_x = car.v_y/5*turn_impulse + car.v_x
	--update distance from the center of the road
	car.dx = car.dx + car.v_x*seconds
	--if on or beyond the shoulder,
	--then your car receives heavy resistance
	if math.abs(car.dx) > STRAFE_CAP then
		car.v_y = car.v_y - 4000*seconds
		if car.v_y < 800 then
			car.v_y = 800
		end
	end
	--decay
	if car.v_x > 0 then
		car.v_x = car.v_x - 4000*seconds -- car.v_x/10
		if car.v_x < 0 then
			car.v_x = 0
		end
	else
		car.v_x = car.v_x + 4000*seconds
		if car.v_x > 0 then
			car.v_x = 0
		end
	end
	
	
	--stop moving if crashed
	if car.crashed and math.abs(car.v_y) > 20 then
		car.v_y = car.v_y/2
	elseif car.crashed then
		car.v_y = 0
	end
	
	if turn_impulse > 0 then
		if turn_impulse > .5 then
			--car.src = "assets/Lambo/01.png"
			car.y_rotation={0,0,0}
		else
			--car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse-2*seconds
		if turn_impulse < 0 then
			turn_impulse = 0
		end
	else
		if turn_impulse < -.5 then
			--car.src = "assets/Lambo/01.png"
			car.y_rotation={180,0,0}
		else
			--car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse+2*seconds
		if turn_impulse > 0 then
			turn_impulse = 0
		end
	end
	
	--while the amount of distance covered in this iteration extends
	--to the end of the current path segment...
	while dy_remaining_in_path < dy do
		--move by whatever distance is left in the current path segment
		world:move(
			dy_remaining_in_path,
			dr_remaining_in_path,
			curr_path.radius
		)
		
		--move onto the next path segment
		road.curr_segment = road.curr_segment.next_segment
		curr_path = road.segments[road.curr_segment]
		--re-adjust the path center to compensate for rounding error
		world:normalize_to(curr_path.parent)
		
		--update the amount of remaining distance to cover
		dy = dy - dy_remaining_in_path
		dr = curr_path.rot*dy/curr_path.dist
		
		--set the amount of distance there is to cover in this path segment
		dy_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
		
	end
	
	--move by the incremental amount
	world:move(dy,dr,curr_path.radius)
	
	--decrement the remaining by the amount travelled
	dy_remaining_in_path = dy_remaining_in_path - dy
	dr_remaining_in_path = dr_remaining_in_path - dr
end

--idle.on_idle = idle_loop

		car:show()
		hud:show()
		curr_path = road.segments[road.curr_segment]
		dy_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
		current_state.paused = false
		idle.on_idle = idle_loop
