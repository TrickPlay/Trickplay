TEXTINPUT = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV




TextInput = setmetatable(
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
                enabled = function(instance,env)
                    return nil,
                    function(oldf,self,v)
                        env.text.editable = instance.enabled
                        env.text.reactive = instance.enabled
                    end
                end,
                text = function(instance,env)
                    return function(oldf) return env.orientation end,
                    function(oldf,self,v) 
            
                        env.text.text = v
                        
                    end
                end,
                widget_type = function(instance,env)
                    return function() return "TextInput" end
                end,
    
            },
            functions = {
            },
        },
        private = {
            update = function(instance,env)
                return function() 
                    if  env.restyle_text then
                        env.restyle_text = false
                        env.text:set(instance.style.text:get_table())
                    end
                    if  env.recolor_text then
                        env.recolor_text = false
                        env.text.color   = instance.style.text.colors.default
                    end
                    if  env.restyle_backing then
                        env.restyle_backing = false
                        print("restyle_backing")
                        env.backing.style:set(instance.style.attributes)
                    end
                    if  env.resize then
                        print("resizing",env.w, instance.style.border.corner_radius*2)
                        env.resize    = false
                        env.text.w    = env.w - instance.style.border.corner_radius*2
                        env.text.h    = env.h - instance.style.border.corner_radius*2
                        print("resizing2",env.w, instance.style.border.corner_radius*2)
                        env.backing.w = env.w 
                        env.backing.h = env.h 
                        print("resizing3",env.backing.w)
                        env.re_align = true
                    end
                    if  env.re_align then
                        env.re_align = false
                        env.text.anchor_point = {
                            env.horizontal_alignment == "center" and env.text.w/2 or 
                            env.horizontal_alignment == "right"  and env.text.w   or 
                            env.horizontal_alignment == "left"   and 0            or
                            error("bad horizontal_alignment: "..tostring(env.horizontal_alignment),2),
                            env.vertical_alignment == "center" and env.text.h/2 or 
                            env.vertical_alignment == "bottom" and env.text.h   or 
                            env.vertical_alignment == "top"    and 0            or
                            error("bad vertical_alignment: "..tostring(env.vertical_alignment),2),
                        }
                        env.text.position = {
                            env.horizontal_alignment == "center" and env.w/2 or 
                            env.horizontal_alignment == "right"  and env.w - instance.style.border.corner_radius or 
                            env.horizontal_alignment == "left"   and instance.style.border.corner_radius or
                            error("bad horizontal_alignment: "..tostring(env.horizontal_alignment),2),
                            env.vertical_alignment == "center" and env.h/2 or 
                            env.vertical_alignment == "bottom" and env.h - instance.style.border.corner_radius or 
                            env.vertical_alignment == "top"    and instance.border.style.corner_radius or
                            error("bad vertical_alignment: "..tostring(env.vertical_alignment),2),
                        }
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            env.backing = NineSlice()
            
            env.text = Text{
                editable       = true,
                single_line    = true,
                cursor_visible = true,
                reactive       = true,
            }
            
            env.add(instance,env.backing,env.text)
            
            env.w = 0
            env.h = 0
            env.horizontal_alignment = "left"
            env.vertical_alignment = "center"
            env.style_flags = {
                border = "restyle_backing",
                text = {
                    "restyle_text",
                    colors = "recolor_text",
                },
                fill_colors = "restyle_backing"
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
external.TextInput = TextInput