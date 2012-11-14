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
                    up:set{
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
                        on_released = function() pane.virtual_y = pane.virtual_y - move_by end,
                    }
                    down:set{ 
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
                        on_released = function() pane.virtual_y = pane.virtual_y + move_by end,
                    }
                    left:set{ 
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
                        on_released = function() pane.virtual_x = pane.virtual_x - move_by end,
                    }
                    right:set{ 
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
                        on_released = function() pane.virtual_x = pane.virtual_x + move_by end,
                    }
                    
                    --redefine function
                    style_buttons = function()
                        mesg("ArrowPane",0,"ArrowPane Restyling Buttons")
                        for _,arrow in pairs(arrows) do
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
            update = function(instance,_ENV)
                return function()
                    mesg("ArrowPane",0,"ArrowPane:update() called")
                    if redraw_buttons then
                        redraw_buttons = false
                        style_buttons()
                    end
                    if respace_buttons then
                        respace_buttons = false
                        instance.horizontal_spacing = instance.style.arrow.offset
                        instance.vertical_spacing   = instance.style.arrow.offset
                    end
                    if redraw_pane then
                        redraw_pane = false
                        pane:set{
                            style = {
                                name=false,
                                fill_colors=instance.style.fill_colors.attributes,
                                border={colors=instance.style.border.colors.attributes},
                            }
                        }
                    end
                    lm_update()
                    
                    if  new_w then
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
                    
                    if  new_h then
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
            
            local l_pane  = ClippingRegion{style = false}
            local l_up    = Button:declare()
            local l_down  = Button:declare()
            local l_left  = Button:declare()
            local l_right = Button:declare()
            
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
            redraw_buttons = true
            
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
            arrows = {
                up    = up,
                down  = down,
                left  = left,
                right = right,
            }
            
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