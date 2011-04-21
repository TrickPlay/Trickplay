
pixels_per_mile = 45
paused = true
local idle_loop
screen:show()
screen_w = screen.w
screen_h = screen.h
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
strafed_dist = 0
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
local speed = 0
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
		accel = accel + .2
		if accel > 1 then accel = 1 end
		
	end,
	[keys.Down] = function()
		accel = -2
		
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
		local lane_one = -600
		table.insert(other_cars,make_on_coming_impreza(road.newest_segment,end_point,lane_one))
		world.cars:add(other_cars[#other_cars])
		ccc = other_cars[#other_cars]
	end
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end

local curr_path = road.segments[road.curr_segment]

local dy = 0
local dr = 0

local dy_remaining_in_path = curr_path.dist
local dr_remaining_in_path = curr_path.rot

idle_loop = function(_,seconds)
	for i = #other_cars,1,-1 do
		if other_cars[i]:move(seconds) then
			table.remove(other_cars,i)
			print("del")
		end
	end
	
	--assert(#path > 0)
	assert(road.curr_segment ~= nil)
	
	--distance covered this iteration
	dy = (speed)*seconds
	dr = curr_path.rot*dy/curr_path.dist --relative to amount travelled
	
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
	
	
	
	
	mph = mph + accel+collision_strength*math.cos(math.pi/180*collision)
	if mph > 200 then mph = 200
	elseif mph < 0 then mph = 0 end
	
	speed = mph*pixels_per_mile
	mph_txt.text = math.floor(mph)
	mph_txt.anchor_point={mph_txt.w+50,mph_txt.h+50}
	mph_sh.text = math.floor(mph)
	mph_sh.anchor_point={mph_sh.w+50,mph_sh.h+50}
	tail_lights.opacity=0
	if accel > 0.05 then
		accel = accel - .1
	elseif accel < -0.05 then
		accel = accel + .2
		tail_lights.opacity=255
	else
		accel = 0
	end
	
	strafed_dist = strafed_dist + speed/100*turn_impulse+
		collision_strength*math.sin(math.pi/180*collision)
	
	if turn_impulse > 0.005 then
		if turn_impulse > .5 then
			car.src = "assets/Lambo/01.png"
			car.y_rotation={0,0,0}
		else
			car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse-.05
	elseif turn_impulse < -0.005 then
		if turn_impulse < -.5 then
			car.src = "assets/Lambo/01.png"
			car.y_rotation={180,0,0}
		else
			car.src = "assets/Lambo/00.png"
			car.y_rotation={0,0,0}
		end
		turn_impulse = turn_impulse+.05
	else
		turn_impulse = 0
		car.src = "assets/Lambo/00.png"
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
		
		--[[
		if curr_path.rot > 0 then
			car.src = "assets/Lambo/1.png"
			car.anchor_point = {2*car.w/5,car.h/2}
			car.y_rotation={0,0,0}
		elseif curr_path.rot < 0 then
			car.src = "assets/Lambo/1.png"
			car.anchor_point = {2*car.w/5,car.h/2}
			car.y_rotation={180,0,0}
		else
			car.src = "assets/Lambo/0.png"
			car.anchor_point = {car.w/2,car.h/2}
		end
		--]]
		
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