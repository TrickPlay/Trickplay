
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

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
            ["style"] = function(instance,_ENV)
                return function()

                    instance.style.arrow:subscribe_to(         nil, arrow_on_changed )
                    instance.style.arrow.colors:subscribe_to(  nil, arrow_colors_on_changed )
                    instance.style.border:subscribe_to(        nil, pane_on_changed )
                    instance.style.fill_colors:subscribe_to(   nil, pane_on_changed )

                    arrow_on_changed()
                    arrow_colors_on_changed()
                end
            end,
            --]]
        },
        public = {
            properties = {
                enabled = function(instance,_ENV)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)

                        horizontal.enabled = v
                        vertical.enabled   = v
                    end
                end,
                w = function(instance,_ENV)
                    return nil,--function(oldf,self) return w     end,
                    function(oldf,self,v)
                        oldf(self,v)--w = v
                        reclip = true
                        new_w  = true
                    end
                end,
                width = function(instance,_ENV)
                    return nil,--function(oldf,self) return w     end,
                    function(oldf,self,v)
                        oldf(self,v)--w = v
                        reclip = true
                        new_w  = true
                    end
                end,
                h = function(instance,_ENV)
                    return nil,--function(oldf,self) return h     end,
                    function(oldf,self,v)
                        oldf(self,v)--h = v
                        reclip = true
                        new_h  = true
                    end
                end,
                height = function(instance,_ENV)
                    return nil,--function(oldf,self) return h     end,
                    function(oldf,self,v)
                        oldf(self,v)--h = v
                        reclip = true
                        new_h  = true
                    end
                end,
                size = function(instance,_ENV)
                    return nil,--function(oldf,self) return {w,h} end,
                    function(oldf,self,v)
                        oldf(self,v)--w = v[1]
                        --h = v[2]
                        reclip = true
                        new_w  = true
                        new_h  = true
                    end
                end,
                virtual_w = function(instance,_ENV)
                    return function(oldf) return pane.virtual_w     end,
                    function(oldf,self,v)        pane.virtual_w = v new_w = true end
                end,
                virtual_h = function(instance,_ENV)
                    return function(oldf) return pane.virtual_h     end,
                    function(oldf,self,v)        pane.virtual_h = v new_h = true end
                end,
                virtual_x = function(instance,_ENV)
                    return function(oldf) return pane.virtual_x     end,
                    function(oldf,self,v)
                        pane.virtual_x = v
                        horizontal.progress = v/(pane.virtual_w - pane.w)
                    end
                end,
                virtual_y = function(instance,_ENV)
                    return function(oldf) return pane.virtual_y     end,
                    function(oldf,self,v)
                        pane.virtual_y = v
                        vertical.progress = v/(pane.virtual_h - pane.h)
                    end
                end,
                pane_w = function(instance,_ENV)
                    return function(oldf) return pane.w     end,
                    function(oldf,self,v)
                        horizontal.track_w = v
                        horizontal.grip_w  = v/10
                        pane.w = v
                        new_w = true
                    end
                end,
                pane_h = function(instance,_ENV)
                    return function(oldf) return pane.h     end,
                    function(oldf,self,v)
                        vertical.track_h   = v
                        vertical.grip_h    = v/10
                        pane.h = v
                        new_h = true
                    end
                end,
                slider_thickness = function(instance,_ENV)
                    return function(oldf) return slider_thickness     end,
                    function(oldf,self,v)

                        horizontal.track_h = v
                        horizontal.grip_h  = v
                        vertical.track_w   = v
                        vertical.grip_w    = v
                        slider_thickness   = v
                        find_width         = true
                        find_height        = true
                        --TODO - set a flag like this: new_h = true
                    end
                end,
                arrow_move_by = function(instance,_ENV)
                    return function(oldf) return move_by     end,
                    function(oldf,self,v) move_by = v end
                end,
                sets_x_to = function(instance,_ENV)
                    return function(oldf) return pane.x_offset end,
                    function(oldf,self,v)
                        pane.x_offset = v
                    end
                end,
                sets_y_to = function(instance,_ENV)
                    return function(oldf) return pane.y_offset     end,
                    function(oldf,self,v)
                        pane.y_offset = v
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "ScrollPane" end
                end,
                attributes = function(instance,_ENV)
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

                        for i, child in ipairs(pane.children) do
                            t.children[i] = child.attributes
                        end

                        t.type = "ScrollPane"

                        return t

                    end
                end,
                children = function(instance,_ENV)
                    return function(oldf) return pane.children     end,
                    function(oldf,self,v)        pane.children = v end
                end,
            },
            functions = {
                add    = function(instance,_ENV) return function(oldf,self,...) pane:add(   ...) end end,
                remove = function(instance,_ENV) return function(oldf,self,...) pane:remove(...) end end,
            },
        },
        private = {
            pane_on_changed = function(instance,_ENV)
                return function()
                    pane.style:set(instance.style.attributes)
                end
            end,
            update = function(instance,_ENV)
                return function()
                    lm_update()

                    if  new_w then
                        new_w = false

                        if instance.virtual_w <= instance.pane_w then
                            horizontal:hide()
                        else
                            horizontal:show()
                        end
                    end

                    if  new_h then
                        new_h = false

                        if instance.virtual_h <= instance.pane_h then
                            vertical:hide()
                        else
                            vertical:show()
                        end
                    end

                end
            end,
        },
        declare = function(self,parameters)

            --local instance, _ENV = LayoutManager:declare()
            --local getter, setter

            local l_pane  = ClippingRegion()--{style = false}
            local l_horizontal = Slider()
            local l_vertical   = Slider{direction="vertical"}

            local instance, _ENV = LayoutManager:declare{
                number_of_rows = 2,
                number_of_cols = 2,
                placeholder = Widget_Clone(),
                cells = {
                    {       l_pane, l_vertical },
                    { l_horizontal,        nil },
                },
            }

            WL_parent_redirect[l_pane] = instance

            local getter, setter

            pane       = l_pane
            horizontal = l_horizontal
            vertical   = l_vertical


            vertical:subscribe_to("progress",function()
                pane.virtual_y = vertical.progress * (pane.virtual_h - pane.h)
            end)
            horizontal:subscribe_to("progress",function()
                pane.virtual_x = horizontal.progress * (pane.virtual_w - pane.w)
            end)
            --[[
            instance:add_key_handler(keys.Up,       up.click)
            instance:add_key_handler(keys.Down,   down.click)
            instance:add_key_handler(keys.Left,   left.click)
            instance:add_key_handler(keys.Right, right.click)
    		up:add_mouse_handler("on_button_up", function()
    		    pane.virtual_y = pane.virtual_y - move_by
    		end)

    		down:add_mouse_handler("on_button_up", function()
    		    pane.virtual_y = pane.virtual_y + move_by
    		end)

    		left:add_mouse_handler("on_button_up", function()
    		    pane.virtual_x = pane.virtual_x - move_by
    		end)

		    right:add_mouse_handler("on_button_up", function()
    	    	pane.virtual_x = pane.virtual_x + move_by
    		end)
            --]]

            lm_update = update
            new_w = true
            new_h = true
            move_by = 10
            slider_thickness = 30

            setup_object(self,instance,_ENV)

            updating = true
            instance.pane_w           = pane.w
            instance.pane_h           = pane.h
            instance.slider_thickness = slider_thickness
            updating = false
            return instance, _ENV

        end
    }
)
external.ScrollPane = ScrollPane
