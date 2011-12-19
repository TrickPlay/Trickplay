

local app_list = apps:get_for_current_profile()

local icons = {}
for k,v in pairs(app_list) do
    
    i = Image{}
    
    if i:load_app_icon(v.id,"launcher-icon.png") then
        i.anchor_point = { i.w/2, i.h/2 }
        table.insert(icons,i)
    elseif i:load_app_icon(v.id,"launcher-icon.jpg") then
        i.anchor_point = { i.w/2, i.h/2 }
        table.insert(icons,i)
    end
    
end


animate{
    duration = math.random(4000,6000),
    z_rotation = (720,1080),
    y = 900,
    x = 500,
}

local curr_i = 1
local start_x = 0
Timer{
    interval = 1000,
    on_timer = function(self)
        
        if icons[curr_i].animating then
            
            
            
        else
            
            icons[curr_i].animating = true
            
            start_x = math.random(-200,300)
            
            icons[curr_i]:set{
                x = start_x,
                y = -300,
                z_rotation = {0,0,0},
            }
            
            icons[curr_i]:animate{
                
                duration = math.random(4000,6000),
                
                z_rotation = (720,1080),
                
                y = 900,
                
                x = start_x+math.random(200,300),
                
                on_completed = function()
                    
                    self.animating = false
                    
                end,
            }
            
            curr_i = ( curr_i % (# icons)) + 1
            
        end
        
    end,
}