TABLEMANIPULATION = true

function recursive_overwrite(target, source)
    
    if target == nil then target = {} end
    
    for k,v in pairs(source) do
        
        --if field is a table
        if type(v) == "table" then
            
            --recurse
            if type(target[k]) == "table" then
                
                recursive_overwrite(target[k],v)
                
            --... and clone
            elseif target[k] == nil then
                
                target[k] = recursive_overwrite( {}, v)
                
            end
            
        --else, just copy value
        elseif target[k] == nil then
            
            target[k] = v
            
        end
        
    end
    
    return target
    
end
