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
            
                widget_type = function(instance,_ENV)
                    return function() return "ToastAlert" end, nil
                end,
                icon = function(instance,_ENV)
                    return function(oldf,...) return icon     end,
                    function(oldf,self,v) 
                        
                        if icon then icon:unparent() end
                        
                        if v == nil then
                            
                            icon = Text{text="!",color = instance.style.border.colors.default,font = "Sans 60px"}
                            
                        elseif type(v) == "string" then
                            
                            icon = Image{ src = v }
                            
                            if icon == nil then
                                
                                error("ToastAlert.icon recieved string but it was not a valid image uri",2)
                                
                            end
                            
                        elseif type(v) == "userdata" and v.__types__.actor then
                            
                            icon = v
                            
                        else
                            
                            error("ToastAlert.icon expected string uri or UIElement. Received "..type(v),2)
                            
                        end
                        
                        instance:add(icon)
                    end
                end,
                message = function(instance,_ENV)
                    return function(oldf,...) return message.text     end,
                    function(oldf,self,v)            message.text = v end
                end,
                message_color = function(instance,_ENV)
                    return function(oldf,...) return message.color     end,
                    function(oldf,self,v) print(v)   message.color = v end
                end,
                message_font = function(instance,_ENV)
                    return function(oldf,...) return message.font     end,
                    function(oldf,self,v)            message.font = v end
                end,
                horizontal_message_padding = function(instance,_ENV)
                    return function(oldf,...) return horizontal_message_padding     end,
                    function(oldf,self,v)            horizontal_message_padding = v end
                end,
                vertical_message_padding = function(instance,_ENV)
                    return function(oldf,...) return vertical_message_padding     end,
                    function(oldf,self,v)            vertical_message_padding = v end
                end,
                horizontal_icon_padding = function(instance,_ENV)
                    return function(oldf,...) return horizontal_icon_padding     end,
                    function(oldf,self,v)            horizontal_icon_padding = v end
                end,
                vertical_icon_padding = function(instance,_ENV)
                    return function(oldf,...) return vertical_icon_padding     end,
                    function(oldf,self,v)            vertical_icon_padding = v end
                end,
                on_completed = function(instance,_ENV)
                    return function(oldf,...) return on_completed     end,
                    function(oldf,self,v)            on_completed = v end
                end,
                on_screen_duration = function(instance,_ENV)
                    return function(oldf,...) return on_screen_duration     end,
                    function(oldf,self,v)            on_screen_duration = v end
                end,
                animate_in_duration = function(instance,_ENV)
                    return function(oldf,...) return animate_in_duration     end,
                    function(oldf,self,v)            animate_in_duration = v end
                end,
                animate_out_duration = function(instance,_ENV)
                    return function(oldf,...) return animate_out_duration     end,
                    function(oldf,self,v)            animate_out_duration = v end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "ToastAlert" end
                end,
                attributes = function(instance,_ENV)
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
                        
                        
                        t.icon = icon and icon.src
                        t.type = "ToastAlert"
                        
                        return t
                    end
                end,
                
    
            },
            functions = {
                popup    = function(instance,_ENV) 
                    return function(oldf,self,...) 
                        
                        if animating then return end
                        
                        if instance.parent then instance:unparent() end
                        
                        screen:add(instance)
                        
                        instance.opacity = 0
                        
                        instance.y = screen.h + instance.anchor_point[2]
                        
                        instance:animate{
                            duration = animate_in_duration,
                            y        = 50 + instance.anchor_point[2],
                            opacity  = 255,
                            on_completed = function()
                                
                                dolater(
                                    on_screen_duration,
                                    function()
                                        
                                        instance:animate{
                                            duration = animate_out_duration,
                                            opacity  = 0,
                                            on_completed = function()
                                                
                                                animating = false
                                                
                                                if on_completed then on_completed(instance) end
                                                
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
        
            subscribe_to_sub_styles = function(instance,_ENV)
                return function()
                    instance.style.border:subscribe_to( nil, function()
                        if canvas then 
                            flag_for_redraw = true 
                            call_update()
                        end
                    end )
                    instance.style.fill_colors:subscribe_to( nil, function()
                        if canvas then 
                            flag_for_redraw = true 
                            call_update()
                        end
                    end )
                    instance.style.text.colors:subscribe_to( nil, function()
                        redraw_title = true
                        call_update()
                    end )
                    instance.style.text:subscribe_to( nil, function()
                        redraw_title = true
                        call_update()
                    end )
                    instance.style:subscribe_to( nil, function()
                            
                        if canvas then 
                            flag_for_redraw = true 
                        end
                        redraw_title = true
                        call_update()
                        
                    end )
                    
                end
            end,
            ---[[
            update = function(instance,_ENV)
                return function()
                    
                    old_update()
                    
                    --reposition icon
                    icon.x = horizontal_icon_padding 
                    icon.y = vertical_icon_padding
            
                    --resize icon
                    if (icon.y + icon.h + vertical_icon_padding) > 
                        (instance.h  - instance.separator_y)  then
				
                        icon.scale = (icon.h - (icon.y + icon.h + 
                            vertical_icon_padding - (instance.h  - instance.separator_y) )) / icon.h
				
                    end
                    --reposition message
                    message.x = icon.x + icon.w + horizontal_icon_padding + horizontal_message_padding
                    message.y = vertical_message_padding
			
                    --resize message
                    message.w = instance.w - message.x - horizontal_message_padding
                    message.h = instance.h - instance.separator_y - vertical_message_padding*2
                end
            end,
            --]]
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, _ENV = DialogBox:declare()
            local getter, setter
            
            old_update = update
            vertical_message_padding   = 10
            horizontal_message_padding = 5
            horizontal_icon_padding = 20
            vertical_icon_padding = 10
            message = Text{
                wrap=true,
            }
            instance:add(message)
            icon = nil
            on_completed = function() end
            on_screen_duration = 5000
            animate_in_duration = 500
            animate_out_duration = 500
            message_color = "ffffff"
            message_font="Sans 40px"
            animating = false
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance.icon          = parameters.icon
            instance.message_color = message_color
            instance.message_font  = message_font
            updating = false
            
            dumptable(get_children(instance))
            return instance, _ENV
            
        end
    }
)
external.ToastAlert = ToastAlert