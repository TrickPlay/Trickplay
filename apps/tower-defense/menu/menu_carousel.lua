--menu carousel

-- This will create a circular carousel effect based on the number of objects
function Menu:create_carousel()
	
	-- 2 pi divided by number of objects
	local rotation=( 2*math.pi ) / self.max_x[1]
	
	for i=1,self.max_x[1] do
		local obj = self.list[1][i]
		-- Store old position, just incase
		obj.extra.x = obj.x
		obj.extra.y = obj.y
	
		-- Update values
		obj.anchor_point = {obj.w/2,obj.h/2}
		obj.x = screen.w/2 + 500*math.sin(rotation*i)
		obj.z = 200*math.cos(rotation*i)
		obj.y = screen.h/2 - 50 + 120*math.cos(rotation*i)
		obj.extra.angle = rotation*i
		obj.opacity = 80 + 175*math.cos(rotation*i)
		
		obj.x = obj.x + obj.extra.x
		obj.y = obj.y + obj.extra.y
		
		self.container:add(obj)
	end
		
end

-- Use this to activate a carousel on the first table within a list
function Menu:carousel_directions()

	container = self.buttons

	function grab_child_functions()
	
		local real_x = self.x - 1
		if real_x == 0 then real_x = self.max_x[1] end
		print("Real x: ", real_x)
		
		-- Grab specific window functions
		if self.list[1][real_x].children ~= nil then
			
			local grab = self.list[1][real_x]:find_child("buttons")

			print("Grabbed functions from child")
			
			if grab then
				self.buttons.extra.up = function() print("doing up") if grab.extra.up then grab.extra.up() end end
				self.buttons.extra.down = function()  print("doing down") if grab.extra.down then grab.extra.down() end end
			else
				self.buttons.extra.up = nil
				self.buttons.extra.down = nil
			end
			
		end
	
	end

	-- Update positions on left
	container.extra.left = function()
	
		self.x = self.x - 1
		if self.x == 0 then self.x = self.max_x[1] end
		
		local rotation=( 2*math.pi ) / self.max_x[1]
		for i=1,self.max_x[1] do
			local obj = self.list[1][i]
			local new_angle = obj.extra.angle + rotation
			local new_x = screen.w/2 + 500*math.sin(new_angle)
			local new_y = screen.h/2 + 30 + 30*math.cos(new_angle)
			local new_z = 200*math.cos(new_angle)
			local new_o = 80 + 175*math.cos(new_angle)
			
			obj:animate{ duration=1000, x=new_x, y=new_y, z=new_z, opacity=new_o, mode="EASE_OUT_QUAD" }
			obj.extra.angle = new_angle
			
		end
		
		grab_child_functions()
		
	end
	
	-- Update positions on right
	container.extra.right = function()
		self.x = self.x + 1
		if self.x > self.max_x[1] then self.x = 1 end
		
		local rotation=( 2*math.pi ) / self.max_x[1]
		for i=1,self.max_x[1] do
			local obj = self.list[1][i]
			local new_angle = obj.extra.angle - rotation
			local new_x = screen.w/2 + 500*math.sin(new_angle)
			local new_y = screen.h/2 + 30 + 30*math.cos(new_angle) --screen.h/2 - 50 + 120*math.cos(new_angle)
			local new_z = 200*math.cos(new_angle)
			local new_o = 80 + 175*math.cos(new_angle)
			
			obj:animate{ duration=1000, x=new_x, y=new_y, z=new_z, opacity=new_o, mode="EASE_OUT_QUAD" }
			obj.extra.angle = new_angle
			
		end
		
		grab_child_functions()
		
	end

end
