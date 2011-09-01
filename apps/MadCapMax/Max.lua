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

local srcs = Group{}
srcs:add(poop_drop,poop_splat)
srcs:hide()

local front_wing = Clone{x = 80, y = 40}
local back_wing  = Clone{source = front_wing,x=100,y=40,scale={.9,.9}}

bird:add(  srcs,  wings,  back_wing,  body,  front_wing,  head,  tail  )

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

--------------------------------------------------------------------------------
-- Methods
--------------------------------------------------------------------------------


function bird:init(t)
    
    if has_been_initialized then
        
        error("Jazz has already been initialized",2)
        
    end
    
    
    
    t.parent:add(bird)
    
    has_been_initialized = true
    
end

function bird:collect_seed()
    seeds = seeds + 1
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

local count = 0
local hit_timer = Timer{
    interval = 400,
    on_timer = function(self)
        if count == 0 then
            hit_v_x = scroll_speed
            hit_v_y = 0
        else
            self:stop()
            bird.hit = false
            bird.z_rotation = {0,0,0}
        end
        count = count + 1
        
        
    end
}

function bird:recieve_impact(v_x,v_y)
    
    damage = damage +1
    
    if damage == 1 then
        eye_l_i.opacity = 255
    elseif damage == 2 then
        eye_r_i.opacity = 255
    elseif damage == 3 then
        v_y
    end
    
    bird.hit = true
    
    bird.z_rotation = {-40,0,0}
    
    hit_v_x = v_x
    hit_v_y = v_y
    
    count = 0
    hit_timer:start()
end


function bird:setup_for_level(t)--next_lvl, start_x, start_y)
    
    --required
    lvl = t.lvl or error("must pass lvl object to 'lvl",2)
    
    scroll_speed = t.scroll_speed or  100
    bird.x       = t.start_x      or  200
    bird.y       = t.start_y      or  200
    bird.y       = t.start_y      or  200
    bottom_limit = t.bottom_limit or  700
    floor_y      = t.floor_y      or 1050
    ceiling_y    = t.ceiling_y    or   40
    
    vx = scroll_speed
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





do
    local e     = 0
    local bob_period = flap_speed * (# flap_order)
    
    function bird.on_idle(s)
        
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
            bird.y = y_base + 10*math.cos(p)
        else
            bird.y = y_base
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
            --Transition_Menu:load_assets(lvl:curr_lvl())
            
        end
        
        y_base = y_base + vy*s
        
        if y_base < ceiling_y then
            
            y_base = ceiling_y
            
        elseif y_base > bottom_limit then
            
            y_base = bottom_limit
            
        end
        
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
        
        next_poop = table.remove(old_poo) or new_poo()
        
        next_poop.x = bird.x+30
        next_poop.y = bird.y+100
        
        layers.player:add(next_poop)
        
        next_poop:lower_to_bottom()
        
        collides_with_enemy[next_poop] = next_poop
        
        Animation_Loop:add_animation(next_poop.fall)
        print("POOOOOOPP",next_poop.fall)
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