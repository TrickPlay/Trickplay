
--[[
    My App_Loop Framework:
    
    The only visible aspect of this file is "animate_list"
    
    Adding items to this list, appends them to the list of animated items.
    
    This list is always empty, the meta-table adds it to the real animate_list
    
    
    How to add an item:
        animate_list[--function_table--] = object
    
    How to delete an item:
        animate_list[--existing_function_table--] = nil
            -----or-----
        animate_list[--object_with_multiple_function_tables--] = nil
    
    
    Definitions:
        
        function_table:
            
            {
              duration = 100,
              loop     = true,
              name     = "This name is used for error statements",
              func     = function(this_object,this_func_table,secs,progress) end,
              elapsed  = 0
            }
            The only necessary field is 'func.' If 'duration' is provided,
            then a progress parameter is passed to 'func.' 'func' is guaranteed
            to receive a progress value of '1,' at which point it gets removed
            unless if 'loop' is set to true.
            'func' can return another func_table. If it does, then the current
            func_table will be removed and the return on will be added to the
            animate_list using the same object
            
        object:
            This can be anything really. Pressumably, it is an object that
            contains the function_table. Passing it to the function allows
            access to other variable.
--]]
animate_list = {}

--flag, used to delay the addition/removal of func_table's to the animate_list
--while it is being iterated across
local in_idle_loop = false

--the real animate_list
local iterated_list = {}

--the list of items to be deleted and added, these are needed to prevent items
--from being removed while the idle loop is moving through the iterated list
local to_be_deleted = {}
local to_be_added   = {}

--meta table used to capture new entries and removals
local mt = {}


local tot = 0
local iterated_tot = 0
function mt.__newindex(t,k,v)
    assert(#animate_list == 0, "User added something to the animate list that"..
                                " wasn't caught by the meta table")
    --assert(type(k) == "table")
    --if an item is being deleted
    if v == nil then
        --if there was no entry of that key, then ignore
        if iterated_list[k] ~= nil then
            if in_idle_loop then
                table.insert(to_be_deleted,k)
            else
                iterated_list[k]=nil
            end
            tot = tot-1
        end
        
    --if an item is being added
    else
        if iterated_list[k] ~= nil then
            if iterating then
                table.insert(to_be_deleted,k)
            else
                iterated_list[k]=nil
            end
        end
        assert(type(k)=="table")
        if k.func ==nil then
            dumptable(k)
            error("no 'func' field")
        end
        --assert(type(v)=="table" )
        
        --if v.setup ~= nil   then v:setup()     end
        if k.duration ~= nil then k.elapsed = 0 end
        
        to_be_added[k] = v
        tot = tot+1
    end
    --print(tot,iterated_tot)
end
setmetatable(animate_list, mt)

local first_exec = true

local elapsed = 0
local idle_loop = function(self, seconds)
    
    
    if first_exec then
        first_exec = false
        return
    end
    
    elapsed = elapsed + seconds*1000
    
    for tbl,object in pairs( to_be_added ) do
        iterated_list[tbl] = object
    end
    to_be_added = {}
    
    
    
    in_idle_loop = true
    local iter = 0
    
    for func_tbl, object in pairs( iterated_list ) do
        iter = iter + 1
        if func_tbl.duration ~= nil then
            
            func_tbl.elapsed = func_tbl.elapsed+seconds*1000
            
            if func_tbl.elapsed > func_tbl.duration then
                
                if func_tbl.loop then
                    
                    func_tbl.elapsed = 0
                    
                    func_tbl.func(object,func_tbl,seconds,0)
                    
                else
                    
                    func_tbl.func(object,func_tbl,seconds,1)
                    
                    --to_be_deleted[func_tbl] = object
                    table.insert(to_be_deleted,func_tbl)
                    
                end
                
            else
                
                func_tbl.func(object,func_tbl,seconds,func_tbl.elapsed/func_tbl.duration)
                
            end
        else
            
            func_tbl.func(object,func_tbl,seconds)
            
        end
    end
    iterated_tot = iter
    in_idle_loop = false
    --[[
    if elapsed >= 1000 then
        print("iterate len",iterated_tot)
        elapsed = 0
    end
    --]]
    
    
    for _,tbl in ipairs( to_be_deleted ) do
        iterated_list[tbl]=nil
    end
    to_be_deleted = {}
    
end

idle.on_idle = idle_loop