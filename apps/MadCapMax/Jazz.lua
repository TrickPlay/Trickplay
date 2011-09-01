
--------------------------------------------------------------------------------
-- Object
--------------------------------------------------------------------------------

local jazz = Clone{}



--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------

--constant
local  swat_threshold_x = 200
local  swat_threshold_y = 200
local lunge_threshold_x = 600
local lunge_threshold_y = 400
local lunge_radius = 700
local hop_dx            = 40   -- dist travelled per hop while running

--private
local is_loaded = false
local srcs = Group{}
local imgs = {}
local has_been_initialized = false
local stop_point, obstacles, flip_interval, floor_y, target

--local arm = Clone{anchor_point = { 5, 90 }}
--arm:hide()

--public
jazz.attacking = false




--------------------------------------------------------------------------------
-- Methods
--------------------------------------------------------------------------------


function jazz:init(t)
    
    if has_been_initialized then
        
        error("jazz has already been initialized",2)
        
    end
    
    flip_interval = t.flip_interval or .08
    floor_y       = t.floor_y       or 900
    jump_dur      = t.jump_duration or 400
    target        = t.target
    
    has_been_initialized = true
    
end

--Loads up the assets for jazz into memory
--That way the character is only in memory when it needs to be
function jazz:load_assets(src_parent, actor_parent)
    
    if not has_been_initialized then
        
        error("Call jazz:Init{} first",2)
        
    end
    
    if type(src_parent) ~= "userdata" then
        
        error("parameter must be a group",2)
        
    end
    
    if is_loaded then
        
        if # srcs.children == 0 then
            
            error("meta-data 'jazz.is_loaded' is incorrect",2)
            
        else
            
            error("load_assets was called when the assets where already loaded",2)
            
        end
        
    end
    
    imgs.default = {
        Image{src ="assets/jazz_sprite/jazz-default-1.png"},
        Image{src ="assets/jazz_sprite/jazz-default-2.png"},
        Image{src ="assets/jazz_sprite/jazz-default-3.png"},
    }
    ---[[
    imgs.jump_down = {
        --Image{src ="assets/jazz_sprite/jazz-jump-down-1.png"},
        Image{src ="assets/jazz_sprite/jazz-jump-down-2.png"},
        --Image{src ="assets/jazz_sprite/jazz-jump-down-3.png"},
    }--]]
    imgs.jump_up = {
        Image{src ="assets/jazz_sprite/jazz-jump-up-1.png"},
        --Image{src ="assets/jazz_sprite/jazz-jump-up-2.png"},
        --Image{src ="assets/jazz_sprite/jazz-jump-up-3.png"},
        Image{src ="assets/jazz_sprite/jazz-jump-up-4.png"},
    }
    --]]
    imgs.run = {
        Image{src ="assets/jazz_sprite/jazz-run-1.png"},
        Image{src ="assets/jazz_sprite/jazz-run-2.png"},
        Image{src ="assets/jazz_sprite/jazz-run-3.png"},
        Image{src ="assets/jazz_sprite/jazz-run-4.png"},
        Image{src ="assets/jazz_sprite/jazz-run-5.png"},
        Image{src ="assets/jazz_sprite/jazz-run-6.png"},
        Image{src ="assets/jazz_sprite/jazz-run-7.png"},
    }
    --[[
    imgs.swat = {
        Image{src ="assets/jazz_sprite/jazz-swat-1.png"},
        Image{src ="assets/jazz_sprite/jazz-swat-2.png"},
        Image{src ="assets/jazz_sprite/jazz-swat-3.png"},
    }
    --]]
    imgs.poop_shake = {
        Image{src ="assets/jazz_sprite/jazz-poop-shake-1.png"},
        Image{src ="assets/jazz_sprite/jazz-poop-shake-2.png"},
        Image{src ="assets/jazz_sprite/jazz-poop-shake-3.png"},
        Image{src ="assets/jazz_sprite/jazz-poop-shake-4.png"},
        Image{src ="assets/jazz_sprite/jazz-poop-shake-5.png"},
    }
    --imgs.arm = Image{src ="assets/jazz_sprite/jazz-swat-arm.png"}
    
    apply_func_to_table(imgs, function(img) srcs:add(img) end)
    
    src_parent:add(srcs)
    
    actor_parent:add(jazz)
    
    is_loaded = true
    
    jazz.anchor_point = {
        imgs.default[1].w/2,
        imgs.default[2].h/2
    }
    
