
LAYOUTMANAGER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local LIST_default_parameters = {spacing = 20, direction = "vertical"}





local next_neighbor

next_neighbor = function(instance,items,obj,dir)
    
    return instance.children_want_focus and (
            --if the obj has a neighbor in the direction
            items[obj].neighbors[dir] and 
            --if that neighbor is enabled, return it
            (items[obj].neighbors[dir].enabled and items[obj].neighbors[dir] or 
                --else return that neighbors neighbor
                next_neighbor(instance,items,items[obj].neighbors[dir],dir)
            )
        ) or nil
end

ListManager = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            --dumptable(p)
            return self:declare():set(p or {})
            
        end,
        
        public = {
            properties = {
                widget_type = function(instance,_ENV)
                    return function() return "ListManager" end
                end,
                placeholder = function(instance,_ENV)
                    return function(oldf) return placeholder     end,
                    function(oldf,self,v) 
                        add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(placeholders) do
                            obj.source = v
                        end
                        
                        placeholder:unparent()
                        if v.subscribe_to then
                            v:subscribe_to(
                                {"h","w","width","height","size"},
                                function(...)
                                    if in_on_entries then return end
                                    
                                    cells:on_entries_changed()
                                    
                                end
                            )
                        end
                        
                        placeholder = v 
                        
                        cells:on_entries_changed()
                    end
                end,
                length = function(instance,_ENV)
                    return function(oldf) return cells.length     end,
                    function(oldf,self,v)        cells.length = v end
                end,
                cell_w = function(instance,_ENV)
                    return function(oldf) return cell_w     end,
                    function(oldf,self,v) 
                        cell_w = v 
                        max_w  = v
                        for_each(cells,function(cell) cell.w = cell_w end)
                        reposition = true
                    end
                end,
                cell_h = function(instance,_ENV)
                    return function(oldf) return cell_h     end,
                    function(oldf,self,v) 
                        cell_h = v 
                        max_h  = v
                        for_each(cells,function(cell) cell.h = cell_h end)
                        reposition = true
                    end
                end,
                direction = function(instance,_ENV)
                    return function(oldf) return direction     end,
                    function(oldf,self,v)        
                        direction = v 
                        reposition = true
                        reassign_neighbors = true
                    end
                end,
                spacing = function(instance,_ENV)
                    return function(oldf) return spacing     end,
                    function(oldf,self,v)        
                        spacing = v
                        reposition  = true
                        find_width  = true
                        find_height = true
                     end
                end,
                horizontal_alignment = function(instance,_ENV)
                    return function(oldf) return horizontal_alignment     end,
                    function(oldf,self,v) 
                        if v == "left" or v == "right" or v == "center" then
                            horizontal_alignment = v 
                            reposition = true
                        else
                            error("expected 'left' 'right' or 'center'. Received "..v,2)
                        end
                    end
                end,
                vertical_alignment = function(instance,_ENV)
                    return function(oldf) return vertical_alignment     end,
                    function(oldf,self,v) 
                        if v == "top" or v == "bottom" or v == "center" then
                            vertical_alignment = v 
                            reposition = true
                        else
                            error("expected 'top' 'bottom' or 'center'. Received "..v,2)
                        end
                    end
                end,
                node_constructor = function(instance,_ENV)
                    return function(oldf) return node_constructor     end,
                    function(oldf,self,v) 
                        if type(v) ~= "function" then
                            error("Expected function. Received "..type(v),2)
                        end
                        node_constructor = v
                    end
                end,
                on_entries_changed = function(instance,_ENV)
                    return function(oldf) return on_entries_changed     end,
                    function(oldf,self,v) 
                        if type(v) ~= "function" then
                            error("Expected function. Received "..type(v),2)
                        end
                        on_entries_changed = v
                    end
                end,
                
                
                
                
                cells = function(instance,_ENV)
                    return function(oldf) return cells     end,
                    function(oldf,self,v)   
                        new_cells = v  
                        --print("herp")
                        dumptable(v)
                    end
                end,
                focus_to_index = function(instance,_ENV)
                    return function(oldf) return focus_to_index     end,
                    function(oldf,self,v)   
                        if type(v) ~= "number" then error("expected number. received "..type(v),2) end
                        focus_to_index = v
                    end
                end,
                children_want_focus = function(instance,_ENV)
                    return function(oldf) return children_want_focus     end,
                    function(oldf,self,v)        children_want_focus = v end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "ListManager" end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        
                        local t = oldf(self)
            
                        t.style = nil
                        
                        t.length               = instance.length
                        t.vertical_alignment   = instance.vertical_alignment
                        t.horizontal_alignment = instance.horizontal_alignment
                        t.direction            = instance.direction
                        t.spacing              = instance.spacing
                        t.cell_h               = instance.cell_h
                        t.cell_w               = instance.cell_w
                        t.cells                = {}
                        for_each(cells,function(obj,i)
                            
                            if not placeholders[obj] then
                                t.cells[i] = obj.attributes
                            else
                                t.cells[i] = false
                            end
                        end)
                        
                        t.type = "ListManager"
                        
                        return t
                        
                    end
                end,
               
            },
            functions = {
            },
        },
        private = {
            widths_of_cols = function(instance,_ENV)
                return function(cell)
                    if cell.w  > (max_w or 0) then 
                        max_w = cell.w 
                    end
                end
            end,
            heights_of_rows = function(instance,_ENV)
                return function(cell)
                    if cell.h  > (max_h or 0) then 
                        max_h = cell.h 
                    end
                end
            end,
            find_w = function(instance,_ENV)
                return function(cell,i)
                    
                    if w < cell.x + cell.w - cell.anchor_point[1] then 
                        w = cell.x + cell.w - cell.anchor_point[1]
                    end
                end
            end,
            find_h = function(instance,_ENV)
                return function(cell,i)
                    
                    if h < cell.y + cell.h - cell.anchor_point[2] then 
                        h = cell.y + cell.h - cell.anchor_point[2]
                    end
                end
            end,
            assign_neighbors = function(instance,_ENV)
                return function(cell,i,cells)
        
                    items[cell].neighbors.up = nil
                    items[cell].neighbors.down = nil
                    items[cell].neighbors.left = nil
                    items[cell].neighbors.right = nil
                    
                    if i ~= 1 then
                        if direction == "vertical" then
                            items[cell].neighbors.up = cells[i-1]
                        elseif direction == "horizontal" then
                            items[cell].neighbors.left = cells[i-1]
                        else
                            error("direction is invalid",2)
                        end
                    end
                    if i ~= cells.length then
                        if direction == "vertical" then
                            items[cell].neighbors.down = cells[i+1]
                        elseif direction == "horizontal" then
                            items[cell].neighbors.right = cells[i+1]
                        else
                            error("direction is invalid",2)
                        end
                    end
                end
            end,
            position_cells = function(instance,_ENV)
                return function(self)
                    if direction == "horizontal" then
                        for i = 1, self.length do
                            self[i].x =  (i-1) > 0 and (self[i-1].x + self[i-1].w + spacing) or 0
                            self[i].y =  0
                        end
                    elseif direction == "vertical" then
                        for i = 1, self.length do
                            self[i].x =  0
                            self[i].y =  (i-1) > 0 and (self[i-1].y + self[i-1].h + spacing) or 0
                        end
                    else
                        error("Invalid direction: "..tostring(direction),2)
                    end
                    
                    local ap = {}
                    for i = 1, self.length do
                        
                        ap[1] = 
                            direction            ~= "vertical" and self[i].w/2 or 
                            horizontal_alignment == "right"    and self[i].w   or
                            horizontal_alignment == "center"   and self[i].w/2 or
                            horizontal_alignment == "left"     and 0
                        
                        ap[2] = 
                            direction            ~= "horizontal" and self[i].h/2 or 
                            horizontal_alignment == "bottom"     and self[i].h   or
                            horizontal_alignment == "center"     and self[i].h/2 or
                            horizontal_alignment == "top"        and 0
                        
                        self[i].anchor_point = ap
                        
                        self[i]:move_by(
                            direction            ~= "vertical" and self[i].w/2  or 
                            horizontal_alignment == "right"    and max_w    or
                            horizontal_alignment == "center"   and max_w/2  or
                            horizontal_alignment == "left"     and 0,
                            
                            direction            ~= "horizontal" and self[i].h/2  or 
                            horizontal_alignment == "bottom"     and max_h    or
                            horizontal_alignment == "center"     and max_h/2  or
                            horizontal_alignment == "top"        and 0
                        )
                        
                    end
                    
                end
            end,
            for_each = function(instance,_ENV)
                return function(self,f)
                     for i = 1, self.length do
                        if self[i] then f(self[i],i,self) end
                    end
                end
            end,

            update = function(instance,_ENV)
                return function(self)
                    
                    if  new_placeholder then
                        local v = new_placeholder
                        new_placeholder = false
                        if v.parent then v:unparent() end
                        --print("add",v.gid)
                        add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(placeholders) do
                            obj.source = v
                        end
                        
                        if placeholder then placeholder:unparent() end
                        
                        placeholder = v 
                    end
                    if  new_cells then
                        print(#new_cells)
                        --cells.length = #new_cells
                        cells:new_data(new_cells) 
                        
                        find_col_widths    = true
                        find_col_heights   = true
                        reposition         = true
                        find_width         = true
                        find_height        = true
                        reassign_neighbors = true
                        
                        new_cells = false
                    end
                    if  find_col_widths then
                        find_col_widths = false
                        max_w  = 0
                        for_each(cells,widths_of_cols) 
                    end
                    --print(#col_widths,instance.number_of_cols)
                    if  find_col_heights then
                        find_col_heights = false
                        max_h  = 0
                        for_each(cells,heights_of_rows) 
                    end
                    --print(#row_heights,instance.number_of_rows)
                    if  reposition then
                        reposition = false
                        position_cells(cells)
                        find_width  = true
                        find_height = true
                    end
                    --print("a")
                    if  find_width then
                        find_width = false
                        w = 0
                        for_each(cells,find_w) 
                        
                        instance.w = w
                    end
                    if  find_height then
                        find_height = false
                        h = 0
                        for_each(cells,find_h) 
                        
                        instance.h = h
                    end
                    if  reassign_neighbors then
                        reassign_neighbors = false
                        for_each(cells,assign_neighbors) 
                    end
                    
                    if children_want_focus and focused_child == nil and 
                        self.length > 0 then 
                        focused_child = self[1]
                        focused_child:grab_key_focus()
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, _ENV = Widget()
            
            function instance:on_key_focus_in()   
                if children_want_focus then
                    if focus_to_index then
                        
                        local obj = cells[ focus_to_index ]
                        
                        dolater(
                            obj.grab_key_focus,
                            obj
                        )
                    elseif focused_child then 
                        dolater(
                            focused_child.grab_key_focus,
                            focused_child
                        )
                    end
                end
                
            end 
            
            local getter, setter
            
            node_constructor = false
            on_entries_changed   = function() end
            cells = ArrayManager{  
                
                node_constructor=function(obj)
                    if node_constructor then
                        
                        obj = node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil or obj == false then  
                            
                            obj = Widget_Clone{source=placeholder}
                            placeholders[obj] = true
                            
                        elseif type(obj) == "table" and obj.type then 
                            
                            obj = _ENV[obj.type](obj)
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    --if cell_w then obj.w = cell_w end    TODO check these
                    --if cell_h then obj.h = cell_h end
                    
                    
                    
                    add(instance,obj)
                    local n
                    items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                n = next_neighbor(instance,items,obj,"up")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                n = next_neighbor(instance,items,obj,"down")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                n = next_neighbor(instance,items,obj,"left")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                n = next_neighbor(instance,items,obj,"right")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                        }
                    }
                    
                    if obj.subscribe_to then
                        obj:subscribe_to(
                            {"h","w","width","height","size"},
                            function(...)
                                if in_on_entries then return end
                                --print("width_changed",obj.w,obj.h)
                                ---[[
                                find_col_widths = true
                                find_col_heights = true
                                reposition = true
                                find_width = true
                                find_height = true
                                --]]
                                if cells.on_entries_changed then cells:on_entries_changed() end
                            end
                        )
                    end
                    
                    return obj
                end,
                
                node_destructor=function(obj) 
                    if obj == focused_child then 
                        local neighbors = items[obj].neighbors
                        focused_child = 
                            neighbors.up or 
                            neighbors.left or
                            neighbors.right or
                            neighbors.down 
                    end
                    for _,f in pairs(items[obj].key_functions) do f() end
                    items[obj] = nil
                    obj:unparent() 
                    placeholders[obj] = nil
                    
                end,
                
                on_entries_changed = function(self)
                    
                    find_col_widths = true
                    find_col_heights = true
                    reposition = true
                    find_width = true
                    find_height = true
                    if not is_setting then
                        call_update()
                        on_entries_changed(self)
                    end
                    --[[
                    max_w = 0
                    for_each(self,widths_of_cols)
                    max_h = 0
                    for_each(self,heights_of_rows)
                    --for_each(self,position_cell)
                    position_cells(self)
                    --set_size(self)
                    w = 0
                    for_each(self,find_w)
                    h = 0
                    for_each(self,find_h)
                    --set_size(self)
                    instance.size = {w,h}
                    for_each(self,assign_neighbors)
                    on_entries_changed()
                    --]]
                end
            }
            new_cells = false
            w = 0
            h = 0
            cell_w = false
            cell_h = false
            spacing = 20
            items = {}
            --public attributes, set to false if there is no default
            max_w = 0
            max_h = 0
            direction   = "vertical"
            vertical_alignment   = "center"
            horizontal_alignment = "center"
            placeholders   = {}
            children_want_focus   = true
            in_on_entries   = false
            focused_child   = false
            placeholder = nil
            new_placeholder = Rectangle{w=200,h=200,color="ff0000"}
            
            instance.reactive = true
            
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance:set(parameters)
            updating = false
            return instance, _ENV
            
        end
    }
)
--------------------------------------------------------------------------------
--============================================================================--
--============================================================================--
--============================================================================--
--------------------------------------------------------------------------------
local LM_default_parameters = {horizontal_spacing = 20, vertical_spacing = 20}--, number_of_rows=3,number_of_cols=3}


