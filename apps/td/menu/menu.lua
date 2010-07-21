-- menu object

Menu = {}
Menu.__index = Menu

function Menu.create(container, list, highlight)
   local m_menu = {}
   setmetatable(m_menu,Menu)
   
	-- Default position is 1, 1
	m_menu.x = 1		m_menu.y = 1

	if list[1][1] ~= nil then
		m_menu.max_y = #list
		m_menu.max_x = {}
		for i=1,#list do
			m_menu.max_x[i] = #list[i]
		end
	end

   m_menu.container = container	-- Container holds the buttons and the focus highlight
   m_menu.list = list				-- List used to create the menu 
	m_menu:create_hl(highlight)	-- TODO not sure if I still use this
   m_menu.buttons = Group{}		-- Buttons group
	m_menu:create_key_functions()	-- Create keypress functions

   container:add(m_menu.buttons, m_menu.hl)
   return m_menu
end

function Menu:create_hl(hl)
	if not hl then return end
	self.hl = hl
	self.hl.opacity=0
	self.hl.extra={ loc=1 }
	self.hl.anchor_point = {self.hl.w/2, self.hl.h/2}
end

function Menu:set_opacity(opacity)
	self.container.opacity = opacity
end

-- Create commands for each button press
function Menu:create_key_functions(container)
	if container == nil then container = self.buttons end
	
	--container:grab_key_focus()
	print("Creating key functions")
	print(type(container))

	container.on_key_down = function(container, k)	
		if k == keys.Right and container.extra.right then print("RIGHT") container.extra.right() print("x: ", self.x) self:update_cursor_position()
		elseif k == keys.Left and container.extra.left then print("LEFT") container.extra.left() print("x: ", self.x) self:update_cursor_position()	
		elseif k == keys.Up and container.extra.up then print("UP") container.extra.up() print("y: ", self.y) self:update_cursor_position()	
		elseif k == keys.Down and container.extra.down then print("DOWN") container.extra.down() print("y: ", self.y) self:update_cursor_position()
		elseif k == keys.Return and container.extra.r then print("ENTER") container.extra.r()
		elseif k == keys.space and container.extra.space then print("BACK") container.extra.space() end
		print("CHILD",k)
		return true -- Prevent bubble upward to screen
	end
end

-- Hmm.. might use this?
function Menu:kill_key_functions(container)
	if not container then container = self.buttons end

	container.extra.functions = {container.extra.up, container.extra.down, container.extra.left, container.extra.right, container.extra.space, container.extra.r}
	container.extra.right = nil
	container.extra.left = nil
	container.extra.up = nil
	container.extra.down = nil
	container.extra.space = nil
	container.extra.r = nil
end

function Menu:restore_key_functions(container)
	if not container then container = self.buttons end

	container.extra.right = container.extra.functions[4]
	container.extra.left = container.extra.functions[3]
	container.extra.up = container.extra.functions[1]
	container.extra.down = container.extra.functions[2]
	container.extra.space = container.extra.functions[5]
	container.extra.r = container.extra.functions[6]
end

-- Add directional movement to x and y according to the sizes of the buttons list
function Menu:button_directions()
	container = self.buttons
	
	container.extra.up = function() -- Up function
		if self.y > 1 and self.x <= self.max_x[self.y-1] then self.y = self.y - 1 end 
	end
		
	container.extra.down = function() -- Down function
		if self.y < self.max_y_movement[self.x] and self.x <= self.max_x[self.y+1] then self.y = self.y + 1 end
	end

	container.extra.left = function() -- Left function
		if self.x > 1 then self.x = self.x - 1 end
		while self.y > self.max_y_movement[self.x] do self.y = self.y - 1 end -- x "slide" is enabled	
	end
		
	container.extra.right = function() -- Right function
		if self.x < self.max_x[self.y] then 
			self.x = self.x + 1 
			while self.y > self.max_y_movement[self.x] do self.y = self.y - 1 end	
		end
	end
end

dofile("menu/menu_playerstats.lua")
dofile("menu/menu_photoreel.lua")
dofile("menu/menu_carousel.lua")
dofile("menu/menu_extra.lua")

function Menu:update_cursor_position()
	if self.hl == nil then print("No cursor available") return end
	cursor = self.hl
	
	if self.button == nil then print("No buttons available") end
	cursor.x = self.button[self.y].children[self.x].x + self.button[self.y].children[self.x].w/2
	cursor.y = self.button[self.y].children[self.x].y + self.button[self.y].children[self.x].h/2
	
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

