PROGRESSSPINNER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local canvas_dot = function(self)--[[
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
	--]]
	return Sprite{w=self.w,h=self.h,sheet = self.style.spritesheet,id="ProgressSpinner/icon.png"}--c:Image()
	
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
                image = function(instance,_ENV)
                    return function(oldf) return image     end,
                    function(oldf,self,v) 
                        return v == nil and make_canvas() or
                            
                            type(v) == "string" and setup_image( Image{ src = v } ) or
                            
                            type(v) == "userdata" and v.__types__.actor and setup_image(v) or
                            
                            error("ProgressSpinner.image expected type 'table'. Received "..type(v),2) 
                    end
                end,
                duration = function(instance,_ENV)
                    return function(oldf) return duration     end,
                    function(oldf,self,v) duration = v end
                end,
                animating = function(instance,_ENV)
                    return function(oldf) return animating     end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "boolean" then
                        elseif animating == v then
                            
                            return
                            
                        end
                        
                        animating = v
                        
                        if animating then
                            start_animation = true
                        else
                            stop_animation = true
                        end
                    end
                end,
                w = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) flag_for_redraw = true w = v end
                end,
                width = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) flag_for_redraw = true w = v end
                end,
                h = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) flag_for_redraw = true h = v end
                end,
                height = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) flag_for_redraw = true h = v end
                end,
                size = function(instance,_ENV)
                    return function(oldf) return {w,h}     end,
                    function(oldf,self,v) 
                        flag_for_redraw = true 
                        w = v[1]
                        h = v[2]
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "ProgressSpinner" end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.animating = self.animating
                        t.duration = self.duration
                        
                        if (not canvas) and image.src and image.src ~= "[canvas]" then 
                            
                            t.image = image.src
                            
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
            make_canvas = function(instance,_ENV)
                return function() 
                    canvas = true
                    
                    if image then image:unparent() end
                    
                    image = canvas_dot(instance)
                    
                    add( instance, image )
                    
                    image:move_anchor_point(image.w/2,image.h/2)
                    image:move_by(image.w/2,image.h/2)
                    
                    return true
                end
            end,
            resize_images = function(instance,_ENV)
                return function() 
                    if not size_is_set then return end
                    
                    image.w = instance.w
                    image.h = instance.h
                end
            end,
            setup_image = function(instance,_ENV)
                return function(v) 
                    canvas = false
                    
                    if image then image:unparent() end
                    
                    image = v
                    
                    add( instance, v )
                    
                    v:move_anchor_point(v.w/2,v.h/2)
                    v:move_by(v.w/2,v.h/2)
                    
                    if instance.is_size_set() then
                        
                        resize_images()
                        
                    else
                        
                        --so that the label centers properly
                        instance.size = v.size
                        
                        instance:reset_size_flag()
                        
                    end
                    
                    return true
                end
            end,
            update = function(instance,_ENV)
                return function()
                    if flag_for_redraw then
                        flag_for_redraw = false
                        if canvas then
                            make_canvas()
                        else
                            resize_images()
                        end
                    end
                    if reanimate then
                        reanimate = false
                        
                        stop_animation = true
                        start_animation = true
                        
                    end
                    if  stop_animation then
                        stop_animation = false
                        image:stop_animation()
                        image.z_rotation = {0,0,0}
                    end
                    if start_animation then
                        start_animation = false
                        
                        image:animate{
                            duration   = duration,
                            z_rotation = 360,
                            loop       = true,
                        }
                        
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, _ENV = Widget()
            
            duration  = 1000
            image     = false
            animating = false
            
            canvas = true
            flag_for_redraw = true
            
            w = 1
            h = 1
            style_flags = {
                border = "flag_for_redraw",
                fill_colors = "flag_for_redraw",
            }
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance:set(parameters)
            updating = false
            
            return instance, _ENV
            
        end
    }
)
external.ProgressSpinner = ProgressSpinner