LayoutManager = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        
        public = {
            properties = {
                widget_type = function(instance,_ENV)
                    return function() return "LayoutManager" end
                end,
                number_of_rows = function(instance,_ENV)
                    return function(oldf) return cells.number_of_rows     end,
                    function(oldf,self,v) 
                         
                        cells.number_of_rows = v 
                        
                        find_col_widths    = true
                        find_col_heights   = true
                        reposition         = true
                        find_width         = true
                        find_height        = true
                        reassign_neighbors = true
                    end
                end,
                on_entries_changed = function(instance_ENV)
                    return function(oldf) return on_entries_changed     end,
                    function(oldf,self,v)        on_entries_changed = v 
                    end
                end,
                number_of_cols = function(instance,_ENV)
                    return function(oldf) return cells.number_of_cols     end,
                    function(oldf,self,v) 
                        
                        cells.number_of_cols = v 
                        
                        find_col_widths    = true
                        find_col_heights   = true
                        reposition         = true
                        find_width         = true
                        find_height        = true
                        reassign_neighbors = true
                    end
                end,
                children_want_focus = function(instance,_ENV)
                    return function(oldf) return children_want_focus     end,
                    function(oldf,self,v)        children_want_focus = v end
                end,
                cell_w = function(instance,_ENV)
                    return function(oldf) return cell_w or nil     end,
                    function(oldf,self,v) 
                        v = type(v) == "number" and v or false
                        cell_w = v 
                        --for_each(cells,function(cell) cell.w = v end)
                        find_col_widths    = true
                        find_col_heights   = true
                        reposition         = true
                        find_width         = true
                        find_height        = true
                    end
                end,
                cell_h = function(instance,_ENV)
                    return function(oldf) return cell_h or nil     end,
                    function(oldf,self,v) 
                        v = type(v) == "number" and v or false
                        cell_h = v 
                        --for_each(cells,function(cell) cell.h = v end)
                        find_col_widths    = true
                        find_col_heights   = true
                        reposition         = true
                        find_width         = true
                        find_height        = true
                    end
                end,
                horizontal_spacing = function(instance,_ENV)
                    return function(oldf) return horizontal_spacing     end,
                    function(oldf,self,v) 
                        horizontal_spacing = v 
                        reposition = true
                        find_width = true
                    end
                end,
                vertical_spacing = function(instance,_ENV)
                    return function(oldf) return vertical_spacing     end,
                    function(oldf,self,v) 
                        vertical_spacing = v
                        reposition = true
                        find_height = true
                    end
                end,
                horizontal_alignment = function(instance,_ENV)
                    return function(oldf) return horizontal_alignment     end,
                    function(oldf,self,v) 
                        horizontal_alignment = v
                        reposition = true
                    end
                end,
                vertical_alignment = function(instance,_ENV)
                    return function(oldf) return vertical_alignment     end,
                    function(oldf,self,v) 
                        vertical_alignment = v
                        reposition = true
                    end
                end,
                individual_duration = function(instance,_ENV)
                    return function(oldf) return individual_duration     end,
                    function(oldf,self,v)        individual_duration = v end
                end,
                cascade_delay = function(instance,_ENV)
                    return function(oldf) return cascade_delay     end,
                    function(oldf,self,v)        cascade_delay = v end
                end,
                placeholder = function(instance,_ENV)
                    return function(oldf) return placeholder     end,
                    function(oldf,self,v) 
                        
                        if placeholder ~= v then
                            new_placeholder = v    
                        end
                    end
                end,
                focus_to_index = function(instance,_ENV)
                    return function(oldf) return focus_to_index     end,
                    function(oldf,self,v)   
                        if type(v) ~= "table" then error("expected table. received "..type(v),2) end
                        focus_to_index = {v[1],v[2]}
                    end
                end,
                cells = function(instance,_ENV)
                    return function(oldf) return cells     end,
                    function(oldf,self,v)   
                        new_cells = v  
                        mesg("LayoutManager",0,"LayoutManager.cells = ",v)
                        dumptable(v)
                        --print("dim",cells.number_of_rows,cells.number_of_cols)
                    end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        local t = oldf(self)
                        
                        t.number_of_cols       = instance.number_of_cols
                        t.number_of_rows       = instance.number_of_rows
                        t.vertical_alignment   = instance.vertical_alignment
                        t.horizontal_alignment = instance.horizontal_alignment
                        t.vertical_spacing     = instance.vertical_spacing
                        t.horizontal_spacing   = instance.horizontal_spacing
                        t.cell_h = cell_h or json.null
                        t.cell_w = cell_w or json.null
                        t.cells = {}
                        for_each(cells,function(obj,r,c)
                            if not t.cells[r] then
                                t.cells[r] = {}
                            end
                            
                            if not placeholders[obj] then
                                t.cells[r][c] = obj.attributes
                            else
                                t.cells[r][c] = false
                            end
                        end)
                        
                        t.type = "LayoutManager"
                        
                        return t
                    end
                end,
               
            },
            functions = {
                r_c_from_x_y = function(instance,_ENV)
                    return function(old_function,self,x,y)
                        if  instance.number_of_rows == 0 or 
                            instance.number_of_cols == 0 then
                            
                            return 0, 0
                        end
                        local r,c = instance.number_of_rows, instance.number_of_cols
                        for i=1,instance.number_of_rows do
                            if y < (cells[i][1].y - cells[i][1].anchor_point[2]) then
                                r = i - 1
                                break
                            end
                        end
                        for i=1,instance.number_of_cols do
                            if x < (cells[1][i].x - cells[1][i].anchor_point[1]) then
                                c = i - 1
                                break
                            end
                        end
                        return (r < 1 and 1 or r),(c < 1 and 1 or c)
                    end
                end,
                r_c_from_abs_x_y = function(instance,_ENV)
                    return function(old_function,self,x,y)
                        return self:r_c_from_x_y(
                            x - self.transformed_position[1]/screen.scale[1],
                            y - self.transformed_position[2]/screen.scale[2]
                        )
                    end
                end,
                prep_animate_in = function(instance,_ENV)
                    return function(old_function,self)
                        for r = 1, cells.number_of_rows do
                            for c = 1, cells.number_of_cols do
                                if cells[r][c] then
                                    cells[r][c]:set{ opacity=0, y_rotation={-90,0,0} }
                                end
                            end
                        end
                    end
                end,
                animate_in = function(instance,_ENV)
                    local animating = false
                    return function(old_function,self)
                        
                        if animating then return end
                        animating = true
                        
                        for r = 1, cells.number_of_rows do
                            for c = 1, cells.number_of_cols do
                                if cells[r][c] then
                                    cells[r][c]:set{ opacity=0, y_rotation={-90,0,0} }
                                end
                            end
                        end
                        for r = 1, cells.number_of_rows do
                            for c = 1, cells.number_of_cols do
                                if cells[r][c] then
                                    dolater(
                                        (r+c-2)*cascade_delay,
                                        cells[r][c].animate,
                                        cells[r][c],
                                        {
                                            duration   = individual_duration,
                                            opacity    = 255,
                                            y_rotation = 0,
                                            on_completed = 
                                                (r == cells.number_of_rows) and 
                                                (c == cells.number_of_cols) and 
                                                function() animating = false end
                                        }
                                    )
                                end
                            end
                        end
                        local r = cells.number_of_rows
                        local c = cells.number_of_cols
                        dolater(
                            (r+c-2)*cascade_delay,
                            cells[r][c].animate,
                            cells[r][c],
                            {
                                duration   = individual_duration,
                                opacity    = 255,
                                y_rotation = 0,
                                on_completed = function() animating = false end
                            }
                        )
                    end
                end,
            },
        },
        private = {
            widths_of_cols = function(instance,_ENV)
                return function(cell,r,c)
                    if cell.w  >= (col_widths[c] or 0) then 
                        col_widths[c] = cell.w
                    end
                end
            end,
            heights_of_rows = function(instance,_ENV)
                return function(cell,r,c)
                    if cell.h  >= (row_heights[r] or 0) then 
                        row_heights[r] = cell.h
                    end
                end
            end,
            find_w = function(instance,_ENV)
                return function(cell,r,c)
                    
                    if w < cell.x + cell.w - cell.anchor_point[1] then 
                        w = cell.x + cell.w - cell.anchor_point[1]
                    end
                end
            end,
            find_h = function(instance,_ENV)
                return function(cell,r,c)
                    
                    if h < cell.y + cell.h - cell.anchor_point[2] then 
                        h = cell.y + cell.h - cell.anchor_point[2]
                    end
                end
            end,
            assign_neighbors = function(instance,_ENV)
                return function(cell,r,c,cells)
                    local neighbors = items[cell].neighbors
                    neighbors.up = nil
                    neighbors.down = nil
                    neighbors.left = nil
                    neighbors.right = nil
                    
                    if r ~= 1 then
                        neighbors.up = cells[r-1][c]
                    end
                    if r ~= instance.number_of_rows then
                        neighbors.down = cells[r+1][c]
                    end
                    
                    if c ~= 1 then
                        neighbors.left = cells[r][c-1]
                    end
                    if c ~= instance.number_of_cols then
                        neighbors.right = cells[r][c+1]
                    end
                end
            end,
            position_cells = function(instance,_ENV)
                return function(...)
                    mesg("LayoutManager",0,"LayoutManager:position_cells()")
                    if cell_w then
                        for i = 1, cells.number_of_rows do
                            for j = 1, cells.number_of_cols do
                                cells[i][j].x = (j-1) > 0 and ((horizontal_spacing + cell_w) * (j-1)) or 0
                            end
                        end
                    else
                        for i = 1, cells.number_of_rows do
                            for j = 1, cells.number_of_cols do
                                cells[i][j].x = (j-1) > 0 and 
                                    (cells[i][j-1].x + col_widths[j-1] + horizontal_spacing) or 0
                            end
                        end
                    end
                    if cell_h then
                        for i = 1, cells.number_of_rows do
                            for j = 1, cells.number_of_cols do
                                cells[i][j].y = (i-1) > 0 and ((vertical_spacing + cell_h) * (i-1)) or 0
                            end
                        end
                    else
                        for i = 1, cells.number_of_rows do
                            for j = 1, cells.number_of_cols do
                                --print("y",i,j)
                                cells[i][j].y = (i-1) > 0 and 
                                    (cells[i-1][j].y + row_heights[i-1] + vertical_spacing) or 0
                            end
                        end
                    end---[[
                    --print("b")
                    local ap = {}
                    
                    for i = 1, cells.number_of_rows do
                        for j = 1, cells.number_of_cols do
                            ap[1] = 
                                horizontal_alignment == "right"  and cells[i][j].w   or
                                horizontal_alignment == "center" and cells[i][j].w/2 or
                                horizontal_alignment == "left"   and 0
                            ap[2] = 
                                vertical_alignment == "bottom" and cells[i][j].h   or
                                vertical_alignment == "center" and cells[i][j].h/2 or
                                vertical_alignment == "top"    and 0
                            
                            cells[i][j]:move_by(
                                horizontal_alignment == "right"  and (cell_w or col_widths[j])   or
                                horizontal_alignment == "center" and (cell_w or col_widths[j])/2 or
                                horizontal_alignment == "left"   and 0,
                                
                                vertical_alignment == "bottom" and (cell_h or row_heights[i])   or
                                vertical_alignment == "center" and (cell_h or row_heights[i])/2 or
                                vertical_alignment == "top"    and 0
                            )
                            cells[i][j].anchor_point = ap
                        end
                    end--]]
                end
            end,
            for_each = function(instance,_ENV)
                return function(cells,f)
                    for r = 1, cells.number_of_rows do
                        for c = 1, cells.number_of_cols do
                            if cells[r][c] then f(cells[r][c],r,c,cells) end
                        end
                    end
                end
            end,
            update = function(instance,_ENV)
                return function()
                    --print("updating")
                    
                    --if updating then return end
                    --updating = true
                    
                    --print("werd")
                    --print("update")
                    if  new_placeholder then
                        local v = new_placeholder
                        new_placeholder = false
                        if v.parent then v:unparent() end
                        --print("add",v.gid)
                        add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(placeholders) do
                            obj.source = v
                        end
                        
                        if placeholder then placeholder:unparent() end
                        find_col_widths = true
                        find_col_heights = true
                        reposition = true
                        find_width = true
                        find_height = true
                        
                        placeholder = v 
                    end
                    if  new_cells then
                        --print(instance.number_of_rows)
                        --print(instance.number_of_cols)
                        --dumptable(new_cells)
                        cells:set(new_cells)
                        focused_child = cells[1][1] 
                        --focused_child:grab_key_focus()
                        find_col_widths = true
                        find_col_heights = true
                        reposition = true
                        find_width = true
                        find_height = true
                        reassign_neighbors = true
                        new_cells = false
                    end
                    if  find_col_widths then
                        find_col_widths = false
                        col_widths  = {}
                        for_each(cells,widths_of_cols) 
                    end
                    if  find_col_heights then
                        find_col_heights = false
                        row_heights = {}
                        for_each(cells,heights_of_rows) 
                    end
                    if  reposition then
                        reposition = false
                        position_cells()
                    end
                    if  find_width then
                        find_width = false
                        w = 0
                        for_each(cells,find_w) 
                        instance.w = w
                    end
                    if  find_height then
                        find_height = false
                        h = 0
                        for_each(cells,find_h) 
                        instance.h = h
                    end
                    if  reassign_neighbors then
                        reassign_neighbors = false
                        for_each(cells,assign_neighbors) 
                    end
                    
                    if children_want_focus and focused_child == nil and 
                        self.number_of_rows > 0 and self.number_of_cols > 0 then 
                        focused_child = self[1][1] 
                        focused_child:grab_key_focus()
                    end
                    
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance,_ENV = Widget()
            
            individual_duration = 100
            cascade_delay       = 100
            
            instance.w = 0
            instance.h = 0
            
            function instance:on_key_focus_in()    
                if children_want_focus then
                    if focus_to_index then
                        
                        local obj = cells[
                            focus_to_index[1] ][
                            focus_to_index[2] ]
                        
                        dolater(
                            obj.grab_key_focus,
                            obj
                        )
                    elseif focused_child then 
                        dolater(
                            focused_child.grab_key_focus,
                            focused_child
                        )
                    end
                end
                
            end 
            
            local getter, setter
            on_entries_changed = function() end
            node_constructor = false
            cells = GridManager{  
                
                node_constructor=function(obj)
                    mesg("LayoutManager",0,"LayoutManager new cell ",obj)
                    if node_constructor then
                        
                        obj = node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil or obj == false then  
                            
                            obj = Widget_Clone{source=placeholder}
                            placeholders[obj] = true
                            
                        elseif type(obj) == "table" and obj.type then 
                            
                            obj = _ENV[obj.type](obj)
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    if cell_w then obj.w = cell_w end
                    if cell_h then obj.h = cell_h end
                    local n
                    add(instance,obj)
                    
                    items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                n = next_neighbor(instance,items,obj,"up")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                n = next_neighbor(instance,items,obj,"down")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                n = next_neighbor(instance,items,obj,"left")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                n = next_neighbor(instance,items,obj,"right")
                                if  n then 
                                    n:grab_key_focus()
                                    focused_child = n 
                                    return true
                                end 
                            end),
                        }
                        --[[
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                if  items[obj].neighbors.up then 
                                    items[obj].neighbors.up:grab_key_focus()
                                    focused_child = items[obj].neighbors.up 
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                if  items[obj].neighbors.down then 
                                    items[obj].neighbors.down:grab_key_focus() 
                                    focused_child = items[obj].neighbors.down
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                if  items[obj].neighbors.left then 
                                    items[obj].neighbors.left:grab_key_focus() 
                                    focused_child = items[obj].neighbors.left
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                if  items[obj].neighbors.right then 
                                    items[obj].neighbors.right:grab_key_focus() 
                                    focused_child = items[obj].neighbors.right
                                end 
                            end),
                        }
                        --]]
                    }
                    if obj.subscribe_to then
                        obj:subscribe_to(
                            {"h","w","width","height","size"},
                            function(...)
                                if in_on_entries then return end
                                --print("width_changed",obj.w,obj.h)
                                find_col_widths = true
                                find_col_heights = true
                                reposition = true
                                find_width = true
                                find_height = true
                                cells:on_entries_changed()
                            end
                        )
                    end
                    
                    return obj
                end,
                
                node_destructor=function(obj,r,c) 
                    if obj == focused_child then 
                        local neighbors = items[obj].neighbors
                        focused_child = 
                            neighbors.up or 
                            neighbors.left or
                            neighbors.right or
                            neighbors.down 
                    end
                    for _,f in pairs(items[obj].key_functions) do f() end
                    items[obj] = nil
                    obj:unparent() 
                    placeholders[obj] = nil
                end,
                
                on_entries_changed = function(self)
                    
                    find_col_widths = true
                    find_col_heights = true
                    reposition = true
                    find_width = true
                    find_height = true
                    reassign_neighbors = true
                    if not is_setting then
                        
                        on_entries_changed(self)
                        call_update()
                        
                    end
                    --[=[
                    if in_on_entries then return end
                    in_on_entries = true
                    if children_want_focus and focused_child == nil and 
                        self.number_of_rows > 0 and self.number_of_cols > 0 then 
                        focused_child = self[1][1] 
                        focused_child:grab_key_focus()
                    end
                    print("me")
                    update()
                    --[[
                    col_widths  = {}
                    row_heights = {}
                    w = 0
                    h = 0
                    for_each(self,widths_of_cols)
                    for_each(self,heights_of_rows)
                    for_each(self,position_cell)
                    for_each(self,find_w)
                    for_each(self,find_h)
                    --set_size(self)
                    instance.size = {w,h}
                    for_each(self,assign_neighbors)
                    --]]
                    if on_entries_changed then
                        on_entries_changed(self)
                    end
                    in_on_entries = false
                    --]=]
                end
            }
            new_cells = false
            w = 0
            h = 0
            cell_w = false
            cell_h = false
            horizontal_spacing = 20
            vertical_spacing = 20
            number_of_rows_set = false
            number_of_cols_set = false
            items = {}
            --public attributes, set to false if there is no default
            col_widths  = {}
            row_heights = {}
            vertical_alignment   = "center"
            horizontal_alignment   = "center"
            placeholders   = {}
            children_want_focus   = true
            in_on_entries   = false
            focused_child   = false
            on_entries_changed   = function() end
            placeholder = nil
            new_placeholder = Rectangle{w=200,h=200,color="ff0000"}
            
            instance.reactive = true
            
            
            setup_object(self,instance,_ENV)
            
            updating = true
            instance:set(parameters)
            updating = false
            --[[
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,)
            end
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,)
            end
            --]]
            return instance, _ENV
            
        end
    }
)
external.ListManager   = ListManager
external.LayoutManager = LayoutManager
