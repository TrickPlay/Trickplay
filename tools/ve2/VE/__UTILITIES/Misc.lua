MISC = true

function bound_to(lower,value,upper)
    
    if lower > value then return lower
    elseif upper < value then return upper
    else return value end
    
end