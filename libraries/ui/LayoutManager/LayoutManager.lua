
LAYOUTMANAGER = true

local default_parameters = {horizontal_spacing = 20, vertical_spacing = 20}--, number_of_rows=3,number_of_cols=3}

LayoutManager = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("LayoutManager",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    ----------------------------------------------------------------------------
	--The LayoutManager Object inherits from Widget
	
	local instance = Widget( parameters )
    
    local placeholder = Rectangle{w=200,h=200,color="ff0000"}
    instance:add(placeholder)
    placeholder:hide()
	local cells
    local cell_w, cell_h
    local horizontal_spacing = 0
    local vertical_spacing   = 0
    local number_of_rows = parameters.number_of_rows
    local number_of_cols = parameters.number_of_cols
    
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
    local position_cell = function(cell,r,c)
        
        --if not cells[r][c-1] then
            cell.x = 0
            for i = 1, c-1 do
                cell.x = cell.x + (cell_w or col_widths[i]) + horizontal_spacing
            end
        --else
        --    cell.x = cells[r][c-1].x + col_widths[c-1]  + horizontal_spacing
        --end
        --if not cells[r-1] or not cells[r-1][c] then
            cell.y = 0
            for i = 1, r-1 do
                cell.y = cell.y + (cell_h or row_heights[i]) + vertical_spacing
            end
        --else
        --    cell.y = cells[r-1][c].y + row_heights[r-1] +   vertical_spacing
        --end
        ---[[
        cell.anchor_point = {cell.w/2,cell.h/2}--cell.center
        cell:move_by(
            (cell_w or col_widths[c])/2,
            (cell_h or row_heights[r])/2
        )
        --]]
    end
    
    local for_each_cell = function(f)
        for r,row in instance.cells.pairs() do
            for c,cell in row.pairs() do
                if cell then f(cell,r,c) end
            end
        end
    end
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"number_of_rows",
		function(oldf) return   number_of_rows     end,
		function(oldf,self,v)   
            
            if number_of_rows > v then
                
                for i = number_of_rows,v+1,-1 do
                --while number_of_rows < v do
                    
                    instance.cells.remove(i)--number_of_rows)
                end
                
            elseif number_of_rows < v then
                
                for i = number_of_rows+1,v do
                --while number_of_rows < v do
                    
                    instance.cells.insert(i)--number_of_rows+1)
                end
                
            end
            
        end
	)
	override_property(instance,"number_of_cols",
		function(oldf) return   number_of_cols     end,
		function(oldf,self,v)   
            
            if number_of_cols > v then
                
                while number_of_cols < v do
                    
                    instance.cells[1].remove(i)
                end
                
            elseif number_of_cols < v then
                
                while number_of_cols < v do
                    
                    instance.cells[1].insert(i+1)
                end
                
            end
            
        end
	)
	override_property(instance,"cell_w",
		function(oldf) return   cell_w     end,
		function(oldf,self,v)   
            cell_w = v 
            for_each_cell(function(cell) cell.w = cell_w end)
            col_widths  = {}
            for_each_cell(widths_of_cols)
            for_each_cell(position_cell)
        end
	)
	override_property(instance,"cell_h",
		function(oldf) return   cell_h     end,
		function(oldf,self,v)   
            cell_h = v 
            for_each_cell(function(cell) cell.h = cell_h end)
            row_heights = {}
            for_each_cell(heights_of_rows)
            for_each_cell(position_cell)
        end
	)
	override_property(instance,"horizontal_spacing",
		function(oldf) return   horizontal_spacing     end,
		function(oldf,self,v)   
            horizontal_spacing = v 
            for_each_cell(position_cell)
        end
	)
	override_property(instance,"vertical_spacing",
		function(oldf) return   vertical_spacing     end,
		function(oldf,self,v)   
            vertical_spacing = v 
            for_each_cell(position_cell)
        end
	)
    
    ----------------------------------------------------------------------------
    cells = GridManager{  data = {},
        
        node_initializer=function(obj,r,c)
            --[[
            if cell_w then  obj.w = cell_w
            
            else  widths_of_cols(obj,r,c) end
            
            if cell_h then  obj.h = cell_h
            
            else  heights_of_rows(obj,r,c) end
            --]]
            col_widths  = {}
            row_heights = {}
            for_each_cell(widths_of_cols)
            for_each_cell(heights_of_rows)
            
            --print(instance.cells.pairs(r))
                for rr,row in instance.cells.pairs(r) do--rr = r, instance.number_of_rows do
                    
                    for cc,cell in row.pairs(c) do--= c, instance.number_of_cols do
                        
                        if cell then position_cell(cell,rr,cc) end
                    end
                end
            
        end,
        node_constructor=function(obj,r,c)
            
            if obj == nil then  obj = Clone{source=placeholder}
            
            elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                
                error("Must be a UIElement or nil. Received "..obj,2) 
            
            elseif obj.parent then  obj:unparent()  end
            
            instance:add(obj)
            
            return obj
        end,
        
        node_destructor=function(obj) obj:unparent() end,
        
        on_size_change = function(r,c)
            
            number_of_rows = r
            number_of_cols = c
            col_widths  = {}
            row_heights = {}
            for_each_cell(widths_of_cols)
            for_each_cell(heights_of_rows)
            for_each_cell(position_cell)
        end
    }
	override_property(instance,"cells",
		function(oldf) return   cells     end,
		function(oldf,self,v)  
            
            local num_cols = 0
            
            number_of_rows = number_of_rows or #v
            
            for r = 1,number_of_rows do
                if not v[r] then 
                    v[r] = {} 
                elseif num_cols < #v[r] then  
                    num_cols = #v[r]
                end
            end  
            
            number_of_cols = number_of_cols or num_cols
            local data = {}
            for r = 1,number_of_rows do
                data[r] = {}
                for c = 1,number_of_cols do
                    
                    data[r][c] = v[r][c] or
                        Clone{source=placeholder}
                        
                end
            end
            
            cells.data = data
        end
	)
    
    
    local function set_and_nil(t,k)
        
        if t[k] == nil then return end
        instance[k] = t[k]
        t[k]        = nil
        
    end
    
	override_function(instance,"set", function(old_function, obj, t )
		--need to force the setting of number_of_cols/rows before cells
        set_and_nil(t,"number_of_cols")
        set_and_nil(t,"number_of_rows")
        
        set_and_nil(t,"cells")
        
		old_function(obj, t)
		
	end)
    
    ----------------------------------------------------------------------------
    
	instance:set(parameters)
	
	return instance
    
