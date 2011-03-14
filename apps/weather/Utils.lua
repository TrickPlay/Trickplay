
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

function Shadow_Text(t)
    local g = Group{}
    local base_txt = Text(t)
    local shadow_txt = Text(t)
    
    if t.x ~= nil then g.x = t.x end

    if t.y ~= nil then g.y = t.y end
    
    if t.position ~= nil then g.position = {t.position[1],t.position[2]} end
    
    base_txt.position   = {0,0}
    shadow_txt.position = {2,2}
    shadow_txt.color    = {0,0,0}
    shadow_txt.opacity  = 255*.4
    
    g:add(shadow_txt,base_txt)
    
    
    local mt = {}
    
    function mt.__newindex(t,k,v)
        
        base_txt[k]   = v
        shadow_txt[k] = v
        
        base_txt.position   = {0,0}
        shadow_txt.position = {2,2}
        shadow_txt.color    = {0,0,0}
        shadow_txt.opacity  = 255*.4
    end
    setmetatable(g.extra,mt)
    
    return g
end