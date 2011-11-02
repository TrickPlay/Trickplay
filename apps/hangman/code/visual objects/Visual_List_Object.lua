
local function make_list(t)
--[[
        orientation,
        elements,
        resets_focus_to,
        display_passive_focus)
    --]]
    if t.orientation ~= "VERTICAL" and t.orientation ~= "HORIZONTAL" then
        
        error("orientation must be 'VERTICAL' or 'HORIZONTAL', you gave "..t.orientation,2)
        
    end
    
    local list = Group{}
    
    local items = t.elements or {}
    
    list:add(unpack(items))
    
    local index = 1
    
    function list:add_item(item,i)
        
        if i then
            
            table.insert(items,i,item)
            
        else
            
            table.insert(items,item)
            
        end
        
    end
    function list:remove_item(i)
        
        table.remove(items,i)
        
    end
    local function gains_focus()
        
        if items[index] == nil then return end
        
        
        list:grab_key_focus()
        
        --if the list displays a passive focus while unfocused
        if t.display_passive_focus then
            
            --if reseting the index from the passively focused item
            if t.resets_focus_to and t.resets_focus_to ~= index then
                
                --unfocus the passive item
                items[index]:set_state("UNFOCUSED")
                
                --reset the index
                index = t.resets_focus_to
                
            end
            
            --focus the new index, or change to maintained index from passive to active
            items[index]:set_state("FOCUSED")
            
        --if the list does not displays a passive focus while unfocused
        else
            
            --reset the index if necessary
            if t.resets_focus_to and t.resets_focus_to ~= index then
                
                --unfocus the passive item
                items[index]:set_state("UNFOCUSED")
                
                index = t.resets_focus_to
                
            end
            
            --focus it
            items[index]:set_state("FOCUSED")
            
        end
        
        
    end
    
    local function loses_focus()
        
        list.parent:grab_key_focus()
        
        --if the list displays a passive focus while unfocused
        if t.display_passive_focus then
            
            --unfocus the active element item
            items[index]:set_state("PASSIVE_FOCUSED")
            
        else
            
            --unfocus the active element item
            items[index]:set_state("UNFOCUSED")
            
        end
        
    end
    
    
    function list:set_state(new_state)
        
        if     new_state == "FOCUSED" then
            
            gains_focus()
            
        elseif new_state == "UNFOCUSED" --[[or new_state == "PASSIVE_FOCUSED"]] then
            
            loses_focus()
            
        else
            
            error("received invalid state",2)
            
        end
        
    end
    
    local orig_index
    
    local move_to_lower_index = function()
        
        if index <= 1 then return end
        
        items[index]:set_state("UNFOCUSED")
        
        orig_index = index
        
        index      = index - 1
        
        while items[index]:set_state("FOCUSED") == false do
            
            index = index - 1
            
            if index <= 1 then
                
                index = orig_index
                
                items[index]:set_state("FOCUSED")
                
                break
                
            end
            
        end
        
    end
    local move_to_higher_index = function()
        
        if index >= #items then return end
        
        items[index]:set_state("UNFOCUSED")
        
        orig_index = index
        
        index      = index + 1
        
        while items[index]:set_state("FOCUSED") == false do
            
            index = index + 1
            
            if index >= #items then
                
                index = orig_index
                
                items[index]:set_state("FOCUSED")
                
                break
                
            end
            
        end
    end
    
    
    local key_events =
        
        t.orientation == "VERTICAL" and
        {
            [keys.Up]    = move_to_lower_index,
            [keys.Down]  = move_to_higher_index,
            [keys.OK]    = function() items[index]:select() end,
        } or
        
        t.orientation == "HORIZONTAL" and
        {
            [keys.Left]  = move_to_lower_index,
            [keys.Right] = move_to_higher_index,
            [keys.OK]    = function() if items[index].select then  items[index]:select() end end,
        } or
        
        error("Your logic is flawed!",2)
    
    function list:on_key_down(k)
        
        if key_events[k] then key_events[k]() end
        
    end
    
    function list:define_key_event(k,f)
        
        key_events[k] = f
        
    end
    
    return list
    
end

return make_list