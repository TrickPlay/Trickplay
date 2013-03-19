
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local top_tabs = function(self,state)
            local style = self.style
            return NineSlice{
                w = self.w,
                h = self.h,
                sheet = style.spritesheet,
                ids = {
                                nw   = style["TabBar/default/nw.png"],
                                n    = style["TabBar/default/n.png"],
                                ne   = style["TabBar/default/ne.png"],
                                w    = style["TabBar/default/w.png"],
                                c    = style["TabBar/default/c.png"],
                                e    = style["TabBar/default/e.png"],
                                --sw   = style["TabBar/default/sw.png"],
                                --s    = style["TabBar/default/s.png"],
                                --se   = style["TabBar/default/se.png"],
                            }
            }
    --[[
	local c = Canvas(self.w,self.h)
    mesg("TABBAR",0,"TabBar make top_tab",self.gid,state)

	c.op = "SOURCE"

	c.line_width = self.style.border.width

	local r     = self.style.border.corner_radius
    local inset = c.line_width/2

    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w - (inset+r), inset)
    --top-right corner
    c:arc( c.w - (inset+r), inset+r, r,270,360)
    c:line_to(c.w - inset,c.h + inset)
    --bottom-right corner
    c:line_to( inset, c.h + inset)
    --bottom-left corner
    c:line_to( inset, inset+r)

	c:set_source_color( self.style.fill_colors[state] or "00000000" )

	c:fill(true)

	c:set_source_color( self.style.border.colors[state] or "ffffff" )

	c:stroke(true)

	return c:Image()
	--]]
end

local side_tabs = function(self,state)
            local style = self.style
            return NineSlice{
                w = self.w,
                h = self.h,
                sheet = style.spritesheet,
                ids = {
                                nw   = style["TabBar/default/nw.png"],
                                n    = style["TabBar/default/n.png"],
                                --ne   = style["TabBar/default/ne.png"],
                                w    = style["TabBar/default/w.png"],
                                c    = style["TabBar/default/c.png"],
                                --e    = style["TabBar/default/e.png"],
                                sw   = style["TabBar/default/sw.png"],
                                s    = style["TabBar/default/s.png"],
                                --se   = style["TabBar/default/se.png"],
                            }
            }


    --[[
	local c = Canvas(self.w,self.h)
    mesg("TABBAR",0,"TabBar make side_tab",self.gid,state)
	c.op = "SOURCE"

	c.line_width = self.style.border.width

	local r     = self.style.border.corner_radius
    local inset = c.line_width/2

    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w + inset, inset)
    --top-right corner
    c:line_to(c.w + inset, c.h - inset)
    --bottom-right corner
    c:line_to( inset+r, c.h - inset)
    --bottom-left corner
    c:arc( inset+r, c.h - (inset+r), r,90,180)
    c:line_to( inset, inset+r)


	c:set_source_color( self.style.fill_colors[state] or "00000000" )

	c:fill(true)

	c:set_source_color( self.style.border.colors[state] or "ffffff" )

	c:stroke(true)

	return c:Image()
	--]]
end

local default_parameters = {tab_w = 200,tab_h = 50,pane_w = 400,pane_h = 300, tab_location = "top"}



