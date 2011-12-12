
local ken_burns = {}

function ken_burns:init(p)
end

function ken_burns:create(p)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    local instance = Group{
        --[[
        clip = {
            0,
            0,
            p.visible_w or error("must pass 'visible_w'",2),
            p.visible_h or error("must pass 'visible_h'",2),
        }
        --]]
    }
    
    
    
    local q = p.q or error("must pass a 'q' of images",2)
    
    if #q < 2 then error("must have at least 2 images",2) end
    
    for i,img in ipairs(q) do
        
        if img.w*2 < p.visible_w then error("the "..i.."th element in the q is too narrow",2) end
        if img.h   < p.visible_h then error("the "..i.."th element in the q is too short",2)  end
        
    end
    
    local curr_item = Clone{source = q[1]}
    local prev_item = Clone{}
    
    instance:add(curr_item,prev_item)
    
    local vx      = 0
    local vy      = 0
    local t_scale = 1
    
    local curr_i  = 1
    
    local prev_ms = 0
    
    local scale = Interval(0,0)
    local tl = Timeline{
        duration = 20000,
        on_new_frame = function(self,ms,p)
            
            curr_item.x = curr_item.x + vx*(ms-prev_ms)
            curr_item.y = curr_item.y + vy*(ms-prev_ms)
            ---[[
            curr_item.scale = {
                scale:get_value(p),
                scale:get_value(p),
            }
            --]]
            prev_ms = ms
        end,
        on_completed = function(self)
            
            prev_ms = 0
            
            print("goo")
            prev_item.source = curr_item.source
            
            prev_item.x     = curr_item.x
            prev_item.y     = curr_item.y
            prev_item.scale = {
                curr_item.scale[1],
                curr_item.scale[2],
            }
            prev_item.opacity = 255
            prev_item:animate{
                duration = 2000,
                opacity  = 0,
                x = prev_item.x +vx*.2/.8*self.duration,
                y = prev_item.y +vy*.2/.8*self.duration,
            }
            
            curr_i = curr_i % # q + 1
            
            curr_item.source = q[curr_i]
            vx = (p.visible_w - curr_item.w)/self.duration*.8
            
            if math.random(1,2) == 2 then
                
                curr_item.x = 0
                
            else
                
                vx = -vx
                
                curr_item.x = -(curr_item.w - p.visible_w)
                
            end
            
            
            curr_item.y = -(curr_item.h- p.visible_h)*math.random()
            
            vy = ( -(curr_item.h- p.visible_h)*math.random() - curr_item.y)/self.duration*.8
            
            if math.random(1,2) == 2 then
                scale.to   = 1+.1+.2*math.random()
                scale.from = 1
            else
                scale.to   = 1
                scale.from = 1+.1+.2*math.random()
            end
            
            self:start()
            
        end
    }
    
    function instance:play()
        
        tl:start()
        
    end
    
    function instance:pause()
        
        tl:pause()
        
    end
    
    tl:on_completed()
    
    return instance
    
end


return ken_burns