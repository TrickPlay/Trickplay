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

local arrow = Image{src = "assets/max/arrow-hint.png",scale = {0,0},x = 100}

arrow.anchor_point = {arrow.w/2,arrow.h/2}

local fart_cloud = Image{ src = "assets/max/fart-cloud.png", scale = {0,0}}
local poop_drop  = Image{ src = "assets/max/poop.png"}
local poop_splat = Image{ src = "assets/max/poop-splat.png"}
local stars = Group{ x=120,y=-70, opacity = 0,
    children  = {
        Image{ src = "assets/max/star-1.png" },
        Image{ src = "assets/max/star-2.png" },
        Image{ src = "assets/max/star-3.png" },
    }
}

fart_cloud.anchor_point = {fart_cloud.w,0}


--------------------------------------------------------------------------------
-- Object
--------------------------------------------------------------------------------
local bird = Group{w=230,h=140}



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
bird:add(fart_cloud,bob_group, arrow,stars)
stars:hide()
front_wing.source = wings.children[1]

--Movement Attributes
local vx = 120
local vy =   0
local scroll_speed


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

local sk,hud
function bird:init(t)
    
    if has_been_initialized then
        
        error("Jazz has already been initialized",2)
        
    end
    
    lvl = t.lvl or error("must pass lvl object to 'lvl'",2)
    sk  = t.sk  or error("must pass score_keeper object to 'sk'",2)
    hud = t.hud  or error("must pass score_keeper object to 'sk'",2)
    
    --t.parent:add(bird)
    
    has_been_initialized = true
    
end

function bird:collect_seed()
    sk:inc("seeds")
    hud:inc_poop()
end
function bird:collect_cracker()
    sk:inc("crackers")
    hud:inc_poop()
end

function bird:collect_cherry()
    
    if     damage == 1 then eye_l_i.opacity = 0
    elseif damage == 2 then eye_r_i.opacity = 0    end
    
    damage = damage - 1
    
    if damage < 0 then
        damage = 0
    else
        hud:gain_health()
    end
    
    sk:inc("cherries")
    
end

