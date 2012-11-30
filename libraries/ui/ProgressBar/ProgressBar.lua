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
        
        return Rectangle{name = "fill", size={1,self.h-2*self.style.border.width},color=self.style.fill_colors.activation or "ff0000"}
        
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
                w = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) resize = true w = v end
                end,
                width = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) resize = true w = v end
                end,
                h = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) resize = true h = v end
                end,
                height = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) resize = true h = v end
                end,
                size = function(instance,_ENV)
                    return function(oldf) return {w,h}     end,
                    function(oldf,self,v) 
                        resize = true 
                        w = v[1]
                        h = v[2]
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "ProgressBar" end
                end,
                progress = function(instance,_ENV)
                    return function(oldf) return progress end,
                    function(oldf,self,v)
                        
                        progress = v
                        print(v)
                        if fill then expand_fill() end
                    end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self) 
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
            expand_fill = function(instance,_ENV)
                return function() 
                    print(progress)
                    scale_t[1] = progress
                    fill.scale = scale_t
                end
            end,
            update = function(instance,_ENV)
                return function()
                    if resize then
                        resize = false
                        redraw_shell = true
                        redraw_fill = true
                    end
                    if redraw_shell then
                        redraw_shell = false
                        if shell then shell:unparent() end
                        shell = create_shell(instance)
                        add(instance,shell)
                        shell:lower_to_bottom()
                    end
                    if redraw_fill then
                        redraw_fill = false
                        if fill then fill:unparent() end
                        fill = create_fill(instance)
                        print(fill)
                        fill.w = shell.w-2*instance.style.border.width
                        fill.scale = scale_t
                        add(instance,fill)
                        
                        fill.x = instance.style.border.width
                        fill.y = instance.style.border.width
                        
                        expand_fill()
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, _ENV = Widget()
            
            
            redraw_shell = false
            redraw_fill  = false
            fill  = false
            shell = false
            progress = 0
            scale_t = {0,1}
            
            w = 1
            h = 1
            style_flags = {
                border = {
                    "redraw_fill",
                    "redraw_shell",
                },
                fill_colors = {
                    "redraw_fill",
                    "redraw_shell",
                },
            }
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance:set(parameters)
            updating = false
            
            return instance, _ENV
            
        end
    }
)
external.ProgressBar = ProgressBar