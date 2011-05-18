--[[ FILE CONTENTS
    
    The Enum of all possible states

    The Game State Manager
    
    The App Loop
--]]

--[[
local STATES = {
	OFFLINE = {},--"the app was not launched yet",
	LOADING = {},--"The app is loading from groupon, user has no control",
	ROLODEX = {},--"The Cards have been created and are in the rolodex style",
	ZIP     = {},--"Viewing ZIP Modal menu, entering a new location leads to loading",
	PHONE   = {},--"Viewing Phone Modal menu, entering number leads to rolodex"
}

--should not be modified, unfortunately a call to 'rawset' can supersede this
setmetatable(
    STATES,
    {
        __newindex = function(t,k,v)
            error("Error: Attempt to modify STATES. Received STATES[\""..k.."\"]= \""..v"\"")
        end
    }
)

--reverse lookup, used for checking existance of a state
local states_r = {}
for state_name,state_value in pairs(STATES) do
	states_r[state_value] = state_name
end
--]]

--Game State Manager
local App_State = {
	--app specific state information
	cards = {},
	phone = settings.phone,
	zip   = settings.zip,
	rolodex = nil,
	--needed
	state = ENUM({"OFFLINE","LOADING","ROLODEX","ZIP","PHONE"})
}
--[[
do
	--protected variables
	local current_state = STATES.OFFLINE
	--the functions called during a state change
	local state_change_functions = {}
	
	--inititalize the 2D hastable of functions
	for _,prev_state in pairs(STATES) do
        App_State.states[prev_state] = {}
		state_change_functions[prev_state] = {}
		for _,next_state in pairs(STATES) do
			if prev_state ~= next_state then 
				state_change_functions[prev_state][next_state] = {}
			end
		end
	end
	
	--adds a function to be called when a state change occurs
	App_State.add_state_change_function = function(self, new_function, old_state, new_state)
		assert(type(new_function)=="function", "You attempted to add an element of type \""..type(new_function).."\". This function only accepts other functions")
		if old_state ~= nil then assert(states_r[old_state] ~= nil, tostring(old_state).." is not a State") end
		if new_state ~= nil then assert(states_r[new_state] ~= nil, tostring(new_state).." is not a State") end
		if old_state == nil then
            for _,old_state in pairs(STATES) do
                if new_state == nil then
                    for _,new_state in pairs(STATES) do
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
                for _,new_state in pairs(STATES) do
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
    
    
	App_State.change_state_to = function(self, new_state)
		if current_state == new_state then
			print("warning changing state to current state")
			return
		end
		assert(states_r[new_state] ~= nil, tostring(new_state).." is not a State")
		print("changing state")
		for i,func in ipairs(state_change_functions[current_state][new_state]) do
			func(current_state,new_state)
		end
		current_state = new_state
	end
    
    
	App_State.current_state = function(self)
		return current_state
	end
end
--]]

local Idle_Loop = {}

