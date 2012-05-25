
LAYOUTMANAGER = true

local LIST_default_parameters = {spacing = 20, direction = "vertical"}

ListManager = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ListManager",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,LIST_default_parameters) 
    
    ----------------------------------------------------------------------------
	--The ListManager Object inherits from Widget
	
	local instance = Widget( parameters )
    
    local placeholder = Rectangle{w=200,h=200,color="ff0000"}
    instance:add(placeholder)
    placeholder:hide()
    
    local node_constructor
	local cells, direction
    local cell_w, cell_h
    local spacing = 0
    local number_of_rows_set = false
    local number_of_cols_set = false
    
    ----------------------------------------------------------------------------
    
    local max_w = 0
    local max_h = 0
    
    local widths_of_cols = function(cell)
        
        if cell.w  > (max_w or 0) then 
            max_w = cell.w 
        end
    end
    local heights_of_rows = function(cell)
        if cell.h  > (max_h or 0) then 
            max_h = cell.h
        end
        
    end
    local vertical_alignment   = "center"
    local horizontal_alignment = "center"
    
    local position_cell = function(cell,i)
        
        cell.x = 0
        if direction == "horizontal" then
            for j = 1, i-1 do
                cell.x = cell.x + cells[j].w + spacing
            end
        end
        
        cell.y = 0
        if direction == "vertical" then
            for j = 1, i-1 do
                cell.y = cell.y + cells[j].h + spacing
            end
        end
        
        local ap = {0,0}
        if direction == "vertical" then
            if horizontal_alignment == "left" then
                ap[1] = 0
            elseif horizontal_alignment == "center" then
                ap[1] = cell.w/2
                cell:move_by(max_w/2,0)
            elseif horizontal_alignment == "right" then
                ap[1] = cell.w
                cell:move_by(max_w,0)
            end
        end
        if direction == "horizontal" then
            if vertical_alignment == "top" then
                ap[2] = 0
            elseif vertical_alignment == "center" then
                ap[2] = cell.h/2
                cell:move_by(0,max_h/2)
            elseif vertical_alignment == "bottom" then
                ap[2] = cell.h
                cell:move_by(0,max_h)
            end
        end
        cell.anchor_point = ap
        
    end
    
    local for_each = function(self,f)
        for i = 1, self.length do
            if self[i] then f(self[i],i) end
        end
    end
    
    local set_size = function(self)
        local last_cell = self[self.length]
        if last_cell then
            instance.w = last_cell.x + last_cell.w - last_cell.anchor_point[1]
            instance.h = last_cell.y + last_cell.h - last_cell.anchor_point[2]
        end
    end
    ----------------------------------------------------------------------------
    
	override_property(instance,"widget_type",
		function() return "LayoutManager" end, nil
	)
    
	override_property(instance,    "length",
		function(oldf) return cells.length     end,
		function(oldf,self,v) cells.length = v end
	)
	override_property(instance,"cell_w",
		function(oldf) return   cell_w     end,
		function(oldf,self,v)   
            cell_w = v 
            for_each(cells,function(cell) cell.w = cell_w end)
            max_w = cell_w
        end
	)
	override_property(instance,"cell_h",
		function(oldf) return   cell_h     end,
		function(oldf,self,v)   
            cell_h = v 
            for_each(cells,function(cell) cell.h = cell_h end)
            max_h = cell_h
        end
	)
	override_property(instance,"direction",
		function(oldf)   return direction     end,
		function(oldf,self,v)   direction = v end
	)
	override_property(instance,"spacing",
		function(oldf)   return spacing     end,
		function(oldf,self,v)   spacing = v end
	)
	override_property(instance,"horizontal_alignment",
		function(oldf)   return horizontal_alignment     end,
		function(oldf,self,v)   horizontal_alignment = v end
	)
	override_property(instance,"vertical_alignment",
		function(oldf)   return vertical_alignment     end,
		function(oldf,self,v)   vertical_alignment = v end
	)
    
    instance:subscribe_to( 
        {
            "vertical_alignment","horizontal_alignment",
            "spacing","cell_w", "cell_h", "direction",
        },
        function() 
            for_each(cells,position_cell) 
            set_size(cells)
        end
    )
	override_property(instance,"node_constructor",
		function(oldf)   return node_constructor     end,
		function(oldf,self,v)   
            if type(v) ~= "function" then
                error("Expected function. Received "..type(v),2)
            end
            node_constructor = v 
        end
	)
    local on_entries_changed = function() end
	override_property(instance,"on_entries_changed",
		function(oldf)   return on_entries_changed     end,
		function(oldf,self,v)   
            if type(v) ~= "function" then
                error("Expected function. Received "..type(v),2)
            end
            print("garrrr")
            on_entries_changed = v 
        end
	)
    
    ----------------------------------------------------------------------------
    cells = ArrayManager{  
        
        node_constructor=function(obj)
            print("NODE1",obj)
            if node_constructor then
                
                obj = node_constructor(obj)
                
            else -- default node_constructor
                if obj == nil then  obj = Clone{source=placeholder}
                
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                    
                    error("Must be a UIElement or nil. Received "..obj,2) 
                
                elseif obj.parent then  obj:unparent()  end
            end
            instance:add(obj)
            print("NODE2",obj)
            
            if obj.subscribe_to then
                obj:subscribe_to(
                    {"h","w","width","height","size"},
                    function()
                        if cells.on_entries_changed then
                            cells:on_entries_changed()
                        end
                    end
                )
            end
            
            return obj
        end,
        
        node_destructor=function(obj) obj:unparent() end,
        
        on_entries_changed = function(self)
            
            max_w = 0
            for_each(self,widths_of_cols)
            max_h = 0
            print(max_w,max_h)
            for_each(self,heights_of_rows)
            for_each(self,position_cell)
            set_size(self)
            on_entries_changed()
        end
    }
	override_property(instance,"cells",
		function(oldf) return   cells         end,
		function(oldf,self,v)   
            if type(v) ~= "table" then 
                error("Expected table. Received "..type(v),2)
            end
            cells.length = #v
            cells:set(v) 
        end
	)
    
    
    local function set_and_nil(t,k)
        
        if t[k] == nil then return end
        instance[k] = t[k]
        t[k]     = nil
        
    end
    
	override_function(instance,"set", function(old_function, obj, t )
		--need to force the setting of number_of_cols/rows before cells
        set_and_nil(t,"length")
        set_and_nil(t,"cells")
		old_function(obj, t)
		
	end)
    
    ----------------------------------------------------------------------------
    
    local function set_and_nil(t,k)
        
        if t[k] == nil then return end
        instance[k] = t[k]
        t[k]     = nil
        
    end
    
	override_function(instance,"set", function(old_function, obj, t )
		--need to force the setting of number_of_cols/rows before cells
        set_and_nil(t,"length")
        set_and_nil(t,"cells")
		old_function(obj, t)
		
	end)
    
	instance:set(parameters)
	
	return instance
    
