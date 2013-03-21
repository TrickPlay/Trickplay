
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
                        local style = instance.style
                        backing:set{sheet = style.spritesheet, ids = {
                                nw   = style["TextInput/default/nw.png"],
                                n    = style["TextInput/default/n.png"],
                                ne   = style["TextInput/default/ne.png"],
                                w    = style["TextInput/default/w.png"],
                                c    = style["TextInput/default/c.png"],
                                e    = style["TextInput/default/e.png"],
                                sw   = style["TextInput/default/sw.png"],
                                s    = style["TextInput/default/s.png"],
                                se   = style["TextInput/default/se.png"],
                            }
                        }
                        borders = backing.borders
                    end
                    if  resize then
                        --print("resizing",w, instance.style.border.corner_radius*2)
                        resize    = false
                        text.w    = w - borders[1] - borders[2]
                        text.h    = h - borders[3] - borders[4]
                        --print("resizing2",w, instance.style.border.corner_radius*2)
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
                            horizontal_alignment == "right"  and w - borders[2] or
                            horizontal_alignment == "left"   and borders[1] or
                            error("bad horizontal_alignment: "..tostring(horizontal_alignment),2),
                            vertical_alignment == "center" and h/2 or
                            vertical_alignment == "bottom" and h - borders[4] or
                            vertical_alignment == "top"    and borders[3] or
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
            restyle_backing = true
            setup_object(self,instance,_ENV)

            updating = true
            instance:set(parameters)
            updating = false

            return instance, _ENV

        end
    }
)
external.TextInput = TextInput
