NINESLICE = true

--make_canvas

local make_corner = function(self,state)
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    
    if r == 0 then 
        return Rectangle{w = inset*2,h = inset*2,color = self.style.border.colors[state]}
    end
    
    
    local c = Canvas(r,r)
    c.line_width = inset*2
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    -- wrap back around out of the visible bounds
    c:line_to(r+inset,  inset)
    c:line_to(r+inset,r+inset)
    c:line_to(  inset,r+inset)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end

local make_top = function(self,state)
    
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    if r == 0 then 
        return Rectangle{w = 1,h = inset*2,color = self.style.border.colors[state]}
    end
    local c = Canvas(1,r)
    c.line_width = inset*2
    c:move_to( -inset*2,  inset)
    c:line_to(  inset*2,  inset)
    c:line_to(  inset*2,r+inset*2)
    c:line_to( -inset*2,r+inset*2)
    c:line_to( -inset*2,  inset)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end
local make_side = function(self,state)
    
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    if r == 0 then 
        return Rectangle{w = inset*2,h = 1,color = self.style.border.colors[state]}
    end
    local c = Canvas(r,1)
    c.line_width = inset*2
    c:move_to(  inset, -inset*2)
    c:line_to(  inset,  inset*2)
    c:line_to(r+inset*2,  inset*2)
    c:line_to(r+inset*2, -inset*2)
    c:line_to(   inset,-inset*2)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end
local make_canvas = function(self,state)
    local corner_canvas = make_corner(self,state)
    local top_canvas    = make_top(self,state)
    local side_canvas   = make_side(self,state)
    
    corner_canvas:hide()
    side_canvas:hide()
    top_canvas:hide()
    self:clear()
    self:add(corner_canvas,side_canvas,top_canvas)
    return {
        {
            Widget_Clone{source = corner_canvas},
            Widget_Clone{source =   top_canvas},
            Widget_Clone{source = corner_canvas,z_rotation = {90,0,0}},
        },
        {
            Widget_Clone{source =   side_canvas},
            Widget_Rectangle{color = self.style.fill_colors[state] },
            Widget_Clone{source =   side_canvas,z_rotation = {180,0,0}},
        },
        {
            Widget_Clone{source = corner_canvas,z_rotation = {270,0,0}},
            Widget_Clone{source =   top_canvas, z_rotation = {180,0,0}},
            Widget_Clone{source = corner_canvas,z_rotation = {180,0,0}},
        },
    }
