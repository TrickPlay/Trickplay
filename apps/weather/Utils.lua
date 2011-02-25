
function apply_func_to_leaves(t,f,p)
    for k,v in pairs(t) do
        --recurse through other tables
        if type(v) == "table" then
            apply_func_to_leaves(v,f,p)
        else
            f(p,v)
        end
    end
end