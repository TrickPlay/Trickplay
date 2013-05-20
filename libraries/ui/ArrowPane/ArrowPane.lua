
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local create_arrow = function(dir)
    return function(self,state,_ENV)

        local s = Sprite{
            async = false,
            sheet=self.style.spritesheet,
            id = self.style["ArrowPane/arrow-"..dir.."/"..state..".png"],
        } --]]
        print("new sprite",s.w,s.h, s.id,w,h)
        w = s.w
        h = s.h
        return s
    end
end

ArrowPane = setmetatable(
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
                --[[
                style = function(instance,_ENV)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)

                        subscribe_to_sub_styles()
                        --TODO: double check this
                        flag_for_redraw = true
                        text_style_changed = true
                        text_color_changed = true
                    end
                end,
                --]]
                enabled = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        oldf(self,v)

                        for _,arrow in pairs(arrows) do
                            arrow.enabled = v
                        end

                    end
                end,
                contents_offset = function(instance,_ENV)
                    return function(oldf,self)
                        local x,y = unpack(pane.contents_offset)

                        return {
                            ((self.horizontal_arrows_are_visible) and
                            (x+left.w+self.horizontal_spacing) or x),
                            ((self.vertical_arrows_are_visible) and
                            (y+up.h+self.vertical_spacing) or y)
                        }
                    end
                end,
                w = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        new_w  = true
                        oldf(self,v)
                    end
                end,
                width = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        new_w  = true
                        oldf(self,v)
                    end
                end,
                h = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        new_h  = true
                        oldf(self,v)
                    end
                end,
                height = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        new_h  = true
                        oldf(self,v)
                    end
                end,
                size = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        new_w  = true
                        new_h  = true
                        oldf(self,v)
                    end
                end,
                virtual_w = function(instance,_ENV)
                    return function(oldf) return pane.virtual_w     end,
                    function(oldf,self,v) pane.virtual_w = v new_w = true end
                end,
                virtual_h = function(instance,_ENV)
                    return function(oldf) return pane.virtual_h     end,
                    function(oldf,self,v) pane.virtual_h = v new_h = true end
                end,
                virtual_x = function(instance,_ENV)
                    return function(oldf) return pane.virtual_x     end,
                    function(oldf,self,v) pane.virtual_x = v end
                end,
                virtual_y = function(instance,_ENV)
                    return function(oldf) return pane.virtual_y     end,
                    function(oldf,self,v) pane.virtual_y = v end
                end,
                pane_w = function(instance,_ENV)
                    return function(oldf) return pane.w     end,
                    function(oldf,self,v) pane.w = v new_w = true end
                end,
                pane_h = function(instance,_ENV)
                    return function(oldf) return pane.h     end,
                    function(oldf,self,v) pane.h = v  new_h = true end
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
                horizontal_arrows_are_visible = function(instance,_ENV)

                    return function(oldf) return instance.number_of_cols == 3 end,

                    function(oldf,self,v)

                        if type(v) ~= "boolean" or v == nil then error("Expected boolean or nil. Received "..tostring(v),2) end

                        horizontal_arrows_are_visible = v

                        new_w = (v == nil) and true or new_w

                    end
                end,
                vertical_arrows_are_visible = function(instance,_ENV)

                    return function(oldf) return instance.number_of_rows == 3 end,

                    function(oldf,self,v)

                        if type(v) ~= "boolean" or v == nil then error("Expected boolean or nil. Received "..tostring(v),2) end

                        vertical_arrows_are_visible = v

                        new_h = (v == nil) and true or new_h

                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "ArrowPane" end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        if self == nil then error("no",3) end
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

                       -- t.contents = self.contents
                        t.style = instance.style.name

                        t.contents_offset = instance.contents_offset
                        t.pane_w    = instance.pane_w
                        t.pane_h    = instance.pane_h
                        t.virtual_x = instance.virtual_x
                        t.virtual_y = instance.virtual_y
                        t.virtual_w = instance.virtual_w
                        t.virtual_h = instance.virtual_h
                        t.arrow_move_by   = instance.arrow_move_by

                        t.children = {}

                        for i, child in ipairs(pane.children) do
                            t.children[i] = child.attributes
                        end

                        t.type = "ArrowPane"

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
                arrow_size = function(instance,_ENV)
                    return function(oldf,self,index)
                        return _ENV[index].size
                    end
                end,
            },
        },
        private = {
            --[[
            arrow_on_changed = function(instance,_ENV)
                return function()
                    print("\n\n\narrow_on_changed\n\n\n")
                    for _,arrow in pairs(arrows) do
                        arrow:set{
                            w = instance.style.arrow.size,
                            h = instance.style.arrow.size,
                            anchor_point = {
                                instance.style.arrow.size/2,
                                instance.style.arrow.size/2
                            },
                        }
                    end

                    instance.horizontal_spacing = instance.style.arrow.offset
                    instance.vertical_spacing   = instance.style.arrow.offset
                end
            end,
            arrow_colors_on_changed = function(instance,_ENV)
                return function()
                    for _,arrow in pairs(arrows) do
                        arrow.style.fill_colors =
                            instance.style.arrow.colors.attributes
                    end
                end
            end,
            --]]
            style_buttons = function(instance,_ENV)
                return function()
                    up.style = instance.style--[[.images = {
                        default    = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-up/default.png"    },
                        focus      = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-up/focus.png"      },
                        activation = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-up/activation.png" },
                    }--]]
                    up.anchor_point = { up.w/2, up.h/2 }
                    down.style = instance.style--[[.images = {
                        default    = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-down/default.png"    },
                        focus      = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-down/focus.png"      },
                        activation = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-down/activation.png" },
                    }--]]
                    down.anchor_point = { down.w/2, down.h/2 }
                    left.style = instance.style--[[.images = {
                        default    = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-left/default.png"    },
                        focus      = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-left/focus.png"      },
                        activation = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-left/activation.png" },
                    }--]]
                    left.anchor_point = { left.w/2, left.h/2 }
                    right.style = instance.style--[[.images = {
                        default    = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-right/default.png"    },
                        focus      = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-right/focus.png"      },
                        activation = Sprite{sheet=instance.style.spritesheet,id="ArrowPane/arrow-right/activation.png" },
                    }--]]
                    right.anchor_point = { right.w/2, right.h/2 }
                end
            end,
            update = function(instance,_ENV)
                return function()
                    mesg("ArrowPane",0,"ArrowPane:update() called")
                    if redraw_buttons then
                        redraw_buttons = false
                        style_buttons()
                    end
                    if respace_buttons then
                        respace_buttons = false
                        --instance.horizontal_spacing = instance.style.arrow.offset
                        --instance.vertical_spacing   = instance.style.arrow.offset
                    end
                    if redraw_pane then
                        redraw_pane = false
                        print("balls")
                        pane:set{--[[
                            style = {
                                name=false,
                                fill_colors=instance.style.fill_colors.attributes,
                                border={colors=instance.style.border.colors.attributes},
                            }--]]
                        }
                    end
                    lm_update()


                    if horizontal_arrows_are_visible == true and instance.number_of_cols == 1 then
                        if instance.number_of_rows == 1 then
                            instance.cells:insert_col(1,{left})
                            instance.cells:insert_col(3,{right})
                        elseif instance.number_of_rows == 3 then
                            instance.cells:insert_col(1,{nil,left,nil})
                            instance.cells:insert_col(3,{nil,right,nil})
                        end
                    elseif horizontal_arrows_are_visible == false and instance.number_of_cols == 3 then
                        instance.cells:remove_col(3)
                        instance.cells:remove_col(1)
                    elseif new_w and horizontal_arrows_are_visible == nil then
                        new_w = false

                        if pane.virtual_w <= pane.w then
                            if instance.number_of_cols == 3 then
                                instance.cells:remove_col(3)
                                instance.cells:remove_col(1)
                            end
                        elseif instance.number_of_cols == 1 then
                            if instance.number_of_rows == 1 then
                                instance.cells:insert_col(1,{left})
                                instance.cells:insert_col(3,{right})
                            elseif instance.number_of_rows == 3 then
                                instance.cells:insert_col(1,{nil,left,nil})
                                instance.cells:insert_col(3,{nil,right,nil})
                            else
                                error("impossible number of rows "..instance.number_of_rows,2)
                            end
                        end
                    end

                    if vertical_arrows_are_visible == true and instance.number_of_rows == 1 then
                        if instance.number_of_cols == 1 then
                            instance.cells:insert_row(1,{up})
                            instance.cells:insert_row(3,{down})
                        elseif instance.number_of_cols == 3 then
                            instance.cells:insert_row(1,{nil,up,  nil})
                            instance.cells:insert_row(3,{nil,down,nil})
                        end
                    elseif vertical_arrows_are_visible == false and instance.number_of_rows == 3 then
                        instance.cells:remove_row(3)
                        instance.cells:remove_row(1)
                    elseif new_h and vertical_arrows_are_visible == nil then

                        new_h = false

                        if pane.virtual_h <= pane.h then
                            if instance.number_of_rows == 3 then
                                instance.cells:remove_row(3)
                                instance.cells:remove_row(1)
                            end
                        elseif instance.number_of_rows == 1 then
                            if instance.number_of_cols == 1 then
                                instance.cells:insert_row(1,{up})
                                instance.cells:insert_row(3,{down})
                            elseif instance.number_of_cols == 3 then
                                instance.cells:insert_row(1,{nil,up,  nil})
                                instance.cells:insert_row(3,{nil,down,nil})
                            else
                                error("impossible number of cols "..instance.number_of_cols,2)
                            end
                        end
                    end

                end
            end,
        },
        declare = function(self,parameters)

            --local instance, _ENV = LayoutManager:declare()
            --local getter, setter

            move_by = 10
            local l_pane  = ClippingRegion()
            local l_up    = Button:declare{
                name = "Up Button",
                label="",
                reactive = true,
                create_canvas = create_arrow("up"),
                on_released = function() l_pane.virtual_y = l_pane.virtual_y - move_by end,
            }
            local l_down  = Button:declare{
                name = "Down Button",
                label="",
                reactive = true,
                create_canvas = create_arrow("down"),
                on_released = function() l_pane.virtual_y = l_pane.virtual_y + move_by end,
            }
            local l_left  = Button:declare{
                name = "Left Button",
                label="",
                reactive = true,
                create_canvas = create_arrow("left"),
                on_released = function() l_pane.virtual_x = l_pane.virtual_x - move_by end,
            }
            local l_right = Button:declare{
                name = "Right Button",
                label="",
                reactive = true,
                create_canvas = create_arrow("right"),
                on_released = function() l_pane.virtual_x = l_pane.virtual_x + move_by end,
            }

            local instance, _ENV = LayoutManager:declare{
                children_want_focus = false,
                number_of_rows = 3,
                number_of_cols = 3,
                placeholder = Widget_Clone(),
                cells = {
                    {    nil,   l_up,     nil },
                    { l_left, l_pane, l_right },
                    {    nil, l_down,     nil },
                },
            }

            WL_parent_redirect[l_pane] = instance

            style_flags = {
                border = "redraw_pane",
                arrow = {
                    size = "redraw_buttons",
                    offset = "respace_arrows",
                    colors = "redraw_buttons",
                },
                fill_colors = "redraw_pane"
            }
            local getter, setter

            pane  = l_pane
            up    = l_up
            down  = l_down
            left  = l_left
            right = l_right
            _ENV.move_by = move_by
            redraw_buttons = true

            instance:add_key_handler(keys.Up,       up.click)
            instance:add_key_handler(keys.Down,   down.click)
            instance:add_key_handler(keys.Left,   left.click)
            instance:add_key_handler(keys.Right, right.click)
            --[[
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
            arrows = {
                up    = up,
                down  = down,
                left  = left,
                right = right,
            }
            redraw_pane = true
            lm_update = update
            new_w = true
            new_h = true
            move_by = 10

            setup_object(self,instance,_ENV)

            return instance, _ENV

        end
    }
)

external.ArrowPane = ArrowPane