do
    local msecs = 0
    local paused = true
    local parameters = {}
    
    local animate_list = {}
    local iterated_list = {}
    
    --the list of items to be deleted and added, these are needed to prevent items
    --from being removed while the idle loop is moving through the iterated list
    local to_be_deleted_r = {}
    local to_be_deleted   = {}
    local to_be_added_r   = {}
    local to_be_added     = {}
    
    --flag, used to delay the addition/removal of func_table's to the animate_list
    --while it is being iterated across
    local in_idle_loop = false
    
    
    
    Idle_Loop.add_function = function(self,new_function, containing_object, duration,loop,delay)
        
		assert(type(new_function) == "function","Attempted to add object of type \""..
			type(new_function).."\"to the idle loop. Need object of type \"function\"")
        if to_be_deleted_r[new_function] ~= nil then
			
			--error("function is already being deleted from the idle_loop")
			
			for i = 1, #to_be_deleted do
				if to_be_deleted[i] == new_function then
					table.remove(to_be_deleted,i)
					to_be_deleted_r[new_function] = nil
					
					parameters[new_function].duration = duration
					parameters[new_function].loop     = loop or false
					parameters[new_function].elapsed  = 0
					parameters[new_function].object   = containing_object or {}
					return
				end
			end
			
			error("was in to_be_deleted_r but not to_be_deleted?!?!?")
		elseif to_be_added_r[new_function] ~= nil then
			
			parameters[new_function].duration = duration
			parameters[new_function].loop     = loop or false
			parameters[new_function].elapsed  = 0
			parameters[new_function].object   = containing_object or {}
			return
			
        elseif iterated_list[new_function] ~= nil then
			
			error("function is already iterating in the idle_loop")
			
        else
            
            parameters[new_function] = {
                duration = duration,
                loop     = loop or false,
                elapsed  = 0,
                object   = containing_object or {},
            }
            if in_idle_loop then
                table.insert(to_be_added,new_function)
            else
                iterated_list[new_function] = containing_object or {}
            end
        end
        
    end
    
	Idle_Loop.has_function = function(self,func)
		if	to_be_deleted_r[func] or
			iterated_list[func]   or
			to_be_added_r[func]   then
			
			return true
        else
            return false
        end
	end
	
    Idle_Loop.remove_function = function(self,old_function)
        if in_idle_loop and iterated_list[old_function] then
            table.insert(to_be_deleted,old_function)
			to_be_deleted_r[old_function] = true
		elseif to_be_added_r[new_function] ~= nil then
			for i = 1, #to_be_added do
				if to_be_added[i] == old_function then
					table.remove(to_be_added,i)
					to_be_added_r[old_function] = nil
					parameters[old_function]    = nil
					return
				end
			end
			error("was in to_be_added_r but not to_be_added?!?!?")
        else
            iterated_list[old_function] = nil
            parameters[old_function]    = nil
        end
    end
    
    Idle_Loop.loop = function(self,seconds)
        
        msecs = seconds*1000
		
		--print(msecs)
		
        --may need an if to handle the first execution,
        --since initial seconds value will be way larger than usual
        for i = #to_be_added, 1, -1 do
            
            iterated_list[to_be_added[i]] = parameters[to_be_added[i]].object
            to_be_added[i] = nil
            
        end
        
        in_idle_loop = true
        
        for func, object in pairs( iterated_list ) do
            if to_be_deleted_r[func] == nil then
				if parameters[func].duration ~= nil then
					parameters[func].elapsed = parameters[func].elapsed + msecs
					if parameters[func].elapsed > parameters[func].duration then
						
						func(
							object,
							msecs + parameters[func].duration - parameters[func].elapsed,
							1
						)
						
						if parameters[func].loop then
							
							parameters[func].elapsed = parameters[func].elapsed - parameters[func].duration
							
							func(
								object,
								parameters[func].elapsed,
								parameters[func].elapsed/parameters[func].duration
							)
						else
							table.insert(to_be_deleted,func)
							to_be_deleted_r[func] = true
						end
					else
						func(
								object,
								parameters[func].elapsed,
								parameters[func].elapsed/parameters[func].duration
							)
					end
				else
					func(
						object,
						msecs
					)
				end
			end
			
        end
        
        in_idle_loop = false
        
        
        for i = #to_be_deleted, 1, -1 do
            
			to_be_deleted_r[to_be_deleted[i]] = nil
            iterated_list[to_be_deleted[i]]   = nil
            parameters[to_be_deleted[i]]      = nil
            to_be_deleted[i]                  = nil
            
        end
    end
    
    Idle_Loop.pause = function()
        paused = true
        idle.on_idle = nil
    end
    
    Idle_Loop.resume = function()
        paused = false
        idle.on_idle = Idle_Loop.loop
    end
end

--[[
delay = function(delay_amount, function_to_call, ...)
	
	assert(type(delay_amount)=="number",
		"Received type\""..type(delay_amount)..
		"\" for the delay amount, must be a number."
	)
	
	assert(
		type(function_to_call) == "function",
		"Received type \""..type(function_to_call)..
		"\" for the callback, can only delay the call to a function."
	)
	
	Timer{
		interval = delay_amount,
		
		on_timer = function(self)
			self:stop()
			
			
			function_to_call(...)
		end
	}:start()
end
--]]

return App_State, Idle_Loop