
LAYOUTMANAGER = true

local LIST_default_parameters = {spacing = 20, direction = "vertical"}

--[[
ListManager = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ListManager",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,LIST_default_parameters) 
    
    ----------------------------------------------------------------------------
	--The ListManager Object inherits from Widget
	
	local instance, env = Widget( parameters )
    
    local placeholder = Widget_Rectangle{w=200,h=200,color="ff0000"}
    env.add(instance,placeholder)
    placeholder:hide()
    local placeholders = {}
    local node_constructor
	local cells, direction
    local cell_w, cell_h
    local spacing = 0
    local w = 0
    local h = 0
    local number_of_rows_set = false
    local number_of_cols_set = false
    
    local items = {}
    
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
    
    local find_w = function(cell,i)
        
        if w < cell.x + cell.w - cell.anchor_point[1] then 
            w = cell.x + cell.w - cell.anchor_point[1]
        end
    end
    local find_h = function(cell,i)
        
        if h < cell.y + cell.h - cell.anchor_point[2] then 
            h = cell.y + cell.h - cell.anchor_point[2]
        end
    end
    
    local assign_neighbors = function(cell,i,cells)
        
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
	override_property(instance,"placeholder",
		function(oldf)   return placeholder     end,
		function(oldf,self,v)   
            env.add(instance,v)
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
	)
    local position_cells = function(self)
        
        if direction == "horizontal" then
            for i = 1, self.length do
                self[i].x =  (i-1) > 0 and (self[i-1].x + self[i-1].w + spacing) or 0
            end
        end
        
        if direction == "vertical" then
            for i = 1, self.length do
                self[i].y =  (i-1) > 0 and (self[i-1].y + self[i-1].h + spacing) or 0
                print("y",i,self[i].y,(i-1) > 0 and self[i-1].h)
            end
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
                horizontal_alignment == "right"    and max_w        or
                horizontal_alignment == "center"   and max_w/2      or
                horizontal_alignment == "left"     and 0,
                
                direction            ~= "horizontal" and self[i].h/2  or 
                horizontal_alignment == "bottom"     and max_h        or
                horizontal_alignment == "center"     and max_h/2      or
                horizontal_alignment == "top"        and 0
            )
            
        end
        
    end
    
    local for_each = function(self,f)
        for i = 1, self.length do
            if self[i] then f(self[i],i,self) end
        end
    end
    
    local set_size = function(self)
        local last_cell = self[self.length]
        if last_cell then
            instance.w = last_cell.x + max_w - last_cell.anchor_point[1]
            instance.h = last_cell.y + max_h - last_cell.anchor_point[2]
        end
    end
    ----------------------------------------------------------------------------
    
	override_property(instance,"widget_type",
		function() return "ListManager" end, nil
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
		function(oldf,self,v)   
            if v == "left" or v == "right" or v == "center" then
                horizontal_alignment = v 
            else
                error("expected 'left' 'right' or 'center'. Received "..v,2)
            end
            
        end
	)
	override_property(instance,"vertical_alignment",
		function(oldf)   return vertical_alignment     end,
		function(oldf,self,v)   
            
            if v == "top" or v == "bottom" or v == "center" then
                vertical_alignment = v 
            else
                error("expected 'top' 'bottom' or 'center'. Received "..v,2)
            end
        end
	)
    
    instance:subscribe_to( 
        {
            "vertical_alignment","horizontal_alignment",
            "spacing","cell_w", "cell_h", "direction",
        },
        function() 
            --for_each(cells,position_cell) 
            position_cells(cells)
            --set_size(cells)
            w = 0
            for_each(cells,find_w)
            h = 0
            for_each(cells,find_h)
            --set_size(self)
            instance.size = {w,h}
        end
    )
    
    instance:subscribe_to( "direction",
        function() 
            for_each(cells,assign_neighbors) 
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
            on_entries_changed = v 
        end
	)
    
    ----------------------------------------------------------------------------
    cells = ArrayManager{  
        
        node_constructor=function(obj)
            if node_constructor then
                
                obj = node_constructor(obj)
                
            else -- default node_constructor
                if obj == nil then  
                    
                    obj = Widget_Clone{source=placeholder}
                    placeholders[obj] = true
                
                elseif type(obj) == "table" and obj.type then 
                    
                    obj = _G[obj.type](obj)
                    
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                    
                    error("Must be a UIElement or nil. Received "..obj,2) 
                
                elseif obj.parent then  obj:unparent()  end
            end
            env.add(instance,obj)
            
            items[obj] = {
                neighbors = { },
                key_functions = {
                    up    = obj:add_key_handler(keys.Up,   function() 
                        if  items[obj].neighbors.up then 
                            items[obj].neighbors.up:grab_key_focus() 
                        end 
                    end),
                    down  = obj:add_key_handler(keys.Down, function() 
                        if  items[obj].neighbors.down then 
                            items[obj].neighbors.down:grab_key_focus() 
                        end 
                    end),
                    left  = obj:add_key_handler(keys.Left, function() 
                        if  items[obj].neighbors.left then 
                            items[obj].neighbors.left:grab_key_focus() 
                        end 
                    end),
                    right = obj:add_key_handler(keys.Right,function() 
                        if  items[obj].neighbors.right then 
                            items[obj].neighbors.right:grab_key_focus() 
                        end 
                    end),
                }
            }
            if obj.subscribe_to then
                obj:subscribe_to(
                    {"h","w","width","height","size"},
                    function()
                        print("sz changed",obj.gid,obj.w,obj.h)
                        if cells.on_entries_changed then
                            print("o_e_c")
                            cells:on_entries_changed()
                        end
                    end
                )
            end
            
            return obj
        end,
        
        node_destructor=function(obj) 
            for _,f in pairs(items[obj].key_functions) do f() end
            items[obj] = nil
            obj:unparent() 
            placeholders[obj] = nil
        end,
        
        on_entries_changed = function(self)
            
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
    
    
	----------------------------------------------------------------------------
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
            t.length       = instance.length
            t.vertical_alignment   = instance.vertical_alignment
            t.horizontal_alignment = instance.horizontal_alignment
            t.direction = instance.direction
            t.spacing   = instance.spacing
            t.cell_h = instance.cell_h
            t.cell_w = instance.cell_w
            t.cells = {}
            for_each(cells,function(obj,i)
                
                if not placeholders[obj] then
                    t.cells[i] = obj.attributes
                end
            end)
            
            t.type = "ListManager"
            
            return t
        end
    )
    ----------------------------------------------------------------------------
    
    local function set_and_nil(t,k)
        
        if t[k] == nil then return end
        instance[k] = t[k]
        t[k]     = nil
        
    end
    
	override_function(instance,"set", function(old_function, obj, t )
		--need to force the setting of number_of_cols/rows before cells
        set_and_nil(t,"direction")
        set_and_nil(t,"length")
        set_and_nil(t,"cells")
		old_function(obj, t)
		
	end)
    
	instance:set(parameters)
	
	return instance
    
end

--]]












