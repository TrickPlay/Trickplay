ARROWPANE = true

local create_arrow = function(self,state)
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    print("sssss")
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
            ["enabled"] = function(instance,env)
                return function()

		            for _,arrow in pairs(env.arrows) do
		                arrow.enabled = instance.enabled
		            end

                end
            end,
        },
        public = {
            properties = {
                w = function(instance,env)
                    return function(oldf,self) return env.w     end,
                    function(oldf,self,v) 
                        env.w = v
                        env.reclip = true
                        env.new_w  = true
                    end
                end,
                width = function(instance,env)
                    return function(oldf,self) return env.w     end,
                    function(oldf,self,v) 
                        env.w = v
                        env.reclip = true
                        env.new_w  = true
                    end
                end,
                h = function(instance,env)
                    return function(oldf,self) return env.h     end,
                    function(oldf,self,v) 
                        env.h = v
                        env.reclip = true
                        env.new_h  = true
                    end
                end,
                height = function(instance,env)
                    return function(oldf,self) return env.h     end,
                    function(oldf,self,v) 
                        env.h = v
                        env.reclip = true
                        env.new_h  = true
                    end
                end,
                size = function(instance,env)
                    return function(oldf,self) return {env.w,env.h} end,
                    function(oldf,self,v) 
                        env.w = v[1]
                        env.h = v[2]
                        env.reclip = true
                        env.new_w  = true
                        env.new_h  = true
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
            			
            			t.contents = self.contents
            			
            			t.pane_w    = instance.pane_w
            			t.pane_h    = instance.pane_h
            			t.virtual_x = instance.virtual_x
            			t.virtual_y = instance.virtual_y
            			t.virtual_w = instance.virtual_w
            			t.virtual_h = instance.virtual_h
            			t.arrow_move_by   = instance.arrow_move_by
            
                        
                        t.type = "ArrowPane"
                        
                        return t
                    end
                end,
                contents = function(instance,env)
                    return function(oldf,self)
						return env.pane.contents
					end,
					function(oldf,self,v)
						env.pane.contents = v
                    end
                end,
            },
            functions = {
                add = function(instance,env) return function(oldf,self,...) env.pane:add(...) end end,
            },
        },
        private = {
            arrow_on_changed = function(instance,env)
                return function() 
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
                    instance.vertical_spacing = instance.style.arrow.offset
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
            pane_on_changed = function(instance,env)
                return function() 
                    env.pane.style:set(instance.style.attributes)
                end
            end,
            style_buttons = function(instance,env)
                return function()
                    env.up:set{
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = { 90,0,0} ,
                        on_released = function() env.pane.virtual_y = env.pane.virtual_y - env.move_by end,
                    }
                    env.down:set{ 
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = {270,0,0},
                        on_released = function() env.pane.virtual_y = env.pane.virtual_y + env.move_by end,
                    }
                    env.left:set{ 
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow,
                        on_released = function() env.pane.virtual_x = env.pane.virtual_x - env.move_by end,
                    }
                    print(env.left.w,instance.style.arrow.size)
                    env.right:set{ 
                        w = instance.style.arrow.size,
                        h = instance.style.arrow.size,
                        anchor_point = {
                            instance.style.arrow.size/2,
                            instance.style.arrow.size/2
                        },
                        label = "", 
                        style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                        create_canvas = create_arrow, 
                        z_rotation = {180,0,0},
                        on_released = function() env.pane.virtual_x = env.pane.virtual_x + env.move_by end,
                    }
                    
                    --redefine function
                    env.style_buttons = function()
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
                    env.lm_update()
                    if env.ap_updating then return end
                    env.ap_updating = true
                    if env.redraw_buttons then
                        env.redraw_buttons = false
                        env.style_buttons()
                    end
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
                    
                    print(env.left.w,instance.style.arrow.size)
                    env.ap_updating = false
                end
            end,
        },
        declare = function(self,parameters)
            
            local instance, env = LayoutManager:declare()
            local getter, setter
            
            env.pane = ClippingRegion{style = false}--:set(parameters)
            print("fffff",env.pane.virtual_w,env.pane.virtual_h)
            env.up    = Button:declare()--[[{
                w = instance.style.arrow.size,
                h = instance.style.arrow.size,
                anchor_point = {
                    instance.style.arrow.size/2,
                    instance.style.arrow.size/2
                },
                label = "", 
                style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                create_canvas = create_arrow, 
                z_rotation = { 90,0,0} ,
                on_released = function() env.pane.virtual_y = env.pane.virtual_y - env.move_by end,
            }--]]
            env.down  = Button:declare()--[[{ 
                w = instance.style.arrow.size,
                h = instance.style.arrow.size,
                anchor_point = {
                    instance.style.arrow.size/2,
                    instance.style.arrow.size/2
                },
                label = "", 
                style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                create_canvas = create_arrow, 
                z_rotation = {270,0,0},
                on_released = function() env.pane.virtual_y = env.pane.virtual_y + env.move_by end,
            }--]]
            env.left  = Button:declare()--[[{ 
                w = instance.style.arrow.size,
                h = instance.style.arrow.size,
                anchor_point = {
                    instance.style.arrow.size/2,
                    instance.style.arrow.size/2
                },
                label = "", 
                style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                create_canvas = create_arrow,
                on_released = function() env.pane.virtual_x = env.pane.virtual_x - env.move_by end,
            }--]]
            env.right = Button:declare()--[[{ 
                w = instance.style.arrow.size,
                h = instance.style.arrow.size,
                anchor_point = {
                    instance.style.arrow.size/2,
                    instance.style.arrow.size/2
                },
                label = "", 
                style = {name=false,fill_colors=instance.style.arrow.colors.attributes}, 
                create_canvas = create_arrow, 
                z_rotation = {180,0,0},
                on_released = function() env.pane.virtual_x = env.pane.virtual_x + env.move_by end,
            }--]]
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
            print(11111)
            print(33333)
            instance:set{
                number_of_rows = 3,
                number_of_cols = 3,
                placeholder = Widget_Clone(),
                horizontal_spacing = instance.style.arrow.offset,
                vertical_spacing   = instance.style.arrow.offset,
                cells = {
                    {  nil,   env.up,   nil },
                    { env.left, env.pane, env.right },
                    {  nil, env.down,   nil },
                },
            }
            env.lm_update = env.update
            env.new_w = true
            env.new_h = true
            
            
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
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)














