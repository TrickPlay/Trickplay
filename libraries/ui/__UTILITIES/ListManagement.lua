LISTMANAGER = true

ArrayManager = function(p)
    
    local instance = {}
    local data     = {}
    local indices  = {}
    local mt       = {}
    local setters  = {}
    local getters  = {}
    ----------------------------------------------------------------------------
    -- mimicks table.insert()
    mt.insert = function(i,entry) 
        
        --check inputs
        if type(i) ~= "number" or i <= 0 then
            error("1st parameter must be positive number. Received "..i,2)
        end
        
        --you cant create the 10th node without having nodes 1-9
        if i > instance.length then i = instance.length+1 end
        
        --insert a hole into the list
        table.insert(data, i,false)
        
        indices = false
        
        --enter the value using mt.__newindex(instance,i,entry)
        instance[i] = entry
        
        if p.on_length_change then p.on_length_change(instance.length) end
    end
    ----------------------------------------------------------------------------
    -- mimicks table.remove()
    mt.remove = function(i) 
        --check inputs
        if type(i) ~= "number" or i <= 0 then
            error("1st parameter must be positive number. Received "..i,2)
        end
        
        --fill nil spot in the list
        p.node_destructor(
            table.remove( data, i )
        )
        
        indices = false
        
        if p.on_length_change then p.on_length_change(instance.length) end
    end
    ----------------------------------------------------------------------------
    -- returns the index of the node in the list, 
    -- if the node is not present, then nil is returned
    mt.index_of = function(cell) 
        
        if not indices then 
            indices = {}
            for index,cell in ipairs(data) do
                indices[cell] = index
            end
        end
        
        return indices[cell]
    end
    ----------------------------------------------------------------------------
    -- handles overwriting entries
    mt.__newindex = function(_,k,new_entry) 
        
        --check inputs
        if type(k) ~= "number" then 
            if  setters[k] then
                return setters[k](new_entry)
            else
                error("The index to is not a number: "..k,2) 
            end
        end
        
        --returns if the entry is the same as the existing
        if new_entry == data[k] then return end
        
        --deletes the old entry
        if data[k] then 
            p.node_destructor(data[k],k) 
            if indices then indices[ data[k] ] = nil end
        end
        
        if indices and new_entry ~= nil then
            indices[new_entry] = k
        end
        
        --inserts the new entry
        data[k] = p.node_constructor(new_entry,k)
        
        if p.node_initializer then p.node_initializer(new_entry,k) end
        
    end
    setters.data = function(new_data) 
        
        --toss the old data
        for i,_    in ipairs(    data) do  instance[i] = nil  end
        
        --insert the new data
        for i,cell in ipairs(new_data) do  instance[i] = cell end
        
        indices = false
        --if p.on_length_change then p.on_length_change(instance.length) end
    end
    
    getters.length = function() return #data end
    mt.pairs  = function(from,to,inc)
        
        if from == nil then from = 1
        elseif from < 0 or from > instance.length then 
            error("first parameter is outside",2)
        end
        
        if to == nil then to = instance.length
        elseif to   < 0 or to   > instance.length then 
        end
        
        local inc = from <= to and 1 or -1
        local i   = from - inc
        return function()
            
            i = i + inc
            
            if i > instance.length then
                
                return nil
                
            else
                
                return i, instance[i]
                
            end
        end
    end
    
    ----------------------------------------------------------------------------
    -- passes the data back
    mt.__index = function(_,k)  
        return getters[k] and getters[k]() or mt[k] or data[k] 
    end
    
    mt.getters = getters
    mt.setters = setters
    
    setmetatable( instance, mt )
    
    --insert the initialization data
    instance.data = p.data or {}
    
    return instance
end

--------------------------------------------------------------------------------

GridManager = function(p)
    
    local rows
    rows = ArrayManager{
        --data = p.data,
        on_length_change = function(l) p.on_size_change(l,rows and rows[1] and rows[1].length or 0) end,
        ------------------------------------------------------------------------
        node_initializer = function(data,r)
            local col = rows[r]
            --dumptable(data)
            if data == nil then
                data = {}
                for i = 1,rows[1].length do
                    data[i] = p.node_constructor(nil,r,i)
                end
                col.data = data 
                for i = 1,rows[1].length do
                    p.node_initializer(data[i],r,i)
                end
            else
                col.data = data 
            end
        end,
        node_constructor = function(data,r)
            
            local col 
            col = ArrayManager{
                --data  = data,
                node_initializer = function(cell,c) 
                    return p.node_initializer( cell, rows.index_of(col)or r, c ) 
                end,
                node_constructor = function(cell,c) 
                    return p.node_constructor( cell, rows.index_of(col)or r, c ) 
                end, 
                node_destructor  = function(cell,c) 
                    p.node_destructor( cell, rows.index_of(col), c )  
                end
            }
            local col_mt = getmetatable(col)
            
            --save the original insert/remove methods
            col_mt.insert_cell = col_mt.insert
            col_mt.remove_cell = col_mt.remove
            --------------------------------------------------------------------
            --the new insert/remove functions that call the old ones for every row
            col_mt.insert = function(i,new_col)
                --[[
                new_col = new_col or {}
                for j,row in ipairs(p.data) do
                    row.insert_cell(i,new_col[j])
                end
                
                if p.on_size_change then p.on_size_change(rows.length,col.length) end
                --]]
                if new_col == nil then
                    data = {}
                    for r = rows.length,1,-1 do
                        rows[r].insert_cell(i,p.node_constructor(nil,r,i))
                    end
                    --old_insert(i,data)
                else
                    for r = rows.length,1,-1 do
                        rows[r].insert_cell(i,new_col[r])
                    end
                end
                if p.on_size_change then p.on_size_change(rows.length,col.length) end
            end
            
            col_mt.remove = function(i)
                for r = 1,rows.length do
                    rows[r].remove_cell(i)
                end
                
                if p.on_size_change then p.on_size_change(rows.length,col.length) end
            end
            return col
        end,
        ------------------------------------------------------------------------
        node_destructor = function(old_node)
            
            for i,cell in old_node.pairs() do
                if cell then p.node_destructor(cell) end
            end
            
        end,
    }
    local rows_mt = getmetatable(rows)
    
    local old_insert = rows_mt.insert
    rows_mt.insert = function(r,entry) 
        
        if entry == nil then
            data = {}
            if r > rows.length then r = rows.length+1 end
            for i = 1,(rows[r] and rows[r].length or rows[rows.length].length) do
                data[i] = p.node_constructor(nil,r,i)
            end
            old_insert(r,data)
            ---[[
            for i = 1,rows[r].length do
                p.node_initializer(data[i],r,i)
            end
            --]]
        else
            old_insert(r,entry)
        end
    end
    
    rows.data = p.data
    return rows
    
end