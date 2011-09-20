local crawfish = {}

local clone_srcs = Group{}
    
layers.srcs:add(clone_srcs)

local assets = {}

local assets_loaded = false

local attack_range = 700

crawfish.dump_assets = function()
    
    assert( assets_loaded )
    
    clone_srcs:clear()
    
    assets = {}
    
    assets_loaded = false
    
end

crawfish.load_assets = function()
    
    assert( not assets_loaded )
    
    assets.body       = Image{src = "assets/crawfish/body.png"}
    assets.claw_1     = Image{src = "assets/crawfish/claw-1.png"}
    assets.claw_2     = Image{src = "assets/crawfish/claw-2.png"}
    assets.pupils     = Image{src = "assets/crawfish/pupils.png"}
    
    clone_srcs:add(
        assets.body,      
        assets.claw_1,    
        assets.claw_2,    
        assets.pupils 
    )
    
    assets_loaded = true
    
end

crawfish.create = function(t)
    
    assert( assets_loaded )
    
    local new_c_fish = Group{anchor_point = {120,100}}
    
    local body      = Clone{ name = "body",     source = assets.body }
    local pupils    = Clone{ name = "pupils",   source = assets.pupils, x =  90, y =  20 }
    local claw_l_1  = Clone{ name = "claw_l_1", source = assets.claw_1, x = -20, y = -40 }
    local claw_l_2  = Clone{ name = "claw_l_2", source = assets.claw_2, x =  30, y =   0, anchor_point = {20,20} }
    local claw_r_1  = Clone{ name = "claw_r_1", source = assets.claw_1, x = -20, y = -40 }
    local claw_r_2  = Clone{ name = "claw_r_2", source = assets.claw_2, x =  30, y =   0, anchor_point = {20,20} }
    local claw_l    = Group{ name = "claw_l",   x =110, y = 100, scale = {-1,1}, anchor_point = {-40,0} }
    local claw_r    = Group{ name = "claw_r",   x =130, y = 100, anchor_point = {-40,0}}
    
    claw_l:add(claw_l_2,claw_l_1)
    claw_r:add(claw_r_2,claw_r_1)
    
    new_c_fish:add(body,claw_l,claw_r,pupils)
    
    do
        
        local attacking = false
        
        local left_click_in  = 0
        local right_click_count = 0
        
        local right_arm_dn = {
            
            duration = .25,
            
            on_step = function(s,p)   claw_r.z_rotation = {-30*(1-p),0,0}  end,
            
            on_completed = function()
                
                attacking = false
                
            end
            
        }
        local right_click_in 
        local right_click_out = {
            duration = .15,
            on_step = function(s,p)  claw_r_2.z_rotation = {-60*(1-p)*(1-p),0,0}  end,
            on_completed = function()
                
                right_click_count = right_click_count + 1
                
                if right_click_count < 3 then
                    
                    Animation_Loop:add_animation(right_click_in)
                    
                else
                    
                    Animation_Loop:add_animation(right_arm_dn)
                    
                end
                
            end
        }
        right_click_in = {
            duration = .15,
            on_step = function(s,p)  claw_r_2.z_rotation = {-60*p*p,0,0}  end,
            on_completed = function()
                
                Animation_Loop:add_animation(right_click_out)
                
            end
        }
        local right_arm_up = {
            
            duration = .15,
            
            on_step = function(s,p)   claw_r.z_rotation = {-30*p,0,0}  end,
            
            on_completed = function()
                
                Animation_Loop:add_animation(right_click_in)
                
            end
            
        }
        local left_arm_dn = {
            
            duration = .15,
            
            on_step = function(s,p)   claw_l.z_rotation = {-30*(1-p),0,0}  end,
            
            on_completed = function()
                
                
            end
            
        }
        local left_click_in
        local left_click_out = {
            duration = .15,
            on_step = function(s,p)  claw_l_2.z_rotation = {-60*(1-p)*(1-p),0,0}  end,
            on_completed = function()
                
                left_click_count = left_click_count + 1
                
                if left_click_count < 3 then
                    
                    Animation_Loop:add_animation(left_click_in)
                    
                else
                    
                    Animation_Loop:add_animation(right_arm_up)
                    
                    Animation_Loop:add_animation(left_arm_dn)
                    
                end
                
            end
        }
        left_click_in = {
            duration = .15,
            on_step = function(s,p)  claw_l_2.z_rotation = {-60*p*p,0,0}  end,
            on_completed = function()
                
                Animation_Loop:add_animation(left_click_out)
                
            end
        }
        local left_arm_up = {
            
            duration = .15,
            
            on_step = function(s,p)   claw_l.z_rotation = {-30*p,0,0}  end,
            
            on_completed = function()
                
                Animation_Loop:add_animation(left_click_in)
                
            end
            
        }
        
        function new_c_fish:attack()
            
            if attacking then
                return false
            end
            attacking = true
            Animation_Loop:add_animation(left_arm_up)
            left_click_count  = 0
            right_click_count = 0
            return true
        end
        
    end
    return new_c_fish
end

return crawfish