end


    ----------------------------------------------------------------------------
    --[[
    rows_metatable = {
        insert = function(r,new_row)
            
            if type(r) ~= "number" or r <= 0 then
                error("1st parameter must be positive number. Received "..r,2)
            end
            
            if type(new_row) ~= "table" then
                error("2nd parameter must be a table. Received "..new_row,2)
            end
            
            table.insert(cells_interface, r)
            table.insert(cells_data,      r)
            
            --triggers rows_metatable.__newindex
            cells_interface[r] = new_row
            
            number_of_rows = number_of_rows + 1
            
        end,
        remove = function(r)
            
            if type(r) ~= "number" or r <= 0 then
                error("1st parameter must be positive number. Received "..r,2)
            end
            
            for i=1,number_of_cols then 
                if  cells_data[r][i] then 
                    cells_data[r][i]:unparent() 
                end 
            end
            
            table.remove(cells_interface, r)
            table.remove(cells_data,      r)
            
            number_of_rows = number_of_rows - 1
            
        end,
        __newindex = function(t,r,new_row)
            if type(r) ~= "number" then 
                error("The index to 'rows' is not a number: "..r,2) 
            end
            if type(new_row) ~= "table" then 
                error("Row must be a table, recevied: "..new_row,2) 
            end
            for i,cell in ipairs(cells_data[r]) do
                if cell then cell:unparent() end
            end
            
            if cells_interface[r] == nil then
                cells_data[r] = {}
                
                rawset(
                    cells_interface, r,
                    setmetatable(
                        {},
                        recursive_overwrite(
                            { data = cells_data[r] },
                            cols_metatable
                        )
                    )
                )
            end
            --triggers cols_metatable.__newindex for each entry
            for i=1,number_of_cols then cells_interface[r][i] = new_row[i] end
            
        end
    }
    --]]
    ----------------------------------------------------------------------------
    --[[
    cols_metatable = {
        insert = function(c,new_col)
            
            if type(c) ~= "number" or c <= 0 then
                error("1st parameter must be positive number. Received "..c,2)
            end
            
            if type(new_col) ~= "table" then
                error("2nd parameter must be a table. Received "..new_col,2)
            end
            
            number_of_cols = number_of_cols + 1
            
            for i=1, number_of_rows then 
                table.insert(cells_interface[i], c )
                table.insert(cells_data[i],      c )
                --triggers cols_metatable.__newindex
                cells_interface[i][c] = new_col[i]
            end
            
        end,
        remove = function(c)
            
            if type(c) ~= "number" or c <= 0 then
                error("1st parameter must be positive number. Received "..c,2)
            end
            
            for i=1,number_of_rows then 
                if  cells[i][c] then 
                    cells[i][c]:unparent()
                end 
                table.remove(cells[i],c)
            end
            
            number_of_cols = number_of_cols - 1
            
        end,
        __index = function(t,k)  return getmetatable(t).data[k]  end,
        __newindex = function(t,c,obj)
            
            if type(c) ~= "number" then 
                error("The index to 'cells' is not a number: "..c,2) 
            end
            if type(obj) ~= "userdata" and obj.__types__.actor then 
                error("Must be a UIElement"..obj,2) 
            end
            
            if t[c] ~= nil then t[c]:unparent() end
            
            rawset(t,c,obj)
            
            if obj and obj.parent then obj:unparent() end
			
            if cell_w then
                obj.w = cell_w
            else
                widths_of_cols(obj,t.index,c)
            end
            if cell_h then
                obj.h = cell_h
            else
                heights_of_rows(obj,t.index)
            end
            
            instance:add(obj)
        end
    }
    --]]
            --[[
            if type(v) ~= "table" then 
                error("LayoutManager.cells expected table",2) 
            end
            
            instance:clear()
            
            number_of_rows = 0
            number_of_cols = 0
            
            cells = {}
            
            for r,row in ipairs(v) do
                if type(row) ~= "table" then 
                    error("LayoutManager.cells expected table of tables",2) 
                end
                
                if r > number_of_rows then number_of_rows = r end
                
                for c,obj in ipairs(row) do
                    if type(obj) ~= "userdata" or obj.__types__.actor then 
                        error("Must be a UIElement. Entry "..r.." "..c.." - "..obj,2) 
                    end
                    if c > number_of_cols then c = number_of_cols end
                    
                end
            end
            
            setmetatable(cells,rows_metatable)
            --]]





