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
local update_children = function(children_using_this_style)
    
    collectgarbage("collect")
    
    for _,update in pairs(children_using_this_style) do
        
        update()
        
    end
    
end


local func_upval
local __newindex = function(meta_setters, children_using_this_style)
    
    return function(t,k,v)
        
        func_upval = meta_setters[k]
        
        if func_upval then
            
            func_upval(v)
            
            update_children(children_using_this_style)
            
        end
        
    end
    
end

local __index = function(meta_getters)
    
    return function(t,k)
        
        func_upval = meta_getters[k]
        
        return func_upval and func_upval()
        
    end
    
end



--------------------------------------------------------------------------------

local all_arrow_styles = setmetatable({},{__mode = 'v'})

local arrowstyles_json = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_arrow_styles) do
        
        t[name]           = {
            size   = obj.size,
            offset = obj.offset,
            colors = obj.colors.name,
        }
        
    end
    
    return json:stringify(t)
    
end

ArrowStyle = function(parameters)
    
    if type(parameters) == "string" then
        
        if all_arrow_styles[parameters] then
            
            return all_arrow_styles[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	--input is either nil or a table
	parameters = is_table_or_nil("ArrowStyle",parameters)
    
    local instance, size, offset, colors, name
    
    local  meta_setters = {
        size   = function(v) size          = v  end,
        offset = function(v) offset        = v  end,
        colors = function(v) arrow_colors  =
            matches_nil_table_or_type(
                ColorScheme,
                "COLORSCHEME",
                type(v) == "string" and v or recursive_overwrite(v, default_arrow_colors)
            )
        end,
        name = function(v)
            if name ~= nil then all_arrow_styles[name] = nil end
            
            name = check_name( all_arrow_styles, instance, v, "ArrowStyle" )
        end,
    }
    local meta_getters = {
        name   = function() return name         end,
        size   = function() return size   or 20 end,
        offset = function() return offset or 10 end,
        colors = function() return arrow_colors end,
        type   = function() return "ARROWSTYLE" end,
    }
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    instance = setmetatable(
        {
            on_changed = function(self,object,update_function)
                
                children_using_this_style[object] = update_function
                
            end,
            styles_json = arrowstyles_json
        },
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters)
        }
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.name   = parameters.name 
    instance.size   = parameters.size
    instance.offset = parameters.offset
    instance.colors = parameters.colors
    
    return instance
    
end

--------------------------------------------------------------------------------

local all_border_styles = setmetatable({},{__mode = 'v'})

local borderstyles_json = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_border_styles) do
        
        t[name]           = {
            width         = obj.width,
            corner_radius = obj.corner_radius,
            colors        = obj.colors.name,
        }
        
    end
    
    return json:stringify(t)
    
end

BorderStyle = function(parameters)
    
    if type(parameters) == "string" then
        
        if all_border_styles[parameters] then
            
            return all_border_styles[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	parameters = is_table_or_nil("BorderStyle",parameters)
    
    
    local instance, width, corner_radius, colors, name
    
    local  meta_setters = {
        width         = function(v) width         = v   end,
        corner_radius = function(v) corner_radius = v   end,
        colors        = function(v) colors        =
            matches_nil_table_or_type(
                ColorScheme,
                "COLORSCHEME",
                type(v) == "string" and v or recursive_overwrite(v, default_border_colors)
            )
        end,
        name = function(v)
            
            if name ~= nil then all_border_styles[name] = nil end
            
            name = check_name( all_border_styles, instance, v, "BorderStyle" )
            
        end,
    }
    local meta_getters = {
        name          = function() return name                end,
        width         = function() return width         or 2  end,
        corner_radius = function() return corner_radius or 10 end,
        colors        = function() return colors              end,
        type          = function() return "BORDERSTYLE"       end,
    }
    
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    instance = setmetatable(
        {
            on_changed = function(self,object,update_function)
                
                children_using_this_style[object] = update_function
                
            end,
            styles_json = borderstyles_json 
        },
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters),
        }
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.name          = parameters.name 
    instance.width         = parameters.width
    instance.corner_radius = parameters.corner_radius
    instance.colors        = parameters.colors
    
    return instance
    
end

--------------------------------------------------------------------------------

local all_text_styles = setmetatable({},{__mode = 'v'})

