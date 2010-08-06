-- menu object

Menu = {}
Menu.__index = Menu

function Menu.create(container, list, highlight)
        local menu = {}
        setmetatable(menu,Menu)
        
                -- Default position is 1, 1
                menu.x = 1		menu.y = 1
        
                if list[1][1] ~= nil then
                        menu.max_y = #list
                        menu.max_x = {}
                        for i=1,#list do
                                menu.max_x[i] = #list[i]
                        end
                end
     
        menu.container = container	-- Container holds the buttons and the focus highlight
        menu.list = list				-- List used to create the menu 
             
        menu.buttons = Group{}		-- Buttons group
             menu:create_key_functions()	-- Create keypress functions
     
        container:add(menu.buttons)
        
        menu:create_hl(highlight)	-- TODO not sure if I still use this
        
        return menu
end

function Menu:new(args)

        -- The only necessary thing is a list
        if not args then
                print("No empty menus!")
                debug()
                return
        elseif not args.list then
                print("Need buttons in a list")
                debug()
                return
        end

        -- Create the menu object
        local menu = {
                x = 1,
                y = 1,
                list = args.list,
                container = args.container or Group{},
                buttons = Group{},
                hl = args.hl or nil
        }
        
        setmetatable(menu, Menu)
        
        menu.container:add(menu.buttons)
                
        -- Add the focus, if there is one
        if menu.hl then
                menu.hl.opacity=255
                menu.hl.anchor_point = {menu.hl.w/2, menu.hl.h/2}
                menu.container:add(menu.hl)
        end
                
        -- Make the x and y map of the button list
        local list = menu.list
        if list[1][1] ~= nil then
                
                menu.max_y = #list
                menu.max_x = {}
                for i=1,#list do
                        menu.max_x[i] = #list[i]
                end
        end
        
        -- Create button press functions
        menu:create_key_functions()
                
        return menu
end

function Menu:create_hl(hl)
	if not hl then return end
	self.hl = hl
	self.hl.opacity=255
	--self.hl.extra={ loc=1 }
	self.hl.anchor_point = {self.hl.w/2, self.hl.h/2}
        self.container:add(self.hl)
end

function Menu:set_opacity(opacity)
	self.container.opacity = opacity
end

-- Create commands for each button press
function Menu:create_key_functions(container)

        -- Defaults to buttons
	if container == nil then container = self.buttons end
	
        -- On key down function
	container.on_key_down = function(container, k)	
		
                pcall ( self.actions[k], container )
                
		return true -- Prevent bubble upward to screen
	end
        
        -- This is what the on key down function does
        self.actions = {}
        self.actions[keys.Right] = function() pcall ( container.extra.right ) if self.debug then print("Right", "-", "x:", self.x) end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.Left] = function() pcall ( container.extra.left ) if self.debug then print("Left", "-", "x:", self.x) end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.Up] = function() pcall ( container.extra.up ) if self.debug then print("Up", "-", "y:", self.y) end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.Down] = function() pcall ( container.extra.down ) if self.debug then print("Down", "-", "y:", self.y) end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.space] = function() pcall ( container.extra.space ) if self.debug then print("Space") end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.Return] = function() pcall ( container.extra.r ) if self.debug then print("Return/Enter") end pcall ( self.update_cursor_position, self ) end
        self.actions[keys.p] = function() pcall ( container.extra.p ) if self.debug then print("You pressed: p") end pcall ( self.update_cursor_position, self ) end
        
end

function Menu:pass_focus_to_controller( controller )

	assert(controller, "There is no controller")
	
	if container.extra.right then keyboardRight = container.extra.right end
	if container.extra.left then keyboardLeft = container.extra.left end
	if container.extra.up then keyboardUp = container.extra.up end
	if container.extra.down then keyboardDown = container.extra.down end
	if container.extra.r then keyboardReturn = container.extra.r end
	if container.extra.space then keyboardSpace = container.extra.space end
	if container.extra.p then keyboardp = container.extra.p end

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
	local container = self.buttons
	
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
dofile("menu/menu_controller.lua")

function Menu:update_cursor_position(obj)
	if not self.hl and not obj then if self.debug then print("No cursor available") end return end
	local cursor = obj or self.hl
	
	local x = self.x
	local y = self.y
	
	--print("Updated!")
	--if obj then print(obj.x, obj.y) end
	
	if obj then x = obj.extra.x y = obj.extra.y end
	
	if not self.button then print("No buttons available") end
	cursor.x = self.button[y].children[x].x + self.button[y].children[x].w/2
	cursor.y = self.button[y].children[x].y + self.button[y].children[x].h/2

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
				--self.button[i]:add( list[i][j] ) -- Don't think this is ever needed... and it makes tons of clutter warnings
			end
			
			if not self.max_y_movement[j] then self.max_y_movement[j] = 0 end
			if list[i][j].name ~= "null" then self.max_y_movement[j] = self.max_y_movement[j] + 1 end
			
			-- Position text on the button, if applicable
			self.text = Group{}
			
			if m_font and list[i][j].name and list[i][j].name ~= "null" then -- ignore if name == "null" 
				list[i][j].extra.text = Text{font = m_font, color = "000000", text = list[i][j].name}
				
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
                obj.z_rotation = {360/self.max_x[1] *i, 0, 0}
		
		self.container:add(obj)
		
		obj.extra.x = obj.x
		obj.extra.y = obj.y
                
                self.container.z_rotation = {0, offset[2], offset[1]}
                self.container.extra.angle = 0

	end
		
end

function Menu:circle_directions(offset, distance)

	local container = self.buttons

	-- Update positions on right
	container.extra.right = function()
            print("Left")
	    self.x = self.x - 1
	    if self.x == 0 then self.x = self.max_x[1] end
	    self.container.extra.angle = self.container.extra.angle + 360/self.max_x[1]
	end
	
	-- Update positions on left
	container.extra.left = function()
	    print("Right")
	    self.x = self.x + 1
	    if self.x > self.max_x[1] then self.x = 1 end
	    self.container.extra.angle = self.container.extra.angle - 360/self.max_x[1]
	end

end

function appendFunction(first, second)

        return function() first() second() end

end
