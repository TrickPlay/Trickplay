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
    
    local mt = getmetatable(instance)
    ----------------------------------------------------------------------------
    -- subscribe_to() / unsubscribe()
    set_up_subscriptions(mt,mt,mt.__newindex,mt.set)
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
    local enabled_upval, retval
    local __call = function(t,...) 
        
        enabled_upval = instance.enabled
        
        retval = false
        
        for f,ignore_enabled in pairs(t) do   
            
            if enabled_upval or ignore_enabled then 
                
                retval = f(...) or retval
                
            end
        end
        
        return retval
        
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
    
    function instance:add_mouse_handler(event,func,ignore_enabled)
        
        if not event or not mouse_functions[event] then
            
            error("Widget."..event.."() is not a mouse event.",2)
            
        end
        
        if type(func) ~= "function" then
            
            error("2nd argument expected to be a function. Received "..type(func)..".",2)
            
        end
        
        if ignore_enabled ~= true then ignore_enabled = false end
        
        mouse_functions[event][func] = ignore_enabled
        
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
    
	override_function(instance,"to_json",
		function(old_function,self) return json:stringify(self.attributes) end
	)
	override_property(instance,"attributes",
        function(oldf,self)
            local t = {}
            
            for _,k in pairs(uielement_properties) do
                
                t[k] = self[k]
                
            end
            
            t.style   = self.style.name
            t.focused = self.focused
            t.enabled = self.enabled
            
            t.type = "Widget"
            
            return t
        end,
        function(oldf,self,v) self:set(v) end
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
    local style = Style("Default")
	override_property(instance,"style",
		function()   return style    end,
		function(oldf,self,v) 
            
            if v == false then
                
                local attr = style.attributes
                attr.name = nil
                style = Style{name=false}:set(attr)
            else
                style = matches_nil_table_or_type(Style, "STYLE", v)
            end
        end
	)
    
	override_property(instance,"widget_type",
		function() return "Widget" end, nil
	)
    return instance
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Widget = function(parameters)
    
    return  Widgetize(  Group()  ):set( 
        
        is_table_or_nil( "Widget_Group", parameters ) 
        
    )
    
end
Widget_Group = function(parameters)
    
    local instance =  Widgetize(  Group()  )
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"children",
        function(oldf,self)  return oldf(self)  end,
        function(oldf,self,v)
            
            if type(v) ~= "table" then 
                
                error("Expected table. Received "..type(v),2)
                
            end
            
            for i,obj in ipairs(v) do
                
                if type(obj) == "table" and obj.type then 
                    
                    v[i] = _G[obj.type](obj)
                    
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                
                    error("Must be a UIElement or nil. Received "..obj,2) 
                    
                end
                
            end
            
            self:clear()
            
            self:add(unpack(v))
            
        end
    )
    
    ----------------------------------------------------------------------------
    
    local a
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.clip_to_size = self.clip_to_size
            
            t.children = {}
            
            for i,child in pairs(instance.children) do
                a = child.attributes
                if a then
                    table.insert(t.children,a)
                end
                
            end
            
            t.type = "Widget_Group"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end

--------------------------------------------------------------------------------
local rectangle_properties = {
    "color","border_width","border_color",
}
Widget_Rectangle = function(parameters)
    
    local instance = Widgetize(  Rectangle()  )
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            for _,k in pairs(rectangle_properties) do
                
                t[k] = self[k]
                
            end
            
            t.type = "Widget_Rectangle"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end
local text_properties = {
    "text","font","color","markup","use_markup","editable","wrap_mode",
    "single_line","wants_enter","max_length","ellipsize","password_char",
    "justify","alignment","baseline","line_spacing","cursor_position",
    "selection_end","selected_text","selection_color","cursor_visible",
    "cursor_color","cursor_size",
}
Widget_Text = function(parameters)
    
    local instance = Widgetize(  Text()  )
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            for _,k in pairs(text_properties) do
                
                t[k] = self[k]
                
            end
            
            t.type = "Widget_Text"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end

local image_properties = {
    "src","loaded","async","read_tags","tags","base_size","tile"
}
Widget_Image = function(parameters)
    
    local instance = Widgetize(  Image()  )
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            for _,k in pairs(image_properties) do
                
                t[k] = self[k]
                
            end
            
            t.type = "Widget_Image"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end

local clone_properties = { 
    "source"
}
Widget_Clone = function(parameters)
    
    local instance = Widgetize(  Clone()  )
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.source = self.source and self.source.name or nil
            
            t.type = "Widget_Clone"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end





