
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000}

ClippingRegion = setmetatable(
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
                contents_offset = function(instance,_ENV)
                    return function(oldf,self)
                        local b = bg.borders

                        return {b[1],b[2]}
                    end
                end,
                w = function(instance,_ENV)
                    return function(oldf,self) return w     end,
                    function(oldf,self,v)
                        w = v
                        reclip = true
                        new_w  = true
                    end
                end,
                width = function(instance,_ENV)
                    return function(oldf,self) return w     end,
                    function(oldf,self,v)
                        w = v
                        reclip = true
                        new_w  = true
                    end
                end,
                h = function(instance,_ENV)
                    return function(oldf,self) return h     end,
                    function(oldf,self,v)
                        print("cr_h",v)
                        h = v
                        reclip = true
                        new_h  = true
                    end
                end,
                height = function(instance,_ENV)
                    return function(oldf,self) return h     end,
                    function(oldf,self,v)
                        h = v
                        reclip = true
                        new_h  = true
                    end
                end,
                size = function(instance,_ENV)
                    return function(oldf,self) return {w,h} end,
                    function(oldf,self,v)
                        w = v[1]
                        h = v[2]
                        reclip = true
                        new_w  = true
                        new_h  = true
                    end
                end,
                virtual_w = function(instance,_ENV)
                    return function(oldf) return virtual_w     end,
                    function(oldf,self,v)
                        virtual_w = v < instance.w  and instance.w or v
                    end
                end,
                virtual_h = function(instance,_ENV)
                    return function(oldf) return virtual_h end,
                    function(oldf,self,v)
                        virtual_h = v < instance.h  and instance.h or v
                    end
                end,
                virtual_x = function(instance,_ENV)
                    return function(oldf) return -contents.x - x_offset end,
                    function(oldf,self,v)
                        contents.x = bound_to(-(virtual_w - instance.w),x_offset - v,0)
                        reclip = true
                    end
                end,
                virtual_y = function(instance,_ENV)
                    return function(oldf) return -contents.y - y_offset end,
                    function(oldf,self,v)
                        contents.y = bound_to(-(virtual_h - instance.h),y_offset - v,0)
                        reclip = true
                    end
                end,
                sets_x_to = function(instance,_ENV)
                    return function(oldf) return x_offset end,
                    function(oldf,self,v)
                        x_offset = v
                    end
                end,
                sets_y_to = function(instance,_ENV)
                    return function(oldf) return y_offset     end,
                    function(oldf,self,v)
                        y_offset = v
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "ClippingRegion" end
                end,
                children = function(instance,_ENV)
                    return function(oldf) return contents.children     end,
                    function(oldf,self,v)
                        if type(v) ~= "table" then error("Expected table. Received "..type(v), 2) end
                        contents:clear()

                        if type(v) == "table" then

                            for i,obj in ipairs(v) do

                                if type(obj) == "table" and obj.type then

                                    v[i] = _ENV[obj.type](obj)

                                elseif type(obj) ~= "userdata" and obj.__types__.actor then

                                    error("Must be a UIElement or nil. Received "..obj,2)

                                end

                            end
                            contents:add(unpack(v))

                        elseif type(v) == "userdata" then

                            contents:add(v)

                        end
                    end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        local t = oldf(self)

                        t.contents_offset = instance.contents_offset
                        t.virtual_x = instance.virtual_x
                        t.virtual_y = instance.virtual_y
                        t.virtual_w = instance.virtual_w
                        t.virtual_h = instance.virtual_h
                        t.sets_x_to = instance.sets_x_to
                        t.sets_y_to = instance.sets_y_to

                        t.children = {}

                        for i, child in ipairs(contents.children) do
                            t.children[i] = child.attributes
                        end
                        t.type = "ClippingRegion"

                        return t
                    end
                end,
            },
            functions = {
                add    = function(instance,_ENV) return function(oldf,self,...) contents:add(   ...) end end,
                remove = function(instance,_ENV) return function(oldf,self,...) contents:remove(...) end end,
            },
        },
        private = {
            update = function(instance,_ENV)
                return function()


                    if  restyle then
                        restyle = false

                        --border.border_width = instance.style.border.width
                        --border.border_color = instance.style.border.colors.default
                        --bg.color            = instance.style.fill_colors.default
                        local style  = instance.style
                        bg:set{sheet = style.spritesheet, ids = {
                                nw   = style["ClippingRegion/default/nw.png"],
                                n    = style["ClippingRegion/default/n.png"],
                                ne   = style["ClippingRegion/default/ne.png"],
                                w    = style["ClippingRegion/default/w.png"],
                                c    = style["ClippingRegion/default/c.png"],
                                e    = style["ClippingRegion/default/e.png"],
                                sw   = style["ClippingRegion/default/sw.png"],
                                s    = style["ClippingRegion/default/s.png"],
                                se   = style["ClippingRegion/default/se.png"],
                            }
                        }
                        borders = bg.borders
                        contents.anchor_point = {
                            -borders[1],-borders[3]
                        }
                        reclip = true
                    end
                    if  new_w then
                        new_w = false

                        bg.w     = w

                        instance.virtual_w = instance.virtual_w --virtual_w must be <= w
                        instance.virtual_x = instance.virtual_x --virtual_x must be <= virtual_w - w

                    end

                    if  new_h then
                        new_h = false

                        bg.h     = h

                        instance.virtual_h = instance.virtual_h --virtual_h must be <= h
                        instance.virtual_y = instance.virtual_y --virtual_y must be <= virtual_h - h

                    end

                    if  reclip then
                        reclip = false
                        contents.clip = {
                            instance.virtual_x,
                            instance.virtual_y,
                            instance.w - borders[1] - borders[2],
                            instance.h - borders[3] - borders[4],
                        }
                        print(
                            instance.virtual_x,
                            instance.virtual_y,
                            instance.w - borders[1] - borders[2],
                            instance.h - borders[3] - borders[4]
                        )
                    end
                    --dumptable(bg.borders)
                end
            end,
        },
        declare = function(self,parameters)

            local instance, _ENV = Widget()
            local getter, setter

            style_flags = "restyle"

            bg       = NineSlice()
            borders = {0,0,0,0}
            contents = Group{     name="Contents"  }

            WL_parent_redirect[contents] = instance

            restyle = true
            new_w   = true
            new_h   = true
            reclip  = true
            --public attributes, set to false if there is no default
            w = 400
            h = 400
            virtual_w = 1000
            virtual_h = 1000
            virtual_x =    0
            virtual_y =    0
            x_offset  =    0
            y_offset  =    0

            add( instance, bg, contents )

            instance.reactive = true


            setup_object(self,instance,_ENV)

            dumptable(get_children(instance))
            return instance, _ENV

        end
    }
)

external.ClippingRegion = ClippingRegion