end
--------------------------------------------------------------------------------
local LM_default_parameters = {horizontal_spacing = 20, vertical_spacing = 20}--, number_of_rows=3,number_of_cols=3}

LayoutManager = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("LayoutManager",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,LM_default_parameters) 
    
    ----------------------------------------------------------------------------
	--The LayoutManager Object inherits from Widget
	
	local instance = Widget( parameters )
    
    local placeholder = Rectangle{w=200,h=200,color="ff0000"}
    instance:add(placeholder)
    placeholder:hide()
    
    local node_constructor
	local cells
    local cell_w, cell_h
    local horizontal_spacing = 0
    local vertical_spacing   = 0
    local number_of_rows_set = false
    local number_of_cols_set = false
    
    ----------------------------------------------------------------------------
    
    local col_widths  = {}
    local row_heights = {}
    
    local widths_of_cols = function(cell,r,c)
        
        if cell.w  > (col_widths[c] or 0) then 
            col_widths[c] = cell.w 
        end
    end
    local heights_of_rows = function(cell,r,c)
        if cell.h  > (row_heights[r] or 0) then 
            row_heights[r] = cell.h
        end
    end
    local vertical_alignment   = "center"
    local horizontal_alignment = "center"
    
    local position_cell = function(cell,r,c)
        
        --if not cells[r][c-1] then
            cell.x = 0
            for i = 1, c-1 do
                cell.x = cell.x + (cell_w or col_widths[i] or cells[r][i].w) + horizontal_spacing
            end
        --else
        --    cell.x = cells[r][c-1].x + col_widths[c-1]  + horizontal_spacing
        --end
        --if not cells[r-1] or not cells[r-1][c] then
            cell.y = 0
            for i = 1, r-1 do
                cell.y = cell.y + (cell_h or row_heights[i] or cells[i][c].h) + vertical_spacing
            end
        --else
        --    cell.y = cells[r-1][c].y + row_heights[r-1] +   vertical_spacing
        --end
        ---[[
        
        local ap = {}
        if horizontal_alignment == "left" then
            ap[1] = 0
            cell:move_by(0,0)
        elseif horizontal_alignment == "center" then
            ap[1] = cell.w/2
            cell:move_by((cell_w or col_widths[c]  or cell.w)/2,0)
        elseif horizontal_alignment == "right" then
            ap[1] = cell.w
            cell:move_by((cell_w or col_widths[c]  or cell.w),0)
        end
        
        if vertical_alignment == "top" then
            ap[2] = 0
            cell:move_by(0,0)
        elseif vertical_alignment == "center" then
            ap[2] = cell.h/2
            cell:move_by(0,(cell_h or row_heights[r]  or cell.h)/2)
        elseif vertical_alignment == "bottom" then
            ap[2] = cell.h
            cell:move_by(0,(cell_h or row_heights[r]  or cell.h))
        end
        cell.anchor_point = ap
    end
    
    local for_each = function(self,f)
        for r = 1, self.number_of_rows do
            for c = 1, self.number_of_cols do
                if self[r][c] then f(self[r][c],r,c) end
            end
        end
    end
    
    local set_size = function(self)
        local last_cell = self[self.number_of_rows] and self[self.number_of_rows][self.number_of_cols]
        if last_cell then
            instance.w = last_cell.x + last_cell.w - last_cell.anchor_point[1]
            instance.h = last_cell.y + last_cell.h - last_cell.anchor_point[2]
        end
    end
    ----------------------------------------------------------------------------
    
	override_property(instance,"widget_type",
		function() return "LayoutManager" end, nil
	)
    
	override_property(instance,    "number_of_rows",
		function(oldf) return cells.number_of_rows     end,
		function(oldf,self,v) cells.number_of_rows = v end
	)
	override_property(instance,    "number_of_cols",
		function(oldf) return cells.number_of_cols     end,
		function(oldf,self,v) cells.number_of_cols = v end
	)
	override_property(instance,"cell_w",
		function(oldf) return   cell_w     end,
		function(oldf,self,v)   
            cell_w = v 
            for_each(cells,function(cell) cell.w = cell_w end)
            col_widths  = {}
            for_each(cells,widths_of_cols)
        end
	)
	override_property(instance,"cell_h",
		function(oldf) return   cell_h     end,
		function(oldf,self,v)   
            cell_h = v 
            for_each(cells,function(cell) cell.h = cell_h end)
            row_heights = {}
            for_each(cells,heights_of_rows)
        end
	)
	override_property(instance,"horizontal_spacing",
		function(oldf)   return horizontal_spacing     end,
		function(oldf,self,v)   horizontal_spacing = v end
	)
	override_property(instance,"vertical_spacing",
		function(oldf)   return vertical_spacing     end,
		function(oldf,self,v)   vertical_spacing = v end
	)
	override_property(instance,"horizontal_alignment",
		function(oldf)   return horizontal_alignment     end,
		function(oldf,self,v)   horizontal_alignment = v end
	)
	override_property(instance,"vertical_alignment",
		function(oldf)   return vertical_alignment     end,
		function(oldf,self,v)   vertical_alignment = v end
	)
    
    instance:subscribe_to( 
        {
            "vertical_alignment","horizontal_alignment",
            "vertical_spacing","horizontal_spacing",
            "cell_w", "cell_h",
        },
        function() 
            for_each(cells,position_cell) 
            set_size(cells)
        end
    )
    ----------------------------------------------------------------------------
	override_property(instance,"node_constructor",
		function(oldf)   return node_constructor     end,
		function(oldf,self,v)   
            if type(v) ~= "function" then
                error("Expected function. Received "..type(v),2)
            end
            node_constructor = v 
        end
	)
    
    local on_entries_changed = function() end
	override_property(instance,"on_entries_changed",
		function(oldf)   return on_entries_changed     end,
		function(oldf,self,v)   
            if type(v) ~= "function" then
                error("Expected function. Received "..type(v),2)
            end
            on_entries_changed = v 
        end
	)
    ----------------------------------------------------------------------------
    cells = GridManager{  
        
        node_constructor=function(obj)
            
            if node_constructor then
                
                obj = node_constructor(obj)
                
            else -- default node_constructor
                if obj == nil then  obj = Clone{source=placeholder}
                
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                    
                    error("Must be a UIElement or nil. Received "..obj,2) 
                
                elseif obj.parent then  obj:unparent()  end
            end
            instance:add(obj)
            
            if obj.subscribe_to then
                obj:subscribe_to(
                    {"h","w","width","height","size"},
                    function()
                        cells:on_entries_changed()
                    end
                )
            end
            
            return obj
        end,
        
        node_destructor=function(obj) obj:unparent() end,
        
        on_entries_changed = function(self)
            col_widths  = {}
            row_heights = {}
            for_each(self,widths_of_cols)
            for_each(self,heights_of_rows)
            for_each(self,position_cell)
            set_size(self)
            on_entries_changed()
        end
    }
	override_property(instance,"cells",
		function(oldf) return   cells           end,
		function(oldf,self,v)   cells:set(v) end
	)
    
    
    local function set_and_nil(t,k)
        
        if t[k] == nil then return end
        instance[k] = t[k]
        t[k]     = nil
        
    end
    
	override_function(instance,"set", function(old_function, obj, t )
		--need to force the setting of number_of_cols/rows before cells
        set_and_nil(t,"number_of_cols")
        set_and_nil(t,"number_of_rows")
        set_and_nil(t,"size")
        set_and_nil(t,"cells")
		old_function(obj, t)
		
	end)
    
    ----------------------------------------------------------------------------
    
	instance:set(parameters)
	
	return instance
    
end
