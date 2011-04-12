local paused = true--false
local idle_loop
screen:show()
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
strafed_dist = 0
local STRAFE_CAP = 550

path={}
local dist_into_path = 0
local rot_into_path = 0

dofile( "Sections.lua" )
dofile(    "Level.lua" )

local dx = 0
local dr = 0
local speed = 2000

local keys = {
	[keys.Up] = function()
		speed = speed + 1000
	end,
	[keys.Down] = function()
		speed = speed - 1000
	end,
	[keys.Left] = function()
		--world:rotate_by(-5)
		if strafed_dist > -STRAFE_CAP then
			strafed_dist = strafed_dist - 50
		end
	end,
	[keys.Right] = function()
		--world:rotate_by(5)
		if strafed_dist < STRAFE_CAP then
			strafed_dist = strafed_dist + 50
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
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end
--[[]]

idle_loop = function(_,seconds)
	
	assert(#path > 0)
	
	dx = speed*seconds
	dr = path[1].rot*dx/path[1].dist
	
	dist_into_path = dist_into_path + dx
	
	rot_into_path = rot_into_path + dr
	--print(rot_into_path,dr)
	if math.abs(rot_into_path) > math.abs(path[1].rot) or
	   path[1].rot == 0 and dist_into_path > path[1].dist then
		
		--old section path
		dx = dist_into_path-path[1].dist
		dr = path[1].rot - (rot_into_path - dr)
		--print(dr)
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius)
		
		dist_into_path = dist_into_path - path[1].dist
		table.remove(path,1)
		--print("\n\n",rot_into_path)
		rot_into_path=0
		assert(#path > 0 )
		
		world:normalize_to(path[1].parent.group)
		
		--new section path
		dx = speed*seconds - dx
		dr = path[1].rot*dx/path[1].dist
		rot_into_path = rot_into_path + dr
		dist_into_path = dist_into_path + dx
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius)
		
		
	else
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius)
	end
end

--idle.on_idle = idle_loop