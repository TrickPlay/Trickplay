
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local default_parameters = {
    direction = "down",
    vertical_alignment = "top",
    item_spacing = 0,
    popup_offset = 10,
}

local create_canvas = function(self,state)
	print("mb:cc",self.w,self.h)
	local c = Canvas(self.w,self.h)

	c.line_width = self.style.border.width

	round_rectangle(c,self.style.border.corner_radius)

	c:set_source_color( self.style.fill_colors[state] or "ffffff66" )     c:fill(true)

	c:set_source_color( self.style.border.colors[state] or self.style.border.colors.default )   c:stroke(true)

	return c:Image()

end

MenuButton = setmetatable(
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
                popup_offset = function(instance,_ENV)
                    return function(oldf)  return   popup_offset      end,
                    function(oldf,self,v)    popup_offset = v end
                end,
                item_spacing = function(instance,_ENV)
                    return function(oldf)  return   popup.spacing      end,
                    function(oldf,self,v)    popup.spacing = v end
                end,
                horizontal_alignment = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)  oldf(self,v)  popup.horizontal_alignment = v end
                end,
                items = function(instance,_ENV)
                    return function(oldf)  return   popup.cells      end,
                    function(oldf,self,v)

                        if type(v) ~= "table" then error("Expected table. Received: ",2) end

                        local items = {}

                        for i, item in ipairs(v) do

                            if type(item) == "table" and item.type then

                                item = _ENV[item.type](item)

                            elseif type(item) ~= "userdata" and item.__types__.actor then

                                error("Must be a UIElement or nil. Received "..obj,2)

                            end

                            --items[i] = {item}
                        end

                        popup.cells = v
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf)  return   "MenuButton"      end
                end,
                direction = function(instance,_ENV)
                    local cap = {
                        left  = "Left",
                        right = "Right",
                        up    = "Up",
                        down  = "Down",
                    }
                    local opposite = {
                        left  = "Right",
                        right = "Left",
                        up    = "Down",
                        down  = "Up",
                    }
                    return function(oldf)  return   direction      end,
                    function(oldf,self,v)
                        if direction == v then return end
                        if direction then
                            button.neighbors[cap[direction]] = nil
                            popup.neighbors[opposite[direction]] = nil
                        end
                        button.neighbors[cap[v]] = popup

                        if undo_curr_direction then undo_curr_direction() end
                        undo_curr_direction = button:add_key_handler(keys[cap[v]], function() open_popup() popup:grab_key_focus() end )

                        new_direction = v
                    end
                end,
                enabled = function(instance,_ENV)
                    return function(oldf)  return   button.enabled      end,
                    function(oldf,self,v)

                        button.enabled = v

                    end
                end,
                focused = function(instance,_ENV)
                    return function(oldf)  return   button.focused      end,
                    function(oldf,self,v)
                        if not instance.enabled then return end

                        button.focused = v

                    end
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

                        t.items = {}

                        for i = 1,popup.length do
                            t.items[i] = popup.cells[i].attributes
                        end

                        t.direction = instance.direction
                        t.item_spacing = instance.item_spacing
                        t.popup_offset = instance.popup_offset
                        t.horizontal_alignment = instance.horizontal_alignment

                        t.type = "MenuButton"

                        return t
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            position_popup= function(instance,_ENV)
                local possible_directions = {
                    up    = function()
                    end,
                    down  = function()
                    end,
                    left  = function()
                    end,
                    right = function()
                    end,
                }
                return function()
                    button.x = (direction == "left") and
                        (popup.w + popup_offset)or 0
                    button.y = (direction == "up") and
                        (popup.h + popup_offset)or 0
                    instance.anchor_point = button.position
                    popup.x = (direction == "right") and
                        (button.w + popup_offset)or 0
                    popup.y = (direction == "down") and
                        (button.h + popup_offset)or 0
                end
            end,
            update = function(instance,_ENV)
                local possible_directions = {
                    up    = { {popup},{button}},
                    down  = {{button}, {popup}},
                    left  = {{ popup,  button}},
                    right = {{button,   popup}},
                }
                return function()

                    if new_direction then
                        direction = new_direction
                        new_direction = false
                        reposition_popup = true
--[[
                        instance.number_of_rows =
                                ((direction == "up"   or direction == "down")  and 2) or
                                ((direction == "left" or direction == "right") and 1)
                        instance.number_of_cols =
                                ((direction == "up"   or direction == "down")  and 1) or
                                ((direction == "left" or direction == "right") and 2)
                        instance.cells = possible_directions[direction]

                        instance.focus_to_index = {
                            direction == "up"   and 2 or 1,
                            direction == "left" and 2 or 1
                        }

                        print("here")
--]]

                    end
                    if  reposition_popup then
                        reposition_popup = false

                        if popup.parent then
                            position_popup()
                        end
                    end
                    if restyle_button then
                        restyle_button = false
                        --local t = instance.style.attributes
                        --t.name = nil
                        --button.style:set(t)
                    end
                    old_update()
                end
            end,
            open_popup= function(instance,_ENV)
                return function()
                    add(instance,popup)
                    position_popup()
                end
            end,
            close_popup= function(instance,_ENV)
                return function()
                    popup:unparent()
                    button.position={0,0}
                    instance.anchor_point = button.position
                end
            end,
        },
        declare = function(self,parameters)

            parameters = parameters or {}


            local instance, _ENV = Widget()
            button = ToggleButton{
                --create_canvas=create_canvas,
                style = instance.style,
                w=300,
                reactive=true,
                selected = true
            }
            popup_offset = 10
            popup = ListManager{focus_to_index=1}

            add(instance,button,popup)
            --dumptable(get_children(instance))
            reposition_popup = true
            WL_parent_redirect[popup] = instance
            function instance:on_key_focus_in()
                button:grab_key_focus()
            end

            style_flags = "restyle_button"
            old_update = update
            new_direction  = "down"
            button:add_key_handler(   keys.OK, function() button:click()   end)

            old_on_pressed = button.on_pressed
            ---[[
            function button:on_pressed()

                old_on_pressed(self)

                if popup.parent then
                    close_popup()
                else
                    open_popup()
                end
            end
            --]]

            setup_object(self,instance,_ENV)

            updating = true
            instance:set(parameters)
            updating = false

            dumptable(get_children(instance))
            return instance, _ENV

        end
    }
)
external.MenuButton = MenuButton
