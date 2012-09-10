STYLE = true

local default_fill_colors = {
    default    = {  0,  0,  0},
    focus      = {155,155,155},
    activation = {155,155,155}
} 
local default_arrow_colors = {
    default    = {255,255,255},
    focus      = {255,255,255},
    activation = {255,  0,  0}
} 
local default_border_colors = {
    default    = {255,255,255},
    focus      = {255,255,255},
    activation = {255,  0,  0}
} 
local default_text_colors = {
    default    = {255,255,255},
    focus      = {255,255,255},
    activation = {255,  0,  0}
}

local func_upval
local __newindex = function(meta_setters)
    
    return function(t,k,v)
        
        func_upval = meta_setters[k]
        
        return func_upval and func_upval(v)
        
    end
    
end

local __index = function(meta_getters)
    
    return function(t,k)
        
        func_upval = meta_getters[k]
        
        return func_upval and func_upval()
        
    end
    
end



--------------------------------------------------------------------------------

ArrowStyle = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("ArrowStyle",parameters)
    
    local instance, size, offset
    local colors = ColorScheme(default_arrow_colors)
    
    local  meta_setters = {
        size   = function(v) size   = v  end,
        offset = function(v) offset = v  end,
        colors = function(v) colors:set(v or {}) end,
    }
    local meta_getters = {
        size   = function() return size   or 20 end,
        offset = function() return offset or 10 end,
        colors = function() return colors       end,
        type   = function() return "ARROWSTYLE" end,
        attributes = function() 
            return {
                size   = instance.size,
                offset = instance.offset,
                colors = colors.attributes,
            }
        end,
    }
    
    instance = setmetatable(
        {
            to_json = function()
                return json:stringify{
                    size   = instance.size,
                    offset = instance.offset,
                    colors = instance.colors.attributes,
                }
            end,
        },
        {
            __index    = __index(meta_getters)
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        __newindex(meta_setters),
        
        function(self,t)
            
            if type(t) ~= "table" then
                error("Expects a table. Received "..type(t),2)
            end
            
            for k, v in pairs(t) do
                self[k] = v
            end
            
        end
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.size   = parameters.size
    instance.offset = parameters.offset
    instance.colors = parameters.colors
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    return instance
    
end

--------------------------------------------------------------------------------

BorderStyle = function(parameters)
    
	parameters = is_table_or_nil("BorderStyle",parameters)
    
    
    local instance, width, corner_radius, name
    local colors = ColorScheme(default_border_colors)
    
    local  meta_setters = {
        width         = function(v) width         = v   end,
        corner_radius = function(v) corner_radius = v   end,
        colors        = function(v) colors:set(v or {}) end,
    }
    local meta_getters = {
        width         = function() return width         or 2  end,
        corner_radius = function() return corner_radius or 10 end,
        colors        = function() return colors              end,
        type          = function() return "BORDERSTYLE"       end,
        attributes    = function() 
            return {
                width         = instance.width,
                corner_radius = instance.corner_radius,
                colors        = colors.attributes,
            }
        end,
    }
    
    instance = setmetatable(
        {
            to_json = function()
                return json:stringify{
                    width         = instance.width,
                    corner_radius = instance.corner_radius,
                    colors        = instance.colors.name,
                }
            end,
        },
        {
            __index    = __index(meta_getters),
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        __newindex(meta_setters),
        
        function(self,t)
            
            if type(t) ~= "table" then
                error("Expects a table. Received "..type(t),2)
            end
            
            for k, v in pairs(t) do
                self[k] = v
            end
            
        end
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.width         = parameters.width
    instance.corner_radius = parameters.corner_radius
    instance.colors        = parameters.colors
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    return instance
    
end

--------------------------------------------------------------------------------

TextStyle = function(parameters)
    
	parameters = is_table_or_nil("TextStyle",parameters)
    local colors = ColorScheme(default_text_colors)
    local properties = {
        font  = "Sans 40px",
        alignment = "CENTER",
        justify = true,
        wrap    = true,
        x_offset = 0,
        y_offset = 0,
    }
    
    local instance
    instance = {
        set = function(_,parameters)
            
            for k,v in pairs(parameters) do
                
                instance[k] = v
                
            end
            
        end,
        get_table  = function() return properties end,
        to_json = function()
            local t = {}
            
            for property, value in pairs(instance:get_table()) do
                t[property] = value
            end
            t.color  = nil
            t.name   = instance.name
            t.colors = obj.colors.attributes
            
            return json:stringify(t)
        end,
    }
    
    
    local meta_setters = {
        colors    = function(v) 
            
            colors:set(v or {})
            
            return true
            
        end,
    }
    
    local meta_getters = {
        colors = function() return colors end,
        attributes = function() 
            local t = recursive_overwrite({}, properties)
            t.colors = colors.attributes
            return t 
        end,
    }
    
    setmetatable(
        
        instance,
        
        {
            
            __index    = function(t,k)
                
                func_upval = meta_getters[k]
                
                if func_upval then return func_upval()
                else return properties[k] end
                
            end
            
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        function(t,k,v)
            
            func_upval = meta_setters[k]
            
            if      func_upval then func_upval(v)
            elseif k ~= "type" then properties[k] = v end
            
        end,
        
        function(self,parameters)
            
            for k,v in pairs(parameters) do
                
                self[k] = v
                
            end
            
        end
    )
    
    if parameters.colors == nil then instance.colors = nil end
    instance:set(parameters)
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    --properties.color = parameters.color or instance.colors.default
    
    return instance
    
end

--------------------------------------------------------------------------------

local all_styles =  setmetatable({},{__mode = 'v'})

get_all_styles = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_styles) do
        
        t[name]         =  {
            name        = obj.name,
            arrow       = obj.arrow.attributes,
            border      = obj.border.attributes,
            text        = obj.text.attributes,
            fill_colors = obj.fill_colors.attributes,
        }
    end
    
    return json:stringify(t)
    
end

local global_style_subscriptions = {}

Style = setmetatable({},
    {

        subscribe_to = function(self,f)
            
            global_style_subscriptions[f] = true
            
            collectgarbage("collect")
            
            for _,s in pairs(all_styles) do
                
                s:subscribe_to(nil,f)
                
            end
            
        end,

        __index = function(t,k)
            t = getmetatable(t)
            
            return t[k]
        end,

        __call = function(self,parameters)
            
            if type(parameters) == "string" then
                
                if all_styles[parameters] then
                    
                    return all_styles[parameters]
                    
                else
                    
                    parameters = { name = parameters }
                    
                end
                
            end
            
            parameters = is_table_or_nil("Style",parameters)
            
            local instance, name
            local arrow       = ArrowStyle()
            local border      = BorderStyle()
            local text        = TextStyle()
            local fill_colors = ColorScheme(default_fill_colors)
            
            local meta_setters = {
                arrow       = function(v) arrow:set(      v or {}) end,
                border      = function(v) border:set(     v or {}) end,
                text        = function(v) text:set(       v or {}) end,
                fill_colors = function(v) fill_colors:set(v or {}) end,
                name        = function(v)
                    
                    if v ~= false then
                        
                        if name then all_styles[name] = nil end
                        
                        v = check_name( all_styles, instance, v, "Style" )
                        
                    end
                    
                    name = v
                    
                end,
            }
            local meta_getters = {
                name        = function() return name        end,
                arrow       = function() return arrow       end,
                border      = function() return border      end,
                text        = function() return text        end,
                fill_colors = function() return fill_colors end,
                type        = function() return "STYLE"     end,
                attributes  = function() 
                    return {
                        name        = instance.name,
                        arrow       = instance.arrow.attributes,
                        border      = instance.border.attributes,
                        text        = instance.text.attributes,
                        fill_colors = instance.fill_colors.attributes,
                    }
                end,
            }
            
            instance = setmetatable(
                { 
                    to_json = function()
                        
                        return json:stringify(instance.attributes)
                        
                    end,
                },
                {
                    __index    = __index(meta_getters)
                }
            )
            set_up_subscriptions( instance, getmetatable(instance),
                
                __newindex(meta_setters),
                
                function(self,t)
                    
                    if type(t) == "string" then
                        
                        if not all_styles[t] then
                            error("No existing style by the name "..t,2)
                        end
                        
                        for k, v in pairs(all_styles[t].attributes) do
                            if k ~= "name" then self[k] = v end
                        end
                        
                    elseif type(t) == "table" then
                        
                        for k, v in pairs(t) do
                            self[k] = v
                        end
                        
                    else
                        error("Expects a string or a table. Received "..type(t),2)
                    end
                    
                    return instance
                end
            )
            
            
            --can't use a table, need to ensure some properties receive a nil in order
            --to trigger the default condition
            instance.name        = parameters.name 
            instance.arrow       = parameters.arrow
            instance.border      = parameters.border
            instance.text        = parameters.text
            instance.fill_colors = parameters.fill_colors
            ---[[
            -- if a substyle was modified, notify my subscribers
            print(instance.name,"Style object is subscribing to sub-styles")
            arrow:subscribe_to(       nil, function(t) instance:notify({arrow       = t}) end )
            border:subscribe_to(      nil, function(t) instance:notify({border      = t}) end )
            text:subscribe_to(        nil, function(t) instance:notify({text        = t}) end )
            fill_colors:subscribe_to( nil, function(t) instance:notify({fill_colors = t}) end )
            --]]
            for f,_ in pairs(global_style_subscriptions) do
                instance:subscribe_to(nil,f)
            end
            
            return instance
    
        end
    }
)
--really dumb, but I need to hold a reference for the default style somewhere
--so that the weak table doesn't throw it away (if i use a local, lua is smart
--enough to realize its never going to be usedand will throw it away anyway)
getmetatable(all_styles).default = Style("Default")
