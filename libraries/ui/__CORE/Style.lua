
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

ArrowStyle = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("ArrowStyle",parameters)
    
    local size, offset, colors
    
    local  meta_setters = {
        size          = function(v) size          = v  end,
        offset        = function(v) offset        = v  end,
        arrow_colors  = function(v) arrow_colors  = matches_nil_table_or_type(ColorScheme, "COLORSCHEME", cover_defaults(v, default_arrow_colors)) end,
    }
    local meta_getters = {
        size          = function() return size   or 20 end,
        offset        = function() return offset or 10 end,
        arrow_colors  = function() return arrow_colors end,
        type          = function() return "ARROWSTYLE" end,
    }
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    local instance = setmetatable(
        {on_changed = function(self,object,update_function)
            children_using_this_style[object] = update_function
        end},
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters)
        }
    )
    
    instance.size   = parameters.size
    instance.offset = parameters.offset
    instance.colors = parameters.colors
    
    return instance
    
end

BorderStyle = function(parameters)
    
	parameters = is_table_or_nil("BorderStyle",parameters)
    
    
    local width, corner_radius, colors
    
    local  meta_setters = {
        width         = function(v) width         = v   end,
        corner_radius = function(v) corner_radius = v   end,
        colors        = function(v) colors        = matches_nil_table_or_type(ColorScheme, "COLORSCHEME", cover_defaults(v, default_border_colors)) end,
    }
    local meta_getters = {
        width         = function() return width         or 2  end,
        corner_radius = function() return corner_radius or 20 end,
        colors        = function() return colors              end,
        type          = function() return "BORDERSTYLE"       end,
    }
    
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    local instance = setmetatable(
        {on_changed = function(self,object,update_function)
            children_using_this_style[object] = update_function
        end},
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters),
        }
    )
    
    instance.width         = parameters.width
    instance.corner_radius = parameters.corner_radius
    instance.colors        = parameters.colors
    
    return instance
    
end


TextStyle = function(parameters)
    
	parameters = is_table_or_nil("TextStyle",parameters)
    
    local properties = {
        font  = "Sans 40px",
        alignment = "CENTER",
        justify = true,
        wrap    = true,
        x_offset = 0,
        y_offset = 0,
        type = "TEXTSTYLE",
    }
    
    
    parameters.colors = matches_nil_table_or_type(ColorScheme, "COLORSCHEME", cover_defaults(parameters.colors, default_text_colors))
    
    properties.color = parameters.color or parameters.colors.default
    
    
    local children_using_this_style = setmetatable( {}, { __mode = "k" } )
    
    local instance = {
        set = function(_,parameters)
            
            for k,v in pairs(parameters) do
                
                properties[k] = v
                
            end
            
            update_children(children_using_this_style)
            
        end,
        get_table  = function() return properties end,
        on_changed = function(_,object,update_function)
            
            children_using_this_style[object] = update_function
            
        end,
    }
    
    
    instance:set(parameters)
    
    setmetatable(
        
        instance,
        
        {
            
            __newindex = function(t,k,v)
                
                if k ~= "type" then
                    
                    properties[k] = v
                    
                    update_children(children_using_this_style)
                    
                end
            end,
            
            __index    = function(t,k)   return properties[k]  end
            
        }
    )
    
    return instance
    
end

Style = function(parameters)
	parameters = is_table_or_nil("Style",parameters)
    
    local instance = {}
    
    local arrow       = matches_nil_table_or_type(ArrowStyle,  "ARROWSTYLE",  parameters.arrow)
    local border      = matches_nil_table_or_type(BorderStyle, "BORDERSTYLE", parameters.border)
    local text        = matches_nil_table_or_type(TextStyle,   "TEXTSTYLE",   parameters.text)
    local fill_colors = matches_nil_table_or_type(ColorScheme, "COLORSCHEME", cover_defaults(parameters.fill_colors, default_fill_colors))
    
    local meta_setters = {
        arrow          = function(v) arrow       = ArrowStyle(v)  end,
        border         = function(v) border      = BorderStyle(v) end,
        text           = function(v) text        = TextStyle(v)   end,
        fill_colors    = function(v) fill_colors = ColorScheme(v) end,
    }
    local meta_getters = {
        arrow          = function() return arrow       end,
        border         = function() return border      end,
        text           = function() return text        end,
        fill_colors    = function() return fill_colors end,
        type           = function() return "STYLE"     end,
    }
    
    setmetatable(
        instance,
        {
            __newindex = function(t,k,v)
                
                func_upval = meta_setters[k]
                
                return func_upval and func_upval(v)
                
            end,
            __index    = __index(meta_getters)
        }
    )
    
    return instance
    
end