end


--The AI of the cat
do
    
    --Upvals
    
    --frame table
    local frames, frame_i
    
    --functions
    local run_7, swat, swat_pos_check, animating, act_on_frame,
    jump, show_arm, wait_check, attack
    
    --sequences
    local run_sequence, jump_up_sequence, jump_down_sequence,
    to_swat_sequence, swat_sequence, swat_blink_sequence, swat_to_run_sequence,
    swat_wait, attack_sequence, pos_wait, poop_shake_sequence
    
    
    local next_obst_x, next_obst_y, o_x, o_y
    
    ----------------------------------------------------------------------------
    --init's all of the sequences
    --can only be called once assets were loaded
    local function make_sequences()
        poop_shake_sequence = {
            imgs.poop_shake[1],
            imgs.poop_shake[2],
            imgs.poop_shake[3],
            imgs.poop_shake[4],
            imgs.poop_shake[5], --
            imgs.poop_shake[4],
            imgs.poop_shake[3],
            imgs.poop_shake[4],
            imgs.poop_shake[5], --
            imgs.poop_shake[4],
            imgs.poop_shake[3],
            imgs.poop_shake[4],
            imgs.poop_shake[5], --
            imgs.poop_shake[4],
            imgs.poop_shake[3],
            imgs.poop_shake[4],
            imgs.poop_shake[5], --
            imgs.poop_shake[4],
            imgs.poop_shake[3],
            imgs.poop_shake[2],
            imgs.poop_shake[1],
            run_7,
        }
        
        run_sequence = {
            function() jazz.x = jazz.x + 30 end,
            imgs.run[7],
            function() jazz.x = jazz.x + 20 end,
            imgs.run[1],
            function() jazz.x = jazz.x + 20 end,
            imgs.run[2],
            --function() jazz.x = jazz.x + 50 end,
            --imgs.run[3],
            function() jazz.x = jazz.x + 90 end,
            imgs.run[4],
            function() jazz.x = jazz.x + 70 end,
            imgs.run[5],
            function() jazz.x = jazz.x + 70 end,
            imgs.run[6],
            run_7,
        }
        attack_sequence = {
            imgs.jump_up[2],
            flip_interval*2,
            imgs.jump_up[1],
            imgs.run[2],
            attack,
            imgs.run[3],
            imgs.run[4],
            imgs.jump_down[1],
            imgs.run[6],
            run_7,
        }
        --[[
        oldattack_sequence = {
            imgs.run[1],
            imgs.run[2],
            attack,
            imgs.jump_up[2],
            imgs.jump_down[2],
            imgs.jump_down[3],
            imgs.run[7],
            run_7,
        }
        --]]
        --[[
        jump_up_sequence = {
            function() jazz.x = jazz.x + 20 end,
            imgs.run[1],
            function() jazz.x = jazz.x + 20 end,
            imgs.run[2],
            imgs.jump_up[1],
            jump,
            imgs.jump_up[2],
            imgs.jump_up[3],
            function() jazz.x = jazz.x + 50 end,
            imgs.jump_up[4],
            function() jazz.x = jazz.x + 30 end,
            imgs.run[7],
            run_7,
        }
        jump_down_sequence = {
            function() jazz.x = jazz.x + 20 end,
            imgs.run[1],
            function() jazz.x = jazz.x + 20 end,
            imgs.run[2],
            --imgs.jump_up[1],
            jump,
            imgs.jump_down[1],
            imgs.jump_down[2],
            function() jazz.x = jazz.x + 50 end,
            imgs.jump_down[3],
            function() jazz.x = jazz.x + 50 end,
            imgs.run[7],
            run_7,
        }
        --]]
        --[[
        to_swat_sequence = {
            imgs.jump_up[4],
            show_arm,
            imgs.swat[1],
            swat_pos_check
        }
        swat_sequence = {
            swat,
            1000,
            swat_pos_check,
        }
        swat_blink_sequence = {
            imgs.swat[2],
            imgs.swat[3],
            imgs.swat[2],
            imgs.swat[1],
            swat_pos_check,
        }
        swat_to_run_sequence = {
            imgs.jump_up[4],
            imgs.run[7],
            run_7
        }
        swat_wait = {
            500,
            swat_pos_check,
        }
        --]]
        pos_wait = {
            500,
            run_7,
        }
        wait_sequence = {
            500,
            wait_check,
        }
    end
    
    
    ----------------------------------------------------------------------------
    --lunging at the bird
    
    local in_attack_range = function(always)
        
        return (always or math.random(1,3) == 1) and
            (
                math.sqrt(
                    math.pow(target.x - jazz.x, 2) +
                    math.pow(target.y - jazz.y, 2)
                ) < lunge_radius
            )
        
    end
    
    local jazz_y_func, land_y, jazz_x_func, start_x, start_y, will_be_on
    local attack_x = Interval(0,0)
    local z_rot_mag = 10
    local attack_z_rot = Interval(-z_rot_mag,z_rot_mag)
    --[=[
    local attack_tl = Timeline{
        duration = jump_dur,
        on_new_frame = function(tl,ms,p)
            
            --print("A",jazz.x,jazz.y)
            
            jazz:set{
                x          = jazz_x_func(ms/1000),--attack_x:get_value(p),
                --p*(land_x - start_x),
                y          = jazz_y_func(ms/1000),--attack_x:get_value(p)),
                --peak_y - math.pow( jump_dist*p-jump_dist/2 ,2),
                z_rotation = {attack_z_rot:get_value(p),0,0},
            }
            
            --print("B",jazz.x,jazz.y)
            
        end,
        on_completed = function()
            
            print("attack done")
            
            jazz.on_obstacle = will_be_on
            
            Animation_Loop:add_animation(cat_animation)
            --[[
            jazz:set{
                x          = final_x,
                y          = final_y,
                z_rotation = final_z_rot,
            }
            --]]
            jazz.y_rotation = {0,0,0}
            jazz.z_rotation = {0,0,0}
            
            for i = 1, # obstacles do
                if jazz.x < obstacles[i].x + (obstacles[i].x_off or 0) then
                    
                    obstacle_i = i
                    
                    print("BEHIND",obstacles[i].source)
                    
                    break
                    
                end
            end
            print("attack_done_end\n\n")
        end,
        on_marker_reached = function()
            
            cat_animation:on_loop()
            
        end
    }
    --]=]
    local markers = {
        .2,
        .5,
        .7,
        .8
    }
    local marker_i = 1
    local attack_animation = {
        duration = 1,
        on_step = function(s,p)
            jazz:set{
                x          = jazz_x_func(s),--attack_x:get_value(p),
                --p*(land_x - start_x),
                y          = jazz_y_func(s),--attack_x:get_value(p)),
                --peak_y - math.pow( jump_dist*p-jump_dist/2 ,2),
                z_rotation = {attack_z_rot:get_value(p),0,0},
            }
            
            if markers[marker_i] and markers[marker_i] < p then
                cat_animation:on_loop()
                marker_i = marker_i + 1
            end
        end,
        on_completed = function()
            marker_i = 1
            print("attack done")
            
            jazz.on_obstacle = will_be_on
            
            Animation_Loop:add_animation(cat_animation)
            --[[
            jazz:set{
                x          = final_x,
                y          = final_y,
                z_rotation = final_z_rot,
            }
            --]]
            jazz.y_rotation = {0,0,0}
            jazz.z_rotation = {0,0,0}
            
            for i = 1, # obstacles do
                if jazz.x < obstacles[i].x + (obstacles[i].x_off or 0) then
                    
                    obstacle_i = i
                    
                    print("BEHIND",obstacles[i].source)
                    
                    break
                    
                end
            end
            print("attack_done_end\n\n")
        end,
    }
    
    --markers are used to flip between images during the jump
    --attack_tl:add_marker( "launch_to_mid", attack_tl.duration * .3 )
    --attack_tl:add_marker( "mid_to_land",   attack_tl.duration * .8 )
    
    local min_vy = -10
    local max_vy = -1500
    local min_vx = 10
    local max_vx = 700
    
    local g = -max_vy*1.5
    
    local function attack_prep(position)
        
        start_x = jazz.x
        start_y = jazz.y
        
        local vx = (position.x - jazz.x)*3
        --print(vx)
        vx = clamp_mag(vx,min_vx,max_vx)
        
        jazz_x_func = function(t)
            
            return start_x + vx * t --x_t = x_0 + v_x_0 * t
            
        end
        
        jazz_rev_x_func = function(x)
            
            return (x - start_x) / vx
            
        end
        
        local t = jazz_rev_x_func(position.x)
        
        local vy = (position.y - jazz.y - .5 * g * t * t) / t
        --print("vy",vy,t)
        if position.land == nil then vy = clamp(vy,max_vy,min_vy) end
        
        jazz_y_func = function(t)
            --print(start_y,vy,start_y   +   vy * t   +   .5 * g * t * t)
            
            -- y_t = y_0 + y_t_0 * t + .5*a*t^2
            return start_y   +   vy * t   +   .5 * g * t * t
            
        end
        
        land_y = floor_y
        will_be_on = false
        
        if position.land ~= nil then
            print("yuuuup")
            land_y = position.y
            
            --aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
            will_be_on = position.land
            attack_animation.duration = t
            
            if position.x < jazz.x then
                attack_z_rot.from =  position.y < jazz.y and  z_rot_mag or 0
                attack_z_rot.to   =  land_y+150 > jazz.y and -z_rot_mag or 0
            else
                attack_z_rot.to   = land_y+150 > jazz.y and  z_rot_mag or 0
                attack_z_rot.from = position.y < jazz.y and -z_rot_mag or 0
            end
            
        elseif position.x < jazz.x then
            
            jazz.y_rotation = {180,0,0}
            
            for i, o in pairs( obstacles ) do
                print(o.source)
                
                o_x = o.x + ( o.x_off or 0 )
                o_y = o.y + ( o.y_off or 0 ) - jazz.h/2
                
                if  o_y < jazz_y_func(jazz_rev_x_func(o_x)) and
                    o_y > jazz_y_func(jazz_rev_x_func(o_x+obstacles[i].w)) and
                    o_y < land_y then
                    print("gah",o_y,o.source)
                    will_be_on = o
                    
                    land_y = o_y
                end
                
            end
            
            
            attack_z_rot.from =  position.y < jazz.y and  z_rot_mag or 0
            attack_z_rot.to   =  land_y+150 > jazz.y and -z_rot_mag or 0
            
            aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
            
            attack_animation.duration = aaa
            
        else
            
            
            for i, o in pairs( obstacles ) do
                
                o_x = o.x + ( o.x_off or 0 )
                o_y = o.y + ( o.y_off or 0 ) - jazz.h/2
                print(o_y , jazz_y_func(jazz_rev_x_func(o_x)),jazz_y_func(jazz_rev_x_func(o_x+obstacles[i].w)))
                if  o_y > jazz_y_func(jazz_rev_x_func(o_x)) and
                    o_y < jazz_y_func(jazz_rev_x_func(o_x+obstacles[i].w)) and
                    o_y < land_y - jazz.h then
                    
                    print("gah",o_y,o.source)
                    will_be_on = o
                    
                    land_y = o_y
                end
                
            end
            attack_z_rot.to   = land_y+150 > jazz.y and  z_rot_mag or 0
            attack_z_rot.from = position.y < jazz.y and -z_rot_mag or 0
            
            aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
            
            attack_animation.duration = aaa
            
        end
        
        print("LAND_Y",land_y)
        
    end
    
    function attack()
        print("attack")
        
        Animation_Loop:delete_animation(cat_animation)
        
        attack_x.from = jazz.x
        
        start_x = jazz.x
        start_y = jazz.y
        
        --attack_tl:start()
        Animation_Loop:add_animation(attack_animation)
        
        return true
        
    end
    
    
    ----------------------------------------------------------------------------
    --Jumping up to obstacles
    --[=[
    local alpha_x    = Alpha{mode = "EASE_OUT_QUAD" }
    local alpha_y    = Alpha()
    local jump_x     = Interval(0,0)
    local jump_y     = Interval(0,0)
    local jump_z_rot = Interval(-20,0)
    
    local final_x, final_y, final_z_rot
    
    local jump_tl = Timeline{
        duration = jump_dur,
        on_new_frame = function(tl,ms,p)
            
            jazz:set{
                x          = jump_x:get_value(alpha_x.alpha),
                y          = jump_y:get_value(alpha_y.alpha),
                z_rotation = {jump_z_rot:get_value(alpha_x.alpha),0,0},
            }
            
        end,
        on_completed = function()
            
            Animation_Loop:add_animation(cat_animation)
            --[[
            jazz:set{
                x          = final_x,
                y          = final_y,
                z_rotation = final_z_rot,
            }
            --]]
            jazz.z_rotation = {0,0,0}
        end,
        on_marker_reached = function()
            
            cat_animation:on_loop()
            
        end
    }
    
    jump_tl:add_marker("launch_to_mid",jump_tl.duration*.3)
    jump_tl:add_marker("mid_to_land",jump_tl.duration*.8)
    
    alpha_x.timeline = jump_tl
    alpha_y.timeline = jump_tl
    
    local jump_prep = function(t)
        
        --dumptable(t)
        
        --jump_tl.duration = t.duration
        
        --jump_x.from      = t.curr_x
        --jump_y.from      = t.curr_y
        --jump_z_rot.from  = t.curr_z_rot or 0
        
        jump_x.to        = t.targ_x + jazz.w/2
        jump_y.to        = t.targ_y + jazz.h/2
        --jump_z_rot.to    = t.targ_z_rot
        
        jazz.on_obstacle = t.obstacle or false
        
        jazz.attacking   = t.attacking or false
        
    end
    
    jump = function()
        
        Animation_Loop:delete_animation(cat_animation)
        
        jump_x.from      = jazz.x
        jump_y.from      = jazz.y
        
        --if jumping up
        if jump_y.from > jump_y.to then
            alpha_y.mode = "EASE_OUT_BACK"
            
            jump_z_rot.from = math.deg(
                math.atan2(
                    (jump_y.to-jump_y.from),
                    (jump_x.to-jump_x.from)
                )
            )/2
            
            jump_z_rot.to   =   0
        --if jumping down
        else
            alpha_y.mode    = "EASE_IN_CIRC"
            jump_z_rot.from =  -5
            jump_z_rot.to   =  10
        end
        
        print(jump_x.from,jump_x.to)
        if not jazz.attacking and jump_x.from + 150 > jump_x.to then
            print("capped")
            jump_x.to = jump_x.from + 150
            
        end
        
        jump_tl:start()
        
        return true
        
    end
    --]=]
    ----------------------------------------------------------------------------
    --Wait
    
    function wait_check()
        
        frame_i = 1
        --[[
        if  math.abs(target.x - jazz.x) < swat_threshold_x and
            math.abs(target.y - jazz.y) < swat_threshold_y then
            
            print("SWAT")
            
            frames = to_swat_sequence
            
            return 
            
        --if Max is in lunge range, then lunge with a probabilty of missing
        else]]if in_attack_range(true) then   
            
            print("lunge")
            
            attack_prep(target)
            
            frames = attack_sequence
            
            return
            
        elseif target.x > jazz.x + lunge_threshold_x then
            
            run_7()
            
        end
        
        print(math.abs(target.x - jazz.x),math.abs(target.y - jazz.y))
    end
    ----------------------------------------------------------------------------
    --Swatting at the target
    --[=[
    function show_arm()
        arm:show()
        arm.x = jazz.x --+ 210
        arm.y = jazz.y --+ 150
    end
    
    local swat_angle = Interval(10,-10)
    local swat_tl_count = 0
    local swat_tl = Timeline{
        duration = 300,
        loop     = true,
        on_new_frame = function(tl,ms,p)
            
            arm.z_rotation = {
                
                swat_angle:get_value(
                    .5 + .5 * math.sin(
                        math.pi*2*p
                    )
                ),
                
                0,
                
                0
            }
            
        end,
        on_completed = function(self)
            
            swat_tl_count = swat_tl_count + 1
            
            if swat_tl_count > 3 then
                
                self:stop()
                
            end
            
        end,
    }
    
    swat_tl_count = 0
    
    swat = function()
        
        swat_tl_count = 0
        
        swat_tl:start()
        
    end
    --]=]
    swat_pos_check = function()
        
        frame_i = 1
        
        if  math.abs(target.x - jazz.x) < swat_threshold_x and
            math.abs(target.y - jazz.y) < swat_threshold_y then
            
            
            if math.random(1,4) == 1 then
                
                --print("swat blink")
                
                frames = swat_blink_sequence
                
            else
                
                --print("commence swatting!")
                
                frames = swat_sequence
                
            end
            
        elseif jazz.on_obstacle and
            target.x < jazz.x + swat_threshold_x then
            
            
            frames = swat_wait
            
        else
            
            --print("f this",math.abs(target.x - jazz.x),math.abs(target.y - jazz.y))
            
            arm:hide()
            
            frames = swat_to_run_sequence
            
        end
        
    end
    
    --]=]
    ----------------------------------------------------------------------------
    --Running
    
    run_7  = function()
        
        frame_i = 1
        
        if obstacles[obstacle_i] then
            next_obst_x = obstacles[obstacle_i].x + (obstacles[obstacle_i].x_off or 0)
            next_obst_y = obstacles[obstacle_i].y + (obstacles[obstacle_i].y_off or 0)
        else
            next_obst_x = false
        end
        
        
            
        if jazz.x > stop_point then
            
            jazz.source = imgs.default[1]
            print("Jazz stopping")
            Animation_Loop:delete_animation(cat_animation)
            
            return
            
        --if jazz got pooped on, then wipe it off
        elseif jazz.pooped_on then
            
            jazz.pooped_on = false
            
            frames = poop_shake_sequence
            
            return
            
        --[[
        --if Max is in swat range, then swat
        elseif math.abs(target.x - jazz.x) < swat_threshold_x and
               math.abs(target.y - jazz.y) < swat_threshold_y then
            
            print("SWAT")
            
            frames = to_swat_sequence
            
            return 
        --]]
        --if Max is in lunge range, then lunge with a probabilty of missing
        elseif in_attack_range() then   
            
            print("lunge")
            
            attack_prep(target)
            
            frames = attack_sequence
            
            return
            --]]
        --if jazz is on an obstacle and Max is behind, wait to swat
        elseif jazz.on_obstacle and
            target.x < jazz.x - lunge_threshold_x then
            
            print("prep swat")
            
            jazz.y_rotation = {180,0,0}
            
            jazz.source = imgs.default[1]
            
            frames = wait_sequence
            
            return
        --]]
        -- if jazz is nearing the end of an obstacle
        elseif jazz.on_obstacle and
            jazz.on_obstacle.x + (jazz.on_obstacle.x_off or 0) + jazz.on_obstacle.w -
                jazz.x < 300 then 
            
            if next_obst_x ~= false and next_obst_x - jazz.x - jazz.w < 300 then
                --jump to next obstacle
                
                --[[
                jump_prep{
                    duration   = 500,
                    targ_x     = next_obst_x,
                    targ_y     = next_obst_y - jazz.h,
                    targ_z_rot = 0,
                    obstacle   = obstacles[obstacle_i],
                }
                
                obstacle_i = obstacle_i + 1
                
                if next_obst_y > jazz.y then
                    frames = jump_down_sequence
                else
                    frames = jump_up_sequence
                end
                --]]
                
                
                
                attack_prep{x=next_obst_x+jazz.w/2,y=next_obst_y-jazz.h/2,land=obstacles[obstacle_i]}
                
                obstacle_i = obstacle_i + 1
                
                frames = attack_sequence
                
                return
                
            else
                --jump back to the floor
                
                --[[
                jump_prep{
                    duration   = 500,
                    targ_x     = jazz.x + 300,
                    targ_y     = floor_y - jazz.h/2,
                    targ_z_rot = 0,
                    obstacle   = false,
                }
                
                frames = jump_down_sequence
                --]]
                
                
                
                attack_prep{x=jazz.x + 300,y=floor_y,land=false}
                
                obstacle_i = obstacle_i + 1
                
                frames = attack_sequence
                
                return
            end
            
            jazz.z_rotation = {0,0,0}
            
            return
            
        --if nearing an obstacle, jump to it
        elseif next_obst_x ~= false and next_obst_x - jazz.x - jazz.w < 300 then
            
            print("AAAAAfrom floor x: ",next_obst_x - jazz.x - jazz.w)
            --[[
            jump_prep{
                duration   = 500,
                targ_x     = next_obst_x - jazz.w/3,
                targ_y     = next_obst_y - jazz.h,
                targ_z_rot = 0,
                obstacle   = obstacles[obstacle_i],
            }
            
            obstacle_i = obstacle_i + 1
            
            frames = jump_up_sequence
            
            jazz.z_rotation = {0,0,0}
            --]]
            
            
            
            attack_prep{x=next_obst_x+jazz.w/2,y=next_obst_y-jazz.h/2,land=obstacles[obstacle_i]}
            
            obstacle_i = obstacle_i + 1
            
            frames = attack_sequence
            
            return
            
        elseif next_obst_x ~= false and target.x < jazz.x
            and next_obst_x - jazz.x - jazz.w > 600 then
            
            jazz.source = imgs.default[1]
            
            frames = pos_wait
            
            return
            
        end
        
        jazz.z_rotation = {0,0,0}
        --else just keep running
        print("run")
        frames = run_sequence
        
    end
    
    
    ----------------------------------------------------------------------------
    --General Animation Stuff
    
    act_on_frame = function(item)
        
        frame_i = frame_i + 1
        
        if type(item) == "userdata" then
            
            jazz.source = item
            
            return true
            
        elseif type(item) == "number" then
            
            cat_animation.duration = item/1000--cat_animation.duration = item
            
            return true
            
        elseif type(item) == "function" then
            
            return item() or false
            
        else
            
            error("frame type not expected " .. type(item), 2)
            
        end
    end
    
    cat_animation = {
        duration = flip_interval,
        loop    = true,
        on_step = function() end,
        on_loop = function(self)
            
            self.duration = flip_interval   -- if a delay was set, then this resets
            
            while not act_on_frame(frames[frame_i]) do end
            
        end
    }
    --[[
    animating = Timer{
        
        interval  = flip_interval,
        
        on_timer  = function(self)
            
            self.interval = flip_interval   -- if a delay was set, then this resets
            
            while not act_on_frame(frames[frame_i]) do end
            
        end
        
    }
    
    Animation_Loop:delete_animation(cat_animation)
    --]]
    
    function jazz:launch_AI(obstacle_list,end_x)
        
        if not has_been_initialized then
            
            error("Call jazz:Init{} first",2)
            
        end
        
        if not is_loaded then
            
            error("Call jazz:load_assets{} first",2)
            
        end
        
        if type(obstacle_list) ~= "table" then
            
            error("expected type 'table' for parameter 1",2)
            
        end
        
        if type(end_x) ~= "number" then
            
            error("expected type 'number' for parameter 2",2)
            
        end
        
        obstacle_i = 1
        
        obstacles  = obstacle_list
        
        --arm.source = imgs.arm
        
        --dumptable(obstacle_list)
        stop_point = end_x
        
        make_sequences()
        
        frame_i = 1
        
        frames = run_sequence
        
        cat_animation.duration = flip_interval
        
        Animation_Loop:add_animation(cat_animation)
        
        jazz.x = 0
        jazz.y = floor_y
        
    end
    
end

gamestate:add_state_change_function(
    function()
        
        jazz:unparent()
        
        srcs:clear()
        srcs:unparent()
        
        is_loaded = false
    end,
    "ACTIVE","LVL_TRANSITION"
)

--------------------------------------------------------------------------------
-- Object
--------------------------------------------------------------------------------

return jazz







