WIDGET = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

--List of Properties copied from docs
local uielement_properties = {
    "name",
    "gid",
    --"x",   redundant to position
    --"y",
    --"z",
    --"depth",
    "position",
    --"w",   redundant to size
    --"h",
    --"width",
    --"height",
    "size",
    "center",
    "anchor_point",
    "scale",
    "x_rotation",
    "y_rotation",
    "z_rotation",
    "is_scaled",
    "is_rotated",
    "opacity",
    "clip",
    "has_clip",
    --"clip_to_size",    only applies to Groups
    --"parent",          handled separately in Widget.attributes
    "reactive",
    "transformed_size",
    "transformed_position",
    "is_animating",
    "is_visible",
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
local table_of_envs = {}

function get_env(w) return table_of_envs[w] end

--------------------------------------------------------------------------------

WL_parent_redirect = setmetatable({},{__mode='v'})

--------------------------------------------------------------------------------
local function Widgetize(instance)
    
    local _ENV = setmetatable({},{__index=_ENV})
    
    table_of_envs[instance] = _ENV
    
    update = function() end
    ----------------------------------------------------------------------------
    
    --Pablo's function to duplicate the metatable of UIElements
    dupmetatable(instance)
    
    local mt = getmetatable(instance)
    ----------------------------------------------------------------------------
    -- subscribe_to() / unsubscribe()
    
    local old__newindex = mt.__newindex
    local old_set       = mt.set
    
    is_setting = false
    
    updating = false
    
    call_update = function()
        if not updating then
            
            updating = true
            
            update(instance)
            
            updating = false
            
        end
    end
    
    set_up_subscriptions(mt,mt,
        --This function is called every time an attribute is being set
        --set_up_subscriptions() sets up the real __newindex, and wraps this function
        function(...)
            
            --print("w1",instance.w)
            old__newindex(...)
            --print("w2",instance.w)
            
            call_update()
            
        end,
        function(self,v)
            
            if type(v) ~= "table" then error("Expected table. Received ".. type(v), 3 ) end
            
            if is_setting then error("already setting",2) end
            
            is_setting = true
            
            old_set(self,v)
            
            call_update()
            
            if not is_setting then error("no",2) end
            
            is_setting = false
        end
    )
    ----------------------------------------------------------------------------
    local key_functions = {}
    
    override_function(instance,"add_key_handler",function(oldf,self,key,func)
        
        if not key_functions[key] then
            
            key_functions[key] = {}
            
        end
        
        key_functions[key][func] = true
        
        return function()
            
            key_functions[key][func] = nil
            
        end
        
    end)
    
    function instance:on_key_down(key,...)
        if not instance.enabled then return end
        
        if key_functions[key] then
            
            local retval = false
            
            for f,_ in pairs(key_functions[key]) do
                retval = f(self,key,...) or retval
            end
            
            return retval
        end
        
    end
    
    ----------------------------------------------------------------------------
    
    local neighbors_unsubscribe = {}
    local neighbors = {}
    local opposite_keys = {
        Left  = "Right",
        Right = "Left",
        Up    = "Down",
        Down  = "Up",
    }
    
    local external_neighbors = setmetatable(
        {},
        {
            __newindex = function(t,k,v)
                
                if keys[k] == nil then error("'"..tostring(k).."' is an invalid key",2) end
                
                if neighbors[k]  then neighbors_unsubscribe[k]() end
                
                if type(v) == "userdata" and v.grab_key_focus then
                    
                    neighbors_unsubscribe[k] = instance:add_key_handler(
                        
                        keys[k],  function()   v:grab_key_focus()   end
                    )
                    
                    neighbors[k] = v
                    
                    if opposite_keys[k] and v.neighbors[ opposite_keys[k] ] == nil then
                        
                        v.neighbors[ opposite_keys[k] ] = instance
                        
                    end
                    
                    instance:notify()
                    
                elseif v == nil then
                    
                    neighbors[k] = nil
                    
                    instance:notify()
                    
                end
                
            end,
            __index = function(t,k)
                
                return neighbors[k]
                
            end,
        }
    )
    
	override_property(instance,"neighbors",
        function(oldf,self) return external_neighbors end,
        function(oldf,self,v) 
            
            if type(v) ~= "table" then error("Expected table. Received "..type(v),2) end
            
            for k,v in pairs(v) do  external_neighbors[k] = v  end
        end
    )
    
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
    
    override_function(instance,"add_mouse_handler",function(oldf,self,event,func,ignore_enabled)
        
        if not event or not mouse_functions[event] then
            
            error("Widget."..event.."() is not a mouse event.",2)
            
        end
        
        if type(func) ~= "function" then
            
            error("2nd argument expected to be a function. Received "..type(func)..".",2)
            
        end
        
        if ignore_enabled ~= true then ignore_enabled = false end
        
        mouse_functions[event][func] = ignore_enabled
        
        return function()  mouse_functions[event][func] = nil  end
    end)
    
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
            
            t.neighbors = {}
            
            for k,v in pairs(neighbors) do
                
                t.neighbors[k] = v.name
                
            end
            
            t.parent  = self.parent and self.parent.gid
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
    local unsubscribe
    
    local function recursive_flag_setter(style_t,style_flags)
        
        if type(style_flags) == "string" then
            mesg("STYLE_SUBSCRIPTIONS",0,"0 _ENV[",style_flags,"] = true")
            _ENV[style_flags] = true
            return
        end
        for k,v in pairs(style_t) do
            
            --if there is string for this substyle, then set the flag and move on
            if type(style_flags[k]) == "string" then
                
                _ENV[  style_flags[k]  ] = true
                mesg("STYLE_SUBSCRIPTIONS",0,"1 _ENV[",style_flags[k],"] = true")
            --if there is a table of flags then
            elseif type(style_flags[k]) == "table" then
                
                if type(v) ~= "table" then
                    --set the list of flags, ignore further specifics
                    for _,v in ipairs(style_flags[k]) do
                        _ENV[v] = true
                        mesg("STYLE_SUBSCRIPTIONS",0,"2 _ENV[",v,"] = true")
                    end
                --traverse the table
                else
                    for kk,vv in pairs(style_flags[k]) do
                        if type(kk) == "number" then
                            _ENV[vv] = true
                            mesg("STYLE_SUBSCRIPTIONS",0,"3 _ENV[",vv,"] = true")
                        elseif type(v) == "table" then
                            recursive_flag_setter(v,style_flags[k])
                        end
                    end
                end
                
            end
        end
    end
    local subscription = function(style_t)
        --print("herefdffds")
        mesg("STYLE_SUBSCRIPTIONS",0, (instance.name or instance.gid),"'s style's subscribe_to was called")
        --dumptable(style_t)
        if not style_flags then return end
        
        recursive_flag_setter(style_t,style_flags)
        
        call_update()
        
    end
    
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
            unsubscribe()
            --print("\n\nSET UP SUBS",instance.gid)
            unsubscribe = style:subscribe_to( nil, subscription )
            
            if style_flags then 
                mesg("STYLE_SUBSCRIPTIONS",0,"Widget.style was set, initiating the flag setter")
                --print("style recursive set\n\n\n")
                --dumptable(style.attributes)
                recursive_flag_setter(style.attributes,style_flags) 
            end
        end
	)
    
    unsubscribe = style:subscribe_to( nil, subscription )
    ----------------------------------------------------------------------------
    
	override_property(instance,"parent",
        function(oldf,self) 
            local p = oldf(self)
            while WL_parent_redirect[p] do
                p = WL_parent_redirect[p]
            end
            return p 
        end
    )
    
    ----------------------------------------------------------------------------
	override_property(instance,"widget_type",
		function() return "Widget" end, nil
	)
    return instance, _ENV
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Widget = function(parameters)
    
    local instance, _ENV = Widgetize(  Group()  )
    
    instance:set( 
        
        is_table_or_nil( "Widget_Group", parameters ) 
        
    )
    
    add           = instance.add
    remove        = instance.remove
    clear         = instance.clear
    foreach_child = instance.foreach_child
    find_child    = instance.find_child
    raise_child   = instance.raise_child
    lower_child   = instance.lower_child
    set_children  = getmetatable(instance).__setters__.children
    get_children  = getmetatable(instance).__getters__.children
    
    override_function( instance, "add",           function() print(pcall(error,          "'add' method is removed",3)) end )
    override_function( instance, "remove",        function() print(pcall(error,       "'remove' method is removed",3)) end )
    override_function( instance, "clear",         function() print(pcall(error,        "'clear' method is removed",3)) end )
    override_function( instance, "foreach_child", function() print(pcall(error,"'foreach_child' method is removed",3)) end )
    override_function( instance, "find_child",    function() print(pcall(error,   "'find_child' method is removed",3)) end )
    override_function( instance, "raise_child",   function() print(pcall(error,  "'raise_child' method is removed",3)) end )
    override_function( instance, "lower_child",   function() print(pcall(error,  "'lower_child' method is removed",3)) end )
    
	override_property(
        instance,"children", 
        function() print("'children' property is removed") end, 
        function() print("'children' property is removed") end
    )
    
    
    return instance, _ENV
