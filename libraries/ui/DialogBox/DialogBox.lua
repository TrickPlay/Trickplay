
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local function default_bg(self,w,h)

	--[[
	local c = Canvas(w,h)

	c.line_width = self.style.border.width

	round_rectangle(c,self.style.border.corner_radius)

	c:set_source_color( self.style.fill_colors.default )     c:fill(true)

	c:move_to(       c.line_width/2, self.separator_y or 0 )
	c:line_to( c.w - c.line_width/2, self.separator_y or 0 )

	c:set_source_color( self.style.border.colors.default )   c:stroke(true)
	--]]
    local style = self.style
	return  Group{children={NineSlice{name="backing",w=w,h=h,sheet = style.spritesheet, ids = {
                                nw   = style[self.widget_type.."/default/nw.png"],
                                n    = style[self.widget_type.."/default/n.png"],
                                ne   = style[self.widget_type.."/default/ne.png"],
                                w    = style[self.widget_type.."/default/w.png"],
                                c    = style[self.widget_type.."/default/c.png"],
                                e    = style[self.widget_type.."/default/e.png"],
                                sw   = style[self.widget_type.."/default/sw.png"],
                                s    = style[self.widget_type.."/default/s.png"],
                                se   = style[self.widget_type.."/default/se.png"],
                            }
                        },
            Sprite{sheet=style.spritesheet,id=self.widget_type.."/seperator-h.png",w=w,y=self.separator_y}
        }
	}
end

local default_parameters = {
	w = 400, h = 300, title = "DialogBox", separator_y = 50, reactive = true
}



DialogBox = setmetatable(
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
                    return function() return "DialogBox" end, nil
                end,
                w = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) flag_for_redraw = true size_is_set = true w = v end
                end,
                width = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) flag_for_redraw = true size_is_set = true w = v end
                end,
                h = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) flag_for_redraw = true size_is_set = true h = v end
                end,
                height = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) flag_for_redraw = true size_is_set = true h = v end
                end,
                size = function(instance,_ENV)
                    return function(oldf) return {w,h}     end,
                    function(oldf,self,v)
                        flag_for_redraw = true
                        size_is_set = true
                        w = v[1]
                        h = v[2]
                    end
                end,
                image = function(instance,_ENV)
                    return function(oldf,self) return image     end,
                    function(oldf,self,v)

                        if type(v) == "string" then

                            if image == nil or image.src ~= v then

                                setup_image(Image{ src = v })

                            end

                        elseif type(v) == "userdata" and v.__types__.actor then

                            if v ~= image then

                                setup_image(v)

                            end

                        elseif v == nil then

                            if not canvas then

                                flag_for_redraw = true

                                return

                            end

                        else

                            error("DialogBox.image expected type 'table'. Received "..type(v),2)

                        end

                    end
                end,
                title = function(instance,_ENV)
                    return function(oldf,self) return title.text     end,
                    function(oldf,self,v)
                        title.text = v
                        print("text h",title.h)
                        redraw_title = true
                    end
                end,
                separator_y = function(instance,_ENV)
                    return function(oldf,self) return separator_y     end,
                    function(oldf,self,v)
                        separator_y = v
                        content_group.y = v
                        flag_for_redraw = true
                        redraw_title = true
                        separator_y_set = true
                    end
                end,
                children = function(instance,_ENV)
                    return function(oldf) return content_group.children     end,
                    function(oldf,self,v)
                        if type(v) ~= "table" then error("Expected table. Received "..type(v), 2) end
                        content_group:clear()

                        if type(v) == "table" then

                            for i,obj in ipairs(v) do

                                if type(obj) == "table" and obj.type then

                                    v[i] = _ENV[obj.type](obj)

                                elseif type(obj) ~= "userdata" and obj.__types__.actor then

                                    error("Must be a UIElement or nil. Received "..obj,2)

                                end

                            end
                            content_group:add(unpack(v))

                        elseif type(v) == "userdata" then

                            content_group:add(v)

                        end
                    end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        local t = oldf(self)

                        t.separator_y = instance.separator_y
                        t.title       = instance.title

                        if (not canvas) and bg.src and bg.src ~= "[canvas]" then

                            t.image = bg.src

                        end

                        t.children = {}

                        for i, child in ipairs(content_group.children) do
                            t.children[i] = child.attributes
                        end
                        --[[
                        if content and content.to_json then

                            t.children =

                        end
                        --]]

                        t.type = "DialogBox"

                        return t
                    end
                end,


            },
            functions = {
                add    = function(instance,_ENV) return function(oldf,self,...) content_group:add(   ...) end end,
                remove = function(instance,_ENV) return function(oldf,self,...) content_group:remove(...) end end,


            },
        },


        private = {

            update_title = function(instance,_ENV)
                return function()

                    local text_style = instance.style.text

                    title:set(   text_style:get_table()   )

                    title.anchor_point = {0,title.h/2}
                    title.x            = text_style.x_offset
                    title.color        = text_style.colors.default

                end
            end,
            center_title = function(instance,_ENV)
                return function()

                    title.w = instance.w
                    title.y = instance.style.text.y_offset + separator_y/2

                end
            end,
            resize_images = function(instance,_ENV)
                return function()

                    if not size_is_set then return end

                    bg.w = instance.w
                    bg.h = instance.h

                end
            end,
            make_canvas = function(instance,_ENV)
                return function()

                    --env.flag_for_redraw = false

                    canvas = true

                    if bg then bg:unparent() end

                    bg = default_bg(instance,w,h)

                    add(instance, bg )

                    bg:lower_to_bottom()

                    return true

                end
            end,
            setup_image = function(instance,_ENV)
                return function(v)

                    canvas = false

                    bg = v

                    if bg then bg:unparent() end

                    add(instance, bg )

                    bg:lower_to_bottom()

                    if instance.is_size_set() then

                        resize_images()

                    else
                        --so that the label centers properly
                        instance.size = bg.size

                        --instance:reset_size_flag()

                        center_title()

                    end

                    return true

                end
            end,

            update = function(instance,_ENV)
                return function()

                    if redraw_title then
                        redraw_title = false
                        update_title()
                        if not separator_y_set then
                            separator_y = title.h
                            content_group.y = separator_y
                            print(separator_y)
                        end
                        resize = true
                    end
                    if flag_for_redraw then
                        flag_for_redraw = false
                        if canvas then
                            make_canvas()
                        else
                            resize_images()
                        end
                    end
                    if resize then
                        resize = false
                        center_title()
                    end
                end
            end,
        },
        declare = function(self,parameters)

            parameters = parameters or {}

            local instance, _ENV = Widget()
            local getter, setter


            style_flags = {
                border = "flag_for_redraw",
                text = {
                    "redraw_title",
                },
                fill_colors = "flag_for_redraw"
            }
            title = Text{text="DialogBox"}
            content_group = Widget_Group()

            WL_parent_redirect[content_group] = instance

            bg = nil
            separator_y_set = false
            separator_y = 50
            content_group.y = separator_y

            w = 400
            h = 300
            canvas = true
            redraw_title = true
            flag_for_redraw = true
            resize = true

            add( instance, content_group, border, title )

            setup_object(self,instance,_ENV)

            dumptable(get_children(instance))
            return instance, _ENV

        end
    }
)
external.DialogBox = DialogBox
