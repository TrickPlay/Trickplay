function Menu:add_hl( hl, addition )

	hl.opacity=255
	hl.anchor_point = {hl.w/2, hl.h/2}
	
	self.hl2 = hl
	
	self.container:add(self.hl2)
	
	self.hl2.extra.x = 1
	self.hl2.extra.y = 1

end

function Menu:controller_directions(object)
	
	local y = object.extra.y
	local x = object.extra.x
	
	object.extra.up = function() -- Up function
		print("Up")
		if object.extra.y > 1 and object.extra.x <= self.max_x[object.extra.y-1] then object.extra.y = object.extra.y - 1 pcall(self:update_cursor_position(object)) end
		print("New Location", object.extra.x, object.extra.y)
	end
		
	object.extra.down = function() -- Down function
		print("Down")
		if object.extra.y < self.max_y_movement[object.extra.x] and object.extra.x <= self.max_x[object.extra.y+1] then object.extra.y = object.extra.y + 1 pcall(self:update_cursor_position(object)) end
		print("New Location", object.extra.x, object.extra.y)
	end

	object.extra.left = function() -- Left function
		print("Left")
		if object.extra.x > 1 then object.extra.x = object.extra.x - 1 pcall(self:update_cursor_position(object)) end
		while object.extra.y > self.max_y_movement[object.extra.x] do object.extra.x = object.extra.x - 1 pcall(self:update_cursor_position(object)) end
		print("New Location", object.extra.x, object.extra.y)
	end
		
	object.extra.right = function() -- Right function
		print("Right")
		if object.extra.x < self.max_x[object.extra.y] then 
			object.extra.x = object.extra.x + 1 pcall(self:update_cursor_position(object))
			while object.extra.y > self.max_y_movement[object.extra.x] do object.extra.x = object.extra.x + 1 pcall(self:update_cursor_position(object)) end
			print("New Location", object.extra.x, object.extra.y)
		end
	end
end




--[[


-- This is a mess, TODO use timeline instead
	if self.wiggle then
		local o = self.anim
		local tempx = self.x
		local tempy = self.y
		if o then o:complete_animation() o.x = o.extra.old[1] o.y = o.extra.old[2] o.z_rotation={0, o.w/2, o.h/2} end
		self.anim = self.button[self.y].children[self.x]
		o = self.anim
		o.extra.old = {o.x, o.y}
		o.extra.animate = function()
			o.z_rotation={o.z_rotation[1],o.w/2, o.h/2}
			o:animate{y=o.extra.old[2]-15, duration=450, mode="EASE_IN_SINE", 
				on_completed = function() 
					print("2nd anim") 
					if tempx == self.x and tempy == self.y then 
						print("same spot") --o.y = o.extra.old[2] + 40
						o:animate{y=o.extra.old[2], duration=450, mode="EASE_OUT_SINE", 
							on_completed = function() 
								if tempx == self.x and tempy == self.y then
									o.extra.animate()
								end  
							end}
					end 
			end} 
		end
		o.extra.animate()
	end --end wiggle
	
	
]]
