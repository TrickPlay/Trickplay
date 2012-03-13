
local states = {"default","focus","selection","activation"}

local make_x = function(color,x,h,w,h)
    
    local c = Canvas(w,h)
    
	c.line_width = border_w
    
    c:move_to(x,y)
    c:line_to(w,h)
    
    c:move_to(x,h)
    c:line_to(w,y)
    
	c:set_source_color( color )
    
	c:stroke(true)
    
    return c:Image()
    
end


ToggleButton = function(parameters)
	
	--input is either nil or a table
	parameters = is_table_or_nil("ToggleButton",parameters)
	
	--flags
	local canvas = type(parameters.images) == "nil"
	
	--upvals
	local images
    
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = Button( parameters )
	
    
    
	local define_image_animation = function(image)
		
		local prev_state = image and image.state and image.state.state
		
		local a = AnimationState{
			duration    = 100,
			transitions = {
				{
					source = "*", target = "OFF",
					keys   = {  {image, "opacity",  0},  },
				},
				{
					source = "*", target = "ON",
					keys   = {  {image, "opacity",255},  },
				},
			}
		}
		
		a:warp(prev_state or "OFF")
		
		return a
		
	end
    
    
	
	override_function(instance,"create_canvas", function(old_function,self,state)
		
		local c = Canvas(self.w,self.h)
		
        c.op = "SOURCE"
        
		c.line_width = self.style.border.width
		
		c:round_rectangle(
			c.line_width/2,
			c.line_width/2,
			c.w - c.line_width,
			c.h - c.line_width,
			self.style.border.corner_radius
		)
		
		c:set_source_color( self.style.fill_colors[state] )
		
		c:fill(true)
		print(1,self.style.border.colors[state])
		c:set_source_color( self.style.border.colors[state] )
		print(2)
		c:stroke()
        
        
		c:rectangle(
			c.h/2-10,
			c.h/2-10,
			20,
			20
		)
        
        if state == "selection" then
            
            c:move_to(c.h/2-10,c.h/2-10)
            c:line_to(c.h/2+10,c.h/2+10)
            
            c:move_to(c.h/2-10,c.h/2+10)
            c:line_to(c.h/2+10,c.h/2-10)
            
        end
        c:set_source_color( self.style.border.colors[state] )
		c:stroke(true)
        
		--]]
		return c:Image()
		
	end)
    
	override_property(instance,"type",   function() return "TOGGLEBUTTON" end )
	override_property(instance,"states", function() return  states        end )
    
    local on_deselection, on_selection
    local selected = false
    
	override_property(instance,"selected",
		function() return selected end,
		function(oldf,self,v)
			
            if type(v) ~= "boolean" then
                error("Widget.focused expected type 'boolean', received "..type(v),2)
            end
            
            if selected == v then return end
            
            selected = v
            
            if selected then
                
                if self.images.selection then self.images.selection.state.state = "ON"   end
                
                if on_deselection then on_deselection() end
                
            else
                
                if self.images.selection then self.images.selection.state.state = "OFF"   end
                
                if on_deselection then on_deselection() end
                
            end
            
		end
	)
	override_property(instance,"on_selection",   function() return on_selection   end, function(oldf,self,v) on_selection   = v end )
    override_property(instance,"on_deselection", function() return on_deselection end, function(oldf,self,v) on_deselection = v end )
	
    
	override_function(instance,"press", function(old_function,self)
        
        self.selected = not self.selected
        
        old_function(self)
        
    end)
    
    print(instance.style.fill_colors.selection)
    if instance.style.fill_colors.selection == nil then
        print(1)
        instance.style.fill_colors.selection = "00000000"
        print(instance.style.fill_colors.selection)
    end
    if instance.style.border.colors.selection == nil then
        
        instance.style.border.colors.selection = "ffffff"
        
    end
    
	if canvas then instance:create_canvases() end
    
    
	instance:set(parameters)
    
	return instance
    
end
    
    
    