end

function Menu:stop_wiggle()
	local o = self.anim
	o:complete_animation()
	o:complete_animation()
	o.extra.animate = function() end
	o.x = o.extra.old[1] o.y = o.extra.old[2]
end

function Menu:create_buttons(margin, m_font, position)

	if not self.buttons then self.buttons = Group{} end

	self.button = {}
	local list = self.list
	
	for i=1,self.max_y do self.button[i] = Group{} end -- Make a group for each "y" list

	if self.margin then local margin = self.margin end
	if not margin then margin = 0 end

	self.max_y_movement = {}

	for i=1,self.max_y do -- For each y value, create buttons in the x direction	
		for j=1,self.max_x[i] do
		
			-- Leave the first where it is, find the x value for the rest
			if j ~= 1 then
				list[i][j].x = list[i][j].x + list[i][j-1].x + list[1][1].w + margin -- new x value is the current offset, plus the x value of the previous, plus its width
			end
			
			local prev		if i > 1 then prev = list[i-1][j].y else prev = 0 end
			
			-- Leave the first where it is, find the y value for the rest
			if i > 1 then
				list[i][j].y = list[i][j].y + prev + list[1][1].h + margin
				self.button[i]:add( list[i][j] )
			end
			
			if not self.max_y_movement[j] then self.max_y_movement[j] = 0 end
			if list[i][j].name ~= "null" then self.max_y_movement[j] = self.max_y_movement[j] + 1 end
			
			-- Position text on the button, if applicable
			self.text = Group{}
			
			if m_font and list[i][j].name and list[i][j].name ~= "null" then -- ignore if name == "null" 
				list[i][j].extra.text = Text{font = m_font, color = "FFFFFF", text = list[i][j].name}
				
				if position == "left" then
					list[i][j].extra.text.anchor_point = {0, list[i][j].extra.text.h/2}
					list[i][j].extra.text.x = -150
				else
					list[i][j].extra.text.anchor_point = {list[i][j].extra.text.w/2, list[i][j].extra.text.h/2}
					list[i][j].extra.text.x = list[i][j].w/2 + list[i][j].x
				end
				
				list[i][j].extra.text.y = list[i][j].h/2 + list[i][j].y
				
				self.text:add(list[i][j].extra.text)
			end
			
			self.container:add(self.text)
			self.button[i]:add( list[i][j] )
			
		end
		self.buttons:add( self.button[i] )
	end
											
end

function Menu:create_circle(offset, distance)
	
	-- 2 pi divided by number of objects
	local rotation=( 2*math.pi ) / self.max_x[1]
	
	for i=1,self.max_x[1] do
		local obj = self.list[1][i]
		
		i = i - 1
	
		-- Update values
		obj.anchor_point = {obj.w/2,obj.h/2}
		obj.x = offset[2] + distance*math.sin(rotation*i)
		obj.y = offset[1] - distance*math.cos(rotation*i)
		obj.extra.angle = rotation*i
		
		self.container:add(obj)
		
		obj.extra.x = obj.x
		obj.extra.y = obj.y
	end
		
end

function Menu:circle_directions(offset, distance)

	local container = self.buttons

	-- Update positions on left
	container.extra.left = function()
	
		print("Left")
	
		self.x = self.x - 1
		if self.x == 0 then self.x = self.max_x[1] end
		
		local rotation=( 2*math.pi ) / self.max_x[1]
		for i=1,self.max_x[1] do
			local obj = self.list[1][i]
			local new_angle = obj.extra.angle + rotation
			local new_x = offset[2] + distance*math.sin(new_angle)
			local new_y = offset[1] - distance*math.cos(new_angle)
			
			obj:animate{ duration=1000, x=new_x, y=new_y, mode="EASE_OUT_QUAD" }
			obj.extra.angle = new_angle
			
		end
		
	end
	
	-- Update positions on right
	container.extra.right = function()
	
		print("Right")
	
		self.x = self.x + 1
		if self.x > self.max_x[1] then self.x = 1 end
		
		local rotation=( 2*math.pi ) / self.max_x[1]
		for i=1,self.max_x[1] do
			local obj = self.list[1][i]
			local new_angle = obj.extra.angle - rotation
			local new_x = offset[2] + distance*math.sin(new_angle)
			local new_y = offset[1] - distance*math.cos(new_angle)
			
			obj:animate{ duration=1000, x=new_x, y=new_y, mode="EASE_OUT_QUAD" }
			obj.extra.angle = new_angle
			
		end
		
	end

end