--[=[
local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000, name="ArrowPane"}

ArrowPane = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ArrowPane",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ArrowPane Object inherits from Widget
	
    local pane = ClippingRegion{style = false}:set(parameters)
    
    local up    = Button{ label = "", style = false, create_canvas = create_arrow, z_rotation = { 90,0,0} }
    local down  = Button{ label = "", style = false, create_canvas = create_arrow, z_rotation = {270,0,0} }
    local left  = Button{ label = "", style = false, create_canvas = create_arrow }
    local right = Button{ label = "", style = false, create_canvas = create_arrow, z_rotation = {180,0,0} }
    
    local arrows = {
        up    = up,
        down  = down,
        left  = left,
        right = right,
    }
	local instance = LayoutManager{
        number_of_rows = 3,
        number_of_cols = 3,
        placeholder = Widget_Clone(),
        cells = {
            {  nil,   up,   nil },
            { left, pane, right },
            {  nil, down,   nil },
        },
    }
    
    pane:lower_to_bottom()
    ----------------------------------------------------------------------------
    
	override_property(instance,"virtual_x",
		function(oldf) return   pane.virtual_x     end,
		function(oldf,self,v)   pane.virtual_x = v end
    )
	override_property(instance,"virtual_y",
		function(oldf) return   pane.virtual_y     end,
		function(oldf,self,v)   pane.virtual_y = v end
    )
	override_property(instance,"virtual_w",
		function(oldf) return   pane.virtual_w     end,
		function(oldf,self,v)   pane.virtual_w = v end
    )
	override_property(instance,"virtual_h",
		function(oldf) return   pane.virtual_h     end,
		function(oldf,self,v)   pane.virtual_h = v end
    )
	override_property(instance,"pane_w",
		function(oldf) return   pane.w     end,
		function(oldf,self,v)   pane.w = v end
    )
	override_property(instance,"pane_h",
		function(oldf) return   pane.h     end,
		function(oldf,self,v)   pane.h = v end
    )
	instance:subscribe_to(
		{"virtual_w","pane_w"},
		function()
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
    )
	instance:subscribe_to(
		{"virtual_h","pane_h"},
		function()
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
                    error("impossible number of cols "..instance.number_of_rows,2)
                end
            end
            
            
        end
    )
    --[[
	pane:subscribe_to(
		"virtual_x",
		function()
            if pane.virtual_x == pane.virtual_w then 
                right:hide()
            elseif pane.virtual_x == 0 then 
                left:hide()
            elseif pane.virtual_w > pane.w then
                left:show()
                right:show()
            end
        end
    )
	pane:subscribe_to(
		"virtual_y",
		function()
            if pane.virtual_y == pane.virtual_h then 
                down:hide()
            elseif pane.virtual_y == 0 then 
                up:hide()
            elseif pane.virtual_h > pane.h then
                up:show()
                down:show()
            end
        end
    )
    --]]
    ----------------------------------------------------------------------------
    
    local move_by = 10
    
	override_property(instance,"arrow_move_by",
		function(oldf) return   move_by     end,
		function(oldf,self,v)   move_by = v end
    )
    
	override_function(instance,"add",
		function(oldf,self,...) pane:add(...) end
	)
    
	instance:subscribe_to( "enabled",
		function()
            for _,arrow in pairs(arrows) do
                arrow.enabled = instance.enabled
            end
        end
	)
    ----------------------------------------------------------------------------

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
    
    instance:add_key_handler(keys.Up,       up.click)
    instance:add_key_handler(keys.Down,   down.click)
    instance:add_key_handler(keys.Left,   left.click)
    instance:add_key_handler(keys.Right, right.click)
    
    ----------------------------------------------------------------------------
    local function arrow_on_changed()
        
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
        instance.vertical_spacing = instance.style.arrow.offset
    end
    local function arrow_colors_on_changed() 
        for _,arrow in pairs(arrows) do
            arrow.style.fill_colors = 
                instance.style.arrow.colors.attributes
        end
    end 
    local function pane_on_changed() 
        pane.style:set(instance.style.attributes)
    end
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.arrow:subscribe_to(        nil, arrow_on_changed )
        instance.style.arrow.colors:subscribe_to( nil, arrow_colors_on_changed )
        instance.style.border:subscribe_to(        nil, pane_on_changed )
        instance.style.fill_colors:subscribe_to(   nil, pane_on_changed )
        
        arrow_on_changed()
        arrow_colors_on_changed()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	override_property(instance,"contents",
		function(oldf) 
            return pane.contents    
        end,
		function(oldf,self,v) 
            pane.contents = v
        end
	)
    instance_on_style_changed()
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
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
            
            t.contents = self.contents
            
            t.pane_w = instance.pane_w
            t.pane_h = instance.pane_h
            t.virtual_x = instance.virtual_x
            t.virtual_y = instance.virtual_y
            t.virtual_w = instance.virtual_w
            t.virtual_h = instance.virtual_h
            t.arrow_move_by   = instance.arrow_move_by
            
            t.type = "ArrowPane"
            
            return t
        end
    )
    
    ----------------------------------------------------------------------------
    
    instance:set(parameters)
    
    if not parameters.virtual_x then instance.virtual_x = 0 end
    if not parameters.virtual_y then instance.virtual_y = 0 end
    
    return instance
end
--]=]