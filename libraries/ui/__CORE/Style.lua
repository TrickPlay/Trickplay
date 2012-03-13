

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
    
    local instance = {}
    
    local children_using_this_style = {}
    
    setmetatable( children_using_this_style, { __mode = "k" } )
    
    local size   = parameters.size   or 20
    local offset = parameters.offset or 10
    local colors = 
        type(parameters.colors) == "nil"   and ColorScheme{
                                                    default = {255,255,255},
                                                    focus = {255,255,255},
                                                    activation = {255,0,0}
                                                } or
        type(parameters.colors) == "table" and parameters.colors.type == "COLORSCHEME" and parameters.colors   or
        error("Must pass nil or ColorScheme to Style.fill_colors",  2)
    
    function instance:on_changed(object,update_function)
        
        children_using_this_style[object] = update_function
        
    end
    
    local  meta_setters = {
        size          = function(v) size          = v              end,
        offset        = function(v) offset        = v              end,
        arrow_colors  = function(v) arrow_colors  = ColorScheme(v) end,
    }
    local meta_getters = {
        size          = function() return size         end,
        offset        = function() return offset       end,
        arrow_colors  = function() return arrow_colors end,
        type          = function() return "ARROWSTYLE" end,
    }
    
    setmetatable(
        instance,
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters)
        }
    )
    
    return instance
    
end

BorderStyle = function(parameters)
    
	parameters = is_table_or_nil("BorderStyle",parameters)
    
    local instance = {}
    
    local children_using_this_style = {}
    
    setmetatable( children_using_this_style, { __mode = "k" } )
    
    local width         = parameters.width         or 2
    local corner_radius = parameters.corner_radius or 20
    local colors        = 
        type(parameters.colors) == "nil"   and ColorScheme{
                                                    default = {255,255,255},
                                                    focus = {255,255,255},
                                                    activation = {255,0,0}
                                                } or
        type(parameters.colors) == "table" and parameters.colors.type == "COLORSCHEME" and parameters.colors   or
        error("Must pass nil or ColorScheme to Style.fill_colors",  2)
        
    function instance:on_changed(object,update_function)
        
        children_using_this_style[object] = update_function
        
    end
    
    local  meta_setters = {
        width         = function(v) width         = v              end,
        corner_radius = function(v) corner_radius = v              end,
        colors        = function(v) colors        = ColorScheme(v) end,
    }
    local meta_getters = {
        width         = function() return width         end,
        corner_radius = function() return corner_radius end,
        colors        = function() return colors        end,
        type          = function() return "BORDERSTYLE" end,
    }
    
    setmetatable(
        instance,
        {
            __newindex = __newindex(meta_setters, children_using_this_style),
            __index    = __index(meta_getters),
        }
    )
    
    return instance
    
end


TextStyle = function(parameters)
    
	parameters = is_table_or_nil("TextStyle",parameters)
    
    local properties = {
        font  = "Sans 40px",
        alignment = "CENTER",
        justify = true,
        wrap    = true,
        colors = ColorScheme{default = {255,255,255}, focus = {255,255,255}, activation = {255,0,0}},
        x_offset = 0,
        y_offset = 0,
        type = "TEXTSTYLE",
        color = {255,255,255},
    }
    
    local children_using_this_style = {}
    
    setmetatable( children_using_this_style, { __mode = "k" } )
    
    local instance = {
        set = function(_,parameters)
            
            for k,v in pairs(parameters) do
                
                properties[k] = v
                
            end
            
            update_children(children_using_this_style)
            
        end,
        get_table = function() return properties end,
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
    
    local arrow       = type(parameters.arrow)  == "nil" and ArrowStyle()  or type(parameters.arrow)   == "table" and parameters.arrow.type  == "ARROWSTYLE"  and parameters.arrow  or error("Must pass nil or ArrowStyle to Style.arrow",   2)
    local border      = type(parameters.border) == "nil" and BorderStyle() or type(parameters.border)  == "table" and parameters.border.type == "BORDERSTYLE" and parameters.border or error("Must pass nil or BorderStyle to Style.border", 2)
    local text        = type(parameters.text)   == "nil" and TextStyle()   or type(parameters.text)    == "table" and parameters.text.type   == "TEXTSTYLE"   and parameters.text   or error("Must pass nil or TextStyle to Style.text",     2)
    
    local fill_colors =
        type(parameters.fill_colors) == "nil"   and ColorScheme{
                                                        default = {0,0,0},
                                                        focus = {155,155,155},
                                                        activation = {155,155,155}
                                                    }   or
        type(parameters.fill_colors) == "table" and parameters.fill_colors.type == "COLORSCHEME" and parameters.fill_colors   or
        error("Must pass nil or ColorScheme to Style.fill_colors",  2)
    
    
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