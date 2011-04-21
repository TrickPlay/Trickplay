--print = function() end
crashed = false
num_passing_cars = 0
math.randomseed(os.time())
end_game = Text{text="YOU CRASHED",font="Sans 60px",x=600,y=500,color="ffffff"}
screen:add(end_game)
pixels_per_mile = 45
paused = false
local idle_loop
screen:show()
screen_w = screen.w
screen_h = screen.h
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
strafed_dist = 1400
local STRAFE_CAP =2000
local hud = Group{}
local mph_txt = Text{text="000",font="Sans 60px",color="ffffff",x=screen_w,y=screen_h}
local mph_sh  = Text{text="000",font="Sans 60px",color="000000",x=screen_w+5,y=screen_h+5}
mph_txt.anchor_point={mph_txt.w+50,mph_txt.h+50}
mph_sh.anchor_point ={mph_sh.w+50, mph_sh.h+50}
hud:add(mph_txt)
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
screen:add(hud)
speed = 0
throttle_position = 0
 accel = 0
 mph = 0
turn_impulse = 0
curve_impulse = 0
collision_strength = 0
collision_angle = 0
ccc = nil
dofile("controller.lua")
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
	
	if not crashed then
		if keys[k] then keys[k]() end
	else
		print("fff")
	end
end

local curr_path = road.segments[road.curr_segment]

local dy = 0
local dr = 0

local dy_remaining_in_path = curr_path.dist
local dr_remaining_in_path = curr_path.rot

local accel_rates = {
	30/1.71,
	60/4.13,
	100/9.02,
	200/24,
}
local curr_accel_rate = accel_rates[1]
local braking_rate = 100/4.32
local damping_effect = 1000

idle_loop = function(_,seconds)
	for i = #other_cars,1,-1 do
		if other_cars[i]:move(seconds) then
			table.remove(other_cars,i)
			print("del")
		end
	end
	

	
	--[[
	if dr< 0 then
		turn_impulse = turn_impulse + 2*dr
		if turn_impulse > 1 then turn_impulse = 1 end
	elseif dr > 0 then
		turn_impulse = turn_impulse - .05
		if turn_impulse < -1 then turn_impulse = -1 end
	else
	end
	--]]
	
	
	
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
	mph_txt.text = math.floor(mph)
	mph_txt.anchor_point={mph_txt.w+50,mph_txt.h+50}
	mph_sh.text = math.floor(mph)
	mph_sh.anchor_point={mph_sh.w+50,mph_sh.h+50}
	
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
	
	
	
	
	--Move the ground
	
	
	--assert(#path > 0)
	assert(road.curr_segment ~= nil)
	
	--distance covered this iteration
	dy = (speed)*seconds
	dr = curr_path.rot*dy/curr_path.dist --relative to amount travelled
	
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

idle.on_idle = idle_loop