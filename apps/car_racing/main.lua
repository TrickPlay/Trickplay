
screen:show()
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()

path={}
local dist_into_path = 0
local rot_into_path = 0

dofile( "Sections.lua" )
dofile(    "Level.lua" )


local keys = {
	[keys.Up] = function()
		world:move(100)
	end,
	[keys.Down] = function()
		world:move(-100)
	end,
	[keys.Left] = function()
		
		world:rotate_by(-5)
	end,
	[keys.Right] = function()
		world:rotate_by(5)
	end,
	[keys.q] = function()
		print("curve added")
		table.insert(
            sections,
            make_curved_section()
        )
	end,
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end

local dx = 0
local dr = 0
local speed = 2000
function idle:on_idle(seconds)
	
	assert(#path > 0)
	
	dx = speed*seconds
	dr = path[1].rot*dx/path[1].dist
	
	dist_into_path = dist_into_path + dx
	
	rot_into_path = rot_into_path + dr
	
	if rot_into_path > path[1].rot or
	   path[1].rot == 0 and dist_into_path > path[1].dist then
		
		--old section path
		dx = dist_into_path-path[1].dist
		dr = path[1].rot - (rot_into_path - dr)
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius/2)
		
		dist_into_path = dist_into_path - path[1].dist
		table.remove(path,1)
		print("\n\n",rot_into_path)
		rot_into_path=0
		assert(#path > 0 )
		
		--new section path
		dx = speed*seconds - dx
		dr = path[1].rot*dx/path[1].dist
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius/2)
		
		
	else
		--world:rotate_by(dr)
		world:move(dx,dr,path[1].radius/2)
	end
	
end