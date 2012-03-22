

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
--[[
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

--]]