local textstyles_json = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_text_styles) do
        
        t[name] = {}
        
        for property, value in pairs(obj:get_table()) do
            t[name][property] = value
        end
        t[name].colors = obj.colors.name
        
    end
    
    return json:stringify(t)
    
end

TextStyle = function(parameters)
    
    if type(parameters) == "string" then
        
        if all_text_styles[parameters] then
            
            return all_text_styles[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	parameters = is_table_or_nil("TextStyle",parameters)
    local colors,name
    local properties = {
        font  = "Sans 40px",
        alignment = "CENTER",
        justify = true,
        wrap    = true,
        x_offset = 0,
        y_offset = 0,
        type = "TEXTSTYLE",
    }
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    local instance
    instance = {
        set = function(_,parameters)
            
            for k,v in pairs(parameters) do
                
                instance[k] = v
                
            end
            
            update_children(children_using_this_style)
            
        end,
        get_table  = function() return properties end,
        on_changed = function(_,object,update_function)
            
            children_using_this_style[object] = update_function
            
        end,
        styles_json = textstyles_json 
    }
    
    
    local meta_setters = {
        colors    = function(v) 
            
            colors = matches_nil_table_or_type(
                ColorScheme,  "COLORSCHEME",
                type(v) == "string" and v or recursive_overwrite(v, default_text_colors)
            )
            
            return true
            
        end,
        name = function(v)
            
            if name ~= nil then all_text_styles[name] = nil end
            
            name = check_name( all_text_styles, instance, v, "TextStyle" )
            
            return true
            
        end,
    }
    
    local meta_getters = {
        colors = function() return colors end,
        name   = function() return name   end,
    }
    
    setmetatable(
        
        instance,
        
        {
            
            __newindex = function(t,k,v)
                
                func_upval = meta_setters[k]
                
                if      func_upval then func_upval(v)
                elseif k ~= "type" then properties[k] = v end
                
                update_children(children_using_this_style)
                
            end,
            
            __index    = function(t,k)
                
                func_upval = meta_getters[k]
                
                if func_upval then return func_upval()
                else return properties[k] end
                
            end
            
        }
    )
    
    if parameters.colors == nil then instance.colors = nil end
    instance.name = parameters.name 
    instance:set(parameters)
    
    properties.color = parameters.color or instance.colors.default
    
    return instance
    
end

--------------------------------------------------------------------------------

local all_styles =  setmetatable({},{__mode = 'v'})

local styles_json = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_styles) do
        
        t[name]         = {
            arrow       = obj.arrow.name,
            border      = obj.border.name,
            text        = obj.text.name,
            fill_colors = obj.fill_colors.name,
        }
        
    end
    
    return json:stringify(t)
    
end
Style = function(parameters)
	
    if type(parameters) == "string" then
        
        if all_styles[parameters] then
            
            return all_styles[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
    parameters = is_table_or_nil("Style",parameters)
    
    local instance, arrow, border,text, fill_colors, name
    
    local meta_setters = {
        arrow          = function(v) arrow       = matches_nil_table_or_type(ArrowStyle,  "ARROWSTYLE",  v)  end,
        border         = function(v) border      = matches_nil_table_or_type(BorderStyle, "BORDERSTYLE", v)  end,
        text           = function(v) text        = matches_nil_table_or_type(TextStyle,   "TEXTSTYLE",   v)  end,
        fill_colors    = function(v) fill_colors = 
            matches_nil_table_or_type(
                ColorScheme,
                "COLORSCHEME",
                type(v) == "string" and v or recursive_overwrite(v, default_fill_colors)
            )
        end,
        name = function(v)
            
            if name ~= nil then all_styles[name] = nil end
            
            name = check_name( all_styles, instance, v, "Style" )
            
        end,
    }
    local meta_getters = {
        name        = function() return name        end,
        arrow       = function() return arrow       end,
        border      = function() return border      end,
        text        = function() return text        end,
        fill_colors = function() return fill_colors end,
        type        = function() return "STYLE"     end,
    }
    
    instance = setmetatable(
        { styles_json = styles_json },
        {
            __newindex = function(t,k,v)
                
                func_upval = meta_setters[k]
                
                return func_upval and func_upval(v)
                
            end,
            __index    = __index(meta_getters)
        }
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.name        = parameters.name 
    instance.arrow       = parameters.arrow
    instance.border      = parameters.border
    instance.text        = parameters.text
    instance.fill_colors = parameters.fill_colors
    
    return instance
    
end