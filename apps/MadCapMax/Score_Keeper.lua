--the Object
local sk = {}

--attributes
local total = {}

local current_lvl = {}

--resetter methods
function sk:reset_all()
    
    total = {}
    
    current_lvl = {}
    
end

function sk:reset_lvl()
    
    current_lvl = {}
    
end

function sk:new_lvl()
    
    for k,v in pairs(current_lvl) do
        
        total[k] = v + (total[k] or 0)
        
    end
    
    current_lvl = {}
    
end

--score incrementer method
function sk:inc(s,amt)
    
    amt            = (type(amt) == number) and amt or 1
    
    current_lvl[s] = amt + (current_lvl[s] or 0)
    
    --total[s]       = amt + (total[s] or 0)
    
end


--Accessor methods

--upval
local read_only

function sk:current_level()
    
    read_only = {}
    
    for k,v in pairs(current_lvl) do
        
        read_only[k] = v
        
    end
    
    return read_only
    
end

function sk:total()
    
    read_only = {}
    
    for k,v in pairs(total) do
        
        read_only[k] = v
        
    end
    
    return read_only
    
end

--singleton
return sk