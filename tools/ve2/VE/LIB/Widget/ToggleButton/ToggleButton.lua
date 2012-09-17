TOGGLEBUTTON = true

local states = {"default","focus","selection","activation"}
--[[
local press = function(old_function,self)
    print("hfhfhf")
    self.selected = not self.selected
    
    old_function(self)
    
end
--]]
local create_canvas = function(self,state)
	print("ccc")
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

--------------------------------------------------------------------------------
-- Constructor - creates an instance of a toggle button
--------------------------------------------------------------------------------


ToggleButton = setmetatable(
    {},
    {
    __index = function(self,k)
        
        return getmetatable(self)[k]
        
    end,
    __call = function(self,p)
        
        return self:declare():set(p or {})
        
    end,
    
    public = {
        properties = {
            on_selection = function(instance,env)
                return function(oldf) return env.on_selection end,
                function(oldf,self,v) env.on_selection = v end
            end,
            on_deselection = function(instance,env)
                return function(oldf) return env.on_deselection end,
                function(oldf,self,v) env.on_deselection = v end
            end,
            type = function(instance,env)
                return function() return "TOGGLEBUTTON" end
            end,
            widget_type = function(instance,env)
                return function() return "ToggleButton" end
            end,
            attributes = function(instance,env)
                return function(oldf,self)
                    local t = oldf(self)
                    
                    t.group    = instance.group and instance.group.name
                    t.selected = instance.selected
                    
                    t.type = "ToggleButton"
                    
                    return t
                end
            end,
            group = function(instance,env)
                return function() return env.radio_button_group end,
                function(oldf,self,v)
                    
                    if env.radio_button_group then
                        if env.radio_button_group == v or env.radio_button_group.name == v then
                            
                            return
                            
                        else
                            
                            env.radio_button_group:remove(self)
                            
                        end
                    end
                    
                    
                    if type(v) == "nil" then
                        
                        env.radio_button_group = nil
                        
                        return
                        
                    elseif type(v) == "string" then
                        
                        env.radio_button_group = RadioButtonGroup(v)
                        
                    elseif type(v) == "table" and v.type == "RadioButtonGroup" then
                        
                        env.radio_button_group = v
                        
                    else
                        
                        error("ToggleButton.group must receive string or RadioButtonGroup",2)
                        
                    end
                    
                    env.radio_button_group:insert(self)
                    
                    if env.selected then
                        
                        env.selected = false
                        self.selected = true
                        
                    end
                    
                end
            end,
            selected = function(instance,env)
                return function() return env.selected end,
                    function(oldf,self,v)
                        print("v",v)
                        if type(v) ~= "boolean" then
                            error("Widget.selected expected type 'boolean', received "..type(v),2)
                        end
                        
                        if env.selected == v then return end
                        
                        env.selected = v
                        ---[[
                        if env.selected then
                            
                            if env.radio_button_group then
                                
                                for i, b in ipairs(env.radio_button_group.items) do
                                    
                                    if b ~= self then
                                        
                                        b.selected = false
                                        
                                    else
                                        
                                        env.radio_button_group.selected = i
                                        
                                    end
                                    
                                end 
                                
                                if env.radio_button_group.on_selection_change then
                                    
                                    env.radio_button_group:on_selection_change()
                                    
                                end 
                                
                            end 
                            
                            if env.image_states.selection then env.image_states.selection.state = "ON"   end
                            
                            if env.on_selection then env.on_selection() end
                            
                        else
                            
                            if env.image_states.selection then env.image_states.selection.state = "OFF"  end
                            
                            if env.on_deselection then env.on_deselection() end
                            
                        end 
                        --]]
                    end 
            end,
        },
        
        functions = {
            press = function(instance,env)
                return function(old_function,self)
                    
                    self.selected = not self.selected
                    
                    old_function(self)
                    
                end
            end,
        }
    },
    declare = function(self,parameters)
        local instance, env = Button:declare()
        
        env.radio_button_group = false
        env.on_deselection     = false
        env.on_selection       = false
        env.selected           = false
        --overwrite existing
        env.states             = states
        env.create_canvas      = create_canvas
        
        for _,state in pairs(env.states) do
            if state ~= "default" then env.image_states[state] = {state = "OFF"} end
        end
        
        --[[
        for name,f in pairs(self.private) do
            env[name] = f(instance,env)
        end
        --]]
        
        local getter, setter
        for name,f in pairs(self.public.properties) do
            getter, setter = f(instance,env)
            override_property( instance, name, getter, setter )
            
        end
        
        for name,f in pairs(self.public.functions) do
            
            override_function( instance, name, f(instance,env) )
            
        end
        --[[
        for t,f in pairs(self.subscriptions) do
            instance:subscribe_to(t,f(instance,env))
        end
        for _,f in pairs(self.subscriptions_all) do
            instance:subscribe_to(nil,f(instance,env))
        end
        --]]
        --instance.images = nil
        return instance, env
        
    end
})
--[=[
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
--]=]
    
    