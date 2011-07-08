--World Object
local World = {}


local old_walls = {}

local wall

local wall_properties = {
	type = "static" ,
	bounce = 0,
	density = 1,
}

local real_max_dist = 590

local curr_max_dist = screen_h/5

local next_branch_y = screen_h/2

local active_walls = {}

local new_wall = function(side,y)
	
	wall = physics:Body(
		
		Group{ name = "wall", size = { 100 , screen_h }, },
		
		wall_properties
	)
		
	function wall:recycle()
		
		for _,b in pairs(self.branches) do      b:recycle()      end
		
		self.branches = {}
		
		self:unparent()
		
		table.insert(old_walls,self)
		
	end
	
	local y
	
	function wall:scroll_by(dy)
		
		y = self.y + dy
		
		if y > screen_h*2 then
			
			self:recycle()
			
			return false
			
		else
			
			self.y = y
			
			for _,b in pairs(self.branches) do      b:scroll_by(dy)      end
			
			return true
			
		end
		
	end
	
	return wall
	
end



function World:scroll_by(dy)
	
	for w,_ in pairs(active_walls) do
		
		if not w:scroll_by(dy) then
			
			active_walls[w] = nil
			
		end
		
	end
	
end


---[[
local backing = Clone{ source = assets.ground }
local floor = physics:Body(
    Group{
		name = "floor",
		size = { screen.w , 100 } ,
	} ,
    {
		type = "static" ,
		bounce = 0,
		density = 1,
		--friction = 1
	}
)
floor.position = {screen.w/2,screen.h+floor.h/2}
floor.on_begin_contact = panda.bounce

function floor:scroll_by(dy)
	
	
	y = self.y + dy
	
	if y > screen_h*2 then
		
		self:unparent()
		
		backing:unparent()
		
		return false
		
	else
		
		self.y = y
		backing.y = backing.y + dy
		
		return true
		
	end
	
end

--]]


local l_wall, r_wall, wall, side

local last_sides = 0

function World:add_first_walls(y)
	
	self:add_next_walls(y)
	
	active_walls[floor] = floor
	panda:position(1500,700)
	screen:add(floor,backing)
	backing.y = screen_h - backing.h
end
function World:add_next_walls(y)
	
	l_wall = table.remove(old_walls) or new_wall(-1,y)
	r_wall = table.remove(old_walls) or new_wall(1,y)
	
	l_wall.position = {
		-l_wall.w/2,
		screen_h/2+y
	}
	
	r_wall.position = {
		screen_w+r_wall.w/2,
		screen_h/2+y
	}
	
	l_wall.branches = {}
	r_wall.branches = {}
		
	--print("new wall")
	while next_branch_y > 0 do
		
		--print(next_branch_y,wall.y)
		side = 3-2*math.random(1,2)
		
		
		if     last_sides == -2 and side == -1 then side =  1
		elseif last_sides ==  2 and side ==  1 then side = -1 end
		last_sides = last_sides + side
		
		
		if side == -1 then wall = l_wall
		elseif side == 1 then wall = r_wall
		else error("invalid side") end
		
		
		table.insert(
			
			wall.branches,
			
			branch_constructor(
				side,
				next_branch_y,
				wall
			)
			
		)
		
		next_branch_y = next_branch_y - math.random(curr_max_dist-100,curr_max_dist)
		
		--print(curr_max_dist)
		
		if curr_max_dist < real_max_dist then
			curr_max_dist = curr_max_dist + 10
		end
		print(curr_max_dist)
	end
	
	next_branch_y = next_branch_y % wall.h
	
	active_walls[l_wall] = l_wall
	active_walls[r_wall] = r_wall
	
	screen:add(l_wall)
	screen:add(r_wall)
		
end






return World