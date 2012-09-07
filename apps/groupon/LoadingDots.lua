local num_dots = 12
local radius   = 80

make_loading_g = function()
    
    local loading_g = Group{x=300,y=300}
    
    loading_g:add(Clone{source=assets.g,anchor_point = {assets.g.w/2,assets.g.h/2}})
    
    local message_s = Text{
        text  = "",
        font  = "Sans 40px",
        color = "000000",
        x     = assets.g.w+2,
        y     = 2,
    }
    message_s.anchor_point={0,message_s.h/2}
    local message = Text{
        text  = "",
        font  = "Sans 40px",
        color = "86ad53",
        x     = assets.g.w,
        on_text_changed = function(self)
            message_s.text = self.text
        end
    }
    message.anchor_point={0,message.h/2}
    loading_g:add(message_s,message)
    loading_g.dots = {}
    
    for i = 1,num_dots do
        
        loading_g.dots[i] = Clone{source=assets.dot}
        
        loading_g.dots[i].anchor_point = {loading_g.dots[i].w/2,loading_g.dots[i].h/2}
        
        loading_g.dots[i].x = radius*math.cos(math.pi/180*360*(i/num_dots))
        loading_g.dots[i].y = radius*math.sin(math.pi/180*360*(i/num_dots))
        
        loading_g.dots[i].spin = function(self,p)
            self.opacity = 255*((1-p)-i/num_dots)
        end
        
        loading_g:add(loading_g.dots[i])
    end
    
    loading_g.spinning = function(self,msecs,p)
        for i,d in ipairs(loading_g.dots) do
            d.opacity = 255*((1-p)-i/num_dots)
        end
    end
    
    loading_g.fade_out = function(self,msecs,p)
        self.opacity=255*(1-p)
        if p == 1 then
            Idle_Loop:remove_function(self.spinning)
            loading_g:message("")
        end
    end
    
    loading_g.message = function(self,t)
        
        message.text = t
        
    end
    
    return loading_g    
end

return make_loading_g()