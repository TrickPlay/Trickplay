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
external.ButtonPicker = ButtonPicker
