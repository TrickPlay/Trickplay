WIDGET = true

local uielement_properties = {
	"x","y","z","w","h","anchor_point","name","gid",
	"x_rotation","y_rotation","z_rotation","scale",
	"opacity","clip",""
}


Widget = function(parameters)
    
	parameters = is_table_or_nil("Widget",parameters)
    
    local style   --= Style(parameters.style)
    
    local focused = parameters.focused or false
    
    
    local instance = Group{}
    
    dupmetatable(instance)
    
    
    ----------------------------------------------------------------------------
	local subscriptions     = {}
	local subscriptions_all = {}
	
	local add_subscription = function(subscription,callback)
		
		if not subscriptions[subscription] then
			
			subscriptions[subscription] = {}
			
		end
		
		subscriptions[subscription][callback] = callback
		
	end
	
	override_function(instance,"unsubscribe",
		function(old_function,self,subscription,callback)
			
			if type(callback) ~= "function" then
				
				error(
					"Widget:unsubscribe() expects a function as the second"..
					" parameter. Received "..type(callback),2
				)
				
			end
			
			if type(subscription) == "nil" then
				
				subscriptions_all[subscription][callback] = nil
				
			elseif type(subscription) == "table" then
				
				for _,key in ipairs(subscription) do
					
					subscriptions[subscription][callback] = nil
					
				end
				
			elseif type(subscription) == "string" then
				
				subscriptions[subscription][callback] = nil
				
			else
				
				error(
					"Widget:subscribe_to() expects a string, a table of strings,"..
					" or nil as its first parameter. Received "..type(subscription),2
				)
				
			end
			
		end
	)
	override_function(instance,"subscribe_to",
		function(old_function,self,subscription,callback)
			
			if type(callback) ~= "function" then
				
				error(
					"Widget:subscribe_to() expects a function as the second"..
					" parameter. Received "..type(callback),2
				)
				
			end
			
			if type(subscription) == "nil" then
				
				subscriptions_all[callback] = callback
				
			elseif type(subscription) == "table" then
				
				for _,key in ipairs(subscription) do
					
					add_subscription(key,callback)
					
				end
				
			elseif type(subscription) == "string" then
				
				add_subscription(subscription,callback)
				
				
			else
				
				error(
					"Widget:subscribe_to() expects a string, a table of strings,"..
					" or nil as its first parameter. Received "..type(subscription),2
				)
				
			end
			
		end
	)
	local instance_mt = getmetatable(instance)
	local old__newindex = instance_mt.__newindex
    function instance_mt:__newindex(key,value)
		
		old__newindex(self,key,value)
		
		if subscriptions[key] then
			
			for _,f in pairs(subscriptions[key]) do f(key) end
		end
		for _,f in pairs(subscriptions_all ) do f(key) end
		
	end
	
	
	override_function(instance,"set", function(old_function, obj, t )
		
		old_function(obj, t)
		
		local p = {}
		
		for key,_ in pairs(t) do
			if subscriptions[key] then
				
				for _,f in pairs(subscriptions[key]) do f(key) end
				
			end
			table.insert(p,key)
		end
		--functionality of widgets relies on subscriptions_all happening after
		--subscriptions
		for _,f in pairs(subscriptions_all ) do f(p) end
		
	end)
	
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
    
    local size_is_set = false
    
	instance:subscribe_to(
		{"w","h","width","height","size"},
		function()
			
			size_is_set = true
			
		end
	)
	
	override_function( instance, "is_size_set",    function() return size_is_set  end)
	override_function( instance, "reset_size_flag",function() size_is_set = false end)
	
	
    ----------------------------------------------------------------------------
    
    local to_json__overridden
    
    local to_json = function(_,t)
        
        t = is_table_or_nil("Widget.to_json",t)
        t = to_json__overridden and to_json__overridden(_,t) or t
        
		
		for _,k in pairs(uielement_properties) do
			
			t[k] = instance[k]
			
		end
        
        t.style   = instance.style.name
        t.focused = instance.focused
        
        return json:stringify(t)
    end
	
	override_property(instance,"to_json",
		function() return to_json end,
		function(oldf,self,v) to_json__overridden = v end
	)
	
	override_function(instance,"from_json", function(old_function,self,j)
		
        if type(j) ~= "string" then
        end
        
        j = json:parse(j)
        
        if type(j) ~= "table" then
        end
        
		self:set(j)
		
	end)
    
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