end
Widget_Group = function(parameters)
    
    local instance =  Widgetize(  Group()  )
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Group" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"children",
        function(oldf,self)  return oldf(self)  end,
        function(oldf,self,v)
            
            if type(v) ~= "table" then 
                
                error("Expected table. Received "..type(v),2)
                
            end
            
            for i,obj in ipairs(v) do
                
                if type(obj) == "table" and obj.type then 
                    
                    v[i] = _ENV[obj.type](obj)
                    
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
            
            t.style = nil
            
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
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Rectangle" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
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
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Text" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
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
    "src","loaded","async","read_tags","tags","base_size","tile","sheet","id"
}
Widget_Image = function(parameters)
    
    local instance = Widgetize(  Image()  )
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Image" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
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
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Clone" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
            t.source = self.source and self.source.name or nil
            
            t.type = "Widget_Clone"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end

local sprite_properties = { 
    "id","sheet"
}
Widget_Sprite = function(parameters)
    
    local instance = Widgetize(  Sprite()  )
    
	override_property(instance,"widget_type",
        function(oldf,self) return "Widget_Sprite" end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
            for _,k in pairs(sprite_properties) do
                
                t[k] = self[k]
                
            end
            
            t.type = "Widget_Sprite"
            
            return t
        end
    )
    
    return parameters and instance:set(parameters) or instance
    
end

external.Widget           = Widget
external.Widget_Group     = Widget_Group
external.Widget_Clone     = Widget_Clone
external.Widget_Image     = Widget_Image
external.Widget_Text      = Widget_Text
external.Widget_Rectangle = Widget_Rectangle
external.Widget_Sprite    = Widget_Sprite



