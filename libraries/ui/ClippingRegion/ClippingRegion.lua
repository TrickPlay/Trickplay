CLIPPINGREGION = true

local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000}

ClippingRegion = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        
        subscriptions = {
        },
        public = {
            properties = {
                w = function(instance,env)
                    return function(oldf,self) return env.w     end,
                    function(oldf,self,v) 
                        env.w = v
                        env.reclip = true
                        env.new_w  = true
                    end
                end,
                width = function(instance,env)
                    return function(oldf,self) return env.w     end,
                    function(oldf,self,v) 
                        env.w = v
                        env.reclip = true
                        env.new_w  = true
                    end
                end,
                h = function(instance,env)
                    return function(oldf,self) return env.h     end,
                    function(oldf,self,v) 
                        print("cr_h",v)
                        env.h = v
                        env.reclip = true
                        env.new_h  = true
                    end
                end,
                height = function(instance,env)
                    return function(oldf,self) return env.h     end,
                    function(oldf,self,v) 
                        env.h = v
                        env.reclip = true
                        env.new_h  = true
                    end
                end,
                size = function(instance,env)
                    return function(oldf,self) return {env.w,env.h} end,
                    function(oldf,self,v) 
                        env.w = v[1]
                        env.h = v[2]
                        env.reclip = true
                        env.new_w  = true
                        env.new_h  = true
                    end
                end,
                virtual_w = function(instance,env)
                    return function(oldf) return env.virtual_w     end,
                    function(oldf,self,v) 
                        env.virtual_w = v < instance.w  and instance.w or v 
                    end
                end,
                virtual_h = function(instance,env)
                    return function(oldf) return env.virtual_h end,
                    function(oldf,self,v) 
                        env.virtual_h = v < instance.h  and instance.h or v 
                    end
                end,
                virtual_x = function(instance,env)
                    return function(oldf) return -env.contents.x - env.x_offset end,
                    function(oldf,self,v) 
                        env.contents.x = bound_to(-(env.virtual_w - instance.w),env.x_offset - v,0)
                        env.reclip = true
                    end
                end,
                virtual_y = function(instance,env)
                    return function(oldf) return -env.contents.y - env.y_offset     end,
                    function(oldf,self,v) 
                        env.contents.y = bound_to(-(env.virtual_h - instance.h),env.y_offset - v,0)
                        env.reclip = true
                    end
                end,
                sets_x_to = function(instance,env)
                    return function(oldf) return env.x_offset end,
                    function(oldf,self,v) 
                        env.x_offset = v
                    end
                end,
                sets_y_to = function(instance,env)
                    return function(oldf) return env.y_offset     end,
                    function(oldf,self,v) 
                        env.y_offset = v
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "ClippingRegion" end
                end,
                children = function(instance,env)
                    return function(oldf) return env.contents.children     end,
                    function(oldf,self,v) 
                        if type(v) ~= "table" then error("Expected table. Received "..type(v), 2) end
                        env.contents:clear()
                        env.contents:add(unpack(v))
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf,self)
                        local t = oldf(self)
                        
                        t.virtual_x = instance.virtual_x
                        t.virtual_y = instance.virtual_y
                        t.virtual_w = instance.virtual_w
                        t.virtual_h = instance.virtual_h
                        t.sets_x_to = instance.sets_x_to
                        t.sets_y_to = instance.sets_y_to
                        
                        t.children = {}
                        
                        for i, child in ipairs(env.contents.children) do
                            t.children[i] = child.attributes
                        end
                        t.type = "ClippingRegion"
                        
                        return t
                    end
                end,
            },
            functions = {
                add    = function(instance,env) return function(oldf,self,...) env.contents:add(   ...) end end,
                remove = function(instance,env) return function(oldf,self,...) env.contents:remove(...) end end,
            },
        },
        private = {
            update = function(instance,env)
                return function()
                    
                    
                    if  env.restyle then
                        env.restyle = false
                        
                        env.border.border_width = instance.style.border.width 
                        env.border.border_color = instance.style.border.colors.default 
                        env.bg.color            = instance.style.fill_colors.default 
                        
                    end
                    if  env.new_w then
                        env.new_w = false
                        
                        env.bg.w     = env.w
                        env.border.w = env.w
                        
                        instance.virtual_w = instance.virtual_w --virtual_w must be <= w
                        instance.virtual_x = instance.virtual_x --virtual_x must be <= virtual_w - w
                        
                    end
                    
                    if  env.new_h then
                        env.new_h = false
                        
                        env.bg.h     = env.h
                        env.border.h = env.h
                        
                        instance.virtual_h = instance.virtual_h --virtual_h must be <= h
                        instance.virtual_y = instance.virtual_y --virtual_y must be <= virtual_h - h
                        
                    end
                    
                    if  env.reclip then
                        env.reclip = false
                        env.contents.clip = {
                            instance.virtual_x,
                            instance.virtual_y,
                            instance.w,
                            instance.h,
                        }
                    end
                    
                end
            end,
        },
        declare = function(self,parameters)
            
            local instance, env = Widget()
            local getter, setter
            
            env.style_flags = "restyle"
            
            env.bg       = Rectangle{ 
                name  = "Background",
                color = instance.style.fill_colors.default,
            }
            env.border   = Rectangle{ 
                name="Border",
                color = "00000000",
                border_color = instance.style.border.colors.default,
                border_width = instance.style.border.width,
            }
            
            env.contents = Group{     name="Contents"  }
            env.new_w = true
            env.new_h = true
            env.reclip = true
            --public attributes, set to false if there is no default
            env.w = 400
            env.h = 400
            env.virtual_w = 1000
            env.virtual_h = 1000
            env.virtual_x =    0
            env.virtual_y =    0
            env.x_offset  =    0
            env.y_offset  =    0
            
            env.add( instance, env.bg, env.contents, env.border )
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            instance.reactive = true
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)





