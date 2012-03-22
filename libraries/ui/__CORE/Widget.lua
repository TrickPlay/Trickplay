WIDGET = true


Widget = function(parameters)
    
	parameters = is_table_or_nil("Widget",parameters)
    
    local style   --= Style(parameters.style)
    
    local focused = parameters.focused or false
    
    
    local instance = Group{}
    
    dupmetatable(instance)
    
    
    ----------------------------------------------------------------------------
    local key_functions = {}
    
    function instance:add_key_handler(key,func)
        
        key_functions[key] = func
        
    end
    
    local func_upval
    
    function instance:on_key_down(key)
        
        func_upval = key_functions[key]
        
        return func_upval and func_upval()
        
    end
    
    ----------------------------------------------------------------------------
    
    local on_size_changed
    local size_is_set = false
    
    local update_size = function(oldf,self,v)
        
        size_is_set = true
        
        oldf(self,v)
        
        if self.on_size_changed then
            
            self:on_size_changed(size_is_set)
            
        end
    end
    
	override_property( instance, "w",      nil, update_size )
	override_property( instance, "h",      nil, update_size )
	override_property( instance, "width",  nil, update_size )
	override_property( instance, "height", nil, update_size )
	override_property( instance, "size",   nil, update_size )
	override_property( instance, "on_size_changed",
        function()     return on_size_changed  end,
        function(oldf,self,v) on_size_changed  = v end
    )
	override_function( instance, "is_size_set",function() return size_is_set end)
	override_function( instance, "reset_size_flag",function() size_is_set = false end)
	
	
    ----------------------------------------------------------------------------
    
    local on_focus_in, on_focus_out
	
	override_property(instance,"focused",
		function() return focused end,
		function(oldf,self,v)
			
            if type(v) ~= "boolean" then
                error("Widget.focused expected type 'boolean', received "..type(v),2)
            end
            
            if focused == v then return end
            
            focused = v
            
            if focused then
                
                if on_focus_in then on_focus_in() end
                
            else
                
                if on_focus_out then on_focus_out() end
                
            end
            
		end
	)
    
	override_property(instance,"style",
		function()   return style    end,
		function(oldf,self,v) 
            style = matches_nil_table_or_type(Style, "STYLE", v)
        end
	)
    
	override_property(instance,"on_focus_in",
		function()      return on_focus_in    end,
		function(oldf,self,v) on_focus_in = v end
	)
    
	
	override_property(instance,"on_focus_out",
		function()      return on_focus_out    end,
		function(oldf,self,v) on_focus_out = v end
	)
	override_property(instance,"type", function()  return "WIDGET"  end )
    
    parameters.style = parameters.style or Style()
    
    instance:set( parameters )
    
    return instance
    
    
end





