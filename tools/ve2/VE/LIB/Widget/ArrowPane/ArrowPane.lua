ARROWPANE = true

local create_arrow = function(self,state)
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    
	c:set_source_color( self.style.fill_colors[state] )     c:fill(true)
	
	return c:Image()
	
end

local default_parameters = {pane_w = 400, pane_w = 400,virtual_w=1000,virtual_h=1000, name="ArrowPane"}

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
    
    function up:on_released()
        pane.virtual_y = pane.virtual_y - move_by
    end
    
    function down:on_released()
        pane.virtual_y = pane.virtual_y + move_by
    end
    
    function left:on_released()
        pane.virtual_x = pane.virtual_x - move_by
    end
    
    function right:on_released()
        pane.virtual_x = pane.virtual_x + move_by
    end
    
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