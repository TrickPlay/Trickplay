TOASTALERT = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


default_parameters = {
    title = "ToastAlert", 
    message_font="Sans 40px",
    message_color = "ffffff",
    vertical_message_padding   =   10,
    horizontal_message_padding =    5,
    horizontal_icon_padding    =   20,
    vertical_icon_padding      =   10,
    on_screen_duration         = 5000,
    animate_in_duration        =  500,
    animate_out_duration       =  500,
}



ToastAlert = setmetatable(
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
            
                widget_type = function(instance,env)
                    return function() return "ToastAlert" end, nil
                end,
                icon = function(instance,env)
                    return function(oldf,...) return env.icon     end,
                    function(oldf,self,v) 
                        
                        if env.icon then env.icon:unparent() end
                        
                        if v == nil then
                            
                            env.icon = Text{text="!",color = instance.style.border.colors.default,font = "Sans 60px"}
                            
                        elseif type(v) == "string" then
                            
                            env.icon = Image{ src = v }
                            
                            if env.icon == nil then
                                
                                error("ToastAlert.icon recieved string but it was not a valid image uri",2)
                                
                            end
                            
                        elseif type(v) == "userdata" and v.__types__.actor then
                            
                            env.icon = v
                            
                        else
                            
                            error("ToastAlert.icon expected string uri or UIElement. Received "..type(v),2)
                            
                        end
                        
                        instance:add(env.icon)
                    end
                end,
                message = function(instance,env)
                    return function(oldf,...) return env.message.text     end,
                    function(oldf,self,v)            env.message.text = v end
                end,
                message_color = function(instance,env)
                    return function(oldf,...) return env.message.color     end,
                    function(oldf,self,v) print(v)   env.message.color = v end
                end,
                message_font = function(instance,env)
                    return function(oldf,...) return env.message.font     end,
                    function(oldf,self,v)            env.message.font = v end
                end,
                horizontal_message_padding = function(instance,env)
                    return function(oldf,...) return env.horizontal_message_padding     end,
                    function(oldf,self,v)            env.horizontal_message_padding = v end
                end,
                vertical_message_padding = function(instance,env)
                    return function(oldf,...) return env.vertical_message_padding     end,
                    function(oldf,self,v)            env.vertical_message_padding = v end
                end,
                horizontal_icon_padding = function(instance,env)
                    return function(oldf,...) return env.horizontal_icon_padding     end,
                    function(oldf,self,v)            env.horizontal_icon_padding = v end
                end,
                vertical_icon_padding = function(instance,env)
                    return function(oldf,...) return env.vertical_icon_padding     end,
                    function(oldf,self,v)            env.vertical_icon_padding = v end
                end,
                on_completed = function(instance,env)
                    return function(oldf,...) return env.on_completed     end,
                    function(oldf,self,v)            env.on_completed = v end
                end,
                on_screen_duration = function(instance,env)
                    return function(oldf,...) return env.on_screen_duration     end,
                    function(oldf,self,v)            env.on_screen_duration = v end
                end,
                animate_in_duration = function(instance,env)
                    return function(oldf,...) return env.animate_in_duration     end,
                    function(oldf,self,v)            env.animate_in_duration = v end
                end,
                animate_out_duration = function(instance,env)
                    return function(oldf,...) return env.animate_out_duration     end,
                    function(oldf,self,v)            env.animate_out_duration = v end
                end,
                widget_type = function(instance,env)
                    return function() return "ToastAlert" end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.children = nil
                        
                        t.message                    = instance.message
                        t.message_font               = instance.message_font
                        t.message_color              = instance.message_color
                        t.horizontal_message_padding = instance.horizontal_message_padding
                        t.vertical_message_padding   = instance.vertical_message_padding
                        t.horizontal_icon_padding    = instance.horizontal_icon_padding
                        t.vertical_icon_padding      = instance.vertical_icon_padding
                        t.on_screen_duration         = instance.on_screen_duration
                        t.animate_in_duration        = instance.animate_in_duration
                        t.animate_out_duration       = instance.animate_out_duration
                        
                        
                        t.icon = env.icon and env.icon.src
                        t.type = "ToastAlert"
                        
                        return t
                    end
                end,
                
    
            },
            functions = {
                popup    = function(instance,env) 
                    return function(oldf,self,...) 
                        
                        if env.animating then return end
                        
                        if instance.parent then instance:unparent() end
                        
                        screen:add(instance)
                        
                        instance.opacity = 0
                        
                        instance.y = screen.h + instance.anchor_point[2]
                        
                        instance:animate{
                            duration = env.animate_in_duration,
                            y        = 50 + instance.anchor_point[2],
                            opacity  = 255,
                            on_completed = function()
                                
                                dolater(
                                    env.on_screen_duration,
                                    function()
                                        
                                        instance:animate{
                                            duration = env.animate_out_duration,
                                            opacity  = 0,
                                            on_completed = function()
                                                
                                                env.animating = false
                                                
                                                if env.on_completed then env.on_completed(instance) end
                                                
                                            end
                                        }
                                        
                                    end
                                )
                                
                            end
                        }
                    end 
                end,
                
                
            },
        },
        
        
        private = {
        
            subscribe_to_sub_styles = function(instance,env)
                return function()
                    instance.style.border:subscribe_to( nil, function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style.fill_colors:subscribe_to( nil, function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style.text.colors:subscribe_to( nil, function()
                        env.redraw_title = true
                        env.call_update()
                    end )
                    instance.style.text:subscribe_to( nil, function()
                        env.redraw_title = true
                        env.call_update()
                    end )
                    instance.style:subscribe_to( nil, function()
                            
                        if env.canvas then 
                            env.flag_for_redraw = true 
                        end
                        env.redraw_title = true
                        env.call_update()
                        
                    end )
                    
                end
            end,
            ---[[
            update = function(instance,env)
                return function()
                    
                    env.old_update()
                    
                    --reposition icon
                    env.icon.x = env.horizontal_icon_padding 
                    env.icon.y = env.vertical_icon_padding
            
                    --resize icon
                    if (env.icon.y + env.icon.h + env.vertical_icon_padding) > 
                        (instance.h  - instance.separator_y)  then
				
                        env.icon.scale = (env.icon.h - (env.icon.y + env.icon.h + 
                            env.vertical_icon_padding - (instance.h  - instance.separator_y) )) / env.icon.h
				
                    end
                    --reposition message
                    env.message.x = env.icon.x + env.icon.w + env.horizontal_icon_padding + env.horizontal_message_padding
                    env.message.y = env.vertical_message_padding
			
                    --resize message
                    env.message.w = instance.w - env.message.x - env.horizontal_message_padding
                    env.message.h = instance.h - instance.separator_y - env.vertical_message_padding*2
                end
            end,
            --]]
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = DialogBox:declare()
            local getter, setter
            
            env.old_update = env.update
            env.vertical_message_padding   = 10
            env.horizontal_message_padding = 5
            env.horizontal_icon_padding = 20
            env.vertical_icon_padding = 10
            env.message = Text{
                wrap=true,
            }
            instance:add(env.message)
            env.icon = nil
            env.on_completed = function() end
            env.on_screen_duration = 5000
            env.animate_in_duration = 500
            env.animate_out_duration = 500
            env.message_color = "ffffff"
            env.message_font="Sans 40px"
            env.animating = false
            
            
            
            
            
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
            instance.icon          = parameters.icon
            print("DURP")
            instance.message_color = env.message_color
            instance.message_font  = env.message_font
            env.updating = false
            
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)
external.ToastAlert = ToastAlert