LISTMANAGER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


ArrayManager = function(p)
    local instance
    -- Metatables
    local instance_mt, row_mt
    
    ----------------------------------------------------------------------------
    -- Attributes
    local number_of_rows = 0
    local number_of_cols = 0
    local number_of_rows_fixed = false
    local number_of_cols_fixed = false
    
    local node_constructor   = function(v) return v end
    local node_destructor    = function() end
    local on_entries_changed = function() end
    local data = {}
    
    ----------------------------------------------------------------------------
    --reports changes to the user, each function performs a test and set on
    local test_and_set, report_change
    do
        local caller
        test_and_set = function(v)
            if caller ~= nil then return end
            caller = v
        end
        report_change = function(v)
            if caller ~= v then return end
            caller = nil
            on_entries_changed(instance)
        end
    end
    ----------------------------------------------------------------------------
    
    
    ----------------------------------------------------------------------------
    
    instance = {}
    
    instance_mt = {
        functions = {
            insert = function(_,i,entry) 
                test_and_set("insert")
                --check inputs
                if type(i) ~= "number" or i < 0 then
                    error("1st parameter must be positive number. Received "..i,2)
                end
                
                --you cant create the 10th node without having nodes 1-9
                if i > instance.length then i = instance.length+1 end
                
                --insert a hole into the list
                table.insert(data, i,false)
                
                --enter the value using mt.__newindex(instance,i,entry)
                instance[i] = entry
                report_change("insert")
            end,
            remove = function(_,i) 
                test_and_set("remove")
                --check inputs
                if type(i) ~= "number" or i <= 0 then
                    error("1st parameter must be positive number. Received "..i,2)
                end
                
                --fill nil spot in the list
                node_destructor(
                    table.remove( data, i ),
                    i
                )
                
                report_change("remove")
            end,
            pairs  = function(from,to,inc)
                
                if from == nil then from = 1
                elseif from < 0 or from > instance.length then 
                    error("first parameter is outside bounds:0 < "..from.." < "..instance.length,2)
                end
                
                if to == nil then to = instance.length
                elseif to   < 0 or to > instance.length then 
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
            end,
            
            new_data = function(self,t)
                test_and_set("set")
                if type(t) ~= "table" then
                    error("Expected table. Received "..type(t),2) 
                end
                
                
                if instance.length > #t then
                    
                    for i = instance.length,#t+1,-1 do
                    --while number_of_rows < v do
                        
                        instance:remove(i)--number_of_rows)
                    end
                    
                    for k,v in ipairs(t) do   self[k] = v   end
                    
                elseif instance.length < #t then
                    
                    for i = 1,instance.length+1 do
                        self[i] = t[i]
                    end
                    for i = instance.length+1,#t do
                    --while number_of_rows < v do
                        mesg("ArrayManager",0,"ArrayManager inserting",i,t[i])
                        instance:insert(i,t[i])--number_of_rows+1)
                    end
                    
                end
                
                
                
                --for k,v in pairs(t) do   self[k] = v   end
                report_change("set")
            end,
            set = function(self,t)
                test_and_set("set")
                if type(t) ~= "table" then
                    error("Expected table. Received "..type(t),2) 
                end
                
                for k,v in pairs(t) do   self[k] = v   end
                report_change("set")
            end,
        },
        setters = {
            length = function(_,v) 
                test_and_set("length")
                
                if instance.length > v then
                    
                    for i = instance.length,v+1,-1 do
                    --while number_of_rows < v do
                        
                        instance:remove(i)--number_of_rows)
                    end
                    
                elseif instance.length < v then
                    
                    for i = instance.length+1,v do
                    --while number_of_rows < v do
                        
                        instance:insert(i)--number_of_rows+1)
                    end
                    
                end
                report_change("length")
                
            end,
            node_constructor = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                node_constructor = v 
            end,
            node_destructor = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                node_destructor = v 
            end,
            on_entries_changed = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                on_entries_changed = v 
            end,
        },
        getters = {
            length             = function()     return #data              end,
            node_constructor   = function(self) return node_constructor   end,
            node_destructor    = function(self) return node_destructor    end,
            on_entries_changed = function(self) return on_entries_changed end,
        },
        __index = function(self,k)
            
            if instance_mt.functions[k] then 
                return instance_mt.functions[k]
            elseif instance_mt.getters[k] then 
                return instance_mt.getters[k]()
            elseif type(k) ~= "number" or k < 1 or k > #data then
                --error("Invalid index. 0 < '"..k.."' < "..#data,2)
                return
            else
                return data[k]
            end
        end,
        __newindex = function(_,k,v) 
            
            test_and_set("__newindex")
            if instance_mt.setters[k] then instance_mt.setters[k](self,v)
            
            elseif type(k) == "number" then
                
                if k < 1 or k > #data + 1 then
                    --error("Invalid index. 0 < '"..k.."' < "..#data,2)
                    return
                end
                
                --deletes the old entry
                if data[k] then 
                    node_destructor(data[k]) 
                end
                
                --inserts the new entry
                data[k] = node_constructor(v)
                
            else
                error("Invalid index: "..tostring(k),2)
            end
            report_change("__newindex")
            
        end,
    }
    
    setmetatable(instance,instance_mt)
    
    if p then instance:set(p) end
    
    return instance
    
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

GridManager = function(p)
    
    -- The Object
    local instance
    -- Metatables
    local instance_mt, row_mt
    
    ----------------------------------------------------------------------------
    -- Attributes
    local number_of_rows = 0
    local number_of_cols = 0
    local number_of_rows_fixed = false
    local number_of_cols_fixed = false
    
    local node_constructor   = function(v) return v end
    local node_destructor    = function() end
    local on_entries_changed = function() end
    local data = {}
    
    ----------------------------------------------------------------------------
    --reports changes to the user, each function performs a test and set on
    local test_and_set, report_change
    do
        local caller
        test_and_set = function(v)
            if caller ~= nil then return end
            caller = v
        end
        report_change = function(v)
            if caller ~= v then return end
            caller = nil
            on_entries_changed(instance)
        end
    end
    ----------------------------------------------------------------------------
    
    local make_row = function()
        
        local row = {}
        local row_data = {}
        local row_mt = {}
        
        row_mt.pairs = function(self,from,to)
        
            if from == nil then from = 1
            elseif from < 1 or from > number_of_cols then 
                error("1st arg is an invalid index. 0 < '"..from.."' < "..number_of_cols,2)
            end
            
            if to == nil then to = number_of_cols
            elseif to   < 1 or to > number_of_cols then 
                error("2nd arg is an invalid index. 0 < '"..to.."' < "..number_of_cols,2)
            end
            
            local inc = from <= to and 1 or -1
            local i   = from - inc
            return function()
                
                i = i + inc
                
                if i > number_of_cols then
                    
                    return nil
                    
                else
                    
                    return i, row[i]
                    
                end
            end
                    
        end
        row_mt.__insert = function(self,i,d)
            if i < 1 or i > number_of_cols+1 then
                --error("Invalid index. 0 < '"..k.."' < "..number_of_cols,2)
                mesg("GridManager",0,"GridManager row insert row_mt.__index oob",1,i,number_of_cols)
                return 
            else
                return table.insert(row_data,i,d)
            end
            
        end
        row_mt.__remove = function(self,i)
            if i < 1 or i > number_of_cols then
                --error("Invalid index. 0 < '"..k.."' < "..number_of_cols,2)
                mesg("GridManager",0,"GridManager row remove row_mt.__index oob",1,i,number_of_cols)
                return 
            else
                return table.remove(row_data,i)
            end
            
        end
        row_mt.__index = function(self,k)
            if row_mt[k] then
                return row_mt[k]
            elseif type(k) ~= "number" then
                return nil
            elseif k < 1 or k > number_of_cols then
                --error("Invalid index. 0 < '"..k.."' < "..number_of_cols,2)
                return 
            else
                return row_data[k]
            end
            
        end
        row_mt.__newindex = function(self,k,v)
            test_and_set("row_mt.__newindex")
            if type(k) == "number" and k >= 1 and 
                k <= number_of_cols then
                if row_data[k] then node_destructor(row_data[k]) end
                row_data[k] = node_constructor(v)
            else
                --error("Invalid index. 0 < '"..k.."' < "..number_of_cols,2)
            end
            report_change("row_mt.__newindex")
        end
                
        setmetatable(row,row_mt)
        
        return row
        
    end
    ----------------------------------------------------------------------------
    
    instance = {}
    
    instance_mt = {
        functions = {
            insert_row = function(self,r,entry)
                test_and_set("insert_row")
                number_of_rows = number_of_rows + 1
                --if inserting a row of placeholders
                
                entry = entry == nil and {} or 
                    type(entry) == "table" and entry or
                    error("2nd argument is expected to be nil or table",2)
                
                table.insert(data,r,false)
                instance[r] = entry
                report_change("insert_row")
            end,
            insert_col = function(self,c,entry)
                test_and_set("insert_col")
                number_of_cols = number_of_cols + 1
                --if no rows, then just inc number_of_cols
                if number_of_rows == 0 then return end
                --if inserting a column of placeholders
                
                entry = entry == nil and {} or 
                    type(entry) == "table" and entry or
                    error("2nd argument is expected to be nil or table",2)
                
                --truncates entries beyond 'number_of_cols',
                --'node_constructor' handles nil entries
                for i = 1,number_of_rows do
                    data[i]:__insert(c, node_constructor(entry[i],i,c) )
                end
                report_change("insert_col")
            end,
            remove_row = function(self,r)
                test_and_set("remove_row")
                if type(r) ~= "number" then
                    error("Number expected. Received "..type(r),2)
                end
                if r < 1 or r > number_of_rows then 
                    error("Received invalid index. 1 < '"..r.."' < "..#data,2) 
                end
                --if no rows, then just inc number_of_cols
                if number_of_cols ~= 0 then
                --if inserting a column of placeholders
                
                local row = table.remove(data,r)
                --truncates entries beyond 'number_of_cols',
                --'node_constructor' handles nil entries
                for i = 1,number_of_cols do
                    node_destructor(row[i],r,i)
                end
                end
                number_of_rows = number_of_rows - 1
                report_change("remove_row")
            end,
            remove_col = function(self,c)

                test_and_set("remove_col")
                if type(c) ~= "number" then
                    error("Number expected. Received "..type(c),2)
                end
                if c < 1 or c > number_of_cols then 
                    error("Received invalid index. 1 < '"..c.."' < "..number_of_cols,2) 
                end
                --if no rows, then just inc number_of_cols
                if number_of_rows ~= 0 then 
                --if inserting a column of placeholders
                
                --truncates entries beyond 'number_of_cols',
                --'node_constructor' handles nil entries
                for i = 1,number_of_rows do
                    node_destructor(data[i]:__remove(c),c,i)
                    --data[i][c] = nil
                end
                end
                number_of_cols = number_of_cols - 1
                report_change("remove_col")
            end,
            pairs  = function(self,from,to)
                
                if from == nil then from = 1
                elseif from < 1 or from > number_of_rows then 
                    error("Invalid index. 0 < '"..from.."' < "..number_of_rows,2)
                end
                
                if to == nil then to = number_of_rows
                elseif to   < 1 or to > number_of_rows then 
                    error("Invalid index. 0 < '"..to.."' < "..number_of_rows,2)
                end
                
                local inc = from <= to and 1 or -1
                local i   = from - inc
                return function()
                    
                    i = i + inc
                    
                    if i > number_of_rows then
                        
                        return nil
                        
                    else
                        
                        return i, instance[i]
                        
                    end
                end
            end, 
            set = function(self,t)
                test_and_set("set")
                if type(t) ~= "table" then
                    error("Expected table. Received "..type(t),2) 
                end
                
                for k,v in pairs(t) do   self[k] = v   end
                report_change("set")
            end
        },
        setters = {
            number_of_rows = function(self,v) 
                test_and_set("number_of_rows")
                
                if v == nil then
                    number_of_rows_fixed = false
                    return
                else
                    number_of_rows_fixed = true
                end
                if number_of_rows > v then
                    
                    for i = number_of_rows,v+1,-1 do
                        
                        self:remove_row(i)
                    end
                    
                elseif number_of_rows < v then
                    
                    for i = number_of_rows+1,v do
                        
                        self:insert_row(i)
                    end
                    
                end
                report_change("number_of_rows")
            end,
            number_of_cols = function(self,v) 
                test_and_set("number_of_cols")
                if v == nil then
                    number_of_cols_fixed = false
                    return
                else
                    number_of_cols_fixed = true
                end
                if number_of_cols > v then
                    
                    for i = number_of_cols,v+1,-1 do
                        
                        self:remove_col(i)
                    end
                    
                elseif number_of_cols < v then
                    
                    for i = number_of_cols+1,v do
                        
                        self:insert_col(i)
                    end
                    
                end
                report_change("number_of_cols")
            end,
            size = function(self,v) 
                test_and_set("size")
                instance.number_of_rows = v[1]
                instance.number_of_cols = v[2]
                report_change("size")
            end,
            node_constructor = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                node_constructor = v 
            end,
            node_destructor = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                node_destructor = v 
            end,
            on_entries_changed = function(self,v) 
                if type(v) ~= "function" then 
                    error("Expected function. Received "..type(v),2) 
                end 
                on_entries_changed = v 
            end,
        },
        getters = {
            number_of_rows = function(self) 
                return number_of_rows
            end,
            number_of_cols = function(self) 
                return number_of_cols
            end,
            size = function(self) 
                return {number_of_rows,number_of_cols} 
            end,
            node_constructor   = function(self) return node_constructor   end,
            node_destructor    = function(self) return node_destructor    end,
            on_entries_changed = function(self) return on_entries_changed end,
        },
        __index = function(self,k)
            
            if instance_mt.functions[k] then 
                return instance_mt.functions[k]
            elseif instance_mt.getters[k] then 
                return instance_mt.getters[k]()
            elseif type(k) ~= "number" or k < 1 or k > number_of_rows then
                --error("Invalid index. 0 < '"..k.."' < "..number_of_rows,2)
                return
            else
                return data[k]
            end
        end,
        __newindex = function(self,k,v)
            test_and_set("__newindex")
            if instance_mt.setters[k] then instance_mt.setters[k](self,v)
            
            elseif type(k) == "number" then
                if k < 1 or k > number_of_rows then
                    mesg("GridManager",0,"GridManager Invalid row index. 0 < '"..k.."' < "..number_of_rows)
                    return
                end
                
                --TODO: use is_nil_or_table()
                v = v == nil and {} or 
                    type(v) == "table" and v or
                    error("Value is expected to be nil or table",2) 
                if data[k] then
                    for i = 1,number_of_cols do
                        node_destructor(data[k][i])
                    end
                end
                
                data[k] = make_row()
                --truncates entries beyond 'number_of_cols',
                --'node_constructor' handles nil entries
                for i = 1,number_of_cols do
                    data[k][i] = v[i]
                end
                
            else
                error("Invalid index: "..k,2)
            end
            report_change("__newindex")
        end,
    }
    
    
    setmetatable(instance,instance_mt)
    
    if p then instance:set(p) end
    
    return instance
    
    
    --[=[
    
    local rows
    local caller
    local on_entries_changed = function(v)
        if caller ~= v then return end
        caller = nil
        if p.on_entries_changed then p.on_entries_changed(rows) end
    end
    rows = ArrayManager{
        --data = p.data,
        on_length_change = function(l) p.on_size_change(l,rows and rows[1] and #rows[1] or 0) end,
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
                    print("here")
                    p.node_initializer(data[i],r,i)
                end
            else
                print("here",rows.length,col.length)
                col.data = data 
            end
        end,
        node_constructor = function(data,r)
            print("ROW",r)
            --dumptable(data)
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
                end,
                
            }
            local col_mt = getmetatable(col)
            
            --save the original insert/remove methods
            local old_insert = col_mt.insert
            local old_remove = col_mt.remove
            local old_overwrite = col_mt.__newindex
            --save the original insert/remove methods
            col_mt.insert_cell = function(...)
                if caller == nil then caller = "col_mt.insert_cell" end
                old_insert(...)
                on_entries_changed("col_mt.insert_cell")
            end
            col_mt.remove_cell = function(...)
                if caller == nil then caller = "col_mt.remove_cell" end
                old_remove(...)
                on_entries_changed("col_mt.remove_cell")
            end
            col_mt.__newindex = function(...)
                if caller == nil then caller = "col_mt.__newindex" end
                old_overwrite(...)
                print("HEEEEEEEE")
                on_entries_changed("col_mt.__newindex")
            end
            --------------------------------------------------------------------
            --the new insert/remove functions that call the old ones for every row
            col_mt.insert = function(i,new_col)
                if caller == nil then caller = "col_mt.insert" end
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
                on_entries_changed("col_mt.insert")
            end
            
            col_mt.remove = function(i)
                if caller == nil then caller = "col_mt.remove" end
                for r = 1,rows.length do
                    rows[r].remove_cell(i)
                end
                
                if p.on_size_change then p.on_size_change(rows.length,col.length) end
                on_entries_changed("col_mt.remove")
            end
            print("row made")
            return col
        end,
        ------------------------------------------------------------------------
        node_destructor = function(old_node)
            dumptable(data)
            for i,cell in old_node.pairs() do
                if cell then p.node_destructor(cell) end
            end
            
        end,
    }
    local rows_mt = getmetatable(rows)
    
    local old_insert    = rows_mt.insert
    local old_remove    = rows_mt.remove 
    local old_overwrite = rows_mt.__newindex
    rows_mt.insert = function(r,entry) 
        if caller == nil then caller = "rows_mt.insert" end
        if entry == nil then
            data = {}
            print(rows[r] and (rows[r].length or rows[rows.length].length))
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
        on_entries_changed("rows_mt.insert")
    end
    rows_mt.remove = function(...) 
        if caller == nil then caller = "rows_mt.remove" end
        old_remove(...)
        on_entries_changed("rows_mt.remove")
    end
    rows_mt.__newindex = function(...) 
        if caller == nil then caller = "rows_mt.__newindex" end
        old_overwrite(...)
        on_entries_changed("rows_mt.__newindex")
    end
    print("true",p.on_entries_changed)
    rows.data = p.data
    return rows
    --]=]
end