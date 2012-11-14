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
                enabled = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        oldf(self,v)
                        text.editable = v
                        text.reactive = v
                    end
                end,
                text = function(instance,_ENV)
                    return function(oldf) return text.text end,
                    function(oldf,self,v) 
            
                        text.text = v
                        
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "TextInput" end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.text = self.text
                        
                        t.type = "TextInput"
                        
                        return t
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            update = function(instance,_ENV)
                return function() 
                    if  restyle_text then
                        restyle_text = false
                        text:set(instance.style.text:get_table())
                    end
                    if  recolor_text then
                        recolor_text = false
                        text.color   = instance.style.text.colors.default
                    end
                    if  restyle_backing then
                        restyle_backing = false
                        print("restyle_backing")
                        backing.style:set(instance.style.attributes)
                    end
                    if  resize then
                        print("resizing",w, instance.style.border.corner_radius*2)
                        resize    = false
                        text.w    = w - instance.style.border.corner_radius*2
                        text.h    = h - instance.style.border.corner_radius*2
                        print("resizing2",w, instance.style.border.corner_radius*2)
                        backing.w = w 
                        backing.h = h 
                        print("resizing3",backing.w)
                        re_align = true
                    end
                    if  re_align then
                        re_align = false
                        text.anchor_point = {
                            horizontal_alignment == "center" and text.w/2 or 
                            horizontal_alignment == "right"  and text.w   or 
                            horizontal_alignment == "left"   and 0            or
                            error("bad horizontal_alignment: "..tostring(horizontal_alignment),2),
                            vertical_alignment == "center" and text.h/2 or 
                            vertical_alignment == "bottom" and text.h   or 
                            vertical_alignment == "top"    and 0            or
                            error("bad vertical_alignment: "..tostring(vertical_alignment),2),
                        }
                        text.position = {
                            horizontal_alignment == "center" and w/2 or 
                            horizontal_alignment == "right"  and w - instance.style.border.corner_radius or 
                            horizontal_alignment == "left"   and instance.style.border.corner_radius or
                            error("bad horizontal_alignment: "..tostring(horizontal_alignment),2),
                            vertical_alignment == "center" and h/2 or 
                            vertical_alignment == "bottom" and h - instance.style.border.corner_radius or 
                            vertical_alignment == "top"    and instance.border.style.corner_radius or
                            error("bad vertical_alignment: "..tostring(vertical_alignment),2),
                        }
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, _ENV = Widget()
            
            backing = NineSlice()
            
            text = Text{
                editable       = true,
                single_line    = true,
                cursor_visible = true,
                reactive       = true,
            }
            
            add(instance,backing,text)
            
            w = 0
            h = 0
            horizontal_alignment = "left"
            vertical_alignment = "center"
            style_flags = {
                border = "restyle_backing",
                text = {
                    "restyle_text",
                    colors = "recolor_text",
                },
                fill_colors = "restyle_backing"
            }
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance:set(parameters)
            updating = false
            
            return instance, _ENV
            
        end
    }
)
external.TextInput = TextInput