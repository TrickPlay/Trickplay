
--the globally visible list, always empty
animate_list = {}

local iterating = false

--the actual animation list
local iterated_list = {}

--the list of items to be deleted and added, these are needed to prevent items
--from being removed while the idle loop is moving through the iterated list
local to_be_deleted = {}
local to_be_added   = {}

--meta table used to capture new entries and removals
local mt = {}
function mt.__newindex(t,k,v)
    assert(#animate_list == 0, "User added something to the animate list")
    --assert(type(k) == "table")
    --if an item is being deleted
    if v == nil then
        --if there was no entry of that key, then ignore
        if iterated_list[k] ~= nil then
            table.insert(to_be_deleted,k)
        else
            print("Tried to delete and entry that was not there")
        end
    --if an item is being added
    else
        if iterated_list[k] ~= nil then
            if iterating then
                table.insert(to_be_deleted,k)
            else
                local item = iterated_list[k]
                if item.on_remove ~= nil then item.on_remove(item) end
                item.elapsed = 0
                item.stage   = 1
                iterated_list[item] = nil
            end
        end
        if k.setup then k:setup() end
        if k.elapsed == nil then k.elapsed = 0 end
        if k.stage   == nil then k.stage   = 1 end
        
        to_be_added[k] = k
    end
end
setmetatable(animate_list, mt)




idle_loop = function(_,seconds)
    iterating = true
    --don't rely on the table size while iterating, size is subject to change
    local num_items = #to_be_added
    
    --used for indexing and iterating
    local i = 1
    
    --used to reduce table look ups
    local p, curr_stage
    
    for _,item in pairs( to_be_added ) do
        iterated_list[item] = item.stages
    end
    
    to_be_added = {}
    
    for item, stages in pairs( iterated_list ) do
        
        item.elapsed = item.elapsed + seconds*1000
        
        curr_stage   = item.stage
        --update the progress
        if item.duration ~= nil and item.duration[curr_stage] ~= nil then
            p = item.elapsed / item.duration[curr_stage]
            
            --progress caps at 1
            if p > 1 then
                p = 1
                --move to the next stage next time around
                item.stage = item.stage + 1
                item.elapsed = 0
            end
            
            --apply the alpha mode if there is one
            if item.mode ~= nil and item.mode[curr_stage] ~= nil then
                --print(item.mode[curr_stage])
                --alpha.mode = item.mode[curr_stage]
                --p = alpha:on_alpha(p)
            end
        --if no duration variable, no progress variable
        else
            p = nil
        end
        --print(p)
        
        --execute the current stage
        if  stages[curr_stage] ~= nil then
            stages[curr_stage](item,seconds,p)
        elseif item.loop then
            item.stage = 1
            p=0
            stages[item.stage](item,seconds,p)
        else
            --if there is no next stage then remove
            table.insert(to_be_deleted,item)
        end
    end
    
    for _,item in pairs( to_be_deleted ) do
        if item.on_remove ~= nil then item.on_remove(item) end
        item.elapsed = 0
        item.stage   = 1
        iterated_list[item] = nil
    end
    to_be_deleted = {}
    iterating = false
end