--[[
ClippingRegion = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ClippingRegion",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ClippingRegion Object inherits from Widget
	
	local instance = Widget( parameters )
    local bg       = Rectangle{ name="Background"}
    local border   = Rectangle{ name="Border",color = "00000000"}
    local contents = Group{ name="Contents"}--,w=instance.virtual_w,h=instance.virtual_h}
	
    instance:add(bg,contents,border)
    
    ----------------------------------------------------------------------------
    
    local x_offset = 0
    local y_offset = 0
    
	override_property(instance,"virtual_w",
		function(oldf) return contents.w   end,
		function(oldf,self,v) 
            
            contents.w = v < instance.w  and instance.w or v 
            
        end
	)
	override_property(instance,"virtual_h",
		function(oldf) return contents.h     end,
		function(oldf,self,v) 
            
            contents.h = v < instance.h  and instance.h or v 
            
        end
	)
	override_property(instance,"virtual_x",
		function(oldf) return -contents.x - x_offset     end,
		function(oldf,self,v)  
            
            contents.x = bound_to(-(contents.w - instance.w),x_offset - v,0)
            env.reclip = true
        end    
	)
	override_property(instance,"virtual_y",
		function(oldf) return -contents.y - y_offset     end,
		function(oldf,self,v)  
            
            contents.y = bound_to(-(contents.h - instance.h),y_offset - v,0)
            env.reclip = true
            
        end 
	)
	override_property(instance,"w",
		function(oldf) return oldf()     end,
		function(oldf,self,v)  
            
            oldf(self,v)
            
            env.reclip = true
            env.new_w  = true
            
        end 
	)
	override_property(instance,"h",
		function(oldf) return oldf()     end,
		function(oldf,self,v)  
            
            oldf(self,v)
            
            env.reclip = true
            env.new_h  = true
            
        end 
	)
	override_property(instance,"sets_x_to",
		function(oldf) return x_offset     end,
		function(oldf,self,v) x_offset = v end
	)
	override_property(instance,"sets_y_to",
		function(oldf) return y_offset     end,
		function(oldf,self,v) y_offset = v end
	)
    
	override_property(instance,"contents",
		function(oldf) 
            local t = {}
            
            for i,child in pairs(contents.children) do
                a = child.attributes
                if a then
                    table.insert(t,a)
                end
                
            end
            
            return t     
        end,
		function(oldf,self,v) 
            
            for i,obj in ipairs(v) do
                
                if type(obj) == "table" and obj.type then 
                    
                    v[i] = _G[obj.type](obj)
                    
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                
                    error("Must be a UIElement or nil. Received "..obj,2) 
                    
                end
                
            end
            
            contents:clear()
            
            contents:add(unpack(v)) 
        end
	)
    
	override_property(instance,"widget_type",
		function() return "ClippingRegion" end, nil
	)
	override_function(instance,"add",
		function(oldf,self,...) contents:add(...) end
	)
    
	----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.virtual_x = self.virtual_x
            t.virtual_y = self.virtual_y
            t.virtual_w = self.virtual_w
            t.virtual_h = self.virtual_h
            t.sets_x_to = self.sets_x_to
            t.sets_y_to = self.sets_y_to
            
            t.contents = self.contents
            
            t.type = "ClippingRegion"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
	
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			
			bg.size     = instance.size
			border.size = instance.size
            
            instance.virtual_w = instance.virtual_w --virtual_w must be <= w
            instance.virtual_h = instance.virtual_h --virtual_h must be <= h
            instance.virtual_x = instance.virtual_x --virtual_x must be <= virtual_w - w
            instance.virtual_y = instance.virtual_y --virtual_y must be <= virtual_h - h
            
            contents.clip = {
                instance.virtual_x,
                instance.virtual_y,
                instance.w,
                instance.h,
            }
            
            
		end
	)
    
	instance:subscribe_to(
		{"virtual_x","virtual_y"},
		function()
            contents.clip = {
                instance.virtual_x,
                instance.virtual_y,
                instance.w,
                instance.h,
            }
        end
    )
	----------------------------------------------------------------------------
	
    local set_border_width = function() border.border_width = instance.style.border.width          end
    local set_border_color = function() border.border_color = instance.style.border.colors.default end
    local set_bg_color     = function() bg.color            = instance.style.fill_colors.default   end
    
    
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, set_border_width )
        instance.style.border.colors:subscribe_to(      nil, set_border_color )
        instance.style.fill_colors:subscribe_to( nil, set_bg_color )
        
		set_border_width()
		set_border_color()
		set_bg_color()
        
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	instance:set(parameters)
    
    contents.clip = {
        instance.virtual_x,
        instance.virtual_y,
        instance.w,
        instance.h,
    }
	return instance
	
end
--]]
