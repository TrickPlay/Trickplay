TOGGLEBUTTON = true

local states = {"default","focus","selection","activation"}

local press = function(old_function,self)
    
    self.selected = not self.selected
    
    old_function(self)
    
end

local create_canvas = function(self,state)
	
	local c = Canvas(self.w,self.h)
	
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
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
	
	parameters = recursive_overwrite(parameters,default_parameters)
	
	
	local instance = Button( parameters )
    
	----------------------------------------------------------------------------
	
	override_function(instance,"press", press)
	
	override_property(instance,"type",   function() return "TOGGLEBUTTON" end )
    
	----------------------------------------------------------------------------
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.group    = instance.group and instance.group.name or nil
            t.selected = instance.selected
            
            t.type = "ToggleButton"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
	-- the ToggleButton.selected attribute and its callbacks
	
	local radio_button_group
    local on_deselection, on_selection
    local selected = false
    
	override_property(instance,"widget_type",
		function() return "ToggleButton" end, nil
	)
    
	override_property(instance,"group",
		function() return radio_button_group end,
		function(oldf,self,v)
			
			if radio_button_group and
				(radio_button_group == v or radio_button_group.name == v) then
				
				return
				
			end
			
			
			if radio_button_group then
				
				radio_button_group:remove(self)
				
			end
			
			if type(v) == "nil" then
				
				radio_button_group = nil
				
				return
				
			elseif type(v) == "string" then
				
				radio_button_group = RadioButtonGroup(v)
				
			elseif type(v) == "table" and v.type == "RadioButtonGroup" then
				
				radio_button_group = v
				
			else
				
				error("ToggleButton.group must receive string or RadioButtonGroup",2)
				
			end
			
			radio_button_group:insert(self)
			
			if selected then
				
				selected = false
				self.selected = true
				
			end
			
		end
	)
	override_property(instance,"selected",
		function() return selected end,
		function(oldf,self,v)
			
            if type(v) ~= "boolean" then
                error("Widget.focused expected type 'boolean', received "..type(v),2)
            end
            
            if selected == v then return end
            
            selected = v
            
            if selected then
                
				if radio_button_group then
					
					for i, b in ipairs(radio_button_group.items) do
						
						if b ~= self then
							
							b.selected = false
							
						else
							
							radio_button_group.selected = i
							
						end
						
					end 
					
					if radio_button_group.on_selection_change then
						
						radio_button_group:on_selection_change()
						
					end 
					
				end 
				
                if self.images.selection then self.images.selection.state.state = "ON"   end
                
                if on_selection then on_selection() end
                
            else
                
                if self.images.selection then self.images.selection.state.state = "OFF"  end
                
                if on_deselection then on_deselection() end
                
            end 
            
		end 
	)
	
	override_property(instance,"on_selection",   function() return on_selection   end, function(oldf,self,v) on_selection   = v end )
    override_property(instance,"on_deselection", function() return on_deselection end, function(oldf,self,v) on_deselection = v end )
	
	----------------------------------------------------------------------------
	--set the parameters
	if parameters.selected then instance.selected = parameters.selected end
	if parameters.group    then instance.group    = parameters.group    end
	
	return instance
    
end
    
    
    