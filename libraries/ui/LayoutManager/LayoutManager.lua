
LAYOUTMANAGER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local LIST_default_parameters = {spacing = 20, direction = "vertical"}





local next_neighbor

next_neighbor = function(items,obj,dir)
    --if the obj has a neighbor in the direction
    return items[obj].neighbors[dir] and 
        --if that neighbor is enabled, return it
        (items[obj].neighbors[dir].enabled and items[obj].neighbors[dir] or 
            --else return that neighbors neighbor
            next_neighbor(items,items[obj].neighbors[dir],dir)
        )
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
                focus_to_index = function(instance,env)
                    return function(oldf) return env.focus_to_index     end,
                    function(oldf,self,v)   
                        if type(v) ~= "number" then error("expected number. received "..type(v),2) end
                        env.focus_to_index = v
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "ListManager" end
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
                        error("Invalid direction: "..tostring(env.direction),2)
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
                        
                        --env.cells.length = #env.new_cells
                        env.cells:new_data(env.new_cells) 
                        
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
                if env.children_want_focus then
                    if env.focus_to_index then
                        
                        local obj = env.cells[ env.focus_to_index ]
                        
                        dolater(
                            obj.grab_key_focus,
                            obj
                        )
                    elseif env.focused_child then 
                        dolater(
                            env.focused_child.grab_key_focus,
                            env.focused_child
                        )
                    end
                end
                
            end 
            
            local getter, setter
            
            env.node_constructor = false
            env.on_entries_changed   = function() end
            env.cells = ArrayManager{  
                
                node_constructor=function(obj)
                    if env.node_constructor then
                        
                        obj = env.node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil or obj == false then  
                            
                            obj = Widget_Clone{source=env.placeholder}
                            env.placeholders[obj] = true
                            
                        elseif type(obj) == "table" and obj.type then 
                            
                            obj = _ENV[obj.type](obj)
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    --if env.cell_w then obj.w = env.cell_w end    TODO check these
                    --if env.cell_h then obj.h = env.cell_h end
                    
                    
                    
                    env.add(instance,obj)
                    local n
                    env.items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                n = next_neighbor(env.items,obj,"up")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                n = next_neighbor(env.items,obj,"down")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                n = next_neighbor(env.items,obj,"left")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                n = next_neighbor(env.items,obj,"right")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
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
                    
                    env.find_col_widths = true
                    env.find_col_heights = true
                    env.reposition = true
                    env.find_width = true
                    env.find_height = true
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
                        env.for_each(env.cells,function(cell) cell.h = v end)
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
                focus_to_index = function(instance,env)
                    return function(oldf) return env.focus_to_index     end,
                    function(oldf,self,v)   
                        if type(v) ~= "table" then error("expected table. received "..type(v),2) end
                        env.focus_to_index = {v[1],v[2]}
                    end
                end,
                cells = function(instance,env)
                    return function(oldf) return env.cells     end,
                    function(oldf,self,v)   
                        env.new_cells = v  
                        mesg("LayoutManager",0,"LayoutManager.cells = ",v)
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
                r_c_from_x_y = function(instance,env)
                    return function(old_function,self,x,y)
                        if  instance.number_of_rows == 0 or 
                            instance.number_of_cols == 0 then
                            
                            return 0, 0
                        end
                        local r,c = instance.number_of_rows, instance.number_of_cols
                        for i=1,instance.number_of_rows do
                            if y < (env.cells[i][1].y - env.cells[i][1].anchor_point[2]) then
                                r = i - 1
                                break
                            end
                        end
                        for i=1,instance.number_of_cols do
                            if x < (env.cells[1][i].x - env.cells[1][i].anchor_point[1]) then
                                c = i - 1
                                break
                            end
                        end
                        return (r < 1 and 1 or r),(c < 1 and 1 or c)
                    end
                end,
                r_c_from_abs_x_y = function(instance,env)
                    return function(old_function,self,x,y)
                        return self:r_c_from_x_y(
                            x - self.transformed_position[1]/screen.scale[1],
                            y - self.transformed_position[2]/screen.scale[2]
                        )
                    end
                end,
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
                    mesg("LayoutManager",0,"LayoutManager:position_cells()")
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
                        env.find_col_widths = true
                        env.find_col_heights = true
                        env.reposition = true
                        env.find_width = true
                        env.find_height = true
                        
                        env.placeholder = v 
                    end
                    if  env.new_cells then
                        --print(instance.number_of_rows)
                        --print(instance.number_of_cols)
                        --dumptable(env.new_cells)
                        env.cells:set(env.new_cells)
                        env.focused_child = env.cells[1][1] 
                        --env.focused_child:grab_key_focus()
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
                if env.children_want_focus then
                    if env.focus_to_index then
                        
                        local obj = env.cells[
                            env.focus_to_index[1] ][
                            env.focus_to_index[2] ]
                        
                        dolater(
                            obj.grab_key_focus,
                            obj
                        )
                    elseif env.focused_child then 
                        dolater(
                            env.focused_child.grab_key_focus,
                            env.focused_child
                        )
                    end
                end
                
            end 
            
            local getter, setter
            env.on_entries_changed = function() end
            env.node_constructor = false
            env.cells = GridManager{  
                
                node_constructor=function(obj)
                    mesg("LayoutManager",0,"LayoutManager new cell ",obj)
                    if env.node_constructor then
                        
                        obj = env.node_constructor(obj)
                        
                    else -- default node_constructor
                        
                        if obj == nil or obj == false then  
                            
                            obj = Widget_Clone{source=env.placeholder}
                            env.placeholders[obj] = true
                            
                        elseif type(obj) == "table" and obj.type then 
                            
                            obj = _ENV[obj.type](obj)
                            
                        elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                            
                            error("Must be a UIElement or nil. Received "..obj,2) 
                        
                        elseif obj.parent then  obj:unparent()  end
                    end
                    
                    if env.cell_w then obj.w = env.cell_w end
                    if env.cell_h then obj.h = env.cell_h end
                    local n
                    env.add(instance,obj)
                    
                    env.items[obj] = {
                        neighbors = { },
                        key_functions = {
                            up    = obj:add_key_handler(keys.Up,   function() 
                                n = next_neighbor(env.items,obj,"up")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            down  = obj:add_key_handler(keys.Down, function() 
                                n = next_neighbor(env.items,obj,"down")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            left  = obj:add_key_handler(keys.Left, function() 
                                n = next_neighbor(env.items,obj,"left")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                            right = obj:add_key_handler(keys.Right,function() 
                                n = next_neighbor(env.items,obj,"right")
                                if  n then 
                                    n:grab_key_focus()
                                    env.focused_child = n 
                                    return true
                                end 
                            end),
                        }
                        --[[
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
                        --]]
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
                    
                    env.find_col_widths = true
                    env.find_col_heights = true
                    env.reposition = true
                    env.find_width = true
                    env.find_height = true
                    env.reassign_neighbors = true
                    if not env.is_setting then
                        
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
            env.on_entries_changed   = function() end
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
external.ListManager   = ListManager
external.LayoutManager = LayoutManager