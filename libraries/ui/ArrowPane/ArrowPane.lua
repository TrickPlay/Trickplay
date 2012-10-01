ARROWPANE = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local create_arrow = function(self,state)
    mesg("ArrowPane",0,"ArrowPane:create_arrow()",self.gid,state)
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
	c:set_source_color( self.style.fill_colors[state] )     c:fill(true)
	
	return c:Image()
	
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
            ["style"] = function(instance,env)
                return function()
                    
                    instance.style.arrow:subscribe_to(         nil, env.arrow_on_changed )
                    instance.style.arrow.colors:subscribe_to(  nil, env.arrow_colors_on_changed )
                    instance.style.border:subscribe_to(        nil, env.pane_on_changed )
                    instance.style.fill_colors:subscribe_to(   nil, env.pane_on_changed )
                    
                    env.arrow_on_changed()
                    env.arrow_colors_on_changed()
                end
            end,
            --]]
        },
        public = {
            properties = {
                --[[
                style = function(instance,env)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)
                        
                        env.subscribe_to_sub_styles()
                        --TODO: double check this
                        env.flag_for_redraw = true 
                        env.text_style_changed = true
                        env.text_color_changed = true 
                    end
                end,
                --]]
                enabled = function(instance,env)
                    return nil,
                    function(oldf,self,v)
                        oldf(self,v)
                        
                        for _,arrow in pairs(env.arrows) do
                            arrow.enabled = v
                        end
                        
                    end
                end,
                w = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        env.new_w  = true
                        oldf(self,v)
                    end
                end,
                width = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        env.new_w  = true
                        oldf(self,v)
                    end
                end,
                h = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        env.new_h  = true
                        oldf(self,v)
                    end
                end,
                height = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        env.new_h  = true
                        oldf(self,v)
                    end
                end,
                size = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        env.new_w  = true
                        env.new_h  = true
                        oldf(self,v)
                    end
                end,
                virtual_w = function(instance,env)
                    return function(oldf) return env.pane.virtual_w     end,
                    function(oldf,self,v) env.pane.virtual_w = v env.new_w = true end
                end,
                virtual_h = function(instance,env)
                    return function(oldf) return env.pane.virtual_h     end,
                    function(oldf,self,v) env.pane.virtual_h = v env.new_h = true end
                end,
                virtual_x = function(instance,env)
                    return function(oldf) return env.pane.virtual_x     end,
                    function(oldf,self,v) env.pane.virtual_x = v end
                end,
                virtual_y = function(instance,env)
                    return function(oldf) return env.pane.virtual_y     end,
                    function(oldf,self,v) env.pane.virtual_y = v end
                end,
                pane_w = function(instance,env)
                    return function(oldf) return env.pane.w     end,
                    function(oldf,self,v) env.pane.w = v env.new_w = true end
                end,
                pane_h = function(instance,env)
                    return function(oldf) return env.pane.h     end,
                    function(oldf,self,v) env.pane.h = v  env.new_h = true end
                end,
                arrow_move_by = function(instance,env)
                    return function(oldf) return env.move_by     end,
                    function(oldf,self,v) env.move_by = v end
                end,
                sets_x_to = function(instance,env)
                    return function(oldf) return env.pane.x_offset end,
                    function(oldf,self,v) 
                        env.pane.x_offset = v
                    end
                end,
                sets_y_to = function(instance,env)
                    return function(oldf) return env.pane.y_offset     end,
                    function(oldf,self,v) 
                        env.pane.y_offset = v
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "ArrowPane" end
                end,
                attributes = function(instance,env)
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
            			
                        t.pane_w    = instance.pane_w
                        t.pane_h    = instance.pane_h
                        t.virtual_x = instance.virtual_x
                        t.virtual_y = instance.virtual_y
                        t.virtual_w = instance.virtual_w
                        t.virtual_h = instance.virtual_h
                        t.arrow_move_by   = instance.arrow_move_by
                        
                        t.children = {}
                        
                        for i, child in ipairs(env.pane.children) do
                            t.children[i] = child.attributes
                        end
                        
                        t.type = "ArrowPane"
                        
                        return t
                    end
                end,
                children = function(instance,env)
                    return function(oldf) return env.pane.children     end,
                    function(oldf,self,v)        env.pane.children = v end
                end,
            },
            functions = {
                add    = function(instance,env) return function(oldf,self,...) env.pane:add(   ...) end end,
                remove = function(instance,env) return function(oldf,self,...) env.pane:remove(...) end end,
            },
        },
        private = {
            --[[
            arrow_on_changed = function(instance,env)
                return function() 
                    print("\n\n\narrow_on_changed\n\n\n")
                    for _,arrow in pairs(env.arrows) do
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
            arrow_colors_on_changed = function(instance,env)
                return function() 
                    for _,arrow in pairs(env.arrows) do
                        arrow.style.fill_colors = 
                            instance.style.arrow.colors.attributes
                    end
                end
            end,
            --]]
            style_buttons = function(instance,env)
                return function()
                    env.up:set{
                        name = "Up Button",
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        reactive = true,
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = { 90,0,0} ,
                        on_released = function() env.pane.virtual_y = env.pane.virtual_y - env.move_by end,
                    }
                    env.down:set{ 
                        name = "Down Button",
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        reactive = true,
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = {270,0,0},
                        on_released = function() env.pane.virtual_y = env.pane.virtual_y + env.move_by end,
                    }
                    env.left:set{ 
                        name = "Left Button",
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        reactive = true,
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow,
                        on_released = function() env.pane.virtual_x = env.pane.virtual_x - env.move_by end,
                    }
                    env.right:set{ 
                        name = "Right Button",
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        reactive = true,
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = {180,0,0},
                        on_released = function() env.pane.virtual_x = env.pane.virtual_x + env.move_by end,
                    }
                    
                    --redefine function
                    env.style_buttons = function()
                        mesg("ArrowPane",0,"ArrowPane Restyling Buttons")
                        for _,arrow in pairs(env.arrows) do
                            arrow:set{
                                w = instance.style.arrow.size,
                                h = instance.style.arrow.size,
                                anchor_point = {
                                    instance.style.arrow.size/2,
                                    instance.style.arrow.size/2
                                },
                                style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                            }
                        end
                    end
                end
            end,
            update = function(instance,env)
                return function()
                    mesg("ArrowPane",0,"ArrowPane:update() called")
                    if env.redraw_buttons then
                        env.redraw_buttons = false
                        env.style_buttons()
                    end
                    if env.respace_buttons then
                        env.respace_buttons = false
                        instance.horizontal_spacing = instance.style.arrow.offset
                        instance.vertical_spacing   = instance.style.arrow.offset
                    end
                    if env.redraw_pane then
                        env.redraw_pane = false
                        env.pane:set{
                            style = {
                                name=false,
                                fill_colors=instance.style.fill_colors.attributes,
                                border={colors=instance.style.border.colors.attributes},
                            }
                        }
                    end
                    env.lm_update()
                    
                    if  env.new_w then
                        env.new_w = false
                        
                        if env.pane.virtual_w <= env.pane.w then
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
                    
                    if  env.new_h then
                        env.new_h = false
                                    
                        if env.pane.virtual_h <= env.pane.h then
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
            
            --local instance, env = LayoutManager:declare()
            --local getter, setter
            
            local pane  = ClippingRegion{style = false}
            local up    = Button:declare()
            local down  = Button:declare()
            local left  = Button:declare()
            local right = Button:declare()
            
            local instance, env = LayoutManager:declare{
                number_of_rows = 3,
                number_of_cols = 3,
                placeholder = Widget_Clone(),
                cells = {
                    {  nil,   up,   nil },
                    { left, pane, right },
                    {  nil, down,   nil },
                },
            }
            env.style_flags = {
                border = "redraw_pane",
                arrow = {
                    size = "redraw_buttons",
                    offset = "respace_arrows",
                    colors = "redraw_buttons",
                },
                fill_colors = "redraw_pane"
            }
            local getter, setter
            
            env.pane = pane
            env.up = up
            env.down = down
            env.left = left
            env.right = right
            env.redraw_buttons = true
            
            instance:add_key_handler(keys.Up,       env.up.click)
            instance:add_key_handler(keys.Down,   env.down.click)
            instance:add_key_handler(keys.Left,   env.left.click)
            instance:add_key_handler(keys.Right, env.right.click)
    		env.up:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_y = env.pane.virtual_y - env.move_by
    		end)
    		
    		env.down:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_y = env.pane.virtual_y + env.move_by
    		end)
			
    		env.left:add_mouse_handler("on_button_up", function()
    		    env.pane.virtual_x = env.pane.virtual_x - env.move_by
    		end)
			
		    env.right:add_mouse_handler("on_button_up", function()
    	    	env.pane.virtual_x = env.pane.virtual_x + env.move_by
    		end)
            env.arrows = {
                up    = env.up,
                down  = env.down,
                left  = env.left,
                right = env.right,
            }
            
            env.lm_update = env.update
            env.new_w = true
            env.new_h = true
            env.move_by = 10
            
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
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            --dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)

external.ArrowPane = ArrowPane