
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

object_shell = function()
    return {
        __index = function(self,k) return getmetatable(self)[k] end,
        __call  = function(self,p) return self:declare():set(p or {}) end,
    
        public = { properties = {}, functions = {}, },
        
        --throw error for creating any variable outside of private
        private = { variables = {--[[defaults values]]}, functions = {} },
        update_functions = { --[[flag = function]] }, -- need order
        update_flag_order = {},
        update = function(instance,_ENV)
            return function()
                for i,flag in ipairs(update_flag_order) do
                    if _ENV[flag] then update_functions[flag]() end
                end
            end
        end,
        declare = function() end,
    }
end
image_set_interface = function(make_default,on_change)
    
    local table_of_images = {}
    local interface = setmetatable({},{
        
        __index = function(_,k) return table_of_images[k] end,
        
        __newindex = function(_,k,v)
            
            v = is_ui_element(v) and v or
                error("Expected UIElement. Received "..tostring(v),3)
                
            if on_change then on_change(table_of_images[k],v) end
            
            table_of_images[k] = v
            
        end,
    })
    return function(self) return interface end, --getter
        function(self,v) --setter
            table_of_images = {}
            
            --if passed nil, make the defaults
            v = v or make_default()
            
            if type(v) == "table" then
                for state,image in pairs(v) do
                    interface[state] = image
                end
            elseif is_ui_element(v) then
                interface.default=v
            else
                error("Expected nil, table of UIElements, or a UIElement, received "..tostring(v),2)
            end
        end
end
array_interface = function(t)
    return {
        
    }
end
table_interface = function(t)
    local setter = {
        label    = function(v) tb.label = v end,
        contents = function(v) 
            tb.contents:unparent()
            tb.contents = v
            panes_obj:add(v)
            if not tb.selected then v:hide() end
        end,
    }
    local getter = {
        label    = function() return tb.label end,
        contents = function() return tb.contents end,
    }
    local interface = setmetatable({},{
        __index = function(_,k)
            return getter[k] and getter[k]()
        end,
        __newindex = function(_,k,v)
            return setter[k] and setter[k](v)
        end,
    })
    return {
        
    }
end
setup_object = function(self,instance,env)
    
    for name,f in pairs(self.private or {}) do
        
        env[name] = f( instance, env )
        
    end
    
    for name,f in pairs(self.public.properties or {}) do
        
        getter, setter = f( instance, env )
        
        override_property( instance, name, getter, setter )
        
    end
    
    for name,f in pairs(self.public.functions or {}) do
        
        override_function( instance, name, f( instance, env ) )
        
    end
    
    for t,f in pairs(self.subscriptions or {}) do
        
        instance:subscribe_to(  t, f( instance, env )  )
        
    end
    
end