ListManager = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            dumptable(p)
            return self:declare():set(p or {})
            
        end,
        
        public = {
            properties = {
                widget_type = function(instance,env)
                    return function() return "ListManager" end
                end,
                placeholder = function(instance,env)
                    return function(oldf) return env.placeholder     end,
                    function(oldf,self,v) 
                        env.add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(env.placeholders) do
                            obj.source = v
                        end
                        
                        env.placeholder:unparent()
                        if v.subscribe_to then
                            v:subscribe_to(
                                {"h","w","width","height","size"},
                                function(...)
                                    if env.in_on_entries then return end
                                    
                                    env.cells:on_entries_changed()
                                    
                                end
                            )
                        end
                        
                        env.placeholder = v 
                        
                        env.cells:on_entries_changed()
                    end
                end,
                length = function(instance,env)
                    return function(oldf) return env.cells.length     end,
                    function(oldf,self,v)        env.cells.length = v end
                end,
                cell_w = function(instance,env)
                    return function(oldf) return env.cell_w     end,
                    function(oldf,self,v) 
                        env.cell_w = v 
                        env.max_w  = v
                        env.for_each(env.cells,function(cell) cell.w = cell_w end)
                        env.reposition = true
                    end
                end,
                cell_h = function(instance,env)
                    return function(oldf) return env.cell_h     end,
                    function(oldf,self,v) 
                        env.cell_h = v 
                        env.max_h  = v
                        env.for_each(env.cells,function(cell) cell.h = cell_h end)
                        env.reposition = true
                    end
                end,
                direction = function(instance,env)
                    return function(oldf) return env.direction     end,
                    function(oldf,self,v)        
                        env.direction = v 
                        env.reposition = true
                        env.reassign_neighbors = true
                    end
                end,
                spacing = function(instance,env)
                    return function(oldf) return env.spacing     end,
                    function(oldf,self,v)        
                        env.spacing = v
                        env.reposition = true
                     end
                end,
                horizontal_alignment = function(instance,env)
                    return function(oldf) return env.horizontal_alignment     end,
                    function(oldf,self,v) 
                        if v == "left" or v == "right" or v == "center" then
                            env.horizontal_alignment = v 
                            env.reposition = true
                        else
                            error("expected 'left' 'right' or 'center'. Received "..v,2)
                        end
                    end
                end,
                vertical_alignment = function(instance,env)
                    return function(oldf) return env.vertical_alignment     end,
                    function(oldf,self,v) 
                        if v == "top" or v == "bottom" or v == "center" then
                            env.vertical_alignment = v 
                            env.reposition = true
                        else
                            error("expected 'top' 'bottom' or 'center'. Received "..v,2)
                        end
                    end
                end,
                node_constructor = function(instance,env)
                    return function(oldf) return env.node_constructor     end,
                    function(oldf,self,v) 
                        if type(v) ~= "function" then
                            error("Expected function. Received "..type(v),2)
                        end
                        env.node_constructor = v
                    end
                end,
                on_entries_changed = function(instance,env)
                    return function(oldf) return env.on_entries_changed     end,
                    function(oldf,self,v) 
                        if type(v) ~= "function" then
                            error("Expected function. Received "..type(v),2)
                        end
                        env.on_entries_changed = v
                    end
                end,
                
                
                
                
                cells = function(instance,env)
                    return function(oldf) return env.cells     end,
                    function(oldf,self,v)   
                        env.new_cells = v  
                        --print("herp")
                        dumptable(v)
                    end
                end,

                attributes = function(instance,env)
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
                        env.for_each(env.cells,function(obj,i)
                            
                            if not env.placeholders[obj] then
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
            widths_of_cols = function(instance,env)
                return function(cell)
                    if cell.w  > (env.max_w or 0) then 
                        env.max_w = cell.w 
                    end
                end
            end,
            heights_of_rows = function(instance,env)
                return function(cell)
                    if cell.h  > (env.max_h or 0) then 
                        env.max_h = cell.h 
                    end
                end
            end,
            find_w = function(instance,env)
                return function(cell,i)
                    
                    if env.w < cell.x + cell.w - cell.anchor_point[1] then 
                        env.w = cell.x + cell.w - cell.anchor_point[1]
                    end
                end
            end,
            find_h = function(instance,env)
                return function(cell,i)
                    
                    if env.h < cell.y + cell.h - cell.anchor_point[2] then 
                        env.h = cell.y + cell.h - cell.anchor_point[2]
                    end
                end
            end,
            assign_neighbors = function(instance,env)
                return function(cell,i,cells)
        
                    env.items[cell].neighbors.up = nil
                    env.items[cell].neighbors.down = nil
                    env.items[cell].neighbors.left = nil
                    env.items[cell].neighbors.right = nil
                    
                    if i ~= 1 then
                        if env.direction == "vertical" then
                            env.items[cell].neighbors.up = cells[i-1]
                        elseif env.direction == "horizontal" then
                            env.items[cell].neighbors.left = cells[i-1]
                        else
                            error("direction is invalid",2)
                        end
                    end
                    if i ~= cells.length then
                        if env.direction == "vertical" then
                            env.items[cell].neighbors.down = cells[i+1]
                        elseif env.direction == "horizontal" then
                            env.items[cell].neighbors.right = cells[i+1]
                        else
                            error("direction is invalid",2)
                        end
                    end
                end
            end,
            position_cells = function(instance,env)
                return function(self)
                    if env.direction == "horizontal" then
                        for i = 1, self.length do
                            self[i].x =  (i-1) > 0 and (self[i-1].x + self[i-1].w + env.spacing) or 0
                            self[i].y =  0
                        end
                    elseif env.direction == "vertical" then
                        for i = 1, self.length do
                            self[i].x =  0
                            self[i].y =  (i-1) > 0 and (self[i-1].y + self[i-1].h + env.spacing) or 0
                        end
                    else
                        error("Invalid direction: "..env.direction,2)
                    end
                    
                    local ap = {}
                    for i = 1, self.length do
                        
                        ap[1] = 
                            env.direction            ~= "vertical" and self[i].w/2 or 
                            env.horizontal_alignment == "right"    and self[i].w   or
                            env.horizontal_alignment == "center"   and self[i].w/2 or
                            env.horizontal_alignment == "left"     and 0
                        
                        ap[2] = 
                            env.direction            ~= "horizontal" and self[i].h/2 or 
                            env.horizontal_alignment == "bottom"     and self[i].h   or
                            env.horizontal_alignment == "center"     and self[i].h/2 or
                            env.horizontal_alignment == "top"        and 0
                        
                        self[i].anchor_point = ap
                        
                        self[i]:move_by(
                            env.direction            ~= "vertical" and self[i].w/2  or 
                            env.horizontal_alignment == "right"    and env.max_w    or
                            env.horizontal_alignment == "center"   and env.max_w/2  or
                            env.horizontal_alignment == "left"     and 0,
                            
                            env.direction            ~= "horizontal" and self[i].h/2  or 
                            env.horizontal_alignment == "bottom"     and env.max_h    or
                            env.horizontal_alignment == "center"     and env.max_h/2  or
                            env.horizontal_alignment == "top"        and 0
                        )
                        
                    end
                    
                end
            end,
            for_each = function(instance,env)
                return function(self,f)
                     for i = 1, self.length do
                        if self[i] then f(self[i],i,self) end
                    end
                end
            end,

            update = function(instance,env)
                return function()
                    
                    if  env.new_placeholder then
                        local v = env.new_placeholder
                        env.new_placeholder = false
                        if v.parent then v:unparent() end
                        --print("add",v.gid)
                        env.add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(env.placeholders) do
                            obj.source = v
                        end
                        
                        if env.placeholder then env.placeholder:unparent() end
                        
                        env.placeholder = v 
                    end
                    if  env.new_cells then
                        
                        env.cells.length = #env.new_cells
                        env.cells:set(env.new_cells) 
                        
                        focused_child = env.cells[1]
                        focused_child:grab_key_focus()
                        
                        env.find_col_widths    = true
                        env.find_col_heights   = true
                        env.reposition         = true
                        env.find_width         = true
                        env.find_height        = true
                        env.reassign_neighbors = true
                        
                        env.new_cells = false
                    end
                    if  env.find_col_widths then
                        env.find_col_widths = false
                        env.max_w  = 0
                        env.for_each(env.cells,env.widths_of_cols) 
                    end
                    --print(#env.col_widths,instance.number_of_cols)
                    if  env.find_col_heights then
                        env.find_col_heights = false
                        env.max_h  = 0
                        env.for_each(env.cells,env.heights_of_rows) 
                    end
                    --print(#env.row_heights,instance.number_of_rows)
                    if  env.reposition then
                        env.reposition = false
                        env.position_cells(env.cells)
                        env.find_width  = true
                        env.find_height = true
                    end
                    --print("a")
                    if  env.find_width then
                        env.find_width = false
                        env.w = 0
                        env.for_each(env.cells,env.find_w) 
                        
                        instance.w = env.w
                    end
                    if  env.find_height then
                        env.find_height = false
                        env.h = 0
                        env.for_each(env.cells,env.find_h) 
                        
                        instance.h = env.h
                    end
                    if  env.reassign_neighbors then
                        env.reassign_neighbors = false
                        env.for_each(env.cells,env.assign_neighbors) 
                    end
                    
                    if env.children_want_focus and env.focused_child == nil and 
                        self.length > 0 then 
                        env.focused_child = self[1]
                        env.focused_child:grab_key_focus()
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            function instance:on_key_focus_in()    
                if env.children_want_focus and env.focused_child then 
                    dolater(function()
                        env.focused_child:grab_key_focus() 
                    end)
                end
                
            end 
            
            local getter, setter
            
            env.node_constructor = false
            env.cells = ArrayManager{  
                
                node_constructor=function(obj)
                    if env.node_constructor then
                        
                        obj = env.node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil or obj == false then  
                            
                            obj = Widget_Clone{source=env.placeholder}
                            env.placeholders[obj] = true
                            
                        elseif type(obj) == "table" and obj.type then 
                            
                            obj = _G[obj.type](obj)
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    --if env.cell_w then obj.w = env.cell_w end    TODO check these
                    --if env.cell_h then obj.h = env.cell_h end
                    
                    
                    
                    env.add(instance,obj)
                    
                    
                    env.items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                if  env.items[obj].neighbors.up then 
                                    env.items[obj].neighbors.up:grab_key_focus()
                                    env.focused_child = env.items[obj].neighbors.up 
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                if  env.items[obj].neighbors.down then 
                                    env.items[obj].neighbors.down:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.down
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                if  env.items[obj].neighbors.left then 
                                    env.items[obj].neighbors.left:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.left
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                if  env.items[obj].neighbors.right then 
                                    env.items[obj].neighbors.right:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.right
                                end 
                            end),
                        }
                    }
                    
                    if obj.subscribe_to then
                        obj:subscribe_to(
                            {"h","w","width","height","size"},
                            function(...)
                                if env.in_on_entries then return end
                                --print("width_changed",obj.w,obj.h)
                                ---[[
                                env.find_col_widths = true
                                env.find_col_heights = true
                                env.reposition = true
                                env.find_width = true
                                env.find_height = true
                                --]]
                                if env.cells.on_entries_changed then env.cells:on_entries_changed() end
                            end
                        )
                    end
                    
                    return obj
                end,
                
                node_destructor=function(obj) 
                    if obj == env.focused_child then 
                        local neighbors = env.items[obj].neighbors
                        env.focused_child = 
                            neighbors.up or 
                            neighbors.left or
                            neighbors.right or
                            neighbors.down 
                    end
                    for _,f in pairs(env.items[obj].key_functions) do f() end
                    env.items[obj] = nil
                    obj:unparent() 
                    env.placeholders[obj] = nil
                    
                end,
                
                on_entries_changed = function(self)
                    
                    if not env.is_setting then
                        env.call_update()
                        env.on_entries_changed(self)
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
            env.new_cells = false
            env.w = 0
            env.h = 0
            env.cell_w = false
            env.cell_h = false
            env.spacing = 20
            env.items = {}
            --public attributes, set to false if there is no default
            env.max_w = 0
            env.max_h = 0
            env.direction   = "vertical"
            env.vertical_alignment   = "center"
            env.horizontal_alignment = "center"
            env.placeholders   = {}
            env.children_want_focus   = true
            env.in_on_entries   = false
            env.focused_child   = false
            env.on_entries_changed   = false
            env.placeholder = nil
            env.new_placeholder = Rectangle{w=200,h=200,color="ff0000"}
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            instance.reactive = true
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            --[[
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            env.updating = true
            instance:set(parameters)
            env.updating = false
            return instance, env
            
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
                widget_type = function(instance,env)
                    return function() return "LayoutManager" end
                end,
                number_of_rows = function(instance,env)
                    return function(oldf) return env.cells.number_of_rows     end,
                    function(oldf,self,v) 
                         
                        env.cells.number_of_rows = v 
                        
                        env.find_col_widths    = true
                        env.find_col_heights   = true
                        env.reposition         = true
                        env.find_width         = true
                        env.find_height        = true
                        env.reassign_neighbors = true
                    end
                end,
                on_entries_changed = function(instance,env)
                    return function(oldf) return env.on_entries_changed     end,
                    function(oldf,self,v) 
                         
                        env.on_entries_changed = v 
                    end
                end,
                number_of_cols = function(instance,env)
                    return function(oldf) return env.cells.number_of_cols     end,
                    function(oldf,self,v) 
                        
                        env.cells.number_of_cols = v 
                        
                        env.find_col_widths    = true
                        env.find_col_heights   = true
                        env.reposition         = true
                        env.find_width         = true
                        env.find_height        = true
                        env.reassign_neighbors = true
                    end
                end,
                cell_w = function(instance,env)
                    return function(oldf) return env.cell_w     end,
                    function(oldf,self,v) 
                        env.cell_w = v 
                        env.for_each(env.cells,function(cell) cell.w = v end)
                        env.find_col_widths    = true
                        env.find_col_heights   = true
                        env.reposition         = true
                        env.find_width         = true
                        env.find_height        = true
                    end
                end,
                cell_h = function(instance,env)
                    return function(oldf) return env.cell_h     end,
                    function(oldf,self,v) 
                        env.cell_h = v 
                        env.for_each(env.cells,function(cell) cell.h = v print(cell.h) end)
                        env.find_col_widths    = true
                        env.find_col_heights   = true
                        env.reposition         = true
                        env.find_width         = true
                        env.find_height        = true
                    end
                end,
                horizontal_spacing = function(instance,env)
                    return function(oldf) return env.horizontal_spacing     end,
                    function(oldf,self,v) 
                        env.horizontal_spacing = v 
                        env.reposition = true
                    end
                end,
                vertical_spacing = function(instance,env)
                    return function(oldf) return env.vertical_spacing     end,
                    function(oldf,self,v) 
                        env.vertical_spacing = v
                        env.reposition = true
                    end
                end,
                horizontal_alignment = function(instance,env)
                    return function(oldf) return env.horizontal_alignment     end,
                    function(oldf,self,v) 
                        env.horizontal_alignment = v
                        env.reposition = true
                    end
                end,
                vertical_alignment = function(instance,env)
                    return function(oldf) return env.vertical_alignment     end,
                    function(oldf,self,v) 
                        env.vertical_alignment = v
                        env.reposition = true
                    end
                end,
                placeholder = function(instance,env)
                    return function(oldf) return env.placeholder     end,
                    function(oldf,self,v) 
                        
                        if env.placeholder ~= v then
                            env.new_placeholder = v    
                        end
                    end
                end,
                cells = function(instance,env)
                    return function(oldf) return env.cells     end,
                    function(oldf,self,v)   
                        env.new_cells = v  
                        --print("herp")
                        dumptable(v)
                        --print("dim",env.cells.number_of_rows,env.cells.number_of_cols)
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf,self)
                        local t = oldf(self)
                        
                        t.number_of_cols       = instance.number_of_cols
                        t.number_of_rows       = instance.number_of_rows
                        t.vertical_alignment   = instance.vertical_alignment
                        t.horizontal_alignment = instance.horizontal_alignment
                        t.vertical_spacing     = instance.vertical_spacing
                        t.horizontal_spacing   = instance.horizontal_spacing
                        t.cell_h = instance.cell_h
                        t.cell_w = instance.cell_w
                        t.cells = {}
                        env.for_each(env.cells,function(obj,r,c)
                            if not t.cells[r] then
                                t.cells[r] = {}
                            end
                            
                            if not env.placeholders[obj] then
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
            },
        },
        private = {
            widths_of_cols = function(instance,env)
                return function(cell,r,c)
                    if cell.w  >= (env.col_widths[c] or 0) then 
                        env.col_widths[c] = cell.w
                    end
                end
            end,
            heights_of_rows = function(instance,env)
                return function(cell,r,c)
                    if cell.h  >= (env.row_heights[r] or 0) then 
                        env.row_heights[r] = cell.h
                    end
                end
            end,
            find_w = function(instance,env)
                return function(cell,r,c)
                    
                    if env.w < cell.x + cell.w - cell.anchor_point[1] then 
                        env.w = cell.x + cell.w - cell.anchor_point[1]
                    end
                end
            end,
            find_h = function(instance,env)
                return function(cell,r,c)
                    
                    if env.h < cell.y + cell.h - cell.anchor_point[2] then 
                        env.h = cell.y + cell.h - cell.anchor_point[2]
                    end
                end
            end,
            assign_neighbors = function(instance,env)
                return function(cell,r,c,cells)
                    local neighbors = env.items[cell].neighbors
                    neighbors.up = nil
                    neighbors.down = nil
                    neighbors.left = nil
                    neighbors.right = nil
                    
                    if r ~= 1 then
                        neighbors.up = env.cells[r-1][c]
                    end
                    if r ~= instance.number_of_rows then
                        neighbors.down = env.cells[r+1][c]
                    end
                    
                    if c ~= 1 then
                        neighbors.left = env.cells[r][c-1]
                    end
                    if c ~= instance.number_of_cols then
                        neighbors.right = env.cells[r][c+1]
                    end
                end
            end,
            position_cells = function(instance,env)
                return function(...)
                    print(env.cells)
                    if env.cell_w then
                        for i = 1, env.cells.number_of_rows do
                            for j = 1, env.cells.number_of_cols do
                                env.cells[i][j].x = (env.horizontal_spacing + env.cell_w) * (i-1)
                            end
                        end
                    else
                        for i = 1, env.cells.number_of_rows do
                            for j = 1, env.cells.number_of_cols do
                                env.cells[i][j].x = (j-1) > 0 and 
                                    (env.cells[i][j-1].x + env.col_widths[j-1] + env.horizontal_spacing) or 0
                            end
                        end
                    end
                    if env.cell_h then
                        for i = 1, env.cells.number_of_rows do
                            for j = 1, env.cells.number_of_cols do
                                env.cells[i][j].y = (env.vertical_spacing + env.cell_h) * (i-1)
                            end
                        end
                    else
                        for i = 1, env.cells.number_of_rows do
                            for j = 1, env.cells.number_of_cols do
                                --print("y",i,j)
                                env.cells[i][j].y = (i-1) > 0 and 
                                    (env.cells[i-1][j].y + env.row_heights[i-1] + env.vertical_spacing) or 0
                            end
                        end
                    end---[[
                    --print("b")
                    local ap = {}
                    
                    for i = 1, env.cells.number_of_rows do
                        for j = 1, env.cells.number_of_cols do
                            ap[1] = 
                                env.horizontal_alignment == "right"  and env.cells[i][j].w   or
                                env.horizontal_alignment == "center" and env.cells[i][j].w/2 or
                                env.horizontal_alignment == "left"   and 0
                            ap[2] = 
                                env.vertical_alignment == "bottom" and env.cells[i][j].h   or
                                env.vertical_alignment == "center" and env.cells[i][j].h/2 or
                                env.vertical_alignment == "top"    and 0
                            
                            env.cells[i][j]:move_by(
                                env.horizontal_alignment == "right"  and (env.cell_w or env.col_widths[j])   or
                                env.horizontal_alignment == "center" and (env.cell_w or env.col_widths[j])/2 or
                                env.horizontal_alignment == "left"   and 0,
                                
                                env.vertical_alignment == "bottom" and (env.cell_h or env.row_heights[i])   or
                                env.vertical_alignment == "center" and (env.cell_h or env.row_heights[i])/2 or
                                env.vertical_alignment == "top"    and 0
                            )
                            env.cells[i][j].anchor_point = ap
                        end
                    end--]]
                end
            end,
            for_each = function(instance,env)
                return function(cells,f)
                    for r = 1, cells.number_of_rows do
                        for c = 1, cells.number_of_cols do
                            if env.cells[r][c] then f(env.cells[r][c],r,c,env.cells) end
                        end
                    end
                end
            end,
            update = function(instance,env)
                return function()
                    --print("updating")
                    
                    --if env.updating then return end
                    --env.updating = true
                    
                    --print("werd")
                    --print("update")
                    if  env.new_placeholder then
                        local v = env.new_placeholder
                        env.new_placeholder = false
                        if v.parent then v:unparent() end
                        --print("add",v.gid)
                        env.add(instance,v)
                        v:hide()
                        
                        for obj, _ in pairs(env.placeholders) do
                            obj.source = v
                        end
                        
                        if env.placeholder then env.placeholder:unparent() end
                        
                        env.placeholder = v 
                    end
                    if  env.new_cells then
                        print(instance.number_of_rows)
                        print(instance.number_of_cols)
                        dumptable(env.new_cells)
                        env.cells:set(env.new_cells)
                        focused_child = env.cells[1][1] 
                        focused_child:grab_key_focus()
                        env.find_col_widths = true
                        env.find_col_heights = true
                        env.reposition = true
                        env.find_width = true
                        env.find_height = true
                        env.reassign_neighbors = true
                        env.new_cells = false
                    end
                    if  env.find_col_widths then
                        env.find_col_widths = false
                        env.col_widths  = {}
                        env.for_each(env.cells,env.widths_of_cols) 
                    end
                    if  env.find_col_heights then
                        env.find_col_heights = false
                        env.row_heights = {}
                        env.for_each(env.cells,env.heights_of_rows) 
                    end
                    if  env.reposition then
                        env.reposition = false
                        env.position_cells()
                    end
                    if  env.find_width then
                        env.find_width = false
                        env.w = 0
                        env.for_each(env.cells,env.find_w) 
                        instance.w = env.w
                    end
                    if  env.find_height then
                        print("here")
                        env.find_height = false
                        env.h = 0
                        env.for_each(env.cells,env.find_h) 
                        instance.h = env.h
                    end
                    print("SZ",instance.w,instance.h)
                    if  env.reassign_neighbors then
                        env.reassign_neighbors = false
                        env.for_each(env.cells,env.assign_neighbors) 
                    end
                    
                    if env.children_want_focus and env.focused_child == nil and 
                        self.number_of_rows > 0 and self.number_of_cols > 0 then 
                        env.focused_child = self[1][1] 
                        env.focused_child:grab_key_focus()
                    end
                    
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            instance.w = 0
            instance.h = 0
            
            function instance:on_key_focus_in()    
                if children_want_focus and env.focused_child then 
                    dolater(function()
                        env.focused_child:grab_key_focus() 
                    end)
                end
                
            end 
            
            local getter, setter
            env.on_entries_changed = function() end
            env.node_constructor = false
            env.cells = GridManager{  
                
                node_constructor=function(obj)
                    print("NEW NODE", obj)
                    if env.node_constructor then
                        
                        obj = env.node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil then  
                            
                            obj = Widget_Clone{source=env.placeholder}
                            env.placeholders[obj] = true
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    if env.cell_w then obj.w = env.cell_w end
                    if env.cell_h then obj.h = env.cell_h end
                    
                    env.add(instance,obj)
                    print(#env.get_children(instance))
                    env.items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                if  env.items[obj].neighbors.up then 
                                    env.items[obj].neighbors.up:grab_key_focus()
                                    env.focused_child = env.items[obj].neighbors.up 
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                if  env.items[obj].neighbors.down then 
                                    env.items[obj].neighbors.down:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.down
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                if  env.items[obj].neighbors.left then 
                                    env.items[obj].neighbors.left:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.left
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                if  env.items[obj].neighbors.right then 
                                    env.items[obj].neighbors.right:grab_key_focus() 
                                    env.focused_child = env.items[obj].neighbors.right
                                end 
                            end),
                        }
                    }
                    if obj.subscribe_to then
                        obj:subscribe_to(
                            {"h","w","width","height","size"},
                            function(...)
                                if env.in_on_entries then return end
                                --print("width_changed",obj.w,obj.h)
                                env.find_col_widths = true
                                env.find_col_heights = true
                                env.reposition = true
                                env.find_width = true
                                env.find_height = true
                                env.cells:on_entries_changed()
                            end
                        )
                    end
                    
                    return obj
                end,
                
                node_destructor=function(obj,r,c) 
                    if obj == env.focused_child then 
                        local neighbors = env.items[obj].neighbors
                        env.focused_child = 
                            neighbors.up or 
                            neighbors.left or
                            neighbors.right or
                            neighbors.down 
                    end
                    for _,f in pairs(env.items[obj].key_functions) do f() end
                    env.items[obj] = nil
                    obj:unparent() 
                    env.placeholders[obj] = nil
                end,
                
                on_entries_changed = function(self)
                    print("hehere")
                        env.find_col_widths = true
                        env.find_col_heights = true
                        env.reposition = true
                        env.find_width = true
                        env.find_height = true
                        env.reassign_neighbors = true
                    if not env.is_setting then
                        print("call")
                        env.on_entries_changed(self)
                        env.call_update()
                        
                    end
                    --[=[
                    if env.in_on_entries then return end
                    env.in_on_entries = true
                    if env.children_want_focus and env.focused_child == nil and 
                        self.number_of_rows > 0 and self.number_of_cols > 0 then 
                        env.focused_child = self[1][1] 
                        env.focused_child:grab_key_focus()
                    end
                    print("me")
                    env.update()
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
                    if env.on_entries_changed then
                        env.on_entries_changed(self)
                    end
                    env.in_on_entries = false
                    --]=]
                end
            }
            print("wut")
            env.new_cells = false
            env.w = 0
            env.h = 0
            env.cell_w = false
            env.cell_h = false
            env.horizontal_spacing = 20
            env.vertical_spacing = 20
            env.number_of_rows_set = false
            env.number_of_cols_set = false
            env.items = {}
            --public attributes, set to false if there is no default
            env.col_widths  = {}
            env.row_heights = {}
            env.vertical_alignment   = "center"
            env.horizontal_alignment   = "center"
            env.placeholders   = {}
            env.children_want_focus   = true
            env.in_on_entries   = false
            env.focused_child   = false
            env.on_entries_changed   = false
            env.placeholder = nil
            env.new_placeholder = Rectangle{w=200,h=200,color="ff0000"}
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            instance.reactive = true
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            env.updating = true
            instance:set(parameters)
            env.updating = false
            --[[
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            return instance, env
            
        end
    }
)




--[=[
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
    local w = 0
    local h = 0
    local cell_w, cell_h
    local horizontal_spacing = 0
    local vertical_spacing   = 0
    local number_of_rows_set = false
    local number_of_cols_set = false
    local items = {}
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
    local find_w = function(cell,r,c)
        if w < cell.x + cell.w - cell.anchor_point[1] then 
            w = cell.x + cell.w - cell.anchor_point[1]
        end
    end
    local find_h = function(cell,r,c)
        
        if h < cell.y + cell.h - cell.anchor_point[2] then 
            h = cell.y + cell.h - cell.anchor_point[2]
        end
    end
    local vertical_alignment   = "center"
    local horizontal_alignment = "center"
    
    local assign_neighbors = function(cell,r,c,cells)
        items[cell].neighbors.up = nil
        items[cell].neighbors.down = nil
        items[cell].neighbors.left = nil
        items[cell].neighbors.right = nil
        
        if r ~= 1 then
            items[cell].neighbors.up = cells[r-1][c]
        end
        if r ~= cells.number_of_rows then
            items[cell].neighbors.down = cells[r+1][c]
        end
        
        if c ~= 1 then
            items[cell].neighbors.left = cells[r][c-1]
        end
        if c ~= cells.number_of_cols then
            items[cell].neighbors.right = cells[r][c+1]
        end
    end
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
                if self[r][c] then f(self[r][c],r,c,self) end
            end
        end
    end
    
    local set_size = function(self)
        local last_cell = self[self.number_of_rows] and self[self.number_of_rows][self.number_of_cols]
        if last_cell then
            instance.w = last_cell.x + (cell_w or col_widths[self.number_of_cols]  or last_cell.w) - last_cell.anchor_point[1]
            instance.h = last_cell.y + (cell_h or row_heights[self.number_of_rows] or last_cell.h) - last_cell.anchor_point[2]
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
		function(oldf,self,v)   
            print(v,v == "left" or v == "right" or v == "center")
            if v == "left" or v == "right" or v == "center" then
                horizontal_alignment = v 
            else
                error("expected 'left' 'right' or 'center'. Received "..v,2)
            end
            
        end
	)
	override_property(instance,"vertical_alignment",
		function(oldf)   return vertical_alignment     end,
		function(oldf,self,v)   
            
            if v == "top" or v == "bottom" or v == "center" then
                vertical_alignment = v 
            else
                error("expected 'top' 'bottom' or 'center'. Received "..v,2)
            end
        end
	)
    local placeholders = {}
	override_property(instance,"placeholder",
		function(oldf)   return placeholder     end,
		function(oldf,self,v)   
            instance:add(v)
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
	)
    
    instance:subscribe_to( 
        {
            "vertical_alignment","horizontal_alignment",
            "vertical_spacing","horizontal_spacing",
            "cell_w", "cell_h",
        },
        function() 
            for_each(cells,position_cell) 
            w = 0
            h = 0
            for_each(cells,find_w)
            for_each(cells,find_h)
            instance.size = {w,h}
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
    local children_want_focus = true
	override_property(instance,"children_want_focus",
		function(oldf)   return children_want_focus     end,
		function(oldf,self,v)   
            if type(v) ~= "boolean" then
                error("Expected boolean. Received "..type(v),2)
            end
            children_want_focus = v 
        end
	)
    ----------------------------------------------------------------------------
    local in_on_entries = false
    local focused_child = nil
    cells = GridManager{  
        
        node_constructor=function(obj)
            if node_constructor then
                
                obj = node_constructor(obj)
                
            else -- default node_constructor
                
                if obj == nil then  
                    
                    obj = Widget_Clone{source=placeholder}
                    placeholders[obj] = true
                    
                elseif type(obj) == "table" and obj.type then 
                    
                    obj = _G[obj.type](obj)
                    
                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                    
                    error("Must be a UIElement or nil. Received "..obj,2) 
                
                elseif obj.parent then  obj:unparent()  end
            end
            
            --TODO: fix this hack
            -- the add method is overwritten in some Widgets, screen holds a handle to the original
            screen.add(instance,obj)
            
            items[obj] = {
                neighbors = { },
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
            }
            if obj.subscribe_to then
                obj:subscribe_to(
                    {"h","w","width","height","size"},
                    function(...)
                        if in_on_entries then return end
                        
                        cells:on_entries_changed()
                        
                    end
                )
            end
            
            return obj
        end,
        
        node_destructor=function(obj,r,c) 
            if obj == focused_child then 
                focused_child = 
                    items[obj].neighbors.up or 
                    items[obj].neighbors.left or
                    items[obj].neighbors.right or
                    items[obj].neighbors.down 
            end
            for _,f in pairs(items[obj].key_functions) do f() end
            items[obj] = nil
            obj:unparent() 
            placeholders[obj] = nil
        end,
        
        on_entries_changed = function(self)
            if in_on_entries then return end
            in_on_entries = true
            if children_want_focus and focused_child == nil and 
                self.number_of_rows > 0 and self.number_of_cols > 0 then 
                focused_child = self[1][1] 
                focused_child:grab_key_focus()
            end
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
            on_entries_changed(self)
            in_on_entries = false
            
        end
    }
	override_property(instance,"cells",
		function(oldf) return   cells           end,
		function(oldf,self,v)   
            cells:set(v) 
            
            if cells.number_of_rows >= 1 and cells.number_of_rows >= 1  then
                focused_child = cells[1][1] 
                focused_child:grab_key_focus()
            else
                focused_child = nil
            end
        end
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
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.style = nil
            
            t.number_of_cols       = instance.number_of_cols
            t.number_of_rows       = instance.number_of_rows
            t.vertical_alignment   = instance.vertical_alignment
            t.horizontal_alignment = instance.horizontal_alignment
            t.vertical_spacing     = instance.vertical_spacing
            t.horizontal_spacing   = instance.horizontal_spacing
            t.cell_h = instance.cell_h
            t.cell_w = instance.cell_w
            t.cells = {}
            for_each(cells,function(obj,r,c)
                if not t.cells[r] then
                    t.cells[r] = {}
                end
                if not placeholders[obj] then
                    t.cells[r][c] = obj.attributes
                end
            end)
            
            t.type = "LayoutManager"
            
            return t
        end
    )
    
    ----------------------------------------------------------------------------
    
	function instance:on_key_focus_in()    
        if children_want_focus and focused_child then 
            dolater(function()
                focused_child:grab_key_focus() 
            end)
        end
        
    end 
    
	instance:set(parameters)
	
	return instance
    
end
--]=]
