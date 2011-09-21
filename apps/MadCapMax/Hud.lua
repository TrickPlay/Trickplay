

local hud = {}

local hud_path = "hud/"

local poop_meter_bg    = Image{src = assets_path_dir..hud_path.."poop-o-meter.png",x = 7, y = 1030 }
local poop_meter_txt   = Image{src = assets_path_dir..hud_path.."poop-o-meter-text.png", x = 50,  y = 1056  }
local poop             = Image{ src = "assets/max/poop-splat.png", x = -10, y = 1025}
local shade            = Rectangle{y_rotation={180,0,0},color="000000",opacity = 255*.7,y=1030,h =poop_meter_bg.h}

local pause_screen = Group{
    opacity  = 0,
    children = {
        Rectangle{color="000000",opacity = 255*.7,size = screen.size},
        Image{ src = "assets/hud/paused-50pcnt-blk-bg.png",x = screen.w/4,y = screen.h/4}
    }
}

local life_meter = Image{src = assets_path_dir..hud_path.."life-meter.png",x = 270,y = 1024}
local life_gone  = Image{src = assets_path_dir..hud_path.."life-gone.png"}

poop:move_anchor_point(poop.w/2,0)

layers.hud:add(pause_screen,poop_meter_bg,poop_meter_txt,shade,poop,life_meter,life_gone)

life_gone:hide()

local empty_x = poop.x
local full_x  = 258
shade.x = full_x
local poo_capacity 
local curr_poo
local poop_cost

local spot_i


local lives = {}
for i = 1, 3 do
    
    lives[i] = Clone{source = life_gone, x =  life_meter.x+7 + (i-1)*27, y = life_meter.y+5 }
    
end

layers.hud:add(unpack(lives))

local live_i = 1
local function update_poop_o_meter()
    
    poop.x  = empty_x + (full_x - empty_x) * curr_poo/poo_capacity
    
    shade.w =  shade.x - poop.x
    
end   

function hud:setup_lvl(t)
    
    poo_capacity = t and t.poo_capacity or 15
    poop_cost    = t and t.poo_capacity or 3
    curr_poo     = t and t.starting_poo or 0
    
    live_i       = 1
    
    for i,l in pairs(lives) do
        l:hide()
    end
    
    update_poop_o_meter()
    
end



function hud:inc_poop(amt)
    
    amt = amt or 1
    
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



function hud:loose_health(amt)
    
    amt = amt or 1
    
    assert(live_i+amt<=4)
    
    for i = live_i, live_i + amt-1 do
        
        lives[i]:show()
        
    end
    
    live_i = live_i + amt
    
end

function hud:gain_health(amt)
    
    amt = amt or 1
    
    assert(live_i-amt>=1)
    
    for i = live_i - amt, live_i-1 do
        
        lives[i]:hide()
        
    end
    
    live_i = live_i - amt
    
end

local show_pause_screen = {
    duration = .3,
    on_step  = function(s,p)
        pause_screen.opacity = 255*p
    end
}

local hide_pause_screen = {
    duration = .3,
    on_step  = function(s,p)
        pause_screen.opacity = 255*(1-p)
    end,
    on_completed = function()
        
        gamestate:change_state_to("ACTIVE")
        
    end
}

function hud:pause()
    
    if Animation_Loop:has_animation(show_pause_screen) then
        return
    end
    if Animation_Loop:has_animation(hide_pause_screen) then
        Animation_Loop:delete_animation(hide_pause_screen)
    end
    
    gamestate:change_state_to("PAUSED")
    
    Animation_Loop:add_animation(show_pause_screen)
    
end

function hud:unpause()
    
    if Animation_Loop:has_animation(hide_pause_screen) then
        return
    end
    if Animation_Loop:has_animation(show_pause_screen) then
        Animation_Loop:delete_animation(show_pause_screen)
    end
    Animation_Loop:add_animation(hide_pause_screen)
    
end

return hud