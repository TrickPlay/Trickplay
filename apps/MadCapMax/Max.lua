local body    = Image{ src = "assets/max/body.png"    ,x =   0, y =   0}
local eye_l_i = Image{ src = "assets/max/head/eye-l-i.png" ,x = -20, y = -35,opacity = 0}
local eye_l_b = Image{ src = "assets/max/head/eye-l-b.png" ,x = -20, y = -35,opacity = 0}
local eye_l   = Image{ src = "assets/max/head/eye-l.png"   ,x = -20, y = -35}
local beak_t  = Image{ src = "assets/max/head/beak-t.png"  ,x =  10, y =  -5, anchor_point = { 10, 15} }
local beak_b  = Image{ src = "assets/max/head/beak-b.png"  ,x =   5, y =   5, anchor_point = {  5,  0} }
local crest_t = Image{ src = "assets/max/head/crest-t.png" ,x =  35, y =  -5, anchor_point = { 60, 90} }
local crest_b = Image{ src = "assets/max/head/crest-b.png" ,x =  25, y = -15, anchor_point = { 40, 35} }
local eye_r_i = Image{ src = "assets/max/head/eye-r-i.png" ,x =  20, y = -30,opacity = 0}
local eye_r_b = Image{ src = "assets/max/head/eye-r-b.png" ,x =  20, y = -30,opacity = 0}
local eye_r   = Image{ src = "assets/max/head/eye-r.png"   ,x =  20, y = -30}
local wings   = Group{
    children  = {
        Image{ src = "assets/max/wing-1.png" ,x = 80,y=40, anchor_point = {70,80} },
        Image{ src = "assets/max/wing-2.png" ,x = 80,y=40, anchor_point = {70,50} },
        Image{ src = "assets/max/wing-3.png" ,x = 80,y=40, anchor_point = {40,20} },
        Image{ src = "assets/max/wing-4.png" ,x = 80,y=40, anchor_point = {40,10} },
        Image{ src = "assets/max/wing-5.png" ,x = 80,y=40, anchor_point = {30,10} },
    }
}
local feathers = {
    Image{src = "assets/max/feather-1.png" },
    Image{src = "assets/max/feather-2.png" },
    Image{src = "assets/max/feather-3.png" },
    Image{src = "assets/max/feather-4.png" },
}
local tail = Image{ src = "assets/max/tail.png" ,x = 25, y = 75, anchor_point = {105,25} }
wings:hide()

local poop_drop  = Image{ src = "assets/max/poop.png"}
local poop_splat = Image{ src = "assets/max/poop-splat.png"}


--------------------------------------------------------------------------------
-- Object
--------------------------------------------------------------------------------
local bird = Group()



--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------

local has_been_initialized = false
local ceiling_y, floor_y, lvl, bottom_limit


-- Visual Attributes
local is_loaded = false
local head = Group{x=120,y=25}

head:add(
    eye_r  , eye_r_i, eye_r_b, -- right eye
    crest_t, crest_b,          -- crest
    beak_b ,  beak_t,          -- beak
    eye_l  , eye_l_i, eye_l_b  -- left eye
)

local srcs = Group()
srcs:add(poop_drop,poop_splat)
srcs:add(unpack(feathers))
srcs:hide()

local front_wing = Clone{x = 80, y = 40}
local back_wing  = Clone{source = front_wing,x=100,y=40,scale={.9,.9}}

local bob_group = Group()
bob_group:add(  srcs,  wings,  back_wing,  body,  front_wing,  head,  tail  )
bird:add(bob_group)

front_wing.source = wings.children[1]

--Movement Attributes
local vx = 120
local vy =   0
local scroll_speed
local y_base = 300


--Animation Attributes
local flap_speeds = {
    fast = .01,
    reg  = .06,
    slow = .1,
}
local flap_speed = flap_speeds.reg
local bob = true

--Behavioral Attributes
local flap_order = {
    4,3,2,1,1,3,5
}
local damage   = 0
local seeds    = 0
local cherries = 0

bird.hit = false
local hit_v_x, hit_v_y
local hit_a = 200
local enemy_obstacles, my_obstacles


--------------------------------------------------------------------------------
-- Methods
--------------------------------------------------------------------------------


