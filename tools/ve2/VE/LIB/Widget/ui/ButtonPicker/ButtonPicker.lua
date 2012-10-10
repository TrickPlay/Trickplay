BUTTONPICKER = true

local create_bg = function(self)
	
	local c = Canvas(self.window_w,self.window_h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors.default )     c:fill(true)
	
	return c:Image{name="bg"}
	
end
local create_fg = function(self)
	
	local c = Canvas(self.window_w,self.window_h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.border.colors.default )   c:stroke(true)
	
	return c:Image{name="fg"}
	
end
local create_arrow = function(self,state)
	
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    
	c:set_source_color( self.style.fill_colors[state] )     c:fill(true)
	
	return c:Image()
	
end



ButtonPicker = setmetatable(
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
                attributes = function(instance,env)
                    return function(oldf,self)
                        local t = oldf(self)
                        
                        t.length       = nil
                        t.vertical_alignment   = nil
                        t.horizontal_alignment = nil
                        t.direction = nil
                        t.spacing   = nil
                        t.cell_h = nil
                        t.cell_w = nil
                        t.cells = nil
                        
                        t.style = instance.style
                        
                        t.window_w = instance.window_w
                        t.window_h = instance.window_h
                        t.animate_duration = instance.animate_duration
                        t.orientation = instance.orientation
                        t.items = {}
                        
                        for i = 1,env.list_entries.length do
                            t.items[i] = env.list_entries[i].text
                        end
                        
                        t.type = "ButtonPicker"
                        
                        return t
                    end
                end,
                enabled = function(instance,env)
                    return nil,
                    function(oldf,self,v)
                        env.next_arrow.enabled = instance.enabled
                        env.prev_arrow.enabled = instance.enabled
                    end
                end,
                animate_duration = function(instance,env)
                    return function(oldf) return env.update_tl.duration     end,
                    function(oldf,self,v)        env.update_tl.duration = v end
                end,
                window_w = function(instance,env)
                    return function(oldf) return env.window_w end,
                    function(oldf,self,v) 
                        env.window_w = v 
                        env.new_window_sz = true
                    end
                end,
                window_h = function(instance,env)
                    return function(oldf) return env.window_h end,
                    function(oldf,self,v) 
                        env.window_h = v 
                        env.new_window_sz = true
                    end
                end,
                items = function(instance,env)
                    return function(oldf) return env.list_entries end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "table" then error("Expected table. Received :"..type(v),2) end
                        
                        if #v == 0 then error("Table is empty.",2) end
                        
                        env.list_entries:set(v)
                        
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "ButtonPicker" end
                end,
                orientation = function(instance,env)
                    return function(oldf) return env.orientation end,
                    function(oldf,self,v) 
            
                        if env.orientation == v then return end
                        
                        env.orientation = v
                        
                    end
                end,
    
            },
            functions = {
            },
        },
        private = {
            update = function(instance,env)
                return function()
                    
                    if env.restyle_label then
                        env.restyle_label = false
                        for i,item in env.list_entries.pairs() do
                            item:set(   instance.style.text:get_table()   )
                            item.color = instance.style.text.colors.default
                        end
                    end
                    if env.recolor_arrows then
                        env.recolor_arrows = false
                        env.prev_arrow.style.fill_colors = instance.style.arrow.colors.attributes
                        env.next_arrow.style.fill_colors = instance.style.arrow.colors.attributes
                    end
                    if env.restyle_arrows then
                        env.restyle_arrows = false
                        env.prev_arrow:set{
                            w = instance.style.arrow.size,
                            h = instance.style.arrow.size,
                            anchor_point = {
                                instance.style.arrow.size/2,
                                instance.style.arrow.size/2
                            },
                        }
                        env.next_arrow:set{
                            w = instance.style.arrow.size,
                            h = instance.style.arrow.size,
                            anchor_point = {
                                instance.style.arrow.size/2,
                                instance.style.arrow.size/2
                            },
                        }
                        instance.spacing = instance.style.arrow.offset
                    end
                    if env.flag_for_redraw then
                        env.flag_for_redraw = false
                        env.redo_fg()
                        env.redo_bg()
                    end
                    if env.new_window_sz then
                        env.new_window_sz = false
                        env.redo_bg()
                        env.redo_fg()
                        env.window.w = env.window_w
                        env.window.h = env.window_h
                        env.window.clip = {
                            0,-- -window_w/2,
                            0,-- -window_h/2,
                            env.window_w,
                            env.window_h,
                        }
                        if env.next_item then
                            env.next_item.x = env.window_w/2
                            env.next_item.y = env.window_h/2
                        end
                        --print("s
                    end
                    if env.new_orientation then
                        env.new_orientation = false
                        if env.undo_prev_function then env.undo_prev_function() end
                        if env.undo_next_function then env.undo_next_function() end
                        
                        if env.orientation == "horizontal" then
                            env.prev_arrow:set{z_rotation={  0,0,0}}
                            env.next_arrow:set{z_rotation={180,0,0}}
                            env.undo_prev_function = instance:add_key_handler(keys.Left, env.prev_i)
                            env.undo_next_function = instance:add_key_handler(keys.Right,env.next_i)
                        elseif env.orientation == "vertical" then
                            env.prev_arrow:set{z_rotation={ 90,0,0}}
                            env.next_arrow:set{z_rotation={270,0,0}}
                            env.undo_prev_function = instance:add_key_handler(keys.Up,  env.prev_i)
                            env.undo_next_function = instance:add_key_handler(keys.Down,env.next_i)
                        else
                            
                            error("ButtonPicker.orientation expects 'horizontal' or 'vertical as its value. Received: "..env.orientation,2)
                            
                        end
                        instance.direction = env.orientation
                    end
                    env.lm_update()
                end
            end,
            prev_i = function(instance,env)
                return function() 
                    if env.list_entries.length <= 1 then return end
                    if not env.animating then
                        env.animating  = "BACK"
                        env.index_direction = -1
                        
                        env.update_tl:start()
                        
                    else
                        env.again = "BACK"
                    end
                end
            end,
            next_i = function(instance,env)
                return function() 
                    if env.list_entries.length <= 1 then return end
                    if not env.animating then
                        env.animating = "FORWARD"
                        env.index_direction = 1
                        
                        env.update_tl:start()
                    else
                        env.again = "FORWARD"
                    end
                end
            end,
            redo_bg = function(instance,env)
                return function() 
                    if env.bg and env.bg.parent then env.bg:unparent() end
                    env.bg = create_bg(instance)
                    env.window:add(env.bg)
                    env.bg:lower_to_bottom()
                end
            end,
            redo_fg = function(instance,env)
                return function() 
                    if env.fg and env.fg.parent then env.fg:unparent() end
                    env.fg = create_fg(instance)
                    env.window:add(env.fg)
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local text = Group{name="text"}
            local window = Widget_Group{name="window",children={text}}
            
            local prev_arrow = Button{
                name = "prev",
                style = false,
                label = "",
                create_canvas = create_arrow,
                reactive = true,
            }
            local next_arrow = Button{
                name = "next",
                style = false,
                label = "",
                create_canvas = create_arrow,
                reactive = true,
            }
            local instance, env  = ListManager:declare{
                cells = {
                    prev_arrow,
                    window,
                    next_arrow
                },
            }
            env.orientation = "horizontal"
            env.lm_update = env.update
            env.flag_for_redraw = true
            env.restyle_arrows  = true
            env.recolor_arrows  = true
            env.restyle_label   = true
            env.new_orientation = true
            env.new_window_sz   = true
            env.style_flags = {
                border = "flag_for_redraw",
                arrow = {
                    "restyle_arrows",
                    colors = "recolor_arrows",
                },
                text = "restyle_label",
                fill_colors = "flag_for_redraw"
            }
            env.next_arrow = next_arrow
            env.prev_arrow = prev_arrow
            env.text       = text
            env.window     = window
            env.window_w   = 200
            env.window_h   = 70
            
            env.bg = false
            env.fg = false
            
            env.list_entries = false
            env.animating = false
            env.again = false
            env.next_item = false
            env.prev_item = false
            env.index_direction = false
            env.curr_index = 1
            print("creating array")
            env.list_entries = ArrayManager{
                
                node_constructor=function(obj,i)
                    --TODO: fix this to accept any UIElement
                    
                    print("node constr",obj)
                    if type(obj) == "string" then  
                        obj = Text{text=obj}
                        obj:set(   instance.style.text:get_table()   )
                        obj.color = instance.style.text.colors.default
                        
                    elseif type(obj) == "table" and obj.type then 
                        
                        obj = _G[obj.type](obj)
                        
                    elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                    
                        error("Must be a UIElement or nil. Received "..obj,2) 
                        
                    end
                    
                    return obj
                end,
                node_destructor=function(obj,i)
                    
                    if obj.parent then  obj:unparent()  end
                    
                end,
                on_entries_changed = function(self)
                    
                    if env.animating then
                        
                        self[env.wrap_i(env.curr_index+env.index_direction)] = env.prev_item.position
                        self[env.curr_index].position  = env.next_item.position
                        
                    elseif self[env.curr_index] ~= nil and env.next_item ~= self[env.curr_index] then
                        print("got it")
                        if env.next_item then env.next_item:unparent() end
                        env.next_item = self[env.curr_index]
                        text:add(env.next_item)
                        env.next_item.anchor_point = {env.next_item.w/2,env.next_item.h/2}
                        env.next_item.x = env.window_w/2
                        env.next_item.y = env.window_h/2
                        
                    end
                    
                end
            }
            print("done")
            env.next_i = false
            env.prev_i = false
            
            env.path = Interval(0,0)
            
            env.animate_x = function(tl,ms,p) env.text.x = env.path:get_value(p) end
            env.animate_y = function(tl,ms,p) env.text.y = env.path:get_value(p) end
            env.wrap_i    = function(i) return (i - 1) % (env.list_entries.length) + 1    end
            
            env.update_tl = Timeline{
                on_started = function(tl)
                    env.prev_item  = env.list_entries[env.curr_index]
                    env.curr_index = env.wrap_i(env.curr_index + env.index_direction)
                    env.next_item  = env.list_entries[env.curr_index]
                    
                    env.text:add(env.next_item)
                    env.next_item.anchor_point = {env.next_item.w/2,env.next_item.h/2}
                    if env.orientation == "horizontal" then
                        
                        env.next_item.x = env.window_w/2-env.window_w*env.index_direction
                        env.next_item.y = env.window_h/2
                        env.path.to = env.window_w*env.index_direction
                        
                        tl.on_new_frame = env.animate_x
                        
                    elseif env.orientation == "vertical" then
                        
                        env.next_item.x = env.window_w/2
                        env.next_item.y = env.window_h/2-env.window_h*env.index_direction
                        
                        env.path.to = env.window_h*env.index_direction
                        
                        tl.on_new_frame = env.animate_y
                        
                    else
                    end
                    
                end,
                on_completed = function()
                    env.prev_item:unparent()
                    env.text.x=0
                    env.text.y=0
                    env.next_item.x = env.window_w/2
                    env.next_item.y = env.window_h/2
                    
                    env.animating = nil
                    
                    if env.again == "BACK" then
                        env.prev_i()
                    elseif again == "FORWARD" then
                        env.next_i()
                    end
                    env.again = nil
                end
            }
            env.undo_prev_function = false
            env.undo_next_function = false
            
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
            env.prev_arrow:add_mouse_handler("on_button_up",env.prev_i)
            env.next_arrow:add_mouse_handler("on_button_up",env.next_i)
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
--[=[
ggButtonPicker = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ButtonPicker",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    local window_w = parameters.window_w
    local window_h = parameters.window_h
    ----------------------------------------------------------------------------
	--The ButtonPicker Object inherits from LayoutManager
	--[[
    local text = Group()
    local window = Widget_Group()
    
    local prev_arrow = Button{
        style = false,
        label = "",
        create_canvas = create_arrow,
        reactive = true,
    }
    local next_arrow = Button{
        style = false,
        label = "",
        create_canvas = create_arrow,
        reactive = true,
    }
	local instance = ListManager{
        cells = {
            prev_arrow,
            window,
            next_arrow
        },
    }
    --]]
    --[[
    local bg,fg
    
    local items
    local animating, again
    local next_item, prev_item,  direction
    local curr_index = 1
	
    items = ArrayManager{
        
        node_constructor=function(obj,i)
            
            if type(obj) ~= "string" then  end
            
            obj = Text{text=obj}
            obj:set(   instance.style.text:get_table()   )
            obj.color = instance.style.text.colors.default
            return obj
        end,
        node_destructor=function(obj,i)
            
            if obj.parent then  obj:unparent()  end
            
        end,
        on_entries_changed = function(self)
            
            if animating then
                
                self[wrap_i(curr_index+direction)] = prev_item.position
                self[curr_index].position  = next_item.position
                
            elseif next_item ~= self[curr_index] then
                
                if next_item then next_item:unparent() end
                next_item = self[curr_index]
                text:add(next_item)
                next_item.anchor_point = {next_item.w/2,next_item.h/2}
                next_item.x = window_w/2
                next_item.y = window_h/2
                
            end
            
        end
    }
    --]]
    ----------------------------------------------------------------------------
    --[[
	override_property(instance,"window_w",
		function(oldf) return   window_w     end,
		function(oldf,self,v)   window_w = v end
	)
	override_property(instance,"window_h",
		function(oldf) return   window_h     end,
		function(oldf,self,v)   window_h = v end
	)
    
    local function redo_bg()
        if bg and bg.parent then bg:unparent() end
        bg = create_bg(instance)
        window:add(bg)
        bg:lower_to_bottom()
    end
    local function redo_fg()
        if fg and fg.parent then fg:unparent() end
        fg = create_fg(instance)
        window:add(fg)
    end
	instance:subscribe_to(
		{"window_h","window_w"},
		function()
			
			redo_bg()
			redo_fg()
            window.w = window_w
            window.h = window_h
            window.clip = {
                0,-- -window_w/2,
                0,-- -window_h/2,
                window_w,
                window_h,
            }
            if next_item then
                next_item.x = window_w/2
                next_item.y = window_h/2
            end
		end
	)
    --]]
    ----------------------------------------------------------------------------
    --[[
	override_property(instance,"items",
		function(oldf) return   items     end,
		function(oldf,self,v)  
            
            if type(v) ~= "table" then error("Expected table. Received :"..type(v),2) end
            
            if #v == 0 then error("Table is empty.",2) end
            
            items.length = #v
            
            items:set(v)
            
        end
	)
    
    
	override_property(instance,"widget_type",
		function() return "ButtonPicker" end, nil
	)
    --]]
    ----------------------------------------------------------------------------
    --[[
    local next_i, prev_i
    
    local path = Interval(0,0)
    
    local animate_x = function(tl,ms,p) text.x = path:get_value(p) end
    local animate_y = function(tl,ms,p) text.y = path:get_value(p) end
    local wrap_i    = function(i) return (i - 1) % (items.length) + 1    end
    local orientation
    --]]
    --[[
    local update = Timeline{
        on_started = function(tl)
            prev_item  = items[curr_index]
            curr_index = wrap_i(curr_index + direction)
            next_item  = items[curr_index]
            
            text:add(next_item)
            next_item.anchor_point = {next_item.w/2,next_item.h/2}
            if orientation == "horizontal" then
                
                next_item.x = window_w/2-window_w*direction
                next_item.y = window_h/2
                path.to = window_w*direction
                
                tl.on_new_frame = animate_x
                
            elseif orientation == "vertical" then
                
                next_item.x = window_w/2
                next_item.y = window_h/2-window_h*direction
                
                path.to = window_h*direction
                
                tl.on_new_frame = animate_y
                
            else
            end
            
        end,
        on_completed = function()
            prev_item:unparent()
            text.x=0
            text.y=0
            next_item.x = window_w/2
            next_item.y = window_h/2
            
            animating = nil
            
            if again == "BACK" then
                prev_i()
            elseif again == "FORWARD" then
                next_i()
            end
            again = nil
        end
    }
	override_property(instance,"animate_duration",
		function(oldf) return update.duration     end,
		function(oldf,self,v) update.duration = v end
	)
    --]]
    ----------------------------------------------------------------------------
    --[[
    prev_i = function()
        if items.length <= 1 then return end
        if not animating then
            animating  = "BACK"
            direction = -1
            
            update:start()
            
        else
            again = "BACK"
        end
    end
    next_i = function()
        if items.length <= 1 then return end
        if not animating then
            animating = "FORWARD"
            direction = 1
            
            update:start()
        else
            again = "FORWARD"
        end
    end
    --]]
    ----------------------------------------------------------------------------
    --[[
    local undo_prev_function, undo_next_function
	override_property(instance,"orientation",
		function(oldf) return   orientation     end,
		function(oldf,self,v)  
            
            if orientation == v then return end
            
            if undo_prev_function then undo_prev_function() end
            if undo_next_function then undo_next_function() end
            
            if v == "horizontal" then
                prev_arrow:set{z_rotation={  0,0,0}}
                next_arrow:set{z_rotation={180,0,0}}
                undo_prev_function = instance:add_key_handler(keys.Left, prev_i)
                undo_next_function = instance:add_key_handler(keys.Right,next_i)
            elseif v == "vertical" then
                prev_arrow:set{z_rotation={ 90,0,0}}
                next_arrow:set{z_rotation={270,0,0}}
                undo_prev_function = instance:add_key_handler(keys.Up,  prev_i)
                undo_next_function = instance:add_key_handler(keys.Down,next_i)
            else
                
                error("ButtonPicker.direction expects 'horizontal' or 'vertical as its value. Received: "..v,2)
                
            end
            orientation = v
            instance.direction = v
        end
	)
    prev_arrow:add_mouse_handler("on_button_up",prev_i)
    next_arrow:add_mouse_handler("on_button_up",next_i)
    --]]
    
    --[[
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.length       = nil
            t.vertical_alignment   = nil
            t.horizontal_alignment = nil
            t.direction = nil
            t.spacing   = nil
            t.cell_h = nil
            t.cell_w = nil
            t.cells = nil
            
            t.style = instance.style
            
            t.window_w = instance.window_w
            t.window_h = instance.window_h
            t.animate_duration = instance.animate_duration
            t.orientation = instance.orientation
            t.items = {}
            
            for i = 1,items.length do
                t.items[i] = items[i].text
            end
            
            t.type = "ButtonPicker"
            
            return t
        end
    )
    
    
	instance:subscribe_to( "enabled",
		function()
            next_arrow.enabled = instance.enabled
            prev_arrow.enabled = instance.enabled
        end
	)
    --]]
    ----------------------------------------------------------------------------
    instance.window_w = parameters.window_w
    instance.window_h = parameters.window_h
    --[[
    local function update_labels()
        for i,item in items.pairs() do
            item:set(   instance.style.text:get_table()   )
            item.color = instance.style.text.colors.default
        end
    end
    local function arrow_on_changed()
        prev_arrow:set{
            w = instance.style.arrow.size,
            h = instance.style.arrow.size,
            anchor_point = {
                instance.style.arrow.size/2,
                instance.style.arrow.size/2
            },
        }
        next_arrow:set{
            w = instance.style.arrow.size,
            h = instance.style.arrow.size,
            anchor_point = {
                instance.style.arrow.size/2,
                instance.style.arrow.size/2
            },
        }
        instance.spacing = instance.style.arrow.offset
    end
    local function arrow_colors_on_changed() 
        
        prev_arrow.style.fill_colors = instance.style.arrow.colors.attributes
        next_arrow.style.fill_colors = instance.style.arrow.colors.attributes
    end 
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.arrow:subscribe_to(      nil, arrow_on_changed )
        instance.style.arrow.colors:subscribe_to(      nil, arrow_colors_on_changed )
        instance.style.border:subscribe_to(      nil, redo_fg )
        instance.style.fill_colors:subscribe_to( nil, redo_bg )
        instance.style.text:subscribe_to( nil, update_labels )
        
		update_labels()
        redo_fg()
        redo_bg()
        arrow_on_changed()
        
        arrow_colors_on_changed()
	end
	
	instance:subscribe_to(
		"style",
		instance_on_style_changed
	)
    instance_on_style_changed()
	--]]
    
    window:add(bg,text,fg)
	instance:set(parameters)
	
	return instance
    
end
--]=]



--[[
Function: buttonPicker

Creates a button picker ui element

Arguments:
	Table of Button picker properties

	skin - Modify the skin for the Button picker by changing this value
    	bwidth - Width of the Button picker 
    	bheight - Height of the Button picker 
        items - A table containing the items for the Button picker
    	text_font - Font of the Button picker items
    	text_color - Color of the Button picker items
    	border_color - Color of the Button 
    	focus_border_color - Focus color of the Button 
		selected_item - The number of the selected item 
		on_selection_change - function that is called by selected item number   

Return:
 		bp_group - Group containing the button picker 

Extra Function:
		set_focus() - Grab focus of button picker 
		clear_focus() - Release focus of button picker
		press_left() - Left key press event, apply the selection of button picker
		press_right() - Right key press event, apply the selection of button picker
		press_up() - Up key press event, apply the selection of button picker
		press_down() - Down key press event, apply the selection of button picker
		press_enter() - Enter key press event, apply the selection of button picker
		insert_item(item) - Add an item to the items table 
		remove_item(item) - Remove an item from the items table 
]]

--[[
function ui_element.buttonPicker(t) 
    local w_scale = 1
    local h_scale = 1

 --default parameters 
    local p = {
	skin = "CarbonCandy", 
	ui_width =  180,
	ui_height = 60,
	items = {"item", "item", "item"},
	text_font = "FreeSans Medium 30px" , 
	focus_text_font = "FreeSans Medium 30px" , 
	text_color = {255,255,255,255}, 
	focus_text_color = {255,255,255,255}, 
	border_color = {255,255,255,255},
	fill_color = {255,255,255,0},
	focus_border_color = {0,255,0,255},
	focus_fill_color = {0,255,0,0},
	on_selection_change = nil, 
    selected_item = 1, 
	direction = "horizontal", 
	ui_position = {300, 300, 0},  
	----------------------------------------------
	inspector = 0, 
    }

 --overwrite defaults
     if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
     end 
     
 --the umbrella Group
     local items = Group{name = "items"}

     local bp_group = Group
     {
		name = "buttonPicker", 
		position = p.ui_position, 
        reactive = true, 
		extra = {type = "ButtonPicker"}
     }

     local index 

     local padding = 5
     local pos = {0, 0}    -- focus, unfocus 
     local t = nil

     local create_buttonPicker = function() 

     	local ring, focus_ring, unfocus, focus, left_un, left_sel, right_un, right_sel
		local button_w 

		bp_group:clear()
		items:clear()

		index = p.selected_item 
    	bp_group.size = { p.ui_width , p.ui_height}

		
		if p.skin == "Custom" then 

			local key = string.format( "ring:%d:%d:%s:%s" , p.ui_width, p.ui_height, color_to_string( p.border_color ), color_to_string( p.fill_color ))
	
			ring = assets( key , my_make_ring , p.ui_width, p.ui_height, p.border_color, p.fill_color, 1, 7, 7, 1)
        	ring:set{name="ring", position = { pos[1] , pos[2] }, opacity = 255 }

			key = string.format( "ring:%d:%d:%s:%s" , p.ui_width, p.ui_height, color_to_string( p.focus_border_color ), color_to_string( p.focus_fill_color ))

			focus_ring = assets( key , my_make_ring , p.ui_width, p.ui_height, p.focus_border_color, p.focus_fill_color, 1, 7, 7, 1)
        	focus_ring:set{name="focus_ring", position = { pos[1] , pos[2] }, opacity = 0}

			button_w = focus_ring.w 
   			bp_group:add(ring, focus_ring)

        	left_un   = assets(skin_list["default"]["buttonpicker_left_un"])
	    	left_sel  = assets(skin_list["default"]["buttonpciker_left_sel"])
	    	right_un  = assets(skin_list["default"]["buttonpicker_right_un"])
        	right_sel = assets(skin_list["default"]["buttonpicker_right_sel"])

		elseif p.skin == "inspector" then  

			local left, right, u1px 
     		unfocus = Group{} --name = "unfocus-button", reactive = true, position = {pos[1], pos[2]}}
			
			left = Image{src="lib/assets/picker-left-cap.png"} 
			right = Image{src="lib/assets/picker-right-cap.png", position = {p.ui_width - left.w, 0}} 
			u1px = Image{src="lib/assets/picker-repeat1px.png", position = {left.w, 0}, tile = {true, false}, width = p.ui_width - left.w - right.w}

			unfocus:add(left)
			unfocus:add(u1px)
			unfocus:add(right)

     		focus = Group{} --name = "focus-button", reactive = true, position = {pos[1], pos[2]}}

			local fleft, fright, f1px
			fleft = Image{src="lib/assets/picker-left-cap-focus.png"}
			fright = Image{src="lib/assets/picker-right-cap-focus.png", position = {p.ui_width - fleft.w, 0}}
			f1px = Image{src="lib/assets/picker-repeat1px-focus.png", position = {fleft.w, 0}, tile = {true, false}, width = p.ui_width - left.w - right.w}

			focus:add(fleft)
			focus:add(f1px)
			focus:add(fright)
			
			bp_group:add(unfocus, focus)

			button_w = focus.w

	    	left_un   = assets("lib/assets/picker-left-arrow.png")
	    	left_sel  = assets("lib/assets/picker-left-arrow-focus.png")
	    	right_un  = assets("lib/assets/picker-right-arrow.png")
        	right_sel = assets("lib/assets/picker-right-arrow-focus.png")
		else 
     		unfocus = assets(skin_list[p.skin]["buttonpicker"])
     		focus = assets(skin_list[p.skin]["buttonpicker_focus"])

			button_w = p.ui_width 
			bp_group:add(unfocus, focus)
			
			left_un   = assets(skin_list[p.skin]["buttonpicker_left_un"])
	    	left_sel  = assets(skin_list[p.skin]["buttonpciker_left_sel"])
	    	right_un  = assets(skin_list[p.skin]["buttonpicker_right_un"])
        	right_sel = assets(skin_list[p.skin]["buttonpicker_right_sel"])
 		end 

		left_un.scale = {w_scale, h_scale}
		left_sel.scale = {w_scale, h_scale}
		right_un.scale = {w_scale, h_scale}
		right_sel.scale = {w_scale, h_scale}

		if unfocus then 
     		unfocus:set{name = "unfocus",  position = {pos[1], pos[2]+padding}, size = {p.ui_width, p.ui_height}, opacity = 255, reactive = true}
		end 
		if focus then 
			focus:set{name = "focus",  position = {pos[1], pos[2]+padding}, size = {p.ui_width, p.ui_height}, opacity = 0}
		end 

		if p.direction == "horizontal" then 
			left_un:set{name = "left_un", position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.ui_height/5}, opacity = 255, reactive = true}
			left_sel:set{name = "left_sel", position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.ui_height/5}, opacity = 0}
			right_un:set{name = "right_un", position = {pos[1] + button_w + padding, pos[2] + p.ui_height/5}, opacity = 255, reactive = true}
			right_sel:set{name = "right_sel", position = {right_un.x, right_un.y},  opacity = 0}
		elseif p.direction == "vertical" then 
            left_un.anchor_point={left_un.w/2,left_un.h/2}
            left_un.z_rotation={90,0,0}
			left_un:set{name = "left_un", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] - left_un.h/2 + 12}, opacity = 255, reactive = true} -- top
			left_sel.anchor_point={left_un.w/2,left_un.h/2}
            left_sel.z_rotation={90,0,0}
			left_sel:set{name = "left_sel", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] - left_un.h/2+ 12 }, opacity = 0}

            right_un.anchor_point={right_un.w/2,right_un.h/2}
            right_un.z_rotation={90,0,0}
			right_un:set{name = "right_un", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] + p.ui_height + padding * 2+ 5 }, opacity = 255, reactive = true} -- bottom
            right_sel.anchor_point={right_un.w/2,right_un.h/2}
            right_sel.z_rotation={90,0,0}
			right_sel:set{name = "right_sel", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] + p.ui_height + padding * 2 + 5 },  opacity = 0}
		end

     	for i, j in pairs(p.items) do 
               items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color =p.text_color, opacity = 255})     
     	end 

		local j_padding = 0

		for i, j in pairs(items.children) do 
	  		if i == p.selected_item then  
               j.position = {p.ui_width/2 - j.width/2, p.ui_height/2 - j.height/2 - p.inspector }
	       	   j_padding = 5 * j.x -- 5 는 진정한 해답이 아니고.. 이걸 바꿔 줘야함.. 그리고 박스 크기가 문자열과 비례해서 적당히 커줘야하고.. ^^;;;
			   break
			end 
		end 

		for i, j in pairs(items.children) do 
	  		if i > p.selected_item then  -- i == 1
               j.position = {p.ui_width/2 - j.width/2 + j_padding, p.ui_height/2 - j.height/2}
	  		elseif i < p.selected_item then  -- i == 1
               j.position = {p.ui_width/2 - j.width/2 + j_padding, p.ui_height/2 - j.height/2}
	  		end 
     	end 

		if p.direction == "vertical" then 
			items.clip = { 0, 10, p.ui_width, p.ui_height-10 }
		else 
			items.clip = { 0, 0, p.ui_width, p.ui_height }
     	end 

   		bp_group:add(right_un, right_sel, left_un, left_sel, items) 

        t = nil

		if editor_lb == nil or editor_use then 

			if ring then 
				ring.reactive = true
				function ring:on_button_down (x,y,b,n)
					if current_focus then
   			         	current_focus.extra.clear_focus()
	        		 	current_focus = group
					end 
					bp_group.set_focus()
	            	bp_group:grab_key_focus()
		        	return true
				end 
			elseif unfocus then 
				unfocus.reactive = true
				function unfocus:on_button_down (x,y,b,n)
					if current_focus then
   			         	current_focus.extra.clear_focus()
	        		 	current_focus = group
					end 
					bp_group.set_focus()
	            	bp_group:grab_key_focus()
		        	return true
				end 
			end

			left_un.reactive = true 
			function left_un:on_button_down(x, y, b, n)
				if current_focus then
					current_focus.extra.clear_focus()
	        		current_focus = group
				end
				bp_group.set_focus()
	        	bp_group:grab_key_focus()
				if p.direction == "vertical" then 
					bp_group.press_up()
				else 
					bp_group.press_left()
				end 
				return true 
			end 

			right_un.reactive = true 
			function right_un:on_button_down(x, y, b, n)
				if current_focus then
					current_focus.extra.clear_focus()
	        		current_focus = group
				end
				bp_group.set_focus()
	        	bp_group:grab_key_focus()
				if p.direction == "vertical" then 
					bp_group.press_down()
				else
					bp_group.press_right()
				end 
				return true 
			end 
		end 

	end 
 
     create_buttonPicker()

	 

    function bp_group.extra.set_focus()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		current_focus = bp_group
		if(p.skin == "Custom") then 
            ring.opacity = 0 
	     	focus_ring.opacity = 255
        else 
            unfocus.opacity = 0
	     	focus.opacity   = 255
		end 
     	for i, j in pairs(p.items) do 
             bp_group:find_child("item"..tostring(i)).color = p.focus_text_color
		end 
	    bp_group:grab_key_focus()
     end

     function bp_group.extra.clear_focus()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		if(p.skin == "Custom") then 
        	ring.opacity = 255 
	     	focus_ring.opacity = 0
		else 
            unfocus.opacity = 255
	    	focus.opacity   = 0
		end 
     	for i, j in pairs(p.items) do 
             bp_group:find_child("item"..tostring(i)).color = p.text_color
		end
     end

     function bp_group.extra.press_left()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		local left_sel = bp_group:find_child("left_sel")
		local left_un = bp_group:find_child("left_un")
		local right_sel = bp_group:find_child("right_sel")
		local right_un  = bp_group:find_child("right_un")

     	local prev_i = index
        local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2 - p.inspector
		local next_old_x, prev_new_x

		if focus then  
	    	next_old_x = p.ui_width/2 - j.width/2 + focus.w
		else 
	    	next_old_x = p.ui_width/2 - j.width/2 + focus_ring.w
		end 

	    local next_old_y = p.ui_height/2 - j.height/2 - p.inspector 

		if focus then  
	    	prev_new_x = p.ui_width/2 - j.width/2 - focus.w
		else
	    	prev_new_x = p.ui_width/2 - j.width/2 - focus_ring.w
		end 

	    local prev_new_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2 - p.inspector 

	    if t ~= nil then
	       t:stop()
	       t:on_completed()
	    end
	    t = Timeline
	    {
	       duration = 300,
	       direction = "FORWARD",
	       loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
				left_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				left_sel.opacity = 255
			else 
				left_sel.opacity = 255*(1- (msecs-200)/100)
			end
			items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
			items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
			items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
			items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end

	    function t.on_completed()
			items:find_child("item"..tostring(prev_i)).x = prev_new_x
			items:find_child("item"..tostring(prev_i)).y = prev_new_y
			items:find_child("item"..tostring(next_i)).x = next_new_x
			items:find_child("item"..tostring(next_i)).y = next_new_y
			p.selected_item = next_i
			if p.on_selection_change then
	       		p.on_selection_change(next_i)
	    	end
			t = nil
	    end
	    t:start()
	end

	function bp_group.extra.press_right()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		local left_sel = bp_group:find_child("left_sel")
		local left_un = bp_group:find_child("left_un")
		local right_sel = bp_group:find_child("right_sel")
		local right_un  = bp_group:find_child("right_un")

	    local prev_i = index
        local next_i = (index)%(#p.items)+1
	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_old_x, prev_new_x 
		if focus then 
	    	next_old_x = p.ui_width/2 - j.width/2 - focus.w
		else 
	    	next_old_x = p.ui_width/2 - j.width/2 - focus_ring.w
		end

	    local next_old_y = p.ui_height/2 - j.height/2 - p.inspector 

		if focus then 
	    	prev_new_x = p.ui_width/2 - j.width/2 + focus.w
		else
	    	prev_new_x = p.ui_width/2 - j.width/2 + focus_ring.w
		end 

	    local prev_new_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2 - p.inspector 

	    if t ~= nil then
		t:stop()
		t:on_completed()
     	    end

	    t = Timeline {
	        duration = 300,
		direction = "FORWARD",
		loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
	        if msecs <= 100 then
		     right_sel.opacity = 255* msecs/100
		elseif msecs <= 200 then
		     right_sel.opacity = 255
		else 
		     right_sel.opacity = 255*(1- (msecs-200)/100)
		end

		items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
		items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
		items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
		items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end
	    function t.on_completed()
	        items:find_child("item"..tostring(prev_i)).x = prev_new_x
		items:find_child("item"..tostring(prev_i)).y = prev_new_y
		items:find_child("item"..tostring(next_i)).x = next_new_x
		items:find_child("item"..tostring(next_i)).y = next_new_y
		p.selected_item = next_i
		if p.on_selection_change then
	       	     p.on_selection_change(next_i)
	    	end
		t = nil
	    end
	    t:start()
	end

 	function bp_group.extra.press_up()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		local left_sel = bp_group:find_child("left_sel")
		local left_un = bp_group:find_child("left_un")
		local right_sel = bp_group:find_child("right_sel")
		local right_un  = bp_group:find_child("right_un")

	    local prev_i = index

        local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    
		local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2

	    local next_old_x = p.ui_width/2 - j.width/2 
	    local next_old_y, prev_new_y 

		if focus then 
	    	next_old_y = p.ui_height/2 - j.height/2 + focus.h
		else
	    	next_old_y = p.ui_height/2 - j.height/2 + focus_ring.h
		end

	    local prev_new_x = p.ui_width/2 - j.width/2 

		if focus then 
	    	prev_new_y = p.ui_height/2 - j.height/2 - focus.h
		else 
	    	prev_new_y = p.ui_height/2 - j.height/2 - focus_ring.h
		end 

	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2

	    if t ~= nil then
	       t:stop()
	       t:on_completed()
	    end
	    t = Timeline
	    {
	       duration = 300,
	       direction = "FORWARD",
	       loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
				left_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				left_sel.opacity = 255
			else 
				left_sel.opacity = 255*(1- (msecs-200)/100)
			end
			items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
			items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
			items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
			items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end
	    function t.on_completed()
			items:find_child("item"..tostring(prev_i)).x = prev_new_x
			items:find_child("item"..tostring(prev_i)).y = prev_new_y
			items:find_child("item"..tostring(next_i)).x = next_new_x
			items:find_child("item"..tostring(next_i)).y = next_new_y
			p.selected_item = next_i
			if p.on_selection_change then
	       		     p.on_selection_change(next_i)
	    		end

			t = nil
	    end
	   
	    t:start()

		
	end

	function bp_group.extra.press_down()
		local unfocus = bp_group:find_child("unfocus")
		local focus = bp_group:find_child("focus")
		local ring = bp_group:find_child("ring")
		local focus_ring = bp_group:find_child("focus_ring")

		local left_sel = bp_group:find_child("left_sel")
		local left_un = bp_group:find_child("left_un")
		local right_sel = bp_group:find_child("right_sel")
		local right_un  = bp_group:find_child("right_un")

	    local prev_i = index
            local next_i = (index)%(#p.items)+1
	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2
	    local next_old_x = p.ui_width/2 - j.width/2 
	    local next_old_y, prev_new_y
		if focus then
	    	next_old_y = p.ui_height/2 - j.height/2 - focus.h
		else 
	    	next_old_y = p.ui_height/2 - j.height/2 - focus_ring.h
		end

	    local prev_new_x = p.ui_width/2 - j.width/2 

		if focus then 
	    	prev_new_y = p.ui_height/2 - j.height/2 + focus.h
		else 
	    	prev_new_y = p.ui_height/2 - j.height/2 + focus_ring.h
		end
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2

	    if t ~= nil then
		t:stop()
		t:on_completed()
     	    end

	    t = Timeline {
	        duration = 300,
		direction = "FORWARD",
		loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
	        if msecs <= 100 then
		     right_sel.opacity = 255* msecs/100
		elseif msecs <= 200 then
		     right_sel.opacity = 255
		else 
		     right_sel.opacity = 255*(1- (msecs-200)/100)
		end

		items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
		items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
		items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
		items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end
	    function t.on_completed()
	        items:find_child("item"..tostring(prev_i)).x = prev_new_x
		items:find_child("item"..tostring(prev_i)).y = prev_new_y
		items:find_child("item"..tostring(next_i)).x = next_new_x
		items:find_child("item"..tostring(next_i)).y = next_new_y
		p.selected_item = next_i
		if p.on_selection_change then
	       	     p.on_selection_change(next_i)
	    	end
		t = nil
	    end
	    t:start()
	end

	function bp_group.extra.press_enter()
	end

	function bp_group.extra.insert_item(itm) 
		table.insert(p.items, itm) 
		create_buttonPicker()
        end 

	function bp_group.extra.remove_item() 
		table.remove(p.items)
		create_buttonPicker()
        end 
	--bp_group.out_focus()
        
        mt = {}
        mt.__newindex = function (t, k, v)

             if k == "bsize" then  
	    	p.ui_width = v[1] 	
		p.ui_height = v[2]  
		w_scale = v[1]/180
		h_scale = v[2]/60
             elseif k == "ui_width" then 
		w_scale = v/180
                p[k] = v
	     elseif k == "ui_height" then   
		h_scale = v/60
                p[k] = v
	     else 
                p[k] = v
             end
	     if k ~= "selected" and k ~= "org_x"  and k ~= "org_y" and 
		k ~= "is_in_group" and k ~= "group_position" then 
                 create_buttonPicker()
	     end 
        end 

        mt.__index = function (t,k)
             if k == "bsize" then 
	        return {p.ui_width, p.ui_height}  
             else 
	        return p[k]
             end 
        end 

        setmetatable (bp_group.extra, mt) 

        return bp_group 
end
--]]
