
local function is_color(v)
    
    if type(v) ~= "string" and type(v) ~= "table" then
        
        return false
        
    end
    
    return v
    
end


ColorScheme = function(parameters)
    
    if parameters == nil then
        parameters = {}
    elseif type(parameters) ~= "table" then
        error("ColorScheme requires a table or nil as input",2)
    end
    
    local instance = {}
    
    local children_using_this_style = {}
    
    setmetatable( children_using_this_style, { __mode = "k" } )
    
    local default    = is_color(parameters.default)    or error("must define 'default'",4)
    local focus      = is_color(parameters.focus)      or error("must define 'focus'",  4)
    local activation = is_color(parameters.activation) or error("must define 'activation'", 4)
    
    
    local  meta_setters = {
        default    = function(v) default     = is_color(v) or error("must define 'default'",    4) end,
        focus      = function(v) focus       = is_color(v) or error("must define 'focus'",      4) end,
        activation = function(v) activation  = is_color(v) or error("must define 'activation'", 4) end,
    }
    local meta_getters = {
        default    = function() return default       end,
        focus      = function() return focus         end,
        activation = function() return activation    end,
        type       = function() return "COLORSCHEME" end,
    }
    
    
    function instance:on_changed(object,update_function)
        
        children_using_this_style[object] = update_function
        
    end
    
    setmetatable(
        instance,
        {
            __newindex = function(t,k,v)
                
                func_upval = meta_setters[k]
                
                if func_upval then
                    
                    func_upval(v)
                    
                    collectgarbage("collect")
                    
                    for _,update in pairs(children_using_this_style) do
                        
                        update(real_table)
                        
                    end
                    
                end
                
            end,
            __index = function(t,k)
                
                func_upval = meta_getters[k]
                
                return func_upval and func_upval()
                
            end
        }
    )
    
    
    return instance
    
end