end
local default_parameters = {}
NineSlice = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("NineSlice",parameters) -- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
    
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    local instance = Widget()
    
    --global row/col sizes
    local left_col_w  = 0
    local right_col_w = 0
    local top_row_h   = 0
    local btm_row_h   = 0
    
    local make_single_nine_slice = function(cells,state)
        
        
        local left_col_w  = 0
        local right_col_w = 0
        local top_row_h   = 0
        local btm_row_h   = 0
        
        local function set_size(self,w,h)
            
            for i = 1, 3 do  self[i][2].w = w  end
            for i = 1, 3 do  self[2][i].h = h  end
        end
        local instance = LayoutManager{
            vertical_spacing   = 0,
            horizontal_spacing = 0,
        }
        ------------------------------------------------------------------------
        -- Fix the size to 3x3
        instance.cells.size = {3,3}
        local setting_size = false
        instance.on_entries_changed = function(self)
                
                if setting_size then return end
                setting_size = true
                left_col_w  = 0
                right_col_w = 0
                top_row_h   = 0
                btm_row_h   = 0
                
                for i = 1, 3 do
                    if left_col_w  < self[i][1].w then left_col_w  = self[i][1].w end
                    if right_col_w < self[i][3].w then right_col_w = self[i][3].w end
                    if top_row_h   < self[1][i].h then top_row_h   = self[1][i].h end
                    if btm_row_h   < self[3][i].h then btm_row_h   = self[3][i].h end
                end
                
                set_size( self,
                    instance.w >= (left_col_w + right_col_w) and 
                    (instance.w - left_col_w - right_col_w) or 0,
                    
                    instance.h >= (top_row_h + btm_row_h) and 
                    (instance.h - top_row_h - btm_row_h) or 0
                )
                
                --Call the user's on_entries_changed function
                --on_entries_changed(self)
                setting_size = false
            end
        --remove the following functionality from the internal GridManager:
        do
            local mt = getmetatable(instance.cells)
            
            mt.functions.insert       = function() end
            mt.functions.remove       = function() end
            mt.setters.size           = function() end
            mt.setters.number_of_rows = function() end
            mt.setters.number_of_cols = function() end
        end
        
        instance:subscribe_to(
            {"h","w","width","height","size"},
            function()
                
                if setting_size then return end
                setting_size = true
                
                set_size( instance.cells,
                    instance.w >= (left_col_w + right_col_w) and 
                    (instance.w - left_col_w - right_col_w) or 0,
                    
                    instance.h >= (top_row_h + btm_row_h) and 
                    (instance.h - top_row_h - btm_row_h) or 0
                )
                setting_size = false
                
            end
        )
        
        override_property(instance,"on_entries_changed", nil, nil)
        override_property(instance,"min_w", 
            function() return left_col_w + right_col_w end, 
            function() error("Attempt to set 'min_w,' a read-only value",2) end
        )
        override_property(instance,"min_h", 
            function() return top_row_h + btm_row_h end, 
            function() error("Attempt to set 'min_w,' a read-only value",2) end
        )
        
        instance.cells = cells == nil and make_canvas(instance,state) or cells
        
        return instance
    end
    ----------------------------------------------------------------------------
    --
    
    ----------------------------------------------------------------------------
    
    local states, states_mt, setting_size
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			
            if setting_size then return end
            setting_size = true
            for state, obj in pairs(states) do
                obj.size = instance.size
            end
            setting_size = false
            
		end
	)
    local define_obj_animation = function(obj)
		
		obj.state = AnimationState{
			duration    = 100,
			transitions = {
				{
					source = "*", target = "OFF",
					keys   = {  {obj, "opacity",  0},  },
				},
				{
					source = "*", target = "ON",
					keys   = {  {obj, "opacity",255},  },
				},
			}
		}
		
	end
    states = {}
    local canvas = false
    states_mt = {
        __newindex = function(t,k,v)
            
            --remove the existing 9slice
            if t[k] then t[k]:unparent() end
            
            --make the new one (if v == nil then a canvas one is made)
            if canvas == false or v == nil then
                v = make_single_nine_slice(v,k)
                
                v.size = instance.size
                
                instance:add(v)
                
                if k ~= "default" then
                    
                    define_obj_animation(v)
                    
                    v.state:warp("OFF")
                end
                
                rawset(t,k, v )
            end
            
        end
    }
    setmetatable(states,states_mt)
    
    local curr_state = "default"
	override_property(instance,"cells", 
        function()
            return states
        end,
		function(oldf,self,v)   
            
            --clear out the existing 9slices
            for state,cells in pairs(states) do
                cells:unparent()
                rawset(states,state,nil)
            end
            canvas = false
            --if passed nil, this will trigger canvases
            if v == nil then 
                
                canvas = true
                states.default    = nil
                states.focus      = nil
                states.activation = nil
            elseif type(v) == "table" then
                if v.default then
                    for state,cells in pairs(v) do
                        states[state] = cells
                    end
                elseif v[1] and v[2] and v[3] then
                    states.default = v
                else
                    error("Expected a 3x3 table, or a table of 3x3 tables (Default is required)",2)
                end
            else
                error("Expected table or nil. Received "..type(v),2)
            end
            
            instance.state = curr_state
        end
	)
    
	override_property(instance,"state", 
        function()
            return curr_state
        end,
		function(oldf,self,v)   
            for state,cells in pairs(states) do
                if cells.state then
                    if state == v then
                        cells.state.state = "ON"
                    else
                        cells.state.state = "OFF"
                    end
                end
            end
            curr_state = v
        end
    )
    ----------------------------------------------------------------------------
	local canvas_callback = function()
        
        if not canvas then return end
        
        instance:clear()
        instance.cells = nil
        
    end
    
    local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, canvas_callback )
        instance.style.fill_colors:subscribe_to( nil, canvas_callback )
        
		canvas_callback()
	end
	
    
	instance:subscribe_to( "style", instance_on_style_changed )
    
    instance_on_style_changed()
	----------------------------------------------------------------------------
    if not parameters.cells then instance.cells = nil end
    
    instance:set(parameters)
    
    return instance
end







