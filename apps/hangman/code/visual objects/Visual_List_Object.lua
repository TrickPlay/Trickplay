
local override_index = {
    ["FROM_LOWER"] = function(items)
        return items[1]:set_state("FOCUSED")
    end,
    ["FROM_HIGHER"] = function(items)
        return items[ # items ]:set_state("FOCUSED")
    end,
}

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
    local new_i
	local function gains_focus(overriding_index)
		
		if items[index] == nil then return end
		
		
		list:grab_key_focus()
        print(list,"list grabbed key")
        if overriding_index and not t.ignore_override and override_index[overriding_index](items) then --items[overriding_index]:set_state("FOCUSED") then
            
            new_i = overriding_index == "FROM_LOWER" and 1 or (# items)
            if new_i ~= index then
                items[index]:set_state("UNFOCUSED")
                index = new_i
            end
            
        elseif t.resets_focus_to and items[t.resets_focus_to]:set_state("FOCUSED") then
            print("resets_focus_to",t.resets_focus_to,list)
            if t.resets_focus_to ~= index then
                items[index]:set_state("UNFOCUSED")
                index = t.resets_focus_to
            end
            
        elseif t.resets_focus_secondary and items[t.resets_focus_secondary]:set_state("FOCUSED") then
            
            if t.resets_focus_secondary ~= index then
                items[index]:set_state("UNFOCUSED")
                index = t.resets_focus_secondary
            end
            
        elseif
            index ~= overriding_index  and
            index ~= t.resets_focus_to and
            index ~= t.resets_focus_secondary then
            
            print(items[index]:set_state("FOCUSED"))
            
        else
            
            print("nothing to focus")
            
        end
        print("end gain_focus",list)
		
	end
	
	local function loses_focus()
		
		--list.parent:grab_key_focus()
		print(list,"list gave up key")
		--if the list displays a passive focus while unfocused
		if t.display_passive_focus then
			
			--unfocus the active element item
			items[index]:set_state("PASSIVE_FOCUSED")
			
		else
			
			--unfocus the active element item
			items[index]:set_state("UNFOCUSED")
			
		end
		
	end
	
	
	function list:set_state(new_state,overriding_index)
		
		if     new_state == "FOCUSED" then
			
            if self.is_visible == false then return false end
            --print(5)
			gains_focus(overriding_index)
            if t.on_focus then t.on_focus() end
			return true
		elseif new_state == "UNFOCUSED" --[[or new_state == "PASSIVE_FOCUSED"]] then
			
			loses_focus()
			
		else
			
			error("received invalid state",2)
			
		end
		
	end
	
	local orig_index
	
	local move_to_lower_index = function()
		
		if index <= 1 and not t.wrap then return false  end
		
        mediaplayer:play_sound("audio/key-arrows.mp3")
		
		items[index]:set_state("UNFOCUSED")
		
		orig_index = index
		
		index      = index - 1
        
        if t.wrap and index == 0 then index = #items end
		
		while items[index]:set_state("FOCUSED","FROM_HIGHER") == false do
			
			index = index - 1
			
			if t.wrap then
                print("dn")
                if index < 1 then
                    
                    index = # items
                    
                elseif index == orig_index then
                    
                    return false
                    
                end
                
            elseif index < 1 then
				
				index = orig_index
				
				items[index]:set_state("FOCUSED","FROM_HIGHER")
				
                return false
				
			end
			
		end
		
        return true
        
	end
    
	local move_to_higher_index = function()
		
		if index >= #items and not t.wrap then return false end
		
        mediaplayer:play_sound("audio/key-arrows.mp3")
        
		items[index]:set_state("UNFOCUSED")
		
		orig_index = index
		
		index      = index + 1
        
        if t.wrap and index == #items + 1 then index = 1 end
		
		while items[index]:set_state("FOCUSED","FROM_LOWER") == false do
			index = index + 1
			print("up",orig_index,index)
			
			if t.wrap then
                
                if index > #items then
                    
                    index = 1
                    
                elseif index == orig_index then
                    
                    return false
                    
                end
                
            elseif index > #items then
				
				index = orig_index
				
				items[index]:set_state("FOCUSED","FROM_LOWER")
				
                return false
				
			end
			
		end
		
        return true
        
	end
	
	
	local key_events =
		
		t.orientation == "VERTICAL" and
		{
			[keys.Up]    = move_to_lower_index,
			[keys.Down]  = move_to_higher_index,
			[keys.OK]    = function()
                mediaplayer:play_sound("audio/key-buttonpress.mp3")
                
                if items[index].select then  items[index]:select() end
            end,
		} or
		
		t.orientation == "HORIZONTAL" and
		{
			[keys.Left]  = move_to_lower_index,
			[keys.Right] = move_to_higher_index,
			[keys.OK]    = function()
                mediaplayer:play_sound("audio/key-buttonpress.mp3")
                
                if items[index].select then  items[index]:select() end
            end,
		} or
		
		error("Your logic is flawed!",2)
	
	function list:on_key_down(k)
		
		if key_events[k] then return key_events[k]() end
		
	end
	
	function list:define_key_event(k,f)
		
		key_events[k] = f
		
	end
	
	return list
	
end

return make_list