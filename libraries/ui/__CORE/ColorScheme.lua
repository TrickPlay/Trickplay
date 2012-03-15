
local function is_color(v)
    
    if type(v) ~= "string" and type(v) ~= "table" then
        
        return false
        
    end
    
    return v
    
end


ColorScheme = function(parameters)
    
	parameters = is_table_or_nil("ColorScheme",parameters)
    
    local instance = {}
    
    local default, focus, activation
    
    local  meta_setters = {
        default    = function(v) default     = is_color(v) end,--error("must define 'default'",    4) end,
        focus      = function(v) focus       = is_color(v) end,--error("must define 'focus'",      4) end,
        activation = function(v) activation  = is_color(v) end,--error("must define 'activation'", 4) end,
        --selection  = function(v) selection   = is_color(v) or error("must define 'activation'", 4) end,
    }
    local meta_getters = {
        default    = function() return default    or "00000000"     end,
        focus      = function() return focus      or "00000000"     end,
        activation = function() return activation or "00000000"   end,
        type       = function() return "COLORSCHEME" end,
    }
    
    
    
    local children_using_this_style = {}
    
    setmetatable( children_using_this_style, { __mode = "k" } )
    
    function instance:on_changed(object,update_function)
        
        children_using_this_style[object] = update_function
        
    end
    function instance:update()
        
        collectgarbage("collect")
        
        for _,update in pairs(children_using_this_style) do
            
            update(real_table)
            
        end
        
    end
    
    setmetatable(
        instance,
        {
            __newindex = function(t,k,v)
                
                func_upval = meta_setters[k]
                
                if func_upval then
                    
                    func_upval(v)
                    
                    t:update()
                    
                else
                    
                    rawset(t,k,v)
                    
                end
                
            end,
            __index = function(t,k)
                
                func_upval = meta_getters[k]
                
                return func_upval and func_upval()
                
            end
        }
    )
    
    for k,v in pairs(parameters) do instance[k] = v  end
    
    return instance
    
end





