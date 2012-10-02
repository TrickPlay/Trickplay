BUTTONPICKER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

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
                attributes = function(instance,_ENV)
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
                        
                        for i = 1,list_entries.length do
                            t.items[i] = list_entries[i].text
                        end
                        
                        t.type = "ButtonPicker"
                        
                        return t
                    end
                end,
                enabled = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v)
                        next_arrow.enabled = instance.enabled
                        prev_arrow.enabled = instance.enabled
                    end
                end,
                animate_duration = function(instance,_ENV)
                    return function(oldf) return update_tl.duration     end,
                    function(oldf,self,v)        update_tl.duration = v end
                end,
                window_w = function(instance,_ENV)
                    return function(oldf) return window_w end,
                    function(oldf,self,v) 
                        window_w = v 
                        new_window_sz = true
                    end
                end,
                window_h = function(instance,_ENV)
                    return function(oldf) return window_h end,
                    function(oldf,self,v) 
                        window_h = v 
                        new_window_sz = true
                    end
                end,
                items = function(instance,_ENV)
                    return function(oldf) return list_entries end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "table" then error("Expected table. Received :"..type(v),2) end
                        
                        if #v == 0 then error("Table is empty.",2) end
                        
                        list_entries:set(v)
                        
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "ButtonPicker" end
                end,
                orientation = function(instance,_ENV)
                    return function(oldf) return orientation end,
                    function(oldf,self,v) 
            
                        if orientation == v then return end
                        
                        orientation = v
                        
                    end
                end,
    
            },
            functions = {
            },
        },
        private = {
            update = function(instance,_ENV)
                return function()
                    
                    if restyle_label then
                        restyle_label = false
                        for i,item in list_entries.pairs() do
                            item:set(   instance.style.text:get_table()   )
                            item.color = instance.style.text.colors.default
                        end
                    end
                    if recolor_arrows then
                        recolor_arrows = false
                        prev_arrow.style.fill_colors = instance.style.arrow.colors.attributes
                        next_arrow.style.fill_colors = instance.style.arrow.colors.attributes
                    end
                    if restyle_arrows then
                        restyle_arrows = false
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
                    if flag_for_redraw then
                        flag_for_redraw = false
                        redo_fg()
                        redo_bg()
                    end
                    if new_window_sz then
                        new_window_sz = false
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
                        --print("s
                    end
                    if new_orientation then
                        new_orientation = false
                        if undo_prev_function then undo_prev_function() end
                        if undo_next_function then undo_next_function() end
                        
                        if orientation == "horizontal" then
                            prev_arrow:set{z_rotation={  0,0,0}}
                            next_arrow:set{z_rotation={180,0,0}}
                            undo_prev_function = instance:add_key_handler(keys.Left, prev_i)
                            undo_next_function = instance:add_key_handler(keys.Right,next_i)
                        elseif orientation == "vertical" then
                            prev_arrow:set{z_rotation={ 90,0,0}}
                            next_arrow:set{z_rotation={270,0,0}}
                            undo_prev_function = instance:add_key_handler(keys.Up,  prev_i)
                            undo_next_function = instance:add_key_handler(keys.Down,next_i)
                        else
                            
                            error("ButtonPicker.orientation expects 'horizontal' or 'vertical as its value. Received: "..orientation,2)
                            
                        end
                        instance.direction = orientation
                    end
                    lm_update()
                end
            end,
            prev_i = function(instance,_ENV)
                return function() 
                    if list_entries.length <= 1 then return end
                    if not animating then
                        animating  = "BACK"
                        index_direction = -1
                        
                        update_tl:start()
                        
                    else
                        again = "BACK"
                    end
                end
            end,
            next_i = function(instance,_ENV)
                return function() 
                    if list_entries.length <= 1 then return end
                    if not animating then
                        animating = "FORWARD"
                        index_direction = 1
                        
                        update_tl:start()
                    else
                        again = "FORWARD"
                    end
                end
            end,
            redo_bg = function(instance,_ENV)
                return function() 
                    if bg and bg.parent then bg:unparent() end
                    bg = create_bg(instance)
                    window:add(bg)
                    bg:lower_to_bottom()
                end
            end,
            redo_fg = function(instance,_ENV)
                return function() 
                    if fg and fg.parent then fg:unparent() end
                    fg = create_fg(instance)
                    window:add(fg)
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
            local instance, _ENV  = ListManager:declare{
                cells = {
                    prev_arrow,
                    window,
                    next_arrow
                },
            }
            orientation = "horizontal"
            lm_update = update
            flag_for_redraw = true
            restyle_arrows  = true
            recolor_arrows  = true
            restyle_label   = true
            new_orientation = true
            new_window_sz   = true
            style_flags = {
                border = "flag_for_redraw",
                arrow = {
                    "restyle_arrows",
                    colors = "recolor_arrows",
                },
                text = "restyle_label",
                fill_colors = "flag_for_redraw"
            }
            --need these to be global
            _ENV.next_arrow = next_arrow
            _ENV.prev_arrow = prev_arrow
            _ENV.text       = text
            _ENV.window     = window
            window_w   = 200
            window_h   = 70
            
            bg = false
            fg = false
            
            list_entries = false
            animating = false
            again = false
            next_item = false
            prev_item = false
            index_direction = false
            curr_index = 1
            print("creating array")
            list_entries = ArrayManager{
                
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
                    
                    if animating then
                        
                        self[wrap_i(curr_index+index_direction)] = prev_item.position
                        self[curr_index].position  = next_item.position
                        
                    elseif self[curr_index] ~= nil and next_item ~= self[curr_index] then
                        print("got it")
                        if next_item then next_item:unparent() end
                        next_item = self[curr_index]
                        text:add(next_item)
                        next_item.anchor_point = {next_item.w/2,next_item.h/2}
                        next_item.x = window_w/2
                        next_item.y = window_h/2
                        
                    end
                    
                end
            }
            print("done")
            next_i = false
            prev_i = false
            
            path = Interval(0,0)
            
            animate_x = function(tl,ms,p) text.x = path:get_value(p) end
            animate_y = function(tl,ms,p) text.y = path:get_value(p) end
            wrap_i    = function(i) return (i - 1) % (list_entries.length) + 1    end
            
            update_tl = Timeline{
                on_started = function(tl)
                    prev_item  = list_entries[curr_index]
                    curr_index = wrap_i(curr_index + index_direction)
                    next_item  = list_entries[curr_index]
                    
                    text:add(next_item)
                    next_item.anchor_point = {next_item.w/2,next_item.h/2}
                    if orientation == "horizontal" then
                        
                        next_item.x = window_w/2-window_w*index_direction
                        next_item.y = window_h/2
                        path.to = window_w*index_direction
                        
                        tl.on_new_frame = animate_x
                        
                    elseif orientation == "vertical" then
                        
                        next_item.x = window_w/2
                        next_item.y = window_h/2-window_h*index_direction
                        
                        path.to = window_h*index_direction
                        
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
            undo_prev_function = false
            undo_next_function = false
            
            
            setup_object(self,instance,_ENV)
            
            prev_arrow:add_mouse_handler("on_button_up",prev_i)
            next_arrow:add_mouse_handler("on_button_up",next_i)
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            
            --env.subscribe_to_sub_styles()
            
            --instance.images = nil
            updating = true
            instance:set(parameters)
            updating = false
            
            return instance, _ENV
            
        end
    }
)
external.ButtonPicker = ButtonPicker
