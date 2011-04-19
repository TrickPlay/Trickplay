local paused = true--false
local idle_loop
screen:show()
screen_w = screen.w
screen_h = screen.h
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
strafed_dist = 0
local STRAFE_CAP =2000

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

local speed = 2000


local keys = {
	[keys.Up] = function()
		speed = speed + 1000
	end,
	[keys.Down] = function()
		speed = speed - 1000
	end,
	[keys.Left] = function()
		if strafed_dist > -STRAFE_CAP then
			strafed_dist = strafed_dist - 100
		end
	end,
	[keys.Right] = function()
		if strafed_dist < STRAFE_CAP then
			strafed_dist = strafed_dist + 100
		end
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
	end
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end

local curr_path = road.segments[road.curr_segment]

local dx = 0
local dr = 0

local dx_remaining_in_path = curr_path.dist
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
	dx = speed*seconds
	dr = curr_path.rot*dx/curr_path.dist --relative to amount travelled
	
	
	--while the amount of distance covered in this iteration extends
	--to the end of the current path segment...
	while dx_remaining_in_path < dx do
		--move by whatever distance is left in the current path segment
		world:move(
			dx_remaining_in_path,
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
		dx = dx - dx_remaining_in_path
		dr = curr_path.rot*dx/curr_path.dist
		
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
		dx_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
		
	end
	
	--move by the incremental amount
	world:move(dx,dr,curr_path.radius)
	
	--decrement the remaining by the amount travelled
	dx_remaining_in_path = dx_remaining_in_path - dx
	dr_remaining_in_path = dr_remaining_in_path - dr
end

--idle.on_idle = idle_loop