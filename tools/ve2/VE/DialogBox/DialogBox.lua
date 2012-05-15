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
	
	--the default w and h does not count as setting the size
	if not size_is_set then instance:reset_size_flag() end
	
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
		
		flag_for_redraw = false
		
		canvas = true
		
		if bg then bg:unparent() end
		
		bg = default_bg(instance)
		
		instance:add( bg )
		
		bg:lower_to_bottom()
		
		return true
		
	end
	
	local function setup_image(v)
		
		canvas = false
		
		bg = v
		
		if bg then bg:unparent() end
		
		instance:add( bg )
		
		bg:lower_to_bottom()
		
		if instance.is_size_set() then
			
			resize_image()
			
		else
			--so that the label centers properly
			instance.size = bg.size
			
			instance:reset_size_flag()
			
			center_title()
			
		end
		
		return true
		
	end
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
    
	override_property(instance,"widget_type",
		function() return "DialogBox" end, nil
	)
    
	override_property(instance,"image",
		
		function(oldf)    return image   end,
		
		function(oldf,self,v)
			
			if type(v) == "string" then
				
				if image == nil or image.src ~= v then
					
					setup_image(Image{ src = v })
					
				end
				
			elseif type(v) == "userdata" and v.__types__.actor then
				
				if v ~= image then
					
					setup_image(v)
					
				end
				
			elseif v == nil then
				
				if not canvas then
					
					flag_for_redraw = true
					
					return
					
				end
				
			else
				
				error("DialogBox.image expected type 'table'. Received "..type(v),2)
				
			end
			
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
			
			if canvas then flag_for_redraw = false end
			
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
	
    ----------------------------------------------------------------------------
    ---[=[
    local widget_to_json = instance.to_json
	
    
	instance.to_json = function(_,t)
		
		t.title = instance.title
		t.separator_y = instance.separator_y
		t.title = instance.title
		
		if (not canvas) and bg.src and bg.src ~= "[canvas]" then 
            
            t.image = bg.src
			
		end
		
        --[[
        if content and content.to_json then
            
            t.children = 
            
        end
        --]]
        
		t.type = t.type or "DialogBox"
		
		return t
		
	end
	
    ----------------------------------------------------------------------------
	
    local to_json__overridden
	
    local to_json = function(_,t)
        
        t = is_table_or_nil("DialogBox.to_json",t)
        t = to_json__overridden and to_json__overridden(_,t) or t
        
        --t = widget_to_json(_,t)
        
        return widget_to_json(_,t)
    end
	
	override_property(instance,"to_json",
		function() return to_json end,
		function(oldf,self,v) to_json__overridden = v end
	)
    --]=]
    ----------------------------------------------------------------------------
	
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
		flag_for_redraw = true
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	
	instance:add(title)
	
	instance:set(parameters)
	
	return instance
end