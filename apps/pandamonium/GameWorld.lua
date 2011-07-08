local old_walls = {}
local wall
local wall_properties = {
	type = "static" ,
	bounce = 0,
	density = 1,
}
local make_wall = function(side,y)
	
	wall = table.remove(old_walls)
	
	if wall == nil then
		
		wall = physics:Body(
			Rectangle{
				name = "wall",
				size = { 100 , screen_h } ,
				color = "404040",
			} ,
			wall_properties
		)
		
		wall.branches = {}
		
		function wall:recycle()
			
			for _,b in pairs(self.branches) do
				
				b:recycle()
				
			end
			
			self.branches = {}
			
			self:unparent()
			
			table.insert(old_walls,self)
			
		end
		
		local y
		
		function wall:scroll_by(dy)
			
			y = self.y + dy
			
			
			if y > screen_h*3/2 then
				print("recycle wall:",self)
				self:recycle()
				
				return false
				
			else
				
				self.y = y
				
				for _,b in pairs(self.branches) do
					
					b.y = b.y + dy
					
					for _,p in pairs(b.palms) do
						
						p.y = p.y + dy
						
					end
					
				end
				
				return true
				
			end
		end
	end
	
	wall.position = {
		screen_w/2+side*(screen_w/2+wall.w/2),
		screen_h/2+y
	}
	
	screen:add(wall)
	
	for i = 1, 2 do
		local y = math.random(0,wall.h/2)+wall.h/2*(i-1)
		wall.branches[i] = branch_constructor(
			side,
			y,
			wall
		)
		
	end
	
	return wall
end

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




screen:add(floor)

return make_wall