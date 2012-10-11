
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

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