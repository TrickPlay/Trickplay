
local make_enum = function(array_of_states)
    
    assert(array_of_states~=nil)
    assert(type(array_of_states) == "table")
    assert(#array_of_states > 1)
    
    --object
    local enum = {}
    
    --attributes
    
    local current_state = array_of_states[1]
    local states = {}
    local state_change_functions = {}
    
    --init attributes
    for _,state_name in pairs(array_of_states) do
        assert(states[state_name] == nil)
        states[state_name] = state_name
    end
    
    for _,prev_state in pairs(states) do
		state_change_functions[prev_state] = {}
		for _,next_state in pairs(states) do
			if prev_state ~= next_state then 
				state_change_functions[prev_state][next_state] = {}
			end
		end
	end
    dumptable(states)
    --methods
    enum.has_state = function(self,state)
        if states[state] == state then
            return true
        else
            return false
        end
    end
    
    enum.add_state_change_function = function(self, new_function, old_state, new_state)
		assert(type(new_function)=="function", "You attempted to add an element of type \""..type(new_function).."\". This function only accepts other functions")
		if old_state ~= nil then assert(states[old_state] ~= nil, tostring(old_state).." is not a State") end
		if new_state ~= nil then assert(states[new_state] ~= nil, tostring(new_state).." is not a State") end
		if old_state == nil then
            for _,old_state in pairs(states) do
                if new_state == nil then
                    for _,new_state in pairs(states) do
						if old_state ~= new_state then 
							table.insert(state_change_functions[old_state][new_state],new_function)
						end
                    end
                else
					if old_state ~= new_state then 
						table.insert(state_change_functions[old_state][new_state],new_function)
					end
                end
            end
		else
			if new_state == nil then
                for _,new_state in pairs(states) do
					if old_state ~= new_state then 
						table.insert(state_change_functions[old_state][new_state],new_function)
					end
                end
            else
				assert(old_state ~= new_state, "Attempting to assign a state change function for same state")
                table.insert(state_change_functions[old_state][new_state],new_function)
            end
		end
	end

    enum.change_state_to = function(self, new_state)
		if current_state == new_state then
			print("warning changing state to current state")
			return
		end
		assert(states[new_state] ~= nil, tostring(new_state).." is not a State")
		for i,func in ipairs(state_change_functions[current_state][new_state]) do
			func(current_state,new_state)
		end
		current_state = new_state
	end
    
    enum.current_state = function()
        return current_state
    end
    
    enum.states = function()
        return array_of_states
    end
    
    return enum
end

return make_enum