-----------------------------------------------------------------------------
-- TabBar's base is a ListManager, this allows for easier alignment when
--         switching the location of the tabs
-- This ListManager contains 2 items: an ArrowPane and a Group
-- The ArrowPane contains a ListManager of ToggleButtons, linked with a
-- RadioButtonGroup
-----------------------------------------------------------------------------
TabBar = setmetatable(
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
                enabled = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        oldf(self,v)
                        for i = 1,tabs_lm.length do
                            tabs_lm.cells[i].enabled = v
                        end
                        tab_pane.enabled = v
                    end
                end,
                pane_w = function(instance,_ENV) -- TODO check need for these upvals
                    return function(oldf) return   pane_w     end,
                    function(oldf,self,v)
                        pane_w = v
                        panes_obj.w = v
                        if tab_location == "top" then
                            tab_pane.pane_w    = pane_w
                        end
                    end
                end,
                pane_h = function(instance,_ENV)
                    return function(oldf) return   pane_h     end,
                    function(oldf,self,v)
                        pane_h = v
                        panes_obj.h = v
                        if tab_location == "left" then
                            tab_pane.pane_h    = pane_h
                        end
                    end
                end,
                tab_w = function(instance,_ENV)
                    return function(oldf) return   tab_w     end,
                    function(oldf,self,v)
                        tab_w = v
                        resize_tabs = true
                    end
                end,
                tab_images = function(instance,_ENV)
                    return function(oldf) return   tab_images     end, -- TODO either return clone, or metatable for changes
                    function(oldf,self,v)
                        local old_images = tab_images or {}
                        tab_images = v

                        for k,v in pairs(v) do
                            add(instance,v)
                            v:hide()
                        end

                        for i = 1,tabs_lm.length do

                            local clones = {}

                            for k,v in pairs(v) do
                                clones[k] = Clone{source=v}
                            end

                            tabs_lm.cells[i].images = clones

                        end

                        for k,v in pairs(old_images) do
                            v:unparent()
                        end
                    end
                end,
                tab_h = function(instance,_ENV)
                    return function(oldf) return   tab_h     end,
                    function(oldf,self,v)
                        tab_h = v
                        resize_tabs = true
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "TabBar" end, nil
                end,
                selected_tab = function(instance,_ENV)
                    return function(oldf) return new_selection or rbg.selected end,
                    function(oldf,self,v)        new_selection = v  end
                end,
                tabs = function(instance,_ENV)
                    return function(oldf)  return   tabs_interface      end,
                    function(oldf,self,v)
                        if type(v) ~= "table" then error("Expected table. Received: ",2) end
                        new_tabs = v
                        resize_tabs = true
                    end
                end,
                tab_location = function(instance,_ENV)
                    return function(oldf) return   tab_location     end,
                    function(oldf,self,v)
                        mesg("TABBAR",0,"TabBar.tab_location =",v)
                        if tab_location == v then return end
                        new_tab_location = true
                        --[[
                        if v == "top" then
                            updating = true --TODO need a better way to do a non-updating set of this
                            instance.direction  = "vertical"
                            updating = false
                            tabs_lm.direction  = "horizontal"
                            --TODO set??
                            print("oreo\n\n\n\n",pane_w,tabs_lm.w)
                            tab_pane.pane_w    = pane_w
                            tab_pane.pane_h    = tab_h
                            tab_pane.virtual_w = tabs_lm.w
                            tab_pane.virtual_h = tab_h
                            tab_pane.arrow_move_by   = tab_w + tabs_lm.spacing
                            for _,tab in tabs_lm.cells.pairs() do
                                tab.create_canvas = top_tabs
                                tab.w = 200
                            end
                        elseif v == "left" then
                            updating = true --TODO need a better way to do a non-updating set of this
                            instance.direction  = "horizontal"
                            updating = false
                            tabs_lm.direction  = "vertical"
                            --TODO set??
                            print("pane_h = "..pane_h)
                            tab_pane.pane_w    = tab_w
                            tab_pane.pane_h    = pane_h
                            tab_pane.virtual_w = tab_w
                            tab_pane.virtual_h = tabs_lm.h
                            tab_pane.arrow_move_by   = tab_h + tabs_lm.spacing
                            for _,tab in tabs_lm.cells.pairs() do
                                tab.create_canvas = side_tabs
                            end
                        else
                            error("Expected 'top' or 'left'. Received "..v,2)
                        end
                        --]]
                        tab_location = v
                    end
                end,

                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        local t = oldf(self)

                        t.length               = nil
                        t.number_of_cols       = nil
                        t.number_of_rows       = nil
                        t.vertical_alignment   = nil
                        t.horizontal_alignment = nil
                        t.vertical_spacing     = nil
                        t.horizontal_spacing   = nil
                        t.cell_h = nil
                        t.cell_w = nil
                        t.cells  = nil

                        t.style = instance.style.name

                        t.tab_w  = instance.tab_w
                        t.tab_h  = instance.tab_h
                        t.pane_w = instance.pane_w
                        t.pane_h = instance.pane_h
                        t.tabs   = instance.tabs
                        t.tab_location = instance.tab_location

                        t.tabs = {}

                        for i = 1,tabs_lm.length do
                            t.tabs[i]    = {
                                label    = tabs_lm.cells[i].label,
                                contents = tabs_lm.cells[i].contents.attributes
                            }
                        end

                        t.type = "TabBar"

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
                    mesg("TABBAR",{0,5},"TabBar update called")
                    if restyle_tabs then
                        restyle_tabs = false
                        for i = 1,tabs_lm.length do

                            tabs_lm.cells[i].style:set(instance.style.attributes)

                        end
                    end
                    if restyle_arrows then
                        restyle_arrows = false

                        tab_pane.style.arrow:set(instance.style.arrow.attributes)
                    end
                    if resize_tabs then
                        resize_tabs = false
                        if not new_tabs then
                            for i = 1,tabs_lm.length do

                                tabs_lm.cells[i].size = {tab_w,tab_h}

                            end
                        end
                        if tab_location == "top" then

                            tab_pane.pane_h        = tab_h
                            tab_pane.virtual_h     = tab_h
                            tab_pane.arrow_move_by = tab_w + tabs_lm.spacing
                        elseif tab_location == "left" then
                            tab_pane.pane_w        = tab_w
                            tab_pane.virtual_w     = tab_w
                            tab_pane.arrow_move_by = tab_h + tabs_lm.spacing
                        end
                    end
                    if new_tabs then
                        mesg("TABBAR",0,"TabBar:update() setting new_tabs")
                        tabs_lm.cells = new_tabs
                        if tab_location == "top" then
                            tab_pane.virtual_w = tabs_lm.w
                        else
                            tab_pane.virtual_h = tabs_lm.h
                        end
                        new_tabs = false
                    end
                    if new_tab_location then
                        new_tab_location = false
                        if tab_location == "top" then
                            instance.direction  = "vertical"
                            tabs_lm.direction  = "horizontal"
                            --TODO set??
                            tab_pane.pane_w    = pane_w
                            tab_pane.pane_h    = tab_h
                            tab_pane.virtual_w = tabs_lm.w
                            tab_pane.virtual_h = tab_h
                            tab_pane.arrow_move_by   = tab_w + tabs_lm.spacing
                            for _,tab in tabs_lm.cells.pairs() do
                                tab.create_canvas = top_tabs
                                tab.w = 200
                            end
                        elseif tab_location == "left" then
                            instance.direction  = "horizontal"
                            tabs_lm.direction  = "vertical"
                            --TODO set??
                            tab_pane.pane_w    = tab_w
                            tab_pane.pane_h    = pane_h
                            tab_pane.virtual_w = tab_w
                            tab_pane.virtual_h = tabs_lm.h
                            tab_pane.arrow_move_by   = tab_h + tabs_lm.spacing
                            for _,tab in tabs_lm.cells.pairs() do
                                tab.create_canvas = side_tabs
                            end
                        else
                            error("Expected 'top' or 'left'. Received "..v,2)
                        end

                    end

                    old_update()
                    print("here")
                    if  new_selection then
                        print("DQDQQQDQDDQ")
                        rbg.selected = new_selection
                        new_selection = false
                    end

                    --tabs_lm__ENV:call_update()
                end
            end,
        },
        declare = function(self,parameters)

            parameters = parameters or {}

            local instance,_ENV = ListManager:declare{vertical_alignment = "top",spacing=0}
            style_flags = {
                border      = "restyle_tabs",
                text        = "restyle_tabs",
                fill_colors = "restyle_tabs",
                arrow       = "restyle_arrows",
            }

            function instance:on_key_focus_in()
                if tabs_lm.length > 0 then
                    rbg.items[rbg.selected]:grab_key_focus()
                end
            end
            panes = {}
            tabs = {}
            rbg= RadioButtonGroup{name = "TabBar",
                on_selection_change = function()
                    mesg("TABBAR",0,"TabBar.rbg.on_selection_change")
                    for i = 1,tabs_lm.length do
                        local t = tabs_lm.cells[i]
                        if t.selected then
                            t.contents:show()
                            --t:grab_key_focus()
                        else
                            t.contents:hide()
                        end
                    end
                end
            }



            old_update = update

            pane_w = 400
            pane_h = 300
            panes_obj = Widget_Group{
                size = {pane_w,pane_h},
                name = "Panes",
                clip_to_size = true,
                on_key_focus_in = function()
                    if tabs_lm.length > 0 then
                        rbg.items[rbg.selected].contents:grab_key_focus()
                    end
                end
            }

            WL_parent_redirect[panes_obj] = instance

            tab_w = 200
            tab_h = 50
            tab_images   = nil
            tab_style    = nil
            tab_location = "top"
            resize_tabs = true
            new_selection = 1

            local function make_tab_interface(tb)
                --prevents the user from getting/setting any of the other fields of the ToggleButtons
                local setter = {
                    label    = function(v) tb.label = v end,
                    contents = function(v)
                        tb.contents:unparent()
                        tb.contents = v
                        panes_obj:add(v)
                        if not tb.selected then v:hide() end
                    end,
                }
                local getter = {
                    label    = function() return tb.label end,
                    contents = function() return tb.contents end,
                }
                return setmetatable({},{
                    __index = function(_,k)
                        return getter[k] and getter[k]()
                    end,
                    __newindex = function(_,k,v)
                        return setter[k] and setter[k](v)
                    end,
                })
            end
            tab_to_interface_map = {}

            tabs_lm = ListManager:declare{
                name = "Tabs ListManager",
                spacing = 0,
                vertical_alignment = "top",
                direction = "horizontal",
                node_constructor = function(obj)



                    mesg("TABBAR",{0,3},"New Tab Button")
                    if obj == nil then
                        obj = {label = "Tab",contents = Widget_Group()}
                    elseif type(obj) ~= "table" then
                        error("Expected tab entry to be a string. Received "..type(obj),2)
                    elseif type(obj.label) ~= "string" then
                        error("Received a tab without a label",2)
                    end
                    if type(obj.contents) == "table" and obj.contents.type then

                        obj.contents = _ENV[obj.contents.type](obj.contents)

                    elseif type(obj.contents) ~= "userdata" and obj.contents.__types__.actor then

                        error("Must be a UIElement or nil. Received "..obj.contents,2)
                    end
                    local pane = obj.contents

                    --local style = instance.style.attributes
                    --style.name = style
                    --style.border.colors.selection = style.border.colors.selection or "ffffff"
                    local clones
                    if tab_images then
                        clones = {}

                        for k,v in pairs(tab_images) do
                            clones[k] = Clone{source=v}
                        end
                    end
                    local sel = rbg.selected
                    obj = RadioButton{
                        hide_icon = true,
                        label  = obj.label,
                        w      = tab_w,
                        h      = tab_h,
                        style  = instance.style,--style,
                        group  = rbg,
                        images = clones,
                        reactive = true,
                        create_canvas = tab_location == "top" and top_tabs or side_tabs,
                        --images = tab_images,
                    }
                    local old_okfi = obj.on_key_focus_in
                    ---[[
                    function obj:on_key_focus_in()
                        old_okfi()
                        --obj.selected = true
                        tab_pane.virtual_x = obj.x - tab_pane.pane_w/2
                        tab_pane.virtual_y = obj.y - tab_pane.pane_h/2
                    end
                    function obj:on_pressed()  obj.selected = true  end
                    --]]
                    obj.contents = pane
                    mesg("TABBAR",0,"button made")
                    ---[[
                    if tab_style then
                        obj.style:set(tab_style.attributes) -- causes extra redraw
                    end
                    --]]

                    tab_to_interface_map[obj] = make_tab_interface(obj)
                    --table.insert(tabs,obj)
                    --obj.pane = pane
                    --table.insert(panes,pane)
                    obj.contents:hide()
                    panes_obj:add(obj.contents)
                    obj.contents.w = pane_w
                    obj.contents.h = pane_h

                    if sel then new_selection = sel end
                    return obj
                end
            }

            tabs_interface = setmetatable({},{
                __index = function(_,k)
                    local v = tabs_lm.cells[k]
                    return type(k) == "number" and v and
                        tab_to_interface_map[v] or
                        v
                end,
                --pass through to the ListManager
                __newindex = function(_,k,v)
                    tabs_lm = v
                end,
            })

            tabs_lm__ENV = get_env(tabs_lm)

            --TODO roll into a single set
            tab_pane = ArrowPane{
                name = "ArrowPane",
                style = instance.style,
                arrow_move_by = tab_w,
                on_key_focus_in = function()
                    if tabs_lm.length > 0 then
                        rbg.items[rbg.selected]:grab_key_focus()
                    end
                end
            }
            --tab_pane.style.arrow.offset = -tab_pane.style.arrow.size
            --tab_pane.style.border.colors.default = "00000000"
            --tab_pane.style.fill_colors.default   = "00000000"
            tab_pane:add(tabs_lm)

            instance.cells = {tab_pane,panes_obj}

            setup_object(self,instance,_ENV)

            dumptable(get_children(instance))
            return instance, _ENV

        end
    }
)
external.TabBar = TabBar
