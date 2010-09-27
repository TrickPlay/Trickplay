--menu photoreel

-- Create the photo reel
function Menu:create_photo_reel(m_x, m_y)
	
	-- Create the photo objects, set them to load async
	for i=1,#self.list do
		local obj = self.list[i][1]
		obj.anchor_point = {obj.w/2, obj.h/2}
		obj.x = m_x
		obj.y = m_y	
		self.container:add(obj)
		obj.async = true
	end
	
	-- Set pointers to the first and last photo
	self.first = self.list[1][1]
	self.last = self.list[#self.list][1]
	
	-- Calculate positions, start the nav at the center
	self.y = 3
	local start = self.list[1][1].y
	local h = self.list[1][1].h
	
	for i=1,self.max_y do
		local obj = self.list[i][1]
		obj.y = start + ( i-3 )*h
		obj.extra.y=obj.y
		obj.extra.id = i
	end
		
end

-- Load the first 5 photos
function Menu:initialize_photos(matchId)

	self.photo_array = globals.everything[matchId].matchPhotos

	for i=1,#self.list do
		local obj = self.list[i][1]
		obj.src=self.photo_array[i]
		obj.on_loaded = function() obj.opacity=255 end
	end

end

function Menu:photo_directions()

	container = self.buttons

	-- Set the reel to loop
	self.p = #self.photo_array
	self.n = self.max_y + 1

	-- Animate the downward shift
	-- If the photo is on the bottom, then move it to the top of the screen
	container.extra.shiftdown = function()
		for i=1, self.max_y do
			local obj = self.list[i][1]
			if i == 1 then i = 6 end
			obj:complete_animation()
			obj.extra.new_y = self.list[i-1][1].extra.y
			if obj.extra.new_y < -100 or obj.extra.new_y > 700 then obj.opacity = 0 else obj.opacity=255 end
			obj:animate{ y = obj.extra.new_y, duration=500, mode="EASE_OUT_QUAD" }
			obj.extra.id = obj.extra.id-1
			if obj.extra.id == 0 then obj.extra.id=5 self.last=obj end
		end
		
		for i=1, self.max_y do
			local obj = self.list[i][1]
			obj.extra.y = obj.extra.new_y		
		end
		
	end
	
	-- Animate the upward shift
	-- If the photo is on the top, then move it to the bottom of the screen
	container.extra.shiftup = function()
		for i=1, self.max_y do
			local obj = self.list[i][1]
			if i == 5 then i = 0 end
			obj:complete_animation()
			obj.extra.new_y = self.list[i+1][1].extra.y
			if obj.extra.new_y < -100 or obj.extra.new_y > 700 then obj.opacity = 0 else obj.opacity=255 end
			obj:animate{ y = obj.extra.new_y, duration=500, mode="EASE_OUT_QUAD" }
			obj.extra.id = obj.extra.id+1
			if obj.extra.id == 6 then obj.extra.id=1 self.first=obj end		
		end
		
		for i=1, self.max_y do
			local obj = self.list[i][1]
			obj.extra.y = obj.extra.new_y		
		end
	end

	-- Up function
	container.extra.up = function()
		if self.first.loaded == true then
			self.y = self.y - 1 
			if self.y == 0 then self.y = self.max_y end
			print("Child y: ", self.y)
			
			container.extra.shiftup()
			
			-- Swap out the photos
			local obj = self.first
			obj.src=self.photo_array[self.p]
			self.n = self.n - 1 if self.n == 0 then self.n = #self.photo_array end
			self.p = self.p - 1 if self.p == 0 then self.p = #self.photo_array end
			obj.opacity = 0
				
		end
	end
	
	-- Down function
	container.extra.down = function()
		
		if self.last.loaded == true then
			self.y = self.y + 1 
			if self.y > self.max_y then self.y = 1 end
			print("Child y: ", self.y)
			
			container.extra.shiftdown()
			
			-- Swap out the photos
			local obj = self.last
			obj.src=self.photo_array[self.n]
			self.n = self.n + 1 if self.n > #self.photo_array then self.n = 1 end
			self.p = self.p + 1 if self.p > #self.photo_array then self.p = 1 end
			obj.opacity = 0
			
		end
	end

end
