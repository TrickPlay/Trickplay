TYPECHECKING = true

function is_table_or_nil(name,input)
    
    return input == nil and {} or
        
        type(input) == "table" and input or 
        
        error(name.." requires a table or nil as input",3)
    
end

--This function needs a better name
function matches_nil_table_or_type(constructor,req_type,input)
    
    return input == nil and constructor() or
        type(input) == "table" and (input.type == req_type and input or constructor(input)) or
        error("input did not match nil, table, or "..req_type,2)
    
end

