SCROLLPANE = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local create_arrow = function(old_function,self,state)
	
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    
	c:set_source_color( self.style.fill_colors[state] )     c:fill(true)
	
	return c:Image()
	
end

local default_parameters = {pane_w = 450, pane_h = 600,virtual_w=1000,virtual_h=1000, slider_thickness = 30}


ScrollPane = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        subscriptions = {
            --[[
            ["style"] = function(instance,env)
                return function()
                    
                    instance.style.arrow:subscribe_to(         nil, env.arrow_on_changed )
                    instance.style.arrow.colors:subscribe_to(  nil, env.arrow_colors_on_changed )
                    instance.style.border:subscribe_to(        nil, env.pane_on_changed )
                    instance.style.fill_colors:subscribe_to(   nil, env.pane_on_changed )
                    
                    env.arrow_on_changed()
                    env.arrow_colors_on_changed()
                end
            end,
            --]]
        },
        public = {
            properties = {
                enabled = function(instance,env)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)
                        
                        env.horizontal.enabled = v
                        env.vertical.enabled   = v
                    end
                end,
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
                    return function(oldf) return env.pane.virtual_w     end,
                    function(oldf,self,v)        env.pane.virtual_w = v env.new_w = true end
                end,
                virtual_h = function(instance,env)
                    return function(oldf) return env.pane.virtual_h     end,
                    function(oldf,self,v)        env.pane.virtual_h = v env.new_h = true end
                end,
                virtual_x = function(instance,env)
                    return function(oldf) return env.pane.virtual_x     end,
                    function(oldf,self,v) env.pane.virtual_x = v end
                end,
                virtual_y = function(instance,env)
                    return function(oldf) return env.pane.virtual_y     end,
                    function(oldf,self,v) env.pane.virtual_y = v end
                end,
                pane_w = function(instance,env)
                    return function(oldf) return env.pane.w     end,
                    function(oldf,self,v) 
                        env.horizontal.track_w = v
                        env.horizontal.grip_w  = v/10
                        env.pane.w = v 
                        env.new_w = true 
                    end
                end,
                pane_h = function(instance,env)
                    return function(oldf) return env.pane.h     end,
                    function(oldf,self,v) 
                        env.vertical.track_h   = v
                        env.vertical.grip_h    = v/10
                        env.pane.h = v  
                        env.new_h = true 
                    end
                end,
                slider_thickness = function(instance,env)
                    return function(oldf) return env.slider_thickness     end,
                    function(oldf,self,v) 
            
                        env.horizontal.track_h = v
                        env.horizontal.grip_h  = v
                        env.vertical.track_w   = v
                        env.vertical.grip_w    = v
                        env.slider_thickness   = v 
                        --TODO - set a flag like this: env.new_h = true 
                    end
                end,
                arrow_move_by = function(instance,env)
                    return function(oldf) return env.move_by     end,
                    function(oldf,self,v) env.move_by = v end
                end,
                sets_x_to = function(instance,env)
                    return function(oldf) return env.pane.x_offset end,
                    function(oldf,self,v) 
                        env.pane.x_offset = v
                    end
                end,
                sets_y_to = function(instance,env)
                    return function(oldf) return env.pane.y_offset     end,
                    function(oldf,self,v) 
                        env.pane.y_offset = v
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "ScrollPane" end
                end,
                attributes = function(instance,env)
                    return function(oldf,self)
                    
                        local t = oldf(self)
                        
                        t.number_of_cols       = nil
                        t.number_of_rows       = nil
                        t.vertical_alignment   = nil
                        t.horizontal_alignment = nil
                        t.vertical_spacing     = nil
                        t.horizontal_spacing   = nil
                        t.cell_h               = nil
                        t.cell_w               = nil
                        t.cells                = nil
                        
                        t.style = instance.style
                        
                        t.contents = self.contents
                        
                        t.pane_w = instance.pane_w
                        t.pane_h = instance.pane_h
                        t.virtual_x = instance.virtual_x
                        t.virtual_y = instance.virtual_y
                        t.virtual_w = instance.virtual_w
                        t.virtual_h = instance.virtual_h
                        
                        t.slider_thickness = instance.slider_thickness
                        
                        t.children = {}
                        
                        for i, child in ipairs(env.pane.children) do
                            t.children[i] = child.attributes
                        end
                        
                        t.type = "ScrollPane"
                        
                        return t
                        
                    end
                end,
                children = function(instance,env)
                    return function(oldf) return env.pane.children     end,
                    function(oldf,self,v)        env.pane.children = v end
                end,
            },
            functions = {
                add    = function(instance,env) return function(oldf,self,...) env.pane:add(   ...) end end,
                remove = function(instance,env) return function(oldf,self,...) env.pane:remove(...) end end,
            },
        },
        private = {
            pane_on_changed = function(instance,env)
                return function() 
                    env.pane.style:set(instance.style.attributes)
                end
            end,
            update = function(instance,env)
                return function()
                    env.lm_update()
                    
                    if  env.new_w then
                        env.new_w = false
                        
                        if instance.virtual_w <= instance.pane_w then
                            env.horizontal:hide()
                        else
                            env.horizontal:show()
                        end
                    end
                    
                    if  env.new_h then
                        env.new_h = false
                        
                        if instance.virtual_h <= instance.pane_h then
                            env.vertical:hide()
                        else
                            env.vertical:show()
                        end
                    end
                    
                end
            end,
        },
        declare = function(self,parameters)
            
            --local instance, env = LayoutManager:declare()
            --local getter, setter
            
            local pane  = ClippingRegion{style = false}
            local horizontal = Slider()
            local vertical   = Slider{direction="vertical"}
            
            local instance, env = LayoutManager:declare{
                number_of_rows = 2,
                number_of_cols = 2,
                placeholder = Widget_Clone(),
                cells = {
                    {       pane, vertical },
                    { horizontal,      nil },
                },
            }
            local getter, setter
            
            env.pane = pane
            env.horizontal = horizontal
            env.vertical = vertical
            
            
            vertical:subscribe_to("progress",function()
                pane.virtual_y = vertical.progress * (pane.virtual_h - pane.h)
            end)
            horizontal:subscribe_to("progress",function()
                pane.virtual_x = horizontal.progress * (pane.virtual_w - pane.w)
            end)
            --[[
            instance:add_key_handler(keys.Up,       env.up.click)
            instance:add_key_handler(keys.Down,   env.down.click)
            instance:add_key_handler(keys.Left,   env.left.click)
            instance:add_key_handler(keys.Right, env.right.click)
    		env.up:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_y = env.pane.virtual_y - env.move_by
    		end)
    		
    		env.down:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_y = env.pane.virtual_y + env.move_by
    		end)
			
    		env.left:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_x = env.pane.virtual_x - env.move_by
    		end)
			
		    env.right:add_mouse_handler("on_button_up", function()
    	    	env.pane.virtual_x = env.pane.virtual_x + env.move_by
    		end)
            --]]
            
            env.lm_update = env.update
            env.new_w = true
            env.new_h = true
            env.move_by = 10
            env.slider_thickness = 30
            
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
            
            env.updating = true
            instance.pane_w           = env.pane.w
            instance.pane_h           = env.pane.h
            instance.slider_thickness = env.slider_thickness
            env.updating = false
            return instance, env
            
        end
    }
)
external.ScrollPane = ScrollPane
