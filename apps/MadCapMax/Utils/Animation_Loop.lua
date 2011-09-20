local Animation_Loop = {}

local in_the_loop = false

local     terminating_animations = {}
local         looping_animations = {}
local non_terminating_animations = {}

local states     = {}
local curr_state = {
    terminating_animations     = terminating_animations,
    looping_animations         = looping_animations,
    non_terminating_animations = non_terminating_animations,
}

local previous_state
local abort

local has_been_initialized = false

function Animation_Loop:init(t)
    
    if has_been_initialized then
        
        error("Animation_Loop has already been initialized", 2)
        
    end
    
    if type(t.states) == "table" then
        
        for i = 1, # t.states do
            
            if type(t.states[i]) ~= "string" then
                
                error("'states' table must be strings (i.e. state names)",2)
                
            end
            
            curr_state = {
                terminating_animations     = {},
                looping_animations         = {},
                non_terminating_animations = {},
                name                       = t.states[i]
            }
            
            if states[curr_state.name] then
                
                error("'"..curr_state.name.."' was used more than once.",2)
                
            end
            
            states[curr_state.name] = curr_state
            
        end
        
        curr_state = states[t.states[1]]
        
        terminating_animations     = curr_state.terminating_animations
        looping_animations         = curr_state.looping_animations
        non_terminating_animations = curr_state.non_terminating_animations
        
    elseif type(t.states) ~= "nil" then
        
        error("'states' must be a table or nil",2)
        
    else
        
        curr_state = {
            terminating_animations     = {},
            looping_animations         = {},
            non_terminating_animations = {},
            name                       = "default"
        }
        
        terminating_animations     = curr_state.terminating_animations
        looping_animations         = curr_state.looping_animations
        non_terminating_animations = curr_state.non_terminating_animations
        
    end
    
    has_been_initialized = true
    
end

--[[]
function Animation_Loop:suspend_current_state()
    
    if in_the_loop then
        
        abort = true
        
    end
    
    states[curr_state] = curr_state
    
    previous_state = curr_state
    
    terminating_animations     = {}
    looping_animations         = {}
    non_terminating_animations = {}
    
    curr_state = {
        terminating_animations     = terminating_animations
        looping_animations         = looping_animations
        non_terminating_animations = non_terminating_animations
    }
    
    return previous_state
    
end
--]]
function Animation_Loop:clear_state(state)
    
    states[state] = {
        terminating_animations     = {},
        looping_animations         = {},
        non_terminating_animations = {},
        name                       = state
    }
    
    if curr_state.name == state and in_the_loop then
        
        abort = true
        
        terminating_animations     = curr_state.terminating_animations
        looping_animations         = curr_state.looping_animations
        non_terminating_animations = curr_state.non_terminating_animations
        
    end
    
end
function Animation_Loop:switch_state_to(state)
    
    if not has_been_initialized then
        
        error("call Animation_Loop:init{} first", 2)
        
    end
    
    if in_the_loop then
        
        abort = true
        
    end
    
    if curr_state.name == state then
        
        error( "already on that state", 2 )
        
    end
    
    if type(state) ~= "string" and states[state] == nil then
        
        error( "parameter is not a state", 2 )
        
    end
    
    --states[curr_state] = curr_state
    
    --states[state]      = nil
    
    curr_state       = states[state]
    --dumptale(curr_state)
    terminating_animations     = curr_state.terminating_animations
    looping_animations         = curr_state.looping_animations
    non_terminating_animations = curr_state.non_terminating_animations
    
end

function Animation_Loop:set_progress(t,p)
    
    if not has_been_initialized then
        
        error("call Animation_Loop:init{} first", 2)
        
    end
    
    if terminating_animations[t] or
        looping_animations[t] then
        
        if p < 0 or p > 1 then
            
            error("progress is a value between 0 and 1, you gave "..p,2)
            
        end
        
        t.elapsed = t.duration*p
        
    elseif non_terminating_animations[t] then
        
        error("tried to state progress of a non terminating animation",2)
        
    else
        
        error("not being animated",2)
        
    end
    
end

function Animation_Loop:has_animation(t)
    
    if not has_been_initialized then
        
        error("call Animation_Loop:init{} first", 2)
        
    end
    
    if terminating_animations[t] or
        looping_animations[t]    or
        non_terminating_animations[t] then
        
        return true
        
    end
    
    return false
end


function Animation_Loop:delete_animation(t)
    
    if not has_been_initialized then
        
        error("call Animation_Loop:init{} first", 2)
        
    end
    
    if terminating_animations[t] then
        
        terminating_animations[t] = nil
        
    elseif looping_animations[t] then
        
        looping_animations[t] = nil
        
    elseif non_terminating_animations[t] then
        
        non_terminating_animations[t] = nil
        
    else -- dump everything before throwing the error
        
        dumptable( terminating_animations     )
        dumptable( looping_animations         )
        dumptable( non_terminating_animations )
        
        print( "Animation_Loop:delete_animation(", t ,")" )
        error( "tried to delete an animation that wasn't animating", 2 )
    end
    
end


function Animation_Loop:add_animation(t,s)
    
    if not has_been_initialized then
        
        error("call Animation_Loop:init{} first", 2)
        
    end

    -- sanitize the input table
    if type(t) ~= "table" then
        
        error("add_animation only receives a table as a parameter",2)
        
    end
    if type(t.on_step) ~= "function" then
        
        error("add_animation must receive an 'on_step' function in the table parameter",2)
        
    end
    if t.loop == true and (type(t.duration) ~= "number" or t.duration < 0) then
        
        error("if the 'on_step' function is going to loop it must have a duration, "..
            "otherwise remove the loop attribute so that it is a non-terminating animation",2
        )
        
    end
    
    if s == nil then
        
        s = curr_state.name
        
    end
    
    if states[s] == nil then
        
        error(
            "Passed invalid state: "..s, 2
        )
        
    end
    
    if self:has_animation(t) then
        
        error("this table is already being animated",2)
        
    end
    
    
    --add it to the loop
    if t.loop then
        print(s)
        
        t.elapsed = 0
        
        states[s].looping_animations[t] = t.on_step
        
    elseif t.duration then
        print(s)
        
        t.elapsed = 0
        
        states[s].terminating_animations[t] = t.on_step
        
    else
        print(s)
        states[s].non_terminating_animations[t] = t.on_step
        
    end
    
    return t
end

function Animation_Loop:loop(s)
    
    in_the_loop = true
    
    abort = false
    
    for t,f in pairs(looping_animations) do
        
        if abort then in_the_loop = false return end
        
        t.elapsed = t.elapsed + s
        
        if t.elapsed > t.duration then
            
            t.elapsed = t.elapsed % t.duration
            
            f(t.elapsed,t.elapsed / t.duration)
            
            if t.on_loop then t.on_loop(t) end
            
        else
            
            f(t.elapsed,t.elapsed / t.duration)
            
        end
        
    end
    
    
    for t,f in pairs(terminating_animations) do
        
        if abort then in_the_loop = false return end
        
        t.elapsed = t.elapsed + s
        
        if t.elapsed > t.duration then
            
            f(t.duration,1)
            
            if t.on_completed then     t.on_completed(t)     end
            
            terminating_animations[t] = nil
            
        else
            
            f(t.elapsed,t.elapsed / t.duration)
            
        end
        
    end
    
    
    for t,f in pairs(non_terminating_animations) do
        
        if abort then in_the_loop = false return end
        
        f(s)
        
    end
    
    in_the_loop = false
    
end

return Animation_Loop