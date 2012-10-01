PROGRESSSPINNER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local canvas_dot = function(self)
	print(self.w,self.h)
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	local c1 = self.style.border.colors.default
	local c2 = self.style.fill_colors.default
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,0,360)
	c:set_source_color(c2)
	c:fill(true)
	c:set_source_color(c1)
	c:stroke()
	
	c:move_to(c.w/2,c.line_width/2)
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,270,360)
	c:line_to(c.w/2,c.h/2)
	c:line_to(c.w/2,c.line_width/2)
	c:set_source_color(c1)
	c:fill()
	
	c:move_to(c.w/2,c.h - c.line_width/2)
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,90,180)
	c:line_to(c.w/2,c.h/2)
	c:line_to(c.w/2,c.h - c.line_width/2)
	c:fill()
	
	return c:Image()
	
end

local default_parameters = {w = 100, h = 100, duration = 2000}


ProgressSpinner = setmetatable(
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
                image = function(instance,env)
                    return function(oldf) return env.image     end,
                    function(oldf,self,v) 
                        return v == nil and env.make_canvas() or
                            
                            type(v) == "string" and env.setup_image( Image{ src = v } ) or
                            
                            type(v) == "userdata" and v.__types__.actor and env.setup_image(v) or
                            
                            error("ProgressSpinner.image expected type 'table'. Received "..type(v),2) 
                    end
                end,
                duration = function(instance,env)
                    return function(oldf) return env.duration     end,
                    function(oldf,self,v) env.duration = v end
                end,
                animating = function(instance,env)
                    return function(oldf) return env.animating     end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "boolean" then
                        elseif env.animating == v then
                            
                            return
                            
                        end
                        
                        env.animating = v
                        
                        if env.animating then
                            env.start_animation = true
                        else
                            env.stop_animation = true
                        end
                    end
                end,
                w = function(instance,env)
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.flag_for_redraw = true env.w = v end
                end,
                width = function(instance,env)
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.flag_for_redraw = true env.w = v end
                end,
                h = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.flag_for_redraw = true env.h = v end
                end,
                height = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.flag_for_redraw = true env.h = v end
                end,
                size = function(instance,env)
                    return function(oldf) return {env.w,env.h}     end,
                    function(oldf,self,v) 
                        env.flag_for_redraw = true 
                        env.w = v[1]
                        env.h = v[2]
                    end
                end,
                widget_type = function(instance,env)
                    return function() return "ProgressSpinner" end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.animating = self.animating
                        t.duration = self.duration
                        
                        if (not canvas) and env.image.src and env.image.src ~= "[canvas]" then 
                            
                            t.image = env.image.src
                            
                        end
                        t.type = "ProgressSpinner"
                        
                        return t
                    end
                end,
    
            },
            functions = {
            },
        },
        private = {
            make_canvas = function(instance,env)
                return function() 
                    env.canvas = true
                    
                    if env.image then env.image:unparent() end
                    
                    env.image = canvas_dot(instance)
                    
                    env.add( instance, env.image )
                    
                    env.image:move_anchor_point(env.image.w/2,env.image.h/2)
                    env.image:move_by(env.image.w/2,env.image.h/2)
                    
                    return true
                end
            end,
            resize_images = function(instance,env)
                return function() 
                    if not size_is_set then return end
                    
                    env.image.w = instance.w
                    env.image.h = instance.h
                end
            end,
            setup_image = function(instance,env)
                return function(v) 
                    env.canvas = false
                    
                    if env.image then env.image:unparent() end
                    
                    env.image = v
                    
                    env.add( instance, v )
                    
                    v:move_anchor_point(v.w/2,v.h/2)
                    v:move_by(v.w/2,v.h/2)
                    
                    if instance.is_size_set() then
                        
                        env.resize_images()
                        
                    else
                        
                        --so that the label centers properly
                        instance.size = v.size
                        
                        instance:reset_size_flag()
                        
                    end
                    
                    return true
                end
            end,
            update = function(instance,env)
                return function()
                    if env.flag_for_redraw then
                        env.flag_for_redraw = false
                        if env.canvas then
                            env.make_canvas()
                        else
                            env.resize_images()
                        end
                    end
                    if env.reanimate then
                        env.reanimate = false
                        
                        env.stop_animation = true
                        env.start_animation = true
                        
                    end
                    if  env.stop_animation then
                        env.stop_animation = false
                        env.image:stop_animation()
                        env.image.z_rotation = {0,0,0}
                    end
                    if env.start_animation then
                        env.start_animation = false
                        
                        env.image:animate{
                            duration   = env.duration,
                            z_rotation = 360,
                            loop       = true,
                        }
                        
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            env.duration  = 1000
            env.image     = false
            env.animating = false
            
            env.canvas = true
            env.flag_for_redraw = true
            
            env.w = 1
            env.h = 1
            env.style_flags = {
                border = "flag_for_redraw",
                fill_colors = "flag_for_redraw",
            }
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
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
            
            --env.subscribe_to_sub_styles()
            
            --instance.images = nil
            env.updating = true
            instance:set(parameters)
            env.updating = false
            
            return instance, env
            
        end
    }
)
external.ProgressSpinner = ProgressSpinner