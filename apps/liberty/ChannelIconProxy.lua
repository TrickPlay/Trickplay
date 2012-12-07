
local channels = {}

local max_h = 70

local size_image = function(obj,orig_size)
    local scale = max_h / orig_size[2]
    
    if scale > 1 then
        obj.base_scale = 1
        return
    end
    --obj.w = obj.w * scale
    --obj.h = obj.h * scale
    obj.scale = scale
    obj.base_scale = scale
end

return function(name,src)
    
    local t = Text{
        name = name.." - text proxy",
        text = name,
        font = "InterstateProBold 36px",
        color = "white",
    }
    
    local i = Image{
        name = name,
        src   = src,
        async = true,
        on_loaded = function(self,failed)
            if failed then 
                --error("loading "..src.." failed",2)
                self:unparent()
                return
            end
            
            local ap_x, ap_y
            for i,c in ipairs(channels[name].clones) do
                
                ap_x = c.anchor_point[1] / c.w
                ap_y = c.anchor_point[2] / c.h
                
                c.source = self
                size_image(c,self.size)
                
                
                c.anchor_point = {ap_x*c.w,ap_y*c.h}
            end
            t:unparent()
            channels[name].text = nil
        end
    }
    
    hidden_assets_group:add(i,t)
    
    channels[name] = {text = t,image = i,clones = {}}
    
    
end, function(name)
    
    if channels[name] == nil then error(tostring(name).." not loaded",2) end
    
    local c = Clone{
        source = 
            channels[name].image.loaded and 
            channels[name].image or 
            channels[name].text
    }
    if channels[name].image.loaded then 
        size_image(c,channels[name].image.size) 
    else
        c.base_scale = 1
    end
    
    c.anchor_point = channels[name].image.loaded and {c.w/2,c.h/2} or {c.w-50,c.h/2}
    
    table.insert( channels[name].clones, c )
    
    return c
    
end