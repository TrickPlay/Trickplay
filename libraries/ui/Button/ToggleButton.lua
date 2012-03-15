
local states = {"default","focus","selection","activation"}

local press = function(old_function,self)
    
    self.selected = not self.selected
    
    old_function(self)
    
end

local create_canvas = function(old_function,self,state)
	
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
	
	c:set_source_color( self.style.border.colors[state] )
	
	c:stroke()
	
	--the X box
	c:rectangle(
		c.h/2-10,
		c.h/2-10,
		20,
		20
	)
	
	--the X
	if state == "selection" then
		
		c:move_to(c.h/2-10,c.h/2-10)
		c:line_to(c.h/2+10,c.h/2+10)
		
		c:move_to(c.h/2-10,c.h/2+10)
		c:line_to(c.h/2+10,c.h/2-10)
		
	end
	
	c:stroke(true)
	
	return c:Image()
	
end

local default_parameters = {
	style = {
		border      = { colors = { selection = "ffffff" } },
		fill_colors = { selection = "00000000" }
	},
	states          = states,
	create_canvas   = create_canvas,
}

--------------------------------------------------------------------------------
-- Constructor - creates an instance of a toggle button
--------------------------------------------------------------------------------

ToggleButton = function(parameters)
	--input is either nil or a table
	parameters = is_table_or_nil("ToggleButton",parameters)
	
	--flags
	local canvas = type(parameters.images) == "nil"
	
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	parameters = cover_defaults(parameters,default_parameters)
	
	
	local instance = Button( parameters )
    
	----------------------------------------------------------------------------
	
	override_function(instance,"press", press)
	
	override_property(instance,"type",   function() return "TOGGLEBUTTON" end )
    
	----------------------------------------------------------------------------
	-- the ToggleButton.selected attribute and its callbacks
	
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
	
	----------------------------------------------------------------------------
	--set the parameters
    
	return instance:set(parameters)
    
end
    
    
    