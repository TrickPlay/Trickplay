PROGRESSBAR = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local create_fill = function(self)
    
    if self.style.fill_colors.focus_upper and self.style.fill_colors.focus_lower then
        
        local h = self.h-2*self.style.border.width
        local c = Canvas(1, h < 1 and 1 or h)
        
        c:rectangle(-1,0,3,c.h )
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.fill_colors.focus_upper )
        c:add_source_pattern_color_stop( 1 , self.style.fill_colors.focus_lower )
        c:fill()
        
    local rv = c:Image{name = "fill"} 
    print("rv",rv)
        return rv 
        
    else
        
        return Rectangle{name = "fill", size={1,self.h-2*self.style.border.width},color=self.style.fill_colors.focus or "ff0000"}
        
    end
    
end

local create_shell = function(self)
    
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
    
    if self.style.fill_colors.default_upper and self.style.border.colors.default_lower then
        
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.fill_colors.default_upper )
        c:add_source_pattern_color_stop( 1 , self.style.fill_colors.default_lower )
        
        c:fill(true)
        
    else
        
        c:set_source_color( self.style.fill_colors.default or "000000" )
        
        c:fill(true)
        
    end
    
    if self.style.border.colors.default_upper and self.style.border.colors.default_lower then
        
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.border.colors.default_upper )
        c:add_source_pattern_color_stop( 1 , self.style.border.colors.default_lower )
        
        c:stroke()
        
    else
        
        c:set_source_color( self.style.border.colors.default or "ffffff" )
        
        c:stroke()
        
    end
    local rv = c:Image{name = "shell"} 
    print("rv",rv)
    return rv
    
end

local default_parameters = {
    w = 200, 
    h = 50,--[[
    style = {
        fill_colors = {
            default_upper = {  0,  0,  0,255},
            default_lower = {127,127,127,255},
            focus_upper   = {255,  0,  0,255},
            focus_lower   = { 96, 48, 48,255},
        },
        border = { 
            corner_radius = 10,
            colors = { default_upper = "ffffff",default_lower = "444444"}
        }
    }--]]
}
ProgressBar = setmetatable(
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
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.resize = true env.w = v end
                end,
                width = function(instance,env)
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.resize = true env.w = v end
                end,
                h = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.resize = true env.h = v end
                end,
                height = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.resize = true env.h = v end
                end,
                size = function(instance,env)
                    return function(oldf) return {env.w,env.h}     end,
                    function(oldf,self,v) 
                        env.resize = true 
                        env.w = v[1]
                        env.h = v[2]
                    end
                end,
                widget_type = function(instance,env)
                    return function() return "ProgressBar" end
                end,
                progress = function(instance,env)
                    return function(oldf) return progress end,
                    function(oldf,self,v)
                        
                        env.progress = v
                        
                        if env.fill then env.expand_fill() end
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf) 
                        local t = oldf(self)
                        
                        t.progress = self.progress
                        
                        t.type = "ProgressBar"
                        
                        return t
                    end
                end,
    
            },
            functions = {
            },
        },
        private = {
            expand_fill = function(instance,env)
                return function() 
                    env.scale_t[1] = env.progress
                    env.fill.scale = env.scale_t
                end
            end,
            update = function(instance,env)
                return function()
                    if env.resize then
                        env.resize = false
                        env.redraw_shell = true
                        env.redraw_fill = true
                    end
                    if env.redraw_shell then
                        env.redraw_shell = false
                        if env.shell then env.shell:unparent() end
                        env.shell = create_shell(instance)
                        env.add(instance,env.shell)
                        env.shell:lower_to_bottom()
                    end
                    if env.redraw_fill then
                        env.redraw_fill = false
                        if env.fill then env.fill:unparent() end
                        env.fill = create_fill(instance)
                        print(env.fill)
                        env.fill.w = env.shell.w-2*instance.style.border.width
                        env.fill.scale = env.scale_t
                        env.add(instance,env.fill)
                        
                        env.fill.x = instance.style.border.width
                        env.fill.y = instance.style.border.width
                        
                        env.expand_fill()
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            
            env.redraw_shell = false
            env.redraw_fill  = false
            env.fill  = false
            env.shell = false
            env.progress = 0
            env.scale_t = {0,1}
            
            env.w = 1
            env.h = 1
            env.style_flags = {
                border = {
                    "redraw_fill",
                    "redraw_shell",
                },
                fill_colors = {
                    "redraw_fill",
                    "redraw_shell",
                },
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
external.ProgressBar = ProgressBar