local function launch_feather(vx,vy,d)
    
    local f = Clone{
        source = feathers[math.random(1,# feathers)],
        position = bird.position,
    }
    clone_counter[f] = true
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

local spinning_stars = {
    duration = 2,
    on_step = function(s,p)
        for i,s in ipairs(stars.children) do
            s.x = 50*math.cos( math.pi*4*(p  +  i / (#stars.children)) )
            s.z = 50*math.sin( math.pi*4*(p  +  i / (#stars.children)) )
        end
        if p > .8 then
            p = (p-.8)*1/.2
            stars.opacity = 255*(1-p)
        end
    end,
    on_completed = function()
        stars:hide()
    end
}

local count = 0
local hit_timer = Timer{
    interval = 100,
    on_timer = function(self)
        if count == 0 then
            --hit_v_x = scroll_speed
            --hit_v_y = 0
            
        elseif count == 4 then
            bird.hit = false
            bird.invincible = true
            bird.z_rotation = {0,0,0}
            stars:show()
            stars.opacity = 255
            
            Animation_Loop:add_animation(spinning_stars)
        elseif count == 24 then
            self:stop()
            bird.invincible = false
        end
        
        count = count + 1
        
    end
}
hit_timer:stop()
local e,start_y = 0,0
bird.death_sequence = {
    
    on_step  = function(s)
        e = e + s
        bird.y = start_y  -  1500*e  +  1500*e*e
        bird.x = bird.x  +  200*s
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
    
    mediaplayer:play_sound("audio/bird-die.wav")
    
    bird.dead = true
    
    start_y = bird.y
    
    e = 0
    
    dolater(Animation_Loop.delete_animation,Animation_Loop,bird.on_idle)
    
    if Animation_Loop:has_animation(bird.death_sequence) then error("already dieing",2) end
    Animation_Loop:add_animation(bird.death_sequence)
    
end
function bird:recieve_impact(v_x,v_y)
    
    if bird.invincible or bird.dead then return end
    
    damage = damage +1
    
    hud:loose_health()
    
    if damage == 1 then
        
        eye_l_i.opacity = 255
        
    elseif damage == 2 then
        
        eye_r_i.opacity = 255
        
    elseif damage == 3 then
        
        bird:death()
        
        return
    end
    
    
    mediaplayer:play_sound("audio/bird-chirp.wav")
    
    for i = 1, 4 do
        
        launch_feather(
            math.random( -2, 2 ) *  100,
            math.random(  60, 70 ) * -10
        )
        
    end
    
    
    bird.hit = true
    
    bird.z_rotation = {-40,0,0}
    
    hit_v_x = 0--v_x
    hit_v_y = 0--v_y
    
    count = 0
    hit_timer:start()
end

local function set_wings_to(i)
    front_wing.source       = wings.children[  i  ]
    front_wing.anchor_point = front_wing.source.anchor_point
    back_wing.anchor_point  = front_wing.source.anchor_point
end

function bird:setup_for_level(t)--next_lvl, start_x, start_y)
    
    eye_l_i.opacity = 0
    eye_r_i.opacity = 0
    
    bird.z_rotation = {0,0,0}
    bird.dead = false
    damage = 0
    bird.hit = false
    
    bird.left_obstacle  = nil
    bird.under_obstacle = nil
    bird.right_obstacle = nil
    
    scroll_speed = t and t.scroll_speed or  100
    bird.x       = t and t.start_x      or  200
    bird.y       = t and t.start_y      or  300
    bottom_limit = t and t.bottom_limit or  700
    floor_y      = t and t.floor_y      or 1050
    ceiling_y    = t and t.ceiling_y    or   40
    
    bird.z_rotation = {t and t.start_z_rot or 0,0,0}
    front_wing.z_rotation = {t and t.start_wing_rot or 0,0,0}
    back_wing.z_rotation = {t and t.start_wing_rot or 0,0,0}
    dumptable(bird.y_rotation)
    enemy_obstacles = lvl.obstacles
    
    set_wings_to(t and t.start_wing_src or 1)
    
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
    vy = 0
    
    layers.player:add(bird)
    
    if t and t.launch then
        
        bird:launch()
        
    end
    
end

function bird:launch()
    
    bird.z_rotation = {0,0,0}
    front_wing.z_rotation = {0,0,0}
    back_wing.z_rotation = {0,0,0}
    Animation_Loop:add_animation(bird.on_idle,"ACTIVE")
    
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
            
            if flap_i + 1 == 5 then
                
                mediaplayer:play_sound("audio/wing-flap-4.mp3")
                
            end
            
        end
        
    end
    
end

bird.flap = flap_func

local col_item
local function place_arrow()--pos)
    
    if col_item.arrow == "up" then
        
        arrow.y = -100
        arrow.x_rotation = {0,0,0}
        
    elseif col_item.arrow == "down" then
        
        arrow.y = 160
        arrow.x_rotation = {180,0,0}
        
    else
        
        error("no position",2)
        
    end
end

local scale_func = function(x)
    
    return .5 + ( math.pow(3*x-1.2, 2) - math.pow(3*x-1.2, 4) )
    
end

local arrow_animation_is_running = false
local arrow_animation = {
    duration = .8,
    on_step  = function(s,p)
        
        p = p*.79
        arrow.scale = {
            scale_func(p),
            scale_func(p),
        }
        --print(p,scale_func(p))
        
    end,
    on_completed = function()
        
        arrow_animation_is_running = false
        
    end
}

local stuck_timer_is_running = false
local stuck_timer = Timer{
    interval = 1500,
    on_timer = function(self)
        stuck_timer_is_running = false
        self:stop()
        place_arrow()
        
        Animation_Loop:add_animation(arrow_animation)
        print("hurr")
    end
}
stuck_timer:stop()
local unstuck_timer = Timer{
    interval = 500,
    on_timer = function(self)
        stuck_timer:stop()
        self:stop()
        stuck_timer_is_running = false
    end
}
unstuck_timer:stop()

local undo_dx, undo_dy

function bird.undo_move(item)
    
    col_item = item
    
    
    if stuck_timer_is_running then
        --print("ffff")
        unstuck_timer:stop()
        unstuck_timer:start()
    elseif not arrow_animation_is_running then
        print("WHAT WAHT")
        stuck_timer_is_running = true
        stuck_timer:start()
        unstuck_timer:start()
    end
    --[[
    if not arrow_timer_is_running then
        
        arrow_timer_is_running = true
        
        place_arrow(item.arrow)
        
        Animation_Loop:add_animation(arrow_animation)
    end
    
    arrow_timer:start()
    --]]
    if bird.y1+undo_dy > item.y2 or bird.y2+undo_dy < item.y1 then
        bird.y = bird.y + undo_dy
    elseif     bird.x1+undo_dx > item.x2 or bird.x2+undo_dx < item.x1 then
        bird.x = bird.x + undo_dx
    end
    
    
    
    
    if bird.x < lvl.left_screen_edge then
        
        bird:death()
        
    end
    
end


--------------------------------------------------------------------------------
-- Movement                                                               --
--------------------------------------------------------------------------------
do
    local e     = 0
    local bob_period = flap_speed * (# flap_order)
    
    
    
    bird.on_idle = {
        on_step = function(s)
            
            undo_dx = bird.x
            undo_dy = bird.y
            
            if bird.hit then
                
                bird.x = bird.x + hit_v_x*s
                
                if bird.x < lvl.left_screen_edge then
                    
                    bird.x = lvl.left_screen_edge
                    
                elseif bird.x > lvl.right_screen_edge then
                    
                    bird.x = lvl.right_screen_edge
                    
                end
                
                bird.y = bird.y + hit_v_y*s
                
                if bird.y < ceiling_y then
                    
                    bird.y = ceiling_y
                    
                elseif bird.y > bottom_limit then
                    
                    bird.y = bottom_limit
                    
                end
                
                
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
            
            if vx > 0 then
                while bird.right_obstacle and bird.x > enemy_obstacles[bird.right_obstacle].x do
                    
                    if bird.x <
                        enemy_obstacles[bird.right_obstacle].x +
                        enemy_obstacles[bird.right_obstacle].w then
                        
                        
                        bird.under_obstacle = bird.right_obstacle
                        
                    else
                        
                        bird.left_obstacle = bird.right_obstacle
                        
                    end
                    
                    --if doesn't exist, then it nils it for us
                    repeat
                        
                        bird.right_obstacle = enemy_obstacles[bird.right_obstacle + 1] ~= nil and
                            bird.right_obstacle + 1 or nil
                        
                    until
                        enemy_obstacles[bird.right_obstacle] == nil or
                        enemy_obstacles[bird.right_obstacle].pre_exit  ~= true and
                        enemy_obstacles[bird.right_obstacle].post_exit ~= true 
                    
                    print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
                end
            elseif vx < 0 then
                while bird.left_obstacle and bird.x <
                    enemy_obstacles[bird.left_obstacle].x +
                    enemy_obstacles[bird.left_obstacle].w do
                    
                    
                    if bird.x > enemy_obstacles[bird.left_obstacle].x then
                        
                        
                        bird.under_obstacle = bird.left_obstacle
                        
                    else
                        
                        bird.right_obstacle = bird.left_obstacle
                        
                    end
                    
                    --if doesn't exist, then it nils it for us
                    repeat
                        
                        bird.left_obstacle = enemy_obstacles[bird.left_obstacle - 1] ~= nil and
                            bird.left_obstacle - 1 or nil
                        
                    until
                        enemy_obstacles[bird.left_obstacle] == nil or
                        enemy_obstacles[bird.left_obstacle].pre_exit  ~= true and
                        enemy_obstacles[bird.left_obstacle].post_exit ~= true 
                    
                    print("MAX OBST:",bird.left_obstacle,bird.under_obstacle,bird.right_obstacle)
                end
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
    }
    
    local stop_fly_to = Timer{
        interval = 1000,
        on_timer = function(self)
            
            self:stop()
            
            Animation_Loop:delete_animation(bird.on_idle)
            
        end
    }
    
    stop_fly_to:stop()
    
    bird.fly_to = function(t)
        
        screen:grab_key_focus()
        
        bird:halt_reset_timers()
        
        bob = true
        
        bird.flap = flap_func
        
        flap_speed = flap_speeds.reg
        
        vx = (t.x - bird.x)/t.d
        vy = (t.y - bird.y)/t.d
        
        stop_fly_to.duration = t.d * 1000
        
        stop_fly_to:start()
        
    end
    
    
end

function bird:update_coll_box()
    
    bird.x1 = bird.x - bird.anchor_point[1] + 20
    bird.y1 = bird.y - bird.anchor_point[2]
    bird.x2 = bird.x - bird.anchor_point[1] + bird.w - 50
    bird.y2 = bird.y - bird.anchor_point[2] + bird.h - 40
    
end


--------------------------------------------------------------------------------
-- POOP                                                                       --
--------------------------------------------------------------------------------
do
    local next_poop
    local old_splats = {}
    local old_poo    = {}
    local sphincter_ready = true
    local sphincter_shutter_speed = Timer{
        interval = 500,
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
        clone_counter[poop] = true
        function poop:collision(enemy)
            
            sk:inc("poop")
            
            enemy:hit()
            
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
                    clone_counter[splat] = true
                    layers.player:add(splat)
                    
                    lvl:add_to_scroll_off(splat)
                end
            end
        }
        
        return poop
    end
    
    local fart_animation = {
        duration = .4,
        on_step = function(s,p)
            fart_cloud.scale = { 1.2*p*p, 1.2*p*p }
            fart_cloud.opacity = ( 1-p*p*p*p )*255
        end
    }
    
    function bird:poop()
        
        if not sphincter_ready then return end
        
        sphincter_ready = false
        sphincter_shutter_speed:start()
        
        if not hud:drop_poop() then
            
            mediaplayer:play_sound("audio/fart.wav")
            
            fart_cloud.x = 0
            fart_cloud.y = 100
            
            Animation_Loop:add_animation(fart_animation)
            
            return
            
        end
        
        next_poop = table.remove(old_poo) or new_poo()
        
        mediaplayer:play_sound("audio/poop.wav")
        
        next_poop.x = bird.x+30
        next_poop.y = bird.y+100
        
        layers.player:add(next_poop)
        
        next_poop:lower_to_bottom()
        
        collides_with_enemy[next_poop] = next_poop
        
        Animation_Loop:add_animation(next_poop.fall)
        --print("POOOOOOPP",next_poop.fall)
    end
end



--------------------------------------------------------------------------------
-- Key handler                                                                --
--------------------------------------------------------------------------------
do
    
    local dx_state = "REGULAR"
    local dy_state = "REGULAR"
    
    --using timers so that a user can have a bunch of presses count as
    --one continuous press
    local reset_x = Timer{
        interval = 500,
        on_timer = function(self)
            
            dx_state = "REGULAR"
            
            vx = scroll_speed
            
            self:stop()
            
        end
    }
    
    reset_x:stop()
    
    local reset_y = Timer{
        interval = 500,
        on_timer = function(self)
            
            dy_state = "REGULAR"
            
            bob = true
            
            bird.flap = flap_func
            
            flap_speed = flap_speeds.reg
            
            vy = 0
            
            self:stop()
            
        end
    }
    
    reset_y:stop()
    
    function bird:halt_reset_timers()
        reset_x:stop()
        reset_y:stop()
        
    end
    local keys = {
        [keys.Up] = function()
            
            --if pressed during the timer, then reset the timer to continue moving up
            if dy_state ~= "UP" then
                
                dy_state = "UP"
                
                vy = -5*scroll_speed
                
                flap_speed = flap_speeds.fast
                
                
            end
            
            reset_y:start()
            
        end,
        [keys.Down] = function()
            
            --if pressed during the timer, then reset the timer to continue moving down
            if dy_state ~= "DOWN" then
                
                dy_state = "DOWN"
                
                vy = 7*scroll_speed
                
                bird.flap = nil
                set_wings_to(2)
                flap_speed = flap_speeds.slow
                
                
                bob = false
                
            end
            
            reset_y:start()
            
        end,
        [keys.Left] = function()
            
            --if pressed during the timer, then reset the timer to continue moving left
            if dx_state ~= "LEFT" then
                
                dx_state = "LEFT"
                
                vx = -5*scroll_speed
                
            end
            
            reset_x:start()
            
        end,
        [keys.Right] = function()
            
            --if pressed during the timer, then reset the timer to continue moving right
            if dx_state ~= "RIGHT" then
                
                dx_state = "RIGHT"
                
                vx = 7*scroll_speed
                
            end
            
            reset_x:start()
            
        end,
        [keys.RED] = function()
            
            if gamestate:current_state() == "PAUSED" then
                
                hud:unpause()
                
            else
                
                hud:pause()
                
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