--[[
Function: Layout Manager

Creates a 2D grid of items, that animate in with a flipping animation

Arguments:
    rows    - number of rows
    columns    - number of columns
    item_w      - width of an item
    item_h      - height of an item
    grid_gap    - the number of pixels in between the grid items
    duration_per_tile - how long a particular tile flips for
    cascade_delay     - how long a tile waits to start flipping after its neighbor began flipping
    cells       - the uielements that are the cells, the elements are assumed to be of the size {item_w,item_h} and that there are 'num_rows' by 'columns' elements in a 2 dimensional table 

Return:
    Group - Group containing the grid
        
Extra Function:
    get_tile_group(r,c) - returns group for the tile at row 'r' and column 'c'
    animate_in() - performs the animate-in sequence
]]
--[=[
function ui_element.layoutManager(t)
    --default parameters
    local p = {
        rows    	= 1,
        columns    	= 5,
        cell_width      = 300,
        cell_height      = 200,
        cell_spacing_width = 40, --grid_gap
        cell_spacing_height = 40, --grid_gap
		cell_timing = 300, -- duration_per_time
		cell_timing_offset = 200,
        cells       = {},
        cells_focusable = false, --focus_visible
        skin="Custom",
		variable_cell_size = false, 
 		ui_position = {200,100},
    }
    
    local functions={}
    local focus_i = {1,1}
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local make_grid
    
    local row_hs = {}
    local col_ws = {}
	
    local x_y_from_index = function(r,c)
        --if p.cell_size == "fixed" then
        if p.variable_cell_size == false then
		    return (p.cell_width+p.cell_spacing_width)*(c-1)+p.cell_width/2,
		           (p.cell_height+p.cell_spacing_height)*(r-1)+p.cell_height/2
        end
        
        local x = (col_ws[1] or p.cell_width)/2
        local y = (row_hs[1] or p.cell_height)/2
        for i = 1, c-1 do x = x + (col_ws[i] or p.cell_width)/2 + (col_ws[i+1] or p.cell_width)/2 + p.cell_spacing_width end
        for i = 1, r-1 do y = y + (row_hs[i] or p.cell_height)/2 + (row_hs[i+1] or p.cell_height)/2 + p.cell_spacing_height end
        return x,y
	end

    --the umbrella Group, containing the full slate of cells
    local slate = Group{ 
        name     = "layoutManager",
        position = p.ui_position, 
        reactive = true,
        extra    = {
	    type = "LayoutManager",
            reactive = true,
            replace = function(self,r,c,obj)
                if p.cells[r][c] ~= nil then
                    p.cells[r][c]:unparent()
                end
                p.cells[r][c] = obj
               	if obj then  
                	if obj.parent ~= nil then obj:unparent() end
				end 
                
                make_grid()
			end,
            remove_row = function(self,r)
                if r > 0 and r <= #p.cells then
                    table.remove(p.cells,r)
                    p.rows = p.rows - 1
                    make_grid()
                end
            end,
            remove_col = function(self,c)
                if c > 0 and c <= #p.cells[1] then
                    for r = 1,#p.cells do
                        table.remove(p.cells[r],c)
                    end
                    p.columns = p.columns - 1
                    make_grid()
                end
            end,
            add_row = function(self,r)
                if r > 0 and r <= #p.cells then
                    table.insert(p.cells,r,{})
                    p.rows = p.rows + 1
                    make_grid()
                end
            end,
            add_col = function(self,c)
                if c > 0 and c <= #p.cells[1] then
                    for r = 1,#p.cells do
                        table.insert(p.cells[r],c,c)
                        p.cells[r][c] = nil
                    end
                    p.columns = p.columns + 1
                    make_grid()
                end
            end,
            add_next = function(self,obj)
                self:replace(focus_i[1],focus_i[2],obj)
                if focus_i[2]+1 > p.columns then
                    if focus_i[1] + 1 >p.rows then
                        self.focus_to(1,1)
                    else
                        self.focus_to(focus_i[1]+1,1)
                    end
                else
                    self.focus_to(focus_i[1],focus_i[2]+1)
                end
            end,
            set_function = function(r,c,f)
                if r > p.rows or r < 1 or c < 1 or c > p.columns then
                    print("invalid row/col")
                    return
                end
                if functions[r][c] == nil then
                    print("no function")
                    return
                else
                    functions[r][c]()
                end
            end,
            focus_to = function(r,c)
				if current_focus then
					current_focus.clear_focus()
				end

				if p.cells[r][c].set_focus then 
					 p.cells[r][c].set_focus()
					 current_focus = p.cells[r][c]
					 focus_i[1] = r
					 focus_i[2] = c 
			    end 
            end,
            press_enter = function(p)
                functions[focus_i[1]][focus_i[2]](p)
            end,
            animate_in = function()
				local tl = Timeline{
					duration =p.cell_timing_offset*(p.rows+p.columns-2)+ p.cell_timing
				}
				function tl:on_started()
					for r = 1, p.rows  do
						for c = 1, p.columns do
							p.cells[r][c].y_rotation={90,0,0}
							p.cells[r][c].opacity = 0
						end
					end
				end
				function tl:on_new_frame(msecs,prog)
					msecs = tl.elapsed
					local item
					for r = 1, p.rows  do
						for c = 1, p.columns do
							item = p.cells[r][c] 
							if msecs > item.delay and msecs < (item.delay+p.cell_timing) then
								prog = (msecs-item.delay) / p.cell_timing
								item.y_rotation = {90*(1-prog),0,0}
								item.opacity = 255*prog
							elseif msecs > (item.delay+p.cell_timing) then
								item.y_rotation = {0,0,0}
								item.opacity = 255
							end
						end
					end
				end
				function tl:on_completed()
					for r = 1, p.rows  do
						for c = 1, p.columns do
							p.cells[r][c].y_rotation={0,0,0}
							p.cells[r][c].opacity = 255
						end
					end
				end
				tl:start()
            end,
            r_c_from_abs_position = function(self,x,y)
                x = x - self.transformed_position[1]/screen.scale[1]
                y = y - self.transformed_position[2]/screen.scale[2]
                --if p.cell_size == "fixed" then
                if p.variable_cell_size == false then
	        	    return math.floor(x/(p.cell_width+p.cell_spacing_width))+1,
                           math.floor(y/(p.cell_height+p.cell_spacing_height))+1
                end
                
                local r = 1
                local c = 1
                for i = 1, p.columns do
                    if x < (col_ws[i] or p.cell_width) then break end
                    x = x - (col_ws[i] or p.cell_width) - p.cell_spacing_width
                    r = r + 1
                end
                for i = 1, p.rows do
                    if y < (row_hs[i] or p.cell_height) then break end
                    y = y - (row_hs[i] or p.cell_height) - p.cell_spacing_height
                    c = c + 1
                end
                return  r,c
	        end,
            cell_x_y_w_h = function(self,r,c)
                --if p.cell_size == "fixed" then
                if p.variable_cell_size == false then
                    
                    return  (p.cell_width+p.cell_spacing_width)*(c-1),
                            (p.cell_height+p.cell_spacing_height)*(r-1),
                            p.cell_width,
                            p.cell_height
                    
                else
                    
                    local x, y = 0, 0
                    
                    for i = 1,c-1 do
                        
                        x = x + (col_ws[i] or p.cell_width) + p.cell_spacing_width
                        
                    end
                    
                    for i = 1,r-1 do
                        
                        y = y + (row_hs[i] or p.cell_height) + p.cell_spacing_height
                        
                    end
                    
                    return x, y, (col_ws[c] or p.cell_width), (row_hs[r] or p.cell_height)
                end
            end,
        }
    }

	local make_tile = function(w,h)
        local c = Canvas{size={w,h}}
        c:begin_painting()
        c:move_to(  0,   0 )
        c:line_to(c.w,   0 )
        c:line_to(c.w, c.h )
        c:line_to(  0, c.h )
        c:line_to(  0,   0 )
        c:set_source_color("ffffff")
        c:set_line_width( 4 )
        c:set_dash(0,{10,10})
        c:stroke(true)
        c:finish_painting()
        if c.Image then
            c = c:Image()
        end
        c.name="placeholder"
		return c
	end

	
	local function my_make_tile( _ , ... )
     	return make_tile( ... )
	end
	
	make_grid = function()
        
		local cell, key
        slate:clear()
        
        focus_i[1] = 1
        focus_i[2] = 1
        
        --if p.cell_size == "variable" then
        if p.variable_cell_size == true then
            for r = 1, p.rows  do
                for c = 1, p.columns do
                    if p.cells[r]    == nil then break end
                    if p.cells[r][c] ~= nil and p.cells[r][c].name ~= "placeholder" then 
                        if row_hs[r] == nil or row_hs[r] < p.cells[r][c].h then
                            row_hs[r] = p.cells[r][c].h
                        end
                        if col_ws[c] == nil or col_ws[c] < p.cells[r][c].w then
                            col_ws[c] = p.cells[r][c].w
                        end
                    end
                end
            end
        end
        
		for r = 1, p.rows  do
            if p.cells[r] == nil then
                p.cells[r]   = {}
                functions[r] = {}
            end
			for c = 1, p.columns do
                if p.cells[r][c] == nil then
                    --if p.cell_size == "variable" then
                    if p.variable_cell_size == true then
						key = string.format("cell:%d:%d",col_ws[c] or p.cell_width, row_hs[r] or p.cell_height) 

                        cell = assets(key, my_make_tile, col_ws[c] or p.cell_width, row_hs[r] or p.cell_height)

                    else
						key = string.format("cell:%d:%d",p.cell_width,p.cell_height)
                        cell = assets(key, my_make_tile, p.cell_width,p.cell_height)
                    end
                else
                    cell = p.cells[r][c]
                    if cell.parent ~= nil then
                        cell:unparent()
                    end
                end
                slate:add(cell)
                cell.x, cell.y = x_y_from_index(r,c)
                cell.delay = p.cell_timing_offset*(r+c-1)
                cell.anchor_point = {cell.w/2,cell.h/2}
			end
		end
        
        slate.w, slate.h = x_y_from_index(p.rows,p.columns)
        slate.w = slate.w + (col_ws[p.columns] or p.cell_width)/2
        slate.h = slate.h + (row_hs[p.rows]    or p.cell_height)/2
        
        if p.rows < #p.cells then
            for r = p.rows + 1, #p.cells do
                for c = 1, #p.cells[r] do
                    p.cells[r][c]:unparent()
                    p.cells[r][c] = nil
                end
                p.cells[r]     = nil
                functions[r] = nil
            end
        end
        
        if p.cells[1] then 
            if p.columns < #p.cells[1] then
                for c = p.columns + 1, #p.cells[r] do
                    for r = 1, #p.cells do
                        p.cells[r][c]:unparent()
                        p.cells[r][c]   = nil
                        functions[r][c] = nil
                    end
                end
            end
        end
	end

	make_grid()
	
	local function layoutManager_on_key_down(key)
		if slate.focus and slate.focus[key] then
			if type(slate.focus[key]) == "function" then
				slate.focus[key]()
			elseif screen:find_child(slate.focus[key]) then
				if slate.clear_focus then
					slate.clear_focus(key)
				end
				screen:find_child(slate.focus[key]):grab_key_focus()
				if screen:find_child(slate.focus[key]).set_focus then
					screen:find_child(slate.focus[key]).set_focus(key)
				end
			end
		end
		return 
	end

    --Key Handler
	local keys={
		[keys.Return] = function()
			if 1 <= focus_i[1] and focus_i[1] <= p.rows and 1 <= focus_i[2] and focus_i[2] <= p.columns then
				if p.cells[focus_i[1]][focus_i[2]].on_press then 
					p.cells[focus_i[1]][focus_i[2]].on_press()
				end
		    end 
		end,
		[keys.Left] = function()
			if focus_i[2] - 1 >= 1 then
				slate.focus_to(focus_i[1] ,focus_i[2] - 1)
			else
				layoutManager_on_key_down(keys.Left)
			end
			
		end,
		[keys.Right] = function()
			if focus_i[2] + 1 > p.columns then
				layoutManager_on_key_down(keys.Right)
			else
				slate.focus_to(focus_i[1],focus_i[2] + 1)
			end
			
		end,
		[keys.Up] = function()
			if focus_i[1] - 1 < 1 then
				layoutManager_on_key_down(keys.Up)
			else
				slate.focus_to(focus_i[1] - 1,focus_i[2])
			end
			
		end,
		[keys.Down] = function()
			if focus_i[1] + 1 > p.rows then
				layoutManager_on_key_down(keys.Down)
			else
				slate.focus_to(focus_i[1] + 1,focus_i[2])
			end
			
		end,
	}
	
	slate.on_key_down = function(self,key)
		
		if keys[key] then keys[key]() end
		
	end

	slate.set_focus = function()

		slate:grab_key_focus()
		slate.focus_to(1,1)

	end 

	slate.clear_focus = function ()
		if current_focus then 
			current_focus.clear_focus ()
		end 
		current_focus = nil 
		screen:grab_key_focus()
	end 

    mt = {}
    mt.__newindex = function(t,k,v)
		
       p[k] = v
	   if k ~= "selected" then 
       		make_grid()
	   end
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(slate.extra, mt)
    return slate
end

--]=]