ARROWPANE = true

local create_arrow = function(old_function,self,state)
	
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    
	c:set_source_color( self.style.arrow.colors[state] )     c:fill(true)
	
	return c:Image()
	
end

local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000, name="ArrowPane"}

ArrowPane = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ArrowPane",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ArrowPane Object inherits from Widget
	
    local pane = ClippingRegion(parameters)
    
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
        cells = {
            { Widget_Clone(),   up, Widget_Clone() },
            {           left, pane,          right },
            { Widget_Clone(), down, Widget_Clone() },
        },
    }
    ----------------------------------------------------------------------------
    
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
            if instance.virtual_w <= instance.pane_w then
                left:hide()
                right:hide()
            else
                left:show()
                right:show()
            end
        end
    )
	instance:subscribe_to(
		{"virtual_h","pane_h"},
		function()
            
            if instance.virtual_h <= instance.pane_h then
                up:hide()
                down:hide()
            else
                up:show()
                down:show()
            end
        end
    )
    ----------------------------------------------------------------------------
    
    local move_by = 10
    
	override_property(instance,"move_by",
		function(oldf) return   move_by     end,
		function(oldf,self,v)   move_by = v end
    )
    
	override_function(instance,"add",
		function(oldf,self,...) pane:add(...) end
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
    end
    local function arrow_colors_on_changed() 
        for _,arrow in pairs(arrows) do
            arrow.style.arrow.colors = 
                instance.style.arrow.colors.attributes
        end
    end 
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.arrow:subscribe_to(        nil, arrow_on_changed )
        instance.style.arrow.colors:subscribe_to( nil, arrow_colors_on_changed )
        
        arrow_on_changed()
        arrow_colors_on_changed()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
    instance_on_style_changed()
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.pane_w = instance.pane_w
            t.pane_h = instance.pane_h
            t.virtual_w = instance.virtual_w
            t.virtual_h = instance.virtual_h
            
            t.type = "ArrowPane"
            
            return t
        end
    )
    
    ----------------------------------------------------------------------------
    
    instance:set(parameters)
    
    return instance
end