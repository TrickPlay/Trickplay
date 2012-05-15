WIDGET = true

local uielement_properties = {
	"position","size","anchor_point","name","gid",
	"x_rotation","y_rotation","z_rotation","scale",
	"opacity","clip","is_visible"
}

--------------------------------------------------------------------------------
-- This function receives a UIElement as its parameter sets up the attributes
-- and methods of Widget. Namely:
--    - focused
--    - enabled
--    - style
--    - subscribe_to()
--    - to_json()
--    - from_json()
--    - add_key_handler()
--    - add_mouse_handler()
--
-- Yes this is a messy way to set up WidgetGroup, WidgetRectangle, WidgetText,
-- WidgetImage, and WidgetClone
--------------------------------------------------------------------------------
local function Widgetize(instance)
    
    --Pablo's function to duplicate the metatable of UIElements
    dupmetatable(instance)
    
    ----------------------------------------------------------------------------
    -- subscribe_to() / unsubscribe()
    do
        -- the table of callbacks for specific attributes, 
        local subscriptions     = {}
        local subscriptions_all = {}
        
        --helper function called by subscribe_to()
        local add = function(subscription,callback)
            --lazy creation of second dimension of tables
            if not subscriptions[subscription] then
                
                subscriptions[subscription] = {}
                
            end
            
            subscriptions[subscription][callback] = true
            
        end
        
        override_function(instance,"unsubscribe",
            function(old_function,self,subscription,f)
                
                if type(f) ~= "function" then
                    
                    error( "2nd arg expected to be a function. Received "..type(f),2 )
                    
                end
                
                if type(subscription) == "nil" then
                    
                    subscriptions_all[subscription][f] = nil
                    
                elseif type(subscription) == "table" then
                    
                    for _,key in ipairs(subscription) do
                        
                        subscriptions[subscription][f] = nil
                        
                    end
                    
                elseif type(subscription) == "string" then
                    
                    subscriptions[subscription][f] = nil
                    
                else
                    
                    error(
                        "1st arg expects a string, a table of strings,"..
                        " or nil. Received "..type(subscription),2
                    )
                    
                end
                
            end
        )
        override_function(instance,"subscribe_to",
            function(old_function,self,subscription,f)
                
                if type(f) ~= "function" then
                    
                    error( "2nd arg expected to be a function. Received "..type(f),2 )
                    
                end
                
                if type(subscription) == "nil" then
                    
                    subscriptions_all[f] = true
                    
                elseif type(subscription) == "table" then
                    
                    for _,key in ipairs(subscription) do
                        
                        add(key,f)
                        
                    end
                    
                elseif type(subscription) == "string" then
                    
                    add(subscription,f)
                    
                else
                    
                    error(
                        "1st arg expects a string, a table of strings,"..
                        " or nil. Received "..type(subscription),2
                    )
                    
                end
                
            end
        )
        ------------------------------------------------------------------------
        -- override UIElement.set and __newindex, necessary in order for
        -- subscribe_to to work
        local instance_mt = getmetatable(instance)
        local old__newindex = instance_mt.__newindex
        function instance_mt:__newindex(key,value)
            
            old__newindex(self,key,value)
            
            if subscriptions[key] then
                
                for f,_ in pairs(subscriptions[key]) do f(key) end
            end
            for f,_ in pairs(subscriptions_all ) do f(key) end
            
        end
        
        override_function(instance,"set", function(old_function, obj, t )
            
            old_function(obj, t)
            
            local p = {}
            
            for key,_ in pairs(t) do
                if subscriptions[key] then
                    
                    for f,_ in pairs(subscriptions[key]) do f(key) end
                    
                end
                table.insert(p,key)
            end
            --functionality of widgets relies on the callbacks in 
            -- 'subscriptions_all' happening after the callbacks
            -- in 'subscriptions'
            for f,_ in pairs(subscriptions_all ) do f(p) end
            
            return instance
            
        end)
	end
    ----------------------------------------------------------------------------
    local key_functions = {}
    
    function instance:add_key_handler(key,func)
        
        if not key_functions[key] then
            
            key_functions[key] = {}
            
        end
        
        key_functions[key][func] = true
        
        return function()
            
            key_functions[key][func] = nil
            
        end
        
    end
    
    function instance:on_key_down(key)
        
        if not instance.enabled then return end
        
        if key_functions[key] then
            for f,_ in pairs(key_functions[key]) do
                f()
            end
        end
        
    end
    
    ----------------------------------------------------------------------------
    local __call = function(t,...) 
        
        if not instance.enabled then return end
        
        for f,_ in pairs(t) do   f(...)   end
        
    end
    
    --all the possible 
    local mouse_functions = {
        on_button_down    = {},
        on_button_up      = {},
        on_motion         = {},
        on_enter          = {},
        on_leave          = {},
    }
    
    for event,_ in pairs(mouse_functions) do
        
        setmetatable(mouse_functions[event],{__call = __call})
        
        --set the event handler to be the table of event handlers
        --when the engine calls the table, __call will get called
        instance[event] = mouse_functions[event]
        
        override_property(  instance,event,
            
            function()   return mouse_functions[event]   end,
            
            --those that are afraid of change can add an event handler the old way
            --this setter function will call add_mouse_handler
            function(oldf,self,v)  self:add_mouse_handler(event,v)  end
        )
    end
    
    function instance:add_mouse_handler(event,func)
        
        if not event or not mouse_functions[event] then
            
            error("Widget."..event.."() is not a mouse event.",2)
            
        end
        
        if type(func) ~= "function" then
            
            error("2nd argument expected to be a function. Received "..type(func)..".",2)
            
        end
        
        mouse_functions[event][func] = true
        
        return function()  mouse_functions[event][func] = nil  end
        
    end
    
    ----------------------------------------------------------------------------
    
    local size_is_set = false
    
	instance:subscribe_to(
		{"w","h","width","height","size"},
		
        function()   size_is_set = true   end
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
		
		t.type = t.type or "Widget"
        
        return json:stringify(t)
    end
	
	override_property(instance,"to_json",
		function() return to_json end,
		function(oldf,self,v) to_json__overridden = v end
	)
	
	override_function(instance,"from_json", function(old_function,self,j)
		
        if type(j) ~= "string" then
            error("Expects string. Received \n"..type(j),2)
        end
        
        local t = json:parse(j)
        
        if type(t) ~= "table" then
            error("Unable to parse the json_string: \n"..j,2)
        end
        
		self:set(t)
		
	end)
    
    ----------------------------------------------------------------------------
	
    local focused = false
    
	override_property(instance,"focused",
		function() return focused end,
		function(oldf,self,v)
			
            if type(v) ~= "boolean" then
                error("Widget.focused expected type 'boolean', received "..type(v),2)
            end
            
            focused = v
            
		end
	)
    
    ----------------------------------------------------------------------------
	
    local enabled = true
    
	override_property(instance,"enabled",
		function() return enabled end,
		function(oldf,self,v)
			
            if type(v) ~= "boolean" then
                error("Widget.enabled expected type 'boolean', received "..type(v),2)
            end
            
            enabled = v
            
		end
	)
    
    ----------------------------------------------------------------------------
    local style = Style()
	override_property(instance,"style",
		function()   return style    end,
		function(oldf,self,v) 
            
			style = matches_nil_table_or_type(Style, "STYLE", v)
            
        end
	)
    
	override_property(instance,"widget_type",
		function() return "Widget" end, nil
	)
    
    return instance
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Widget_Group = function(parameters)
    
    return Widgetize(  Group()  ):set( 
        
        is_table_or_nil( "Widget_Group", parameters ) 
        
    )
    
end

Widget_Rectangle = function(parameters)
    
    return Widgetize(  Rectangle()  ):set( 
        
        is_table_or_nil( "Widget_Rectangle", parameters ) 
        
    )
    
end

Widget_Text = function(parameters)
    
    return Widgetize(  Text()  ):set( 
        
        is_table_or_nil( "Widget_Text", parameters ) 
        
    )
    
end

Widget_Image = function(parameters)
    
    return Widgetize(  Image()  ):set( 
        
        is_table_or_nil( "Widget_Image", parameters ) 
        
    )
    
end

Widget_Clone = function(parameters)
    
    return Widgetize(  Clone()  ):set( 
        
        is_table_or_nil( "Widget_Clone", parameters ) 
        
    )
    
end

Widget = Widget_Group




