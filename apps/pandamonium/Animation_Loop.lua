local Animation_Loop = {}

local     terminating_animations = {}
local         looping_animations = {}
local non_terminating_animations = {}

function Animation_Loop:set_progress(t,p)
    if terminating_animations[t] or
        looping_animations[t] then
        
        if p < 0 or p > 1 then error("progress is a value between 0 and 1, you gave "..p,2) end
        
        t.elapsed = t.duration*p
        
    elseif non_terminating_animations[t] then
        error("tried to set progress of a non terminating animation",2)
    else
        error("not being animated",2)
    end
end
function Animation_Loop:has_animation(t)
    
    if terminating_animations[t] or
        looping_animations[t] or
        non_terminating_animations[t] then
        
        return true
        
    end
    
    return false
end


function Animation_Loop:delete_animation(t)
    if terminating_animations[t] then
        terminating_animations[t] = nil
    elseif looping_animations[t] then
        looping_animations[t] = nil
    elseif non_terminating_animations[t] then
        non_terminating_animations[t] = nil
    else
        dumptable(terminating_animations)
        dumptable(looping_animations)
        dumptable(non_terminating_animations)
        error("tried to delete an animation that wasn't animating",2)
    end
end


function Animation_Loop:add_animation(t)
    if type(t) ~= "table" then
        error("add_function only receives a table as a parameter",2)
    end
    if type(t.on_step) ~= "function" then
        error("add_function must receive an 'on_step' function in the table parameter",2)
    end
    if t.loop == true and (type(t.duration) ~= "number" or t.duration < 0) then
        error("if the 'on_step' function is going to loop it must have a duration, "..
            "otherwise remove the loop attribute so that it is a non-terminating animation",2
        )
    end
    
    if self:has_animation(t) then
        --[[
        if t.copy == true then
            t={
                on_step  = t.on_step,
                copy     = t.copy,
                loop     = t.loop,
                duration = t.duration,
            }
        else
        --]]
            error("this table is already being animated, if you want a duplicate, set 'copy' to true",2)
        --end
    end
    
    if t.loop then
        t.elapsed = 0
        looping_animations[t] = t.on_step
    elseif t.duration then
        t.elapsed = 0
        terminating_animations[t] = t.on_step
    else
        non_terminating_animations[t] = t.on_step
    end
end

local p

function Animation_Loop:loop(s)
    
    
    for t,f in pairs(looping_animations) do
        
        t.elapsed = t.elapsed + s
        
        if t.elapsed > t.duration then
            
            f(t.duration,1)
            
            t.elapsed = 0
            
            if t.on_loop then    t:on_loop()   end
            
        else
            
            p = t.elapsed / t.duration
            
            f(t.elapsed,p)
            
        end
    end
    
    
    for t,f in pairs(terminating_animations) do
        
        t.elapsed = t.elapsed + s
        
        if t.elapsed > t.duration then
            
            f(t.duration,1)
            
            if t.on_completed then     t.on_completed()     end
            
            terminating_animations[t] = nil
            
        else
            
            p = t.elapsed / t.duration
            
            f(t.elapsed,p)
            
        end
        
    end
    
    
    for t,f in pairs(non_terminating_animations) do
        
        f(s)
        
    end
    
    
end

return Animation_Loop