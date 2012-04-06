DIALOGBOX = true

local function default_bg(self)
	
	
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors.default )     c:fill(true)
	
	c:move_to(       c.line_width/2, self.separator_y or 0 )
	c:line_to( c.w - c.line_width/2, self.separator_y or 0 )
	
	c:set_source_color( self.style.border.colors.default )   c:stroke(true)
	
	return c:Image()
	
end

local default_parameters = {
	w = 400, h = 300, title = "DialogBox", separator_y = 50, reactive = true
}

DialogBox = function(parameters)
	
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("DialogBox",parameters)
	
	--flags
	local canvas          = type(parameters.images) == "nil"
	local flag_for_redraw = false --ensure at most one canvas redraw from Button:set()
	local from_set        = false --indicates that an attribute is being set in Button:set()
	local size_is_set = -- an ugly flag that is used to determine if the user set the Button size themselves yet
		parameters.h or
		parameters.w or
		parameters.height or
		parameters.width or
		parameters.size
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = Widget( parameters )
	
	local title = Text()
	
	local bg
	
	----------------------------------------------------------------------------
	-- private helper functions for common actions
	
	local function resize_images()
		
		if not size_is_set then return end
		
		bg.w = instance.w
		bg.h = instance.h
		
	end
	
	local center_title = function()
		
		title.w = instance.w
		title.y = instance.style.text.y_offset + title.h/2
		
	end
	
	----------------------------------------------------------------------------
	
	local function make_canvas()
		
		if from_set then
			
			flag_for_redraw = true
			
			return
			
		end
		
		flag_for_redraw = false
		
		canvas = true
		
		bg = default_bg(instance)
		
		instance:add( bg )
		
		bg:lower_to_bottom()
		
		return true
		
	end
	
	local function setup_image(v)
		
		canvas = false
		
		bg = v
		
		instance:add( bg )
		
		bg:lower_to_bottom()
		
		if instance.is_size_set() then
			
			resize_image()
			
		else
			--so that the label centers properly
			instance.size = images.default.size
			
			instance:reset_size_flag()
			
			center_title()
			
		end
		
		return true
		
	end
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"image",
		
		function(oldf)    return bg   end,
		
		function(oldf,self,v)
			
			if bg then bg:unparent() end
			
			return v == nil and make_canvas() or
				
				type(v) == "userdata" and setup_image(v) or
				
				error("Button.images expected type 'table'. Received "..type(v),2)
			
		end
	)
	
	override_property(instance,"title",
		function(oldf) return title.text     end,
		function(oldf,self,v) title.text = v end
	)
	
	local separator_y = parameters.separator_y
	
	override_property(instance,"separator_y",
		function(oldf) return separator_y     end,
		function(oldf,self,v)
			
			separator_y = v
			
			return canvas and make_canvas()
		end
	)
	
	override_property(instance,"content",
		function(oldf) return content     end,
		function(oldf,self,v)
			
			instance:clear()
			
			instance:add(bg)
			
			if type(v) == "table" then
				
				instance:add(unpack(content))
				
			elseif type(v) == "userdata" then
				
				instance:add(content)
				
			end
			
			instance:add(label)
			
		end
	)
	
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			
			flag_for_redraw = true
			
			center_title()
			
		end
	)
	instance:subscribe_to(
		nil,
		function()
			
			if flag_for_redraw then
				flag_for_redraw = false
				if canvas then
					make_canvas()
				else
					resize_images()
				end
			end
			
		end
	)
	local text_style
	local update_title  = function()
		
		text_style = instance.style.text
		
		title:set(   text_style:get_table()   )
		
		title.anchor_point = {0,title.h/2}
		title.x            = text_style.x_offset
		title.y            = text_style.y_offset + title.h/2
		title.w            = instance.w
		
	end
	
	local canvas_callback = function() if canvas then make_canvas() end end
	
	function instance_on_style_changed()
		
		instance.style.text:on_changed(instance,update_title)
		
		instance.style.fill_colors:on_changed(    instance, canvas_callback )
		instance.style.border:on_changed(         instance, canvas_callback )
		instance.style.border.colors:on_changed(  instance, canvas_callback )
		
		update_title()
		canvas_callback()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	
	
	
	instance:add(title)
	
	instance:set(parameters)
	
	return instance
end