

local hud = {}

local hud_path = "hud/"

local poop_meter_bg    = Image{src = assets_path_dir..hud_path.."poop-o-meter.png",x = 7, y = 1030 }
local poop_meter_txt   = Image{src = assets_path_dir..hud_path.."poop-o-meter-text.png", x = 50,  y = 1056  }
local poop             = Image{ src = "assets/max/poop-splat.png", x = -10, y = 1025}
local shade            = Rectangle{y_rotation={180,0,0},color="000000",opacity = 255*.7,y=1030,h =poop_meter_bg.h}

poop:move_anchor_point(poop.w/2,0)

layers.hud:add(poop_meter_bg,poop_meter_txt,shade,poop)

local empty_x = poop.x
local full_x  = 258
shade.x = full_x
local poo_capacity 
local curr_poo
local poop_cost

local spot_i
local function update_poop_o_meter()
    
    poop.x  = empty_x + (full_x - empty_x) * curr_poo/poo_capacity
    
    shade.w =  shade.x - poop.x
    
end   

function hud:setup_lvl(t)
    
    poo_capacity = t.poo_capacity or 15
    poop_cost    = t.poo_capacity or 3
    curr_poo     = t.starting_poo or 0
    
    update_poop_o_meter()
    
end


function hud:inc_poop(amt)
    
    if curr_poo + amt > poo_capacity then
        
        curr_poo = poo_capacity
        
    else
        
        curr_poo = curr_poo + amt
        
    end
    
    update_poop_o_meter()
    
end

function hud:drop_poop()
    
    if curr_poo < poop_cost then
        
        return false
        
    else
        
        curr_poo = curr_poo - poop_cost
        
        update_poop_o_meter()
        
        return true
        
    end
    
end


return hud