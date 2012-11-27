
local channels = {}

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
            
            for i,c in ipairs(channels[name].clones) do
                
                c.source = self
                c.anchor_point = {self.w/2,self.h/2}
                
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
    
    c.anchor_point = channels[name].image.loaded and {c.w/2,c.h/2} or {c.w-50,c.h/2}
    
    table.insert( channels[name].clones, c )
    
    return c
    
end