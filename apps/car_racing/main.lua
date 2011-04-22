--print = function() end
screen:show()
screen_w = screen.w
screen_h = screen.h
crashed = false
num_passing_cars = 0
math.randomseed(os.time())
--local splash = Group{}
--local splash_title = Image{src="assets/logo.png",x=screen_w/2,y=screen_h/2}
--splash_title.anchor_point={splash_title.w/2,splash_title.h/2}
--splash:add(splash_title)

end_game = Group{x=screen_w/2,y=screen_h/2}
local end_game_text = Text{text="You Crashed\n\nStart Again",font="Digital-7 80px",color="ffd652"}
local end_game_backing=Rectangle{w=end_game_text.w+50,h=end_game_text.h+50,color="000000",opacity=255*.5}
end_game_text.anchor_point={end_game_text.w/2,end_game_text.h/2}
end_game_backing.anchor_point={end_game_backing.w/2,end_game_backing.h/2}
end_game:add(end_game_backing,end_game_text)
screen:add(end_game)
pixels_per_mile = 45
paused = true
local idle_loop

clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
strafed_dist = 960
local STRAFE_CAP =1400
local hud = Group{name="hud"}
local speedo = Image{src="assets/speedo.png",x=screen_w,y=screen_h}
speedo.anchor_point={speedo.w,speedo.h}
hud:add(speedo)
local mph_txt    = Text{text="000",font="Digital-7 60px",color="ffd652",x=1786,y=986}
local points_txt = Text{text="000000",font="Digital-7 26px",color="ffa752",x=1653,y=1050}
local points = 0
local dead_time = 0
hud:add(mph_txt,points_txt)
hud:hide()
road={
	newest_segment = nil,
	curr_segment   = nil,
	oldest_segment = nil,
	segments       = {}
}
other_cars = {}
dofile( "OtherCars.lua" )
dofile(  "Sections.lua" )
dofile(     "Level.lua" )
screen:add(hud,splash)
speed = 0
throttle_position = 0
 accel = 0
 mph = 65
turn_impulse = 0
curve_impulse = 0
collision_strength = 0
collision_angle = 0
ccc = nil
dofile("controller.lua")
local curr_path = nil
local dy_remaining_in_path = 0
local dr_remaining_in_path = 0
local keys = {
	[keys.Up] = function()
		throttle_position = throttle_position + .2
		if throttle_position > 1 then throttle_position = 1 end
		
	end,
	[keys.Down] = function()
		throttle_position = -2
		
	end,
	[keys.Left] = function()
		--if strafed_dist > -STRAFE_CAP then
		--	strafed_dist = strafed_dist - 100
		--end
		turn_impulse = turn_impulse - .4
		if turn_impulse < -1 then turn_impulse = -1 end
	end,
	[keys.Right] = function()
		--if strafed_dist < STRAFE_CAP then
		--	strafed_dist = strafed_dist + 100
		--end
		turn_impulse = turn_impulse + .4
		if turn_impulse > 1 then turn_impulse = 1 end
	end,
	[keys.RED] = function()
		if paused then
			idle.on_idle = idle_loop
		else
			idle.on_idle = nil
		end
		paused = not paused
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
		paused = false
		idle.on_idle = idle_loop
	else]]if not crashed then
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



local dy = 0
local dr = 0



local accel_rates = {
	30/1.71,
	60/4.13,
	100/9.02,
	200/24,
}
local curr_accel_rate = accel_rates[1]
local braking_rate = 100/4.32
local damping_effect = 1000

local spawn_on_coming_car_timer  = 0
local spawn_on_coming_car_thresh = 1.25
local spawn_passing_car_timer    = 0
local spawn_passing_car_thresh   = 1.5*spawn_on_coming_car_thresh

local pos = {-960,-960/3,960/3,960}
local lane3, lane4, rand

idle_loop = function(_,seconds)
	--increment the dead timer
	if crashed then
		dead_time = dead_time + seconds
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
	
	if mph > 60 and spawn_passing_car_timer > spawn_passing_car_thresh then
		
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
	if spawn_on_coming_car_timer > spawn_on_coming_car_thresh then
		spawn_on_coming_car_timer = 0
		table.insert(other_cars,make_car(road.newest_segment,end_point,pos[math.random(1,2)]))
		world.cars:add(other_cars[#other_cars])
        other_cars[#other_cars]:lower_to_bottom()
	end
	--Move the ground
	
	
	--assert(#path > 0)
	assert(road.curr_segment ~= nil)
	
	--distance covered this iteration
	dy = (speed)*seconds
	dr = curr_path.rot*dy/curr_path.dist --relative to amount travelled
	
	
	
	--speed forward
	mph = car.v_y/pixels_per_mile + curr_accel_rate*throttle_position*seconds--+collision_strength*math.cos(math.pi/180*collision_angle)
	if mph > 200 then mph = 200
	elseif mph > 100 then curr_accel_rate = accel_rates[4]
	elseif mph >  60 then curr_accel_rate = accel_rates[3]
	elseif mph >  60 then curr_accel_rate = accel_rates[3]
	elseif mph >  30 then curr_accel_rate = accel_rates[2]
	elseif mph >   0 then curr_accel_rate = accel_rates[1]
	elseif mph <   0 then mph = 0 end
	
	
	speed = mph*pixels_per_mile
	car.v_y = speed
	mph_txt.text = string.format("%03d",mph)
	points = points + dy/pixels_per_mile
	points_txt.text = string.format("%07d",points)
	
	tail_lights.opacity=0
	if throttle_position > 0.05 then
		throttle_position = throttle_position - .1
	elseif throttle_position < -0.05 then
		throttle_position = throttle_position + .2
		tail_lights.opacity=255
	else
		throttle_position = 0
	end
	
	
	
	--speed sideways
	car.v_x = speed/5*turn_impulse + car.v_x
	
	strafed_dist = strafed_dist + car.v_x*seconds--+collision_strength*math.sin(math.pi/180*collision_angle)
	
	if math.abs(strafed_dist) > 1300 then
		car.v_y = car.v_y - 1500*seconds
		if car.v_y < 800 then
			car.v_y = 800
		end
	end
	if math.abs(car.v_x) > 20 then
		car.v_x = car.v_x/10
	else
		car.v_x = 0
	end
	
	
	--stop moving if crashed
	if crashed and math.abs(car.v_y) > 20 then
		car.v_y = car.v_y/2
	elseif crashed then
		car.v_y = 0
	end
	
	if turn_impulse > 0.005 then
		if turn_impulse > .5 then
			--car.src = "assets/Lambo/01.png"
			car.y_rotation={0,0,0}
		else
			--car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse-.05
	elseif turn_impulse < -0.005 then
		if turn_impulse < -.5 then
			--car.src = "assets/Lambo/01.png"
			car.y_rotation={180,0,0}
		else
			--car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse+.05
	else
		turn_impulse = 0
		--car.src = "assets/Lambo/00.png"
		car.y_rotation={0,0,0}
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
		--table.remove(path,1)
		--assert( #path > 0 )
		road.curr_segment = road.curr_segment.next_segment
		curr_path = road.segments[road.curr_segment]
		--readjust the path center to compensate for rounding error
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
		paused = false
		idle.on_idle = idle_loop