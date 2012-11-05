
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

object_shell = function()
    return {
        __index = function(self,k) return getmetatable(self)[k] end,
        __call  = function(self,p) return self:declare():set(p or {}) end,
    
        public = { properties = {}, functions = {}, },
        
        private = {},
        declare = function() end,
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