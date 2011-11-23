
--------------------------------------------------------------------------------
-- Object                                                                     --
--------------------------------------------------------------------------------

local frog = {}

local clone_srcs = Group{}
    
layers.srcs:add(clone_srcs)

local assets = {}

local assets_loaded = false

local attack_range = 700

frog.dump_assets = function()
    
    assert( assets_loaded )
    
    clone_srcs:clear()
    
    assets = {}
    
    assets_loaded = false
    
end

frog.load_assets = function()
    
    assert( not assets_loaded )
    
    assets.body       = Image{src = "assets/frog/body.png"}
    assets.feet       = Image{src = "assets/frog/feet.png"}
    assets.head       = Image{src = "assets/frog/head.png"}
    assets.jaw        = Image{src = "assets/frog/jaw.png"}
    assets.mouth      = Image{src = "assets/frog/mouth.png"}
    assets.pupils     = Image{src = "assets/frog/pupils.png"}
    assets.throat     = Image{src = "assets/frog/throat.png"}
    assets.tongue_end = Image{src = "assets/frog/tongue-end.png"}
    assets.tongue_mid = Image{src = "assets/frog/tongue-long.png"}
    
    clone_srcs:add(
        assets.body,      
        assets.feet,    
        assets.jaw,       
        assets.mouth,        
        assets.head,     
        assets.pupils,    
        assets.throat,    
        assets.tongue_end,
        assets.tongue_mid
    )
    
    assets_loaded = true
end


frog.create = function(t)
    
    assert( assets_loaded )
    
    local new_frog = Group{anchor_point = {80,40}}
    
    --Visual pieces
    local body   = Clone{ name = "body",   source = assets.body      , x =   0, y =    0, }
    local feet   = Clone{ name = "feet",   source = assets.feet      , x =   0, y =   50, }
    local head   = Clone{ name = "head",   source = assets.head      , x =   0, y =  -70, }
    local jaw    = Clone{ name = "jaw",    source = assets.jaw       , x =   0, y =  -20, }
    local mouth  = Clone{ name = "mouth",  source = assets.mouth     , x =  75, y = -200, anchor_point = {30,-200} }
    local pupils = Clone{ name = "pupils", source = assets.pupils    , x =  53, y =  -34, }
    local throat = Clone{ name = "throat", source = assets.throat    , x =  75, y =    0, anchor_point = {50,0} }
    local tongue = Group{ name = "tongue", x = 75, y = 15 }
    local t_end  = Clone{ name = "t_end",  source = assets.tongue_end, x =   0, y =    0, anchor_point = {15-30,10} }
    local t_mid  = Clone{ name = "t_mid",  source = assets.tongue_mid, x =   0, y =    0, anchor_point = {20,5} }
    
    tongue:add(t_mid,t_end)
    
    tongue:hide()
    
    new_frog:add(body,feet,throat,jaw,mouth,head,pupils,tongue)
    
    
    --Methods
    
    do -- RIBBIT
        
        local ribbiting = false
        
        local function scale_f(x) return 1 - math.pow(2*x-1,4) end
        
        local ribbit_anim = {
            
            duration = .4,
            
            on_step = function(s,p)
                
                p = scale_f(p)
                
                mouth.y = -200 + 2 * p
                
                throat.scale = {1+.2 * p,1+.5 * p}
                
            end,
            
            on_completed = function()
                
                ribbiting = false
                
            end
            
        }
        
        function new_frog:ribbit()
            
            if ribbiting then
                
                return false
                
            else
                
                Animation_Loop:add_animation(ribbit_anim)
                
                ribbiting = true
                
                return true
                
            end
            
        end
        
    end
    
    do -- ATTACK
        
        local attacking = false
        
        local attack_dx
        local attack_dy 
        local attack_delta
        local t_w = t_mid.w
        
        local close_mouth = {
            
            duration = .25,
            
            on_step = function(s,p)
                
                mouth.y = -200 + 2 * (1-p)
                
            end,
            
            on_completed = function()
                
                attacking = false
                
            end
            
        }
        
        local function out_and_back(p) return 1 - math.pow(2*p-1,2) end
        
        local tongue_attack = {
            
            duration = .5,
            
            on_step = function(s,p)
                
                p = out_and_back(p)
                
                t_end.x = attack_delta*p
                --t_end.y = attack_dx*p
                
                t_mid.scale = {-attack_delta*p/t_w,1}
                
            end,
            
            on_completed = function()
                
                tongue:hide()
                
                Animation_Loop:add_animation(close_mouth)
                
            end
            
        }
        
        local open_mouth = {
            
            duration = .25,
            
            on_step = function(s,p)
                
                mouth.y = -200 + 2 * p
                
            end,
            
            on_completed = function()
                
                tongue:show()
                
                Animation_Loop:add_animation(tongue_attack)
                
            end
            
        }
        
        function new_frog:attack(x,y)
            
            if attacking or attack_range < math.sqrt(
                    
                    (x-new_frog.x)*(x-new_frog.x) + (y-new_frog.y)*(y-new_frog.y)
                    
                ) then
                
                print(attacking,math.sqrt( (x-new_frog.x)*(x-new_frog.x) + (y-new_frog.y)*(y-new_frog.y)))
                
                return false
                
            end
            
            attacking = true
            
            attack_dx = x-new_frog.x
            attack_dy = y-new_frog.y
            
            attack_delta = math.sqrt( attack_dx * attack_dx  +  attack_dy * attack_dy )
            
            tongue.z_rotation = {math.deg(math.atan2(attack_dy,attack_dx)),0,0}
            
            Animation_Loop:add_animation(open_mouth)
            
            return true
            
        end
        
    end
    
    return new_frog
    
end

return frog