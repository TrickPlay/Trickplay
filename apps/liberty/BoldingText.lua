
local g_fonts = {
    "InterstateProExtraLight",
    "InterstateProLight",
    "InterstateProRegular",
    "InterstateProBold",
}

local create = function(t)
    if type(t) ~= "table" then error("Expected table. Received "..type(t),2) end
    
    local instance = Text{
        text  = t.text,
        color = t.color,
    }
    --------------------------------------------------------------------
    
    local ws = {}
    local fonts = {}
    
    for i,f in ipairs(g_fonts) do
        fonts[i] = f.." "..tostring(t.sz).."px"
        --print(fonts[i])
        instance.font   = fonts[i]
        ws[i]    = instance.w
    end
    --------------------------------------------------------------------
    
    local w, i
    
    local w_len = #ws - 1
    
    local scale = {1,1}
    
    instance.expand  = Timeline{
        duration = t.duration,
        on_new_frame = function(tl,ms,p)
            
            i = math.ceil(w_len*p)
            i = i == 0 and 1 or i
            --print(i)
            p = (p - (i-1)/w_len)*w_len
            
            scale[1] = 1+(ws[i+1]/ws[i]-1 )* p
            
            instance.scale = scale
            
            instance.font  = fonts[i]
            --print(instance.font,scale[1])
        end,
        on_completed = function(tl)
            instance.font  = fonts[#fonts]
            instance.scale = 1
        end,
    }
    
    instance.contract = Timeline{
        duration = t.duration,
        on_new_frame = function(tl,ms,p)
            
            p = 1-p
            
            i = math.ceil(w_len*p)
            i = i == 0 and 1 or i
            
            p = (p - (i-1)/w_len)*w_len
            
            scale[1] = 1+(ws[i+1]/ws[i]-1 )* p
            --print(i,scale[1])
            instance.scale = scale
            
            instance.font  = fonts[i]
        end,
        on_completed = function(tl)
            instance.font  = fonts[1]
            instance.scale = 1
        end,
    }
    --------------------------------------------------------------------
    instance.font = fonts[1]
    return instance
    
end

return create