function bird:init(t)
    
    if has_been_initialized then
        
        error("Jazz has already been initialized",2)
        
    end
    
    
    
    --t.parent:add(bird)
    
    has_been_initialized = true
    
end

function bird:collect_seed()
    seeds = seeds + 1
    Hud:inc_poop(1)
end

function bird:collect_cherry()
    if damage == 1 then
        eye_l_i.opacity = 0
    elseif damage == 2 then
        eye_r_i.opacity = 0
    end
    damage = damage - 1
    if damage < 0 then damage = 0 end
    cherries = cherries + 1
end

local function launch_feather(vx,vy,d)
    
    local f = Clone{
        source = feathers[math.random(1,# feathers)],
        position = bird.position,
    }
    f.x = f.x + math.random(-90,90)
    local orig_x = f.x
    f.anchor_point = { f.w/2, -100}
    
    local orig_y = f.y + f.anchor_point[2]
    
    layers.player:add(f)
    --print("VY",vy)
    
    local e = 0
    
    
    
    
    
    f.stage_1 = {
        duration = 1,
        on_step = function(s,p)
            
            f.y = orig_y + vy*s + 500*s*s
            f.x = orig_x + vx*s - 10*s*s
            f.z_rotation = {
                    10*p*math.sin(math.pi*2*s),
                    0,
                    0
                }
            
        end,
        on_completed = function()
            
            Animation_Loop:add_animation(f.stage_2)
            Animation_Loop:add_animation(f.waft)
            
        end
    }
    
    f.waft = {
        on_step = function(s)
            e = e + s
            f.z_rotation = {
                    10*math.sin(math.pi*2*e),
                    0,
                    0
                }
                
        end
    }
    
    f.stage_2 = {
        on_step = function(s)
            --e = e + s
            f.y = f.y - vy/2 *s
            f.x = f.x + vx/10*s
            --f.z_rotation = {
            --        10*math.sin(math.pi*2*e),
            --        0,
            --        0
            --    }
            if f.y > screen_h then
                
                Animation_Loop:delete_animation(f.stage_2)
                Animation_Loop:delete_animation(f.waft)
                
            end
            
        end,
    }
    
    Animation_Loop:add_animation(f.stage_1)
    
    --[[
    f.animation = Animation_Loop:add_animation{
        
        --duration = d,
        --
        --loop = true,
        
        on_step = function(s)
            e = e + s
            
            f:set{
                x       = orig_x + vx*e,
                y       = orig_y + vy*e ,
                --opacity = 255*(1-p)
                --z_rotation = {
                --    30*math.sin(math.pi*2*s),
                --    0,
                --    0
                --}
            }
            
            vy = vy + 80*e
            
            if f.y > screen_h then
                Animation_Loop:delete_animation(f.animation)
            end
        end,
        on_loop = function()
            
            
            
        end
    }
    --]]
    return f
    
end

local count = 0
local hit_timer = Timer{
    interval = 100,
    on_timer = function(self)
        if count == 0 then
            hit_v_x = scroll_speed
            hit_v_y = 0
            
        elseif count == 4 then
            bird.hit = false
            bird.invincible = true
            bird.z_rotation = {0,0,0}
        elseif count == 8 then
            self:stop()
            bird.invincible = false
        end
        
        count = count + 1
        
        
        
    end
}
local e,start_y = 0,0
bird.death_sequence = {
    
    on_step  = function(s)
        e = e + s
        bird.y = start_y-1500*e+1500*e*e
        bird.x = bird.x+200*s
        bird.z_rotation = {(bird.z_rotation[1]+200*s)%360,bird.w/2,bird.h/2}
        --print(bird.z_rotation[1])
        if bird.y > 1300 then
            --print("1",bird.death_sequence)
            Animation_Loop:delete_animation(bird.death_sequence)
            --print("2")
            
            gamestate:change_state_to("LVL_TRANSITION")
            
            --Animation_Loop:add_animation(bird.death_sequence_pt2)
            --bird.y = -200
            --bird.scale = {2,2}
        end
    end,
}
--[[
bird.death_sequence_pt2 = {
    on_step  = function(s,p)
        bird.y = bird.y+700*s
        bird.x = bird.x+200*s
        bird.z_rotation = {bird.z_rotation[1]+200*s,bird.w/2,bird.h/2}
    end
}
--]]

function bird:death()
    
    bird.dead = true
    
    start_y = bird.y
    
    e = 0
    
    dolater(Animation_Loop.delete_animation,Animation_Loop,bird.animation)
    
    Animation_Loop:add_animation(bird.death_sequence)
    
end
function bird:recieve_impact(v_x,v_y)
    
    --print()
    
    if bird.invincible or bird.dead then return end
    
    damage = damage +1
    
    if damage == 1 then
        
        eye_l_i.opacity = 255
        
    elseif damage == 2 then
        
        eye_r_i.opacity = 255
        
    elseif damage == 3 then
        
        bird:death()
        
        return
    end
    
    
    for i = 1, 4 do
        
        launch_feather(
            math.random( -2, 2 ) *  100,
            math.random(  60, 70 ) * -10
        )
        
    end
    
    
    bird.hit = true
    
    bird.z_rotation = {-40,0,0}
    
    hit_v_x = v_x
    hit_v_y = v_y
    
    count = 0
    hit_timer:start()
end


function bird:setup_for_level(t)--next_lvl, start_x, start_y)
    
    eye_l_i.opacity = 0
    eye_r_i.opacity = 0
    
    bird.z_rotation = {0,0,0}
    bird.dead = false
    damage = 0
    bird.hit = false
    
    --required
    lvl = t.lvl or error("must pass lvl object to 'lvl",2)
    
    scroll_speed = t.scroll_speed or  100
    bird.x       = t.start_x      or  200
    bird.y       = t.start_y      or  200
    y_base       = t.start_y      or  200
    bottom_limit = t.bottom_limit or  700
    floor_y      = t.floor_y      or 1050
    ceiling_y    = t.ceiling_y    or   40
    
    enemy_obstacles = t.enemy_obstacles or {}
    my_obstacles    = t.my_obstacles    or {}
    
    
    if # enemy_obstacles ~= 0 then
        for i = 1, # enemy_obstacles do
            
            if enemy_obstacles[i].x > bird.x then
                
                bird.right_obstacle = i
                
                break
                
            elseif enemy_obstacles[i].x < bird.x and
                enemy_obstacles[i].x + enemy_obstacles[i].w > bird.x then
                
                bird.under_obstacle = i
                
            else
                
                bird.left_obstacle = i
                
            end
            
        end
    end
    
    vx = scroll_speed
    
    layers.player:add(bird)
end


local function set_wings_to(i)
    front_wing.source       = wings.children[  i  ]
    front_wing.anchor_point = front_wing.source.anchor_point
    back_wing.anchor_point  = front_wing.source.anchor_point
end

local flap_func

do
    
    local flap_i = 0
    
    local e = 0 --elapsed
    
    flap_func = function(_,s)
        
        e = e + s
        
        if e > flap_speed then
            
            flap_i =( flap_i + 1) % #flap_order
            
            e = 0
            
            set_wings_to(flap_order[  flap_i + 1  ])
            
        end
        
    end
    
end

bird.flap = flap_func


local undo_dx, undo_dy

function bird.undo_move(item)
    
    --prin
    
    if     bird.x1+undo_dx > item.x2 or bird.x2+undo_dx < item.x1 then
        bird.x = bird.x + undo_dx
    elseif bird.y1+undo_dy > item.y2 or bird.y2+undo_dy < item.y1 then
        bird.y = bird.y + undo_dy
    end
    
    
    
    
    if bird.x < lvl.left_screen_edge then
        
        bird:death()
        
    end
    
end


do
    local e     = 0
    local bob_period = flap_speed * (# flap_order)
    
    function bird.on_idle(s)
        
        undo_dx = bird.x
        undo_dy = bird.y
        
        if bird.hit then
            
            bird.x = bird.x + hit_v_x*s
            
            if bird.x < lvl.left_screen_edge then
                
                bird.x = lvl.left_screen_edge
                
            elseif bird.x > lvl.right_screen_edge then
                
                bird.x = lvl.right_screen_edge
                
            end
            
            y_base = y_base + hit_v_y*s
            
            if y_base < ceiling_y then
                
                y_base = ceiling_y
                
            elseif y_base > bottom_limit then
                
                y_base = bottom_limit
                
            end
            
            bird.y = y_base
            
            
            undo_dx = undo_dx - bird.x
            undo_dy = undo_dy - bird.y
            
            return
        end
        
        
        
        e = e + s
        
        if e > bob_period then e = 0 end
        
        --progress
        p = 2*math.pi*e/bob_period
        
        
        --flap the wings
        if bird.flap then bird:flap(s) end
        
        --bob up and down
        if bob then
            bob_group.y =  10*math.cos(p)
        else
            bob_group.y = 0
        end
        
        --move its crest and tail
        crest_t.z_rotation = {   2*math.cos(p), 0, 0 }
        tail.z_rotation    = { 2+2*math.sin(p), 0, 0 }
        
        bird.x = bird.x + vx*s
        
        if bird.x < lvl.left_screen_edge then
            
            bird.x = lvl.left_screen_edge
            
        elseif bird.x > lvl.right_screen_edge - bird.w then
            
            bird.x = lvl.right_screen_edge - bird.w
            
        elseif bird.x > lvl.stop_scroll then
            
            gamestate:change_state_to("LVL_TRANSITION")
            
        end
        
        if bird.under_obstacle then
            if bird.x >
                enemy_obstacles[bird.under_obstacle].x +
                enemy_obstacles[bird.under_obstacle].w then
                
                
                bird.left_obstacle = bird.under_obstacle
                
                bird.under_obstacle = nil
                
                print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
                
            elseif bird.x < enemy_obstacles[bird.under_obstacle].x then
                
                
                bird.right_obstacle = bird.under_obstacle
                
                bird.under_obstacle = nil
                
                
                print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
                
            end
            
        end
        
        if vx > 0 and bird.right_obstacle and bird.x > enemy_obstacles[bird.right_obstacle].x then
            
            if bird.x <
                enemy_obstacles[bird.right_obstacle].x +
                enemy_obstacles[bird.right_obstacle].w then
                
                
                bird.under_obstacle = bird.right_obstacle
                
            else
                
                bird.left_obstacle = bird.right_obstacle
                
            end
            
            --if doesn't exist, then it nils it for us
            bird.right_obstacle = enemy_obstacles[bird.right_obstacle + 1] ~= nil and bird.right_obstacle + 1 or nil
            
            print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
            
        elseif vx < 0 and bird.left_obstacle and bird.x <
            enemy_obstacles[bird.left_obstacle].x +
            enemy_obstacles[bird.left_obstacle].w then
            
            
            if bird.x > enemy_obstacles[bird.left_obstacle].x then
                
                
                bird.under_obstacle = bird.left_obstacle
                
            else
                
                bird.right_obstacle = bird.left_obstacle
                
            end
            
            --if doesn't exist, then it nils it for us
            bird.left_obstacle = enemy_obstacles[bird.left_obstacle - 1] ~= nil and bird.left_obstacle - 1 or nil
            
            print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
            
        end
        
        bird.y = bird.y + vy*s
        
        if bird.y < ceiling_y then
            
            bird.y = ceiling_y
            
        elseif bird.y > bottom_limit then
            
            bird.y = bottom_limit
            
        end
        
        undo_dx = undo_dx - bird.x
        undo_dy = undo_dy - bird.y
        
    end
end

do
    local next_poop
    local old_splats = {}
    local old_poo    = {}
    local sphincter_ready = true
    local sphincter_shutter_speed = Timer{
        interval = 200,
        on_timer = function(self)
            
            sphincter_ready = true
            
            self:stop()
        end
    }
    
    sphincter_shutter_speed:stop()
    
    local poop_speed_y = 1000
    
    local function new_poo()
        local poop  = Clone{
            source = poop_drop,
            anchor_point = {
                poop_drop.w/2,
                poop_drop.h/2
            }
        }
        
        function poop:collision(enemy)
            
            enemy.pooped_on = true
            
            Animation_Loop:delete_animation(poop.fall)
            
            collides_with_enemy[poop] = nil
            
            poop:unparent()
            
            table.insert(old_poo,poop)
            
        end
        
        poop.fall = {
            on_step = function(s)
                poop.y = poop.y + poop_speed_y * s
                if poop.y > floor_y then
                    
                    Animation_Loop:delete_animation(poop.fall)
                    
                    poop:unparent()
                    
                    collides_with_enemy[poop] = nil
                    
                    table.insert(old_poo,poop)
                    
                    splat = table.remove(old_splats) or Clone{
                        source = poop_splat,
                        position     = poop.position,
                        anchor_point = {
                            poop_splat.w/2,
                            poop_splat.h/2
                        }
                    }
                    
                    layers.player:add(splat)
                    
                    lvl:add_to_scroll_off(splat)
                end
            end
        }
        
        return poop
    end
    
    
    function bird:poop()
        
        if not sphincter_ready then return end
        
        if not Hud:drop_poop() then return end
        
        next_poop = table.remove(old_poo) or new_poo()
        
        next_poop.x = bird.x+30
        next_poop.y = bird.y+100
        
        layers.player:add(next_poop)
        
        next_poop:lower_to_bottom()
        
        collides_with_enemy[next_poop] = next_poop
        
        Animation_Loop:add_animation(next_poop.fall)
        --print("POOOOOOPP",next_poop.fall)
        sphincter_ready = false
        sphincter_shutter_speed:start()
    end
end

--Key handler
do
    
    local state_x = StateMachine{"REGULAR",  "LEFT", "RIGHT"}
    local state_y = StateMachine{"STRAIGHT", "UP",   "DOWN"}
    
    --using a timer so that a user can have a bunch of presses count as
    --one continuous press
    local reset_x = Timer{
        interval = 500,
        on_timer = function(self)
            
            state_x:change_state_to("REGULAR")
            self:stop()
            
        end
    }
    
    reset_x:stop()
    local reset_y = Timer{
        interval = 500,
        on_timer = function(self)
            
            state_y:change_state_to("STRAIGHT")
            self:stop()
            
        end
    }
    
    reset_y:stop()
    
    state_x:add_state_change_function(
        function()
            
            vx = -5*scroll_speed
            
            --flap_speed = flap_speeds.fast
            
            reset_x:start()
            
        end, nil, "LEFT"
    )
    state_x:add_state_change_function(
        function()
            
            vx = scroll_speed*7
            
            --bird.flap = nil
            --set_wings_to(2)
            --flap_speed = flap_speeds.slow
            --
            --
            --bob = false
            reset_x:start()
            
        end, nil, "RIGHT"
    )
    state_x:add_state_change_function(
        function()
            --bob = true
            --bird.flap = flap_func
            --
            --flap_speed = flap_speeds.reg
            
            vx = scroll_speed
            
        end, nil, "REGULAR"
    )
    
    state_y:add_state_change_function(
        function()
            
            vy = -5*scroll_speed
            
            flap_speed = flap_speeds.fast
            
            reset_y:start()
            
        end, nil, "UP"
    )
    state_y:add_state_change_function(
        function()
            
            vy = 7*scroll_speed
            
            bird.flap = nil
            set_wings_to(2)
            flap_speed = flap_speeds.slow
            
            
            bob = false
            reset_y:start()
            
        end, nil, "DOWN"
    )
    state_y:add_state_change_function(
        function()
            bob = true
            bird.flap = flap_func
            
            flap_speed = flap_speeds.reg
            
            vy = 0
            
        end, nil, "STRAIGHT"
    )
    
    
    local keys = {
        [keys.Up] = function()
            --if pressed during the timer, then reset the timer to continue moving up
            if state_y:current_state() == "UP" then
                reset_y:start()
            else
                state_y:change_state_to("UP")
            end
        end,
        [keys.Down] = function()
            --if pressed during the timer, then reset the timer to continue moving down
            if state_y:current_state() == "DOWN" then
                reset_y:start()
            else
                state_y:change_state_to("DOWN")
            end
        end,
        [keys.Left] = function()
            --if pressed during the timer, then reset the timer to continue moving left
            if state_x:current_state() == "LEFT" then
                reset_x:start()
            else
                state_x:change_state_to("LEFT")
            end
        end,
        [keys.Right] = function()
            --if pressed during the timer, then reset the timer to continue moving right
            if state_x:current_state() == "RIGHT" then
                reset_x:start()
            else
                state_x:change_state_to("RIGHT")
            end
        end,
        [keys.RED] = function()
            
            if gamestate:current_state() == "PAUSED" then
                gamestate:change_state_to("ACTIVE")
            else
                gamestate:change_state_to("PAUSED")
            end
            
            
        end,
        
        [keys.OK] = bird.poop,
    }
    
    function bird:on_key_down(k)
        
        if not bird.hit and keys[k] then keys[k]() end
        
        return true
        
    end
end


return bird