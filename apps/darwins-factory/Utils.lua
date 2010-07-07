Utils = {}

function Utils.mixin(table_a, table_b)
    table_a = table_a or {}
    table_b = table_b or {}
    for k,v in pairs(table_b) do
        table_a[k] = v
    end
    return table_a
end

function Utils.clamp(a, b, c)
    if(b < a) then
        return a
    end
    if(b > c) then
        return c
    end
    print("here")
    return b
end
