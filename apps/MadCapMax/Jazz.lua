



local asset_loaders = {
    ["Jazz"] = function(t)
        t.default = {
            Image{src ="assets/jazz_sprite/jazz-default-1.png"},
            Image{src ="assets/jazz_sprite/jazz-default-2.png"},
            Image{src ="assets/jazz_sprite/jazz-default-3.png"},
        }
        t.jump_down = {
            Image{src ="assets/jazz_sprite/jazz-jump-down-2.png"},
        }
        t.jump_up = {
            Image{src ="assets/jazz_sprite/jazz-jump-up-1.png"},
            Image{src ="assets/jazz_sprite/jazz-jump-up-4.png"},
        }
        t.run = {
            Image{src ="assets/jazz_sprite/jazz-run-1.png"},
            Image{src ="assets/jazz_sprite/jazz-run-2.png"},
            Image{src ="assets/jazz_sprite/jazz-run-3.png"},
            Image{src ="assets/jazz_sprite/jazz-run-4.png"},
            Image{src ="assets/jazz_sprite/jazz-run-5.png"},
            Image{src ="assets/jazz_sprite/jazz-run-6.png"},
            Image{src ="assets/jazz_sprite/jazz-run-7.png"},
        }
        t.poop_shake = {
            Image{src ="assets/jazz_sprite/jazz-poop-shake-1.png"},
            Image{src ="assets/jazz_sprite/jazz-poop-shake-2.png"},
            Image{src ="assets/jazz_sprite/jazz-poop-shake-3.png"},
            Image{src ="assets/jazz_sprite/jazz-poop-shake-4.png"},
            Image{src ="assets/jazz_sprite/jazz-poop-shake-5.png"},
        }
    end,
    ["Frank"] = function(t)
        t.default = {
            Image{src ="assets/frank/frank-default-1.png"},
            Image{src ="assets/frank/frank-default-2.png"},
            Image{src ="assets/frank/frank-default-3.png"},
        }
        t.jump_down = {
            Image{src ="assets/frank/frank-jump-down-2.png"},
        }
        t.jump_up = {
            Image{src ="assets/frank/frank-jump-up-1.png"},
            Image{src ="assets/frank/frank-jump-up-4.png"},
        }
        t.run = {
            Image{src ="assets/frank/frank-run-1.png"},
            Image{src ="assets/frank/frank-run-2.png"},
            Image{src ="assets/frank/frank-run-3.png"},
            Image{src ="assets/frank/frank-run-4.png"},
            Image{src ="assets/frank/frank-run-5.png"},
            Image{src ="assets/frank/frank-run-6.png"},
            Image{src ="assets/frank/frank-run-7.png"},
        }
        t.poop_shake = {
            Image{src ="assets/frank/frank-poop-shake-1.png"},
            Image{src ="assets/frank/frank-poop-shake-2.png"},
            Image{src ="assets/frank/frank-poop-shake-3.png"},
            Image{src ="assets/frank/frank-poop-shake-4.png"},
            Image{src ="assets/frank/frank-poop-shake-5.png"},
        }
        t.tall_splash = Image{src ="assets/lvl2/swamp-splash-back.png"}
        t.wide_splash = Image{src ="assets/lvl2/swamp-splash-front.png"}
        t.swamp = Image{src ="assets/lvl2/swamp-splash-btm-cutout.jpg"}
    end,
}


local make_cat = function(cat_name)
    
    if asset_loaders[cat_name] == nil then error("not a valid name",2) end
    
    --------------------------------------------------------------------------------
    -- Object                                                                     --
    --------------------------------------------------------------------------------
    
    local cat = Clone{}
    
    
    
    --------------------------------------------------------------------------------
    -- Attributes                                                                 --
    --------------------------------------------------------------------------------
    
    --constant
    local  swat_threshold_x = 200
    local  swat_threshold_y = 200
    local lunge_threshold_x = 600
    local lunge_threshold_y = 400
    local lunge_radius      = 700
    local hop_dx            =  40   -- dist travelled per hop while running
    
    --private
    local is_loaded = false
    local srcs = Group{}
    local imgs = {}
    local has_been_initialized = false
    local stop_point, obstacles, flip_interval, floor_y, target, lvl
    
    --local arm = Clone{anchor_point = { 5, 90 }}
    --arm:hide()
    
    --public
    cat.attacking = false
    
    
    
    
    --------------------------------------------------------------------------------
    -- Methods                                                                    --
    --------------------------------------------------------------------------------
    
    
    function cat:init(t)
        
        if has_been_initialized then
            
            error("cat has already been initialized",2)
            
        end
        
        flip_interval = t.flip_interval or .08
        floor_y       = t.floor_y       or 900
        target        = t.target        or error("must give cat a target",2)
        lvl           = t.lvl           or error("must give cat the level object",2)
        
        has_been_initialized = true
        
    end
    
    --Loads up the assets for cat into memory
    --That way the character is only in memory when it needs to be
    function cat:load_assets(src_parent, actor_parent)
        
        if not has_been_initialized then
            
            error("Call cat:Init{} first",2)
            
        end
        
        if type(src_parent) ~= "userdata" then
            
            error("parameter must be a group",2)
            
        end
        
        if is_loaded then
            
            if # srcs.children == 0 then
                
                error("meta-data 'cat.is_loaded' is incorrect",2)
                
            else
                
                error("load_assets was called when the assets where already loaded",2)
                
            end
            
        end
        
        asset_loaders[cat_name](imgs)
        --imgs.arm = Image{src ="assets/jazz_sprite/jazz-swat-arm.png"}
        
        apply_func_to_table(imgs, function(img) srcs:add(img) end)
        
        src_parent:add(srcs)
        
        actor_parent:add(cat)
        
        is_loaded = true
        
        cat.anchor_point = {
            imgs.default[1].w/3,
            imgs.default[2].h/2
        }
        
    end
    
    
    --The AI of the cat
    do
        
        --Upvals
        
        local run_dir = 1
        
        --frame table
        local frames, frame_i
        
        --functions
        local next_move, swat, swat_pos_check, animating, act_on_frame,
        jump, show_arm, wait_check, attack
        
        --sequences
        local run_sequence, jump_up_sequence, jump_down_sequence,
        to_swat_sequence, swat_sequence, swat_blink_sequence, swat_to_run_sequence,
        swat_wait, attack_sequence, pos_wait, poop_shake_sequence
        
        
        local next_obst_x, next_obst_y, o_x, o_y
        
        local no_floor = false
        
        local locked_pre_exit
        local locked_post_exit
        local locked_reentry
        
        local function check_obstacles()
            
            if cat.under_obstacle then
                if cat.x >
                    obstacles[cat.under_obstacle].x +
                    obstacles[cat.under_obstacle].w then
                    
                    
                    cat.left_obstacle = cat.under_obstacle
                    
                    cat.under_obstacle = nil
                    
                    print("JAZ OBST1:",cat.left_obstacle,cat.under_obstacle,cat.right_obstacle)
                    
                elseif cat.x < obstacles[cat.under_obstacle].x then
                    
                    
                    cat.right_obstacle = cat.under_obstacle
                    
                    cat.under_obstacle = nil
                    
                    print("JAZ OBST2:",cat.left_obstacle,cat.under_obstacle,cat.right_obstacle)
                    
                end
                
            end
            
            while cat.right_obstacle and cat.x > obstacles[cat.right_obstacle].x do
                
                if cat.x <
                    obstacles[cat.right_obstacle].x +
                    obstacles[cat.right_obstacle].w then
                    
                    
                    cat.left_obstacle = cat.under_obstacle or cat.left_obstacle
                    cat.under_obstacle = cat.right_obstacle
                    
                else
                    
                    cat.left_obstacle = cat.right_obstacle or cat.left_obstacle
                    
                end
                
                --if doesn't exist, then it nils it for us
                repeat
                    
                    cat.right_obstacle = obstacles[cat.right_obstacle + 1] ~= nil and
                        cat.right_obstacle + 1 or nil
                    
                until
                    obstacles[cat.right_obstacle] == nil or
                    obstacles[cat.right_obstacle].post_exit ~= true and
                    (locked_pre_exit ~= nil or
                    obstacles[cat.right_obstacle].pre_exit  ~= true)
                    
                
                print("JAZ OBST3:",cat.left_obstacle,cat.under_obstacle,cat.right_obstacle)
                --print(cat.x , obstacles[cat.right_obstacle].x)
            end
            
            while cat.left_obstacle and cat.x <
                obstacles[cat.left_obstacle].x +
                obstacles[cat.left_obstacle].w do
                
                
                if cat.x > obstacles[cat.left_obstacle].x then
                    
                    
                    cat.right_obstacle = cat.under_obstacle or cat.right_obstacle
                    cat.under_obstacle = cat.left_obstacle
                    
                else
                    
                    cat.right_obstacle = cat.left_obstacle or cat.right_obstacle
                    
                end
                
                --if doesn't exist, then it nils it for us
                repeat
                    
                    cat.left_obstacle = obstacles[cat.left_obstacle - 1] ~= nil and
                        cat.left_obstacle - 1 or nil
                    
                until
                    obstacles[cat.left_obstacle] == nil or
                    obstacles[cat.left_obstacle].post_exit ~= true and
                    (locked_pre_exit ~= nil or
                    obstacles[cat.left_obstacle].pre_exit  ~= true)
                
                print("JAZ OBST4:",cat.left_obstacle,cat.under_obstacle,cat.right_obstacle)
                
            end
            
        end
        
        
        
        
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
            }
            
            run_sequence = {
                function() cat.x = cat.x + run_dir*30 end,
                imgs.run[7],
                function() cat.x = cat.x + run_dir*20 end,
                imgs.run[1],
                function() cat.x = cat.x + run_dir*20 end,
                imgs.run[2],
                --function() cat.x = cat.x + 50 end,
                --imgs.run[3],
                function() cat.x = cat.x + run_dir*90 end,
                imgs.run[4],
                function() cat.x = cat.x + run_dir*70 end,
                imgs.run[5],
                function() cat.x = cat.x + run_dir*70 end,
                imgs.run[6],
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
            }
            wait_sequence = {
                100,
            }
        end
        
        
        ----------------------------------------------------------------------------
        --lunging at the bird
        
        local in_attack_range = function(always)
            
            return (
                    math.sqrt(
                        math.pow(target.x - cat.x, 2) +
                        math.pow(target.y - cat.y, 2)
                    ) < lunge_radius
                )
            
        end
        
        local cat_y_func, land_y, cat_x_func, start_x, start_y, will_be_on
        local attack_x = Interval(0,0)
        local z_rot_mag = 10
        local attack_z_rot = Interval(-z_rot_mag,z_rot_mag)
        local cat_animation
        local markers = {
            .2,
            .5,
            .7,
            .8
        }
        local marker_i = 1
        local on_complete
        
        local big_splash_phase_2 = {
            duration = .3,
            on_step = function(s,p)
                cat.tall_splash.opacity = 255*(1-p)
                cat.wide_splash.opacity = 255*(1-p)
                
            end,
            on_completed = function()
                cat.tall_splash:unparent()
                cat.tall_splash = nil
                cat.wide_splash:unparent()
                cat.wide_splash = nil
                --cat.swamp:unparent()
                cat.swamp = nil
            end
        }
        local big_splash_phase_1 = {
            duration = .3,
            on_step = function(s,p)
                cat.tall_splash.scale = {1,p}
                cat.wide_splash.scale = {p,1.2*p}
                cat.y = start_y + cat.h*p
            end,
            on_completed = function()
                cat.opacity = 0
                Animation_Loop:add_animation(big_splash_phase_2)
            end
        }
        
        
        local attack_animation = {
            duration = 1,
            on_step = function(s,p)
                cat:set{
                    x          = cat_x_func(p),--attack_x:get_value(p),
                    --p*(land_x - start_x),
                    y          = cat_y_func(p),--attack_x:get_value(p)),
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
                print("attack done",cat.y)
                
                cat.on_obstacle = will_be_on
                
                Animation_Loop:add_animation(cat_animation)
                --[[
                cat:set{
                    x          = final_x,
                    y          = final_y,
                    z_rotation = final_z_rot,
                }
                --]]
                --cat.y_rotation = {0,0,0}
                cat.scale = {1,1}
                cat.z_rotation = {0,0,0}
                
                for i = 1, # obstacles do
                    if cat.x < obstacles[i].x + (obstacles[i].x_off or 0) then
                        
                        obstacle_i = i
                        
                        --print("BEHIND",obstacles[i].source)
                        
                        break
                        
                    end
                end
                
                if on_complete then on_complete() end
                --print("attack_done_end\n\n")
            end,
        }
        
        --markers are used to flip between images during the jump
        --attack_tl:add_marker( "launch_to_mid", attack_tl.duration * .3 )
        --attack_tl:add_marker( "mid_to_land",   attack_tl.duration * .8 )
        
        local min_vy = -10
        local max_vy = -1500
        local min_vx = 10
        local max_vx = 700
        local ppm    = 200
        local g = -max_vy*1.5
        
        
        
        local one_sec_A = 0.0059353880964885
        local one_n_half_sec_A = 0.058130242561448
        
        local function leap_prep(land_x,land_y,on_c)
            
            start_x = cat.x
            start_y = cat.y
            
            local jumping_down = land_y > start_y 
            
            local peak_x =  jumping_down and
                    (land_x - start_x)/4 + start_x or
                    (land_x - start_x)/2 + start_x
            local peak_y = jumping_down and start_y - 100 or land_y - 100
            
            cat_y_func, t = calc_parabola(
                
                start_x, start_y,
                
                peak_x,
                peak_y,
                
                land_x,  land_y
                
            )
            
            local vx = (land_x - start_x) --* (jumping_down and 2 or 1)
            
            cat_x_func = function(t)
                
                return start_x + vx * t --x_t = x_0 + v_x_0 * t
                
            end
            
            local old_y_f = cat_y_func
            if land_x == start_x and land_y == start_y then
                cat_y_func = function(e)
                    return peak_y + (land_y-peak_y)*(2*e-1)*(2*e-1)
                end
                t = math.abs(land_y-peak_y)/650
            else
                cat_y_func = function(e)
                    return old_y_f(cat_x_func(e))
                    --print(cat_x_func(t),"\t",old_y_f(cat_x_func(t)))
                end
            end
            attack_animation.duration = t--jumping_down and .5 or 1
            
            --print("try t = ", one_sec_A/a, a/one_sec_A)
            
            
            if land_x < cat.x then
                --cat.y_rotation = {180,0,0}
                cat.scale = {-1,1}
            else
                --cat.y_rotation = {0,0,0}
                cat.scale = {1,1}
            end
            
            on_complete = on_c
            land_x = nil
        end
        
        local function find_land_y(land_x, y_thresh)
            
            land_y = floor_y 
            
            for i, o in pairs( obstacles ) do
                
                
                if  land_x   > o.x           and
                    land_x   < o.x + o.w     and
                    land_y   > o.y - cat.h/2 and
                    y_thresh < o.y           then
                    
                    
                    will_be_on = o
                    
                    land_y = o.y - cat.h/2
                    
                end
                
            end
            
            return  land_y
            
        end
        
        local function strike_prep(on_c)
            
            start_x = cat.x
            start_y = cat.y
            local land_x
            local peak_x, peak_y
            if no_floor then
                
                if target.x < cat.x then
                    
                    land_x = obstacles[target.left_obstacle].x + cat.w/2
                    land_y = obstacles[target.left_obstacle].y - cat.h/2
                    
                    
                else
                    
                    if no_floor and target.right_obstacle == nil then
                        
                        land_x = death_spot and death_spot.x or 11350
                        land_y = death_spot and death_spot.y or start_y
                        
                        on_c = function()
                            print("cat die")
                            dolater(
                                Animation_Loop.delete_animation,
                                Animation_Loop,
                                cat_animation
                            )
                            cat.tall_splash = Clone{
                                source = imgs.tall_splash,
                                anchor_point = {imgs.tall_splash.w/2,imgs.tall_splash.h}
                            }
                            cat.wide_splash = Clone{
                                source = imgs.wide_splash,
                                anchor_point = {imgs.wide_splash.w/2,imgs.wide_splash.h}
                            }
                            cat.swamp = Clone{
                                source = imgs.swamp,
                                anchor_point = {imgs.wide_splash.w/2,0},
                                --scale = {4/3,4/3}
                            }
                            
                            cat.parent:add(
                                cat.tall_splash,
                                cat.swamp,
                                cat.wide_splash
                            )
                            cat.tall_splash:lower_to_bottom()
                            
                            cat.tall_splash.x = cat.x1+(cat.x2-cat.x1)/2
                            cat.tall_splash.y = cat.y2
                            cat.wide_splash.x = cat.x1+(cat.x2-cat.x1)/2
                            cat.wide_splash.y = cat.y2
                            cat.swamp.x = 11366--cat.x1+(cat.x2-cat.x1)/2-40
                            cat.swamp.y = 799--cat.y2 - 68
                            
                            Animation_Loop:add_animation(big_splash_phase_1)
                        end
                        
                    else
                        
                        land_x = obstacles[target.right_obstacle].x + cat.w/2
                        land_y = obstacles[target.right_obstacle].y - cat.h/2
                        
                    end
                end
                
                peak_x = (land_x - start_x)/2 + start_x
                
                peak_y = land_y < start_y and
                    (target.y < land_y  - 100 and target.y or land_y  - 100) or
                    (target.y < start_y - 100 and target.y or start_y - 100)
                
                
            end
            
            local jumping_down = target.y > start_y
            local jumping_level = target.y > start_y -100
            
            
            
            land_x = land_x or
                (jumping_down and 1.2 or jumping_level and 1.5 or 2) *
                (target.x - start_x) + start_x
            
            peak_x = peak_x or target.x
            peak_y = peak_y or target.y
            
            land_y = land_y or find_land_y(land_x, target.y-100)
            
            cat_y_func, t = calc_parabola(
                start_x, start_y,
                peak_x,  peak_y,
                land_x,  land_y
            )
            
            local vx = (land_x - start_x)
            
            cat_x_func = function(t)
                
                return start_x + vx * t --x_t = x_0 + v_x_0 * t
                
            end
            local old_y_f = cat_y_func            
            
            if land_x == start_x and land_y == start_y then
                print("or")
                cat_y_func = function(e)
                    return peak_y + (land_y-peak_y)*(2*e-1)*(2*e-1)
                end
                t = math.abs(land_y-peak_y)/650
            else
                cat_y_func = function(e)
                    return old_y_f(cat_x_func(e))
                    --print(cat_x_func(t),"\t",old_y_f(cat_x_func(t)))
                end
            end
            
            
            
            --print("try t = ",one_n_half_sec_A/a, a/one_n_half_sec_A)
            
            attack_animation.duration = t
            
            if land_x < cat.x then
                --cat.y_rotation = {180,0,0}
                cat.scale = {-1,1}
            else
                --cat.y_rotation = {0,0,0}
                cat.scale = {1,1}
            end
            land_x = nil
            on_complete = on_c
            
        end
        
        --[[
        local function attack_prep(position)
            error("why")
            start_x = cat.x
            start_y = cat.y
            
            local vx = (position.x - cat.x)*3
            
            vx = clamp_mag(vx,min_vx,max_vx)
            
            cat_x_func = function(t)
                
                return start_x + vx * t --x_t = x_0 + v_x_0 * t
                
            end
            
            cat_rev_x_func = function(x)
                
                return (x - start_x) / vx
                
            end
            
            local t = cat_rev_x_func(position.x)
            
            local vy = (position.y - cat.y - .5 * g * t * t) / t
            --print("vy",vy,t)
            if position.land == nil then vy = clamp(vy,max_vy,min_vy) end
            
            cat_y_func = function(t)
                --print(start_y,vy,start_y   +   vy * t   +   .5 * g * t * t)
                
                -- y_t = y_0 + y_t_0 * t + .5*a*t^2
                return start_y   +   vy * t   +   .5 * g * t * t
                
            end
            
            land_y = floor_y
            will_be_on = false
            
            if position.land ~= nil then
                
                land_y = position.y
                
                --aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
                will_be_on = position.land
                attack_animation.duration = t
                
                if position.x < cat.x then
                    cat.y_rotation = {180,0,0}
                    attack_z_rot.from =  position.y < cat.y and  z_rot_mag or 0
                    attack_z_rot.to   =  land_y+150 > cat.y and -z_rot_mag or 0
                else
                    cat.y_rotation = {0,0,0}
                    attack_z_rot.to   = land_y+150 > cat.y and  z_rot_mag or 0
                    attack_z_rot.from = position.y < cat.y and -z_rot_mag or 0
                end
                
            elseif position.x < cat.x then
                
                cat.y_rotation = {180,0,0}
                print("jumping to the left")
                for i, o in pairs( obstacles ) do
                    --print(o.source)
                    
                    o_x = o.x + ( o.x_off or 0 )
                    o_y = o.y + ( o.y_off or 0 ) - cat.h/2
                    
                    if  o_y < cat_y_func(cat_rev_x_func(o_x)) and
                        o_y > cat_y_func(cat_rev_x_func(o_x+obstacles[i].w)) and
                        o_y < land_y then
                        --print("gah",o_y,o.source)
                        will_be_on = o
                        
                        land_y = o_y
                    end
                    
                end
                
                
                attack_z_rot.from =  position.y < cat.y and  z_rot_mag or 0
                attack_z_rot.to   =  land_y+150 > cat.y and -z_rot_mag or 0
                
                aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
                
                attack_animation.duration = aaa
                
            else
                
                cat.y_rotation = {0,0,0}
                
                for i, o in pairs( obstacles ) do
                    
                    o_x = o.x + ( o.x_off or 0 )
                    o_y = o.y + ( o.y_off or 0 ) - cat.h/2
                    --print(o_y , cat_y_func(cat_rev_x_func(o_x)),cat_y_func(cat_rev_x_func(o_x+obstacles[i].w)))
                    if  o_y > cat_y_func(cat_rev_x_func(o_x)) and
                        o_y < cat_y_func(cat_rev_x_func(o_x+obstacles[i].w)) and
                        o_y < land_y - cat.h then
                        
                    --print("gah",o_y,o.source)
                        will_be_on = o
                        
                        land_y = o_y
                    end
                    
                end
                attack_z_rot.to   = land_y+150 > cat.y and  z_rot_mag or 0
                attack_z_rot.from = position.y < cat.y and -z_rot_mag or 0
                
                aaa, bbb = quadratic( .5 * g, vy, start_y - (land_y) )
                
                attack_animation.duration = aaa
                
            end
            
            --print("LAND_Y",land_y)
            
        end
        --]]
        function attack()
            --print("attack")
            
            Animation_Loop:delete_animation(cat_animation)
            
            attack_x.from = cat.x
            
            start_x = cat.x
            start_y = cat.y
            
            --attack_tl:start()
            Animation_Loop:add_animation(attack_animation)
            
            return true
            
        end
        
        ----------------------------------------------------------------------------
        --Running
        
        local function run(dir)
            
            run_dir = dir
            
            --cat.y_rotation = { 90 - dir*90,0,0}
            
            cat.scale = {dir,1}
            
            --moving to the right
            if dir == 1 then
                
                --jump up to the next 
                if cat.right_obstacle and cat.x + cat.w/2 + 400 >
                    obstacles[cat.right_obstacle].x or no_floor then
                    
                    print("run("..dir.."), jump to next")
                    --[[
                    attack_prep{
                        x    = obstacles[cat.right_obstacle].x+cat.w/2,
                        y    = obstacles[cat.right_obstacle].y-cat.h/2,
                        land = obstacles[cat.right_obstacle]
                    }
                    --]]
                    leap_prep(
                        obstacles[cat.right_obstacle].x+cat.w/2,
                        obstacles[cat.right_obstacle].y-cat.h/2
                    )
                    
                    frames = attack_sequence
                    
                elseif cat.under_obstacle and cat.y ~= floor_y and cat.x + cat.w/2 + 400 >
                    obstacles[cat.under_obstacle].x + obstacles[cat.under_obstacle].w then
                    
                    print("run("..dir.."), jump down")
                    --[[
                    attack_prep{x=cat.x + 300,y=floor_y,land=false}
                    --]]
                    leap_prep(
                        cat.x + 400,
                        floor_y
                    )
                    
                    frames = attack_sequence
                    
                else
                    
                    print("run("..dir.."), run")
                    frames  = run_sequence
                    
                end
                
            else
                
                if cat.left_obstacle and cat.x - cat.w/2 - 400 <
                    obstacles[cat.left_obstacle].x +
                    obstacles[cat.left_obstacle].w or no_floor then
                    
                    print("run("..dir.."), jump to next")
                    --[[
                    attack_prep{
                        x    = obstacles[cat.left_obstacle].x+obstacles[cat.left_obstacle].w-cat.w/2,
                        y    = obstacles[cat.left_obstacle].y-cat.h/2,
                        land = obstacles[cat.left_obstacle]
                    }
                    --]]
                    leap_prep(
                        obstacles[cat.left_obstacle].x+obstacles[cat.left_obstacle].w-cat.w/2,
                        obstacles[cat.left_obstacle].y-cat.h/2
                    )
                    
                    frames = attack_sequence
                    
                elseif cat.under_obstacle and cat.y ~= floor_y  and cat.x - cat.w/2 - 400 <
                    obstacles[cat.under_obstacle].x then
                    
                    print("run("..dir.."), jump down")
                    --[[
                    attack_prep{x=cat.x - 300,y=floor_y,land=false}
                    --]]
                    leap_prep(
                        cat.x - 400,
                        floor_y
                    )
                    
                    frames = attack_sequence
                    
                else
                    
                    frames  = run_sequence
                    
                end
                
            end
            
            
        end
        
        
        local function aim_for_obstacle(o)
            
            if type(o) ~= "table" then error("invalid index",2) end
            --if cat is to the left of the obstacle
            if cat.x + cat.w/2 < o.x then
                print("cat left of target")
                --if cat is in jumping range
                if cat.x + cat.w/2 > o.x - 400 then
                    print("jump to it")
                    --[[
                    attack_prep{
                        x    = o.x+cat.w/2,
                        y    = o.y-cat.h/2,
                        land = o
                    }
                    --]]
                    leap_prep(o.x+cat.w/2,o.y-cat.h/2)
                    
                    frames = attack_sequence
                    
                else
                    print("run to it")
                    run(1)
                    
                end
                
            --if cat is to the right of the obstacle
            elseif cat.x - cat.w/2 > o.x + o.w then
                print("cat right of target")
                
                --if cat is in jumping range
                if cat.x - cat.w/2 < o.x + o.w + 400 then
                    print("jump to it",o.x + o.w - cat.w/2, cat.x)
                    --[[
                    attack_prep{
                        x    = o.x + o.w - cat.w/2,
                        y    = o.y-cat.h/2,
                        land = o
                    }
                    --]]
                    leap_prep(o.x+cat.w/2,o.y-cat.h/2)
                    
                    frames = attack_sequence
                    
                else
                    print("run to it")
                    
                    run(-1)
                end
                
            --if cat is under the obstacle
            elseif cat.x + cat.w/2 >= o.x and
                cat.x - cat.w/2 <= o.x + o.w then
                print("cat under target")
                
                if o.can_jump_through then
                    print("can jump through")
                    if target.x < cat.x then
                        --[[
                        attack_prep{
                            x    = cat.x-400 > o.x and cat.x-400 or o.x + cat.w/2,
                            y    = o.y-cat.h/2,
                            land = o
                        }
                        --]]
                        print(2222222)
                        leap_prep(cat.x-400 > o.x and cat.x-400 or o.x + cat.w/2,o.y-cat.h/2)
                        
                    else
                        --[[
                        attack_prep{
                            x    = cat.x+400 < o.x + o.w and
                                cat.x+400 or o.x + o.w - cat.w/2,
                            y    = o.y-cat.h/2,
                            land = o
                        }
                    --]]
                        print(3333)
                        leap_prep(
                            cat.x+400 < o.x + o.w and
                            cat.x+400 or o.x + o.w - cat.w/2,
                            o.y-cat.h/2
                        )
                        
                    end
                    
                    frames = attack_sequence
                    
                else
                    print("run")
                    run(1)
                    
                end
                
                
                
            else    error("IMPOSSIBLE",2)    end
            
        end
        
        
        local exit_count = 1
        local move_to_exit
        cat.exit = function()
            
            local curr_count = 0
            
            for i = 1, # obstacles do
                
                if obstacles[i].pre_exit then
                    
                    curr_count = curr_count + 1
                    
                    if curr_count == exit_count then
                        
                        locked_pre_exit  = obstacles[  i  ]
                        locked_post_exit = obstacles[ i+1 ]
                        
                        assert(
                            locked_pre_exit ~= nil and
                            locked_post_exit ~= nil,
                            "Something went wrong"
                        )
                        
                    end
                    
                end
                
            end
            
            curr_count = 0
            
            for i = 1, # obstacles do
                
                if obstacles[i].reentry then
                    
                    curr_count = curr_count + 1
                    
                    if curr_count == exit_count then
                        
                        locked_reentry = obstacles[i]
                        
                    end
                    
                end
                
            end
            
            
            cat.left_obstacle  = nil
            cat.under_obstacle = nil
            cat.right_obstacle = 1
            
            check_obstacles()
            
            next_move = move_to_exit
            
        end
        local next_move_w_floor
        local reentry_wait = function()
            
            frame_i = 1
            
            if -physics_world.x > locked_reentry.x + locked_reentry.w then
                cat.harmless = false
                
                cat.x = locked_reentry.x
                
                if locked_reentry.reentry == "floorless" then
                    
                    no_floor = true
                    
                else
                    
                    no_floor = false
                    
                end
                
                locked_pre_exit  = nil
                locked_post_exit = nil
                locked_reentry   = nil
                
                
                cat.left_obstacle  = nil
                cat.under_obstacle = nil
                cat.right_obstacle = 1
                
                check_obstacles()
                
                next_move = next_move_w_floor
                
            end
            
        end
        
        move_to_exit = function()
            print("meeeeee")
            check_obstacles()
            frame_i = 1
            
            if obstacles[cat.under_obstacle] == locked_pre_exit and cat.y ~= floor_y then
                print("on pre, jumping to post")
                cat.harmless = true
                leap_prep(
                    locked_post_exit.x + cat.w/2,
                    locked_post_exit.y - cat.h/2,
                    function()
                        --if reentry then wait for it
                        if locked_reentry then
                            print("on post, waiting for reentry")
                            frames = wait_sequence
                            
                            next_move = reentry_wait
                            
                        --otherwise exit
                        else
                            print("on post, halting")
                            dolater(
                                Animation_Loop.delete_animation,
                                Animation_Loop,
                                cat_animation
                            )
                            
                        end
                    end
                )
                
                cat:unparent()
                
                locked_pre_exit.exit_piece.parent:add(cat)
                
                cat:lower_to_bottom()
                
                frames = attack_sequence
                
            else
                print("aiming for pre")
                aim_for_obstacle( locked_pre_exit )
                
            end
            
        end
        local deleting_self = false
        next_move_w_floor = function()
            
            check_obstacles()
            
            if target.dead then
                if deleting_self then
                    return
                end
                print("target is dead")
                deleting_self = true
                dolater(
                    Animation_Loop.delete_animation,
                    Animation_Loop,
                    cat_animation
                )
                return
            end
            
            frame_i = 1
            if no_floor and cat.right_obstacle == nil and target.right_obstacle == nil then
                
                if -physics_world.x < 9300 then
                    
                    cat.scale = {1,1}
                    
                    cat.source = imgs.default[1]
                    
                    frames = wait_sequence
                    
                else
                    
                    strike_prep()--with death parameters
                    
                    frames = attack_sequence
                    
                end
                
                return
            elseif cat.x > stop_point then
                
                cat.source = imgs.default[1]
                print("cat stopping")
                Animation_Loop:delete_animation(cat_animation)
                
                return
                
            --if cat got pooped on, then wipe it off
            elseif cat.pooped_on then
                
                cat.pooped_on = false
                
                frames = poop_shake_sequence
                
                return
                
            --if Max is in lunge range, then lunge with a probabilty of missing
            elseif in_attack_range() then   
                
                print("lunge")
                
                strike_prep()
                
                frames = attack_sequence
                
                return
                
            --if on an obstacle, and target is behind then wait
            elseif cat.under_obstacle and cat.y ~= floor_y and target.x < cat.x then
                --print("cat high wait")
                --cat.y_rotation = {180,0,0}
                cat.scale = {-1,1}
                
                cat.source = imgs.default[1]
                
                frames = wait_sequence
                
            --if Max is over an obstacle, I'm not on it, then run to it
            elseif target.under_obstacle and target.under_obstacle ~= cat.under_obstacle then
                print("aim for bir:under")
                aim_for_obstacle( obstacles[target.under_obstacle] )
                
            --if Max is to the left of an obstacle, and it will be in range of him soon
            elseif target.right_obstacle and
                obstacles[target.right_obstacle].x - target.x < lunge_radius*3/2 then
                print("aim for bir:right")
                
                aim_for_obstacle( obstacles[target.right_obstacle] )
                
            --if Max is to the right of an obstacle, and it is still close to him
            elseif target.left_obstacle  and target.x -
                obstacles[target.left_obstacle].x -
                obstacles[target.left_obstacle].w < lunge_radius/3 then
                print("aim for bir:left")
                
                aim_for_obstacle( obstacles[target.left_obstacle] )
                
                
            elseif target.x < cat.x - 200 then
                run(-1)
            elseif target.x > cat.x + 200 then
                print(target.x, cat.x + 200)
                run(1)
            else
                
                cat.source = imgs.default[1]
                
                frames = wait_sequence
                
            end
            
        end
        
        
        ----------------------------------------------------------------------------
        --General Animation Stuff
        
        act_on_frame = function(item)
            
            frame_i = frame_i + 1
            
            if type(item) == "userdata" then
                
                cat.source = item
                
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
                
                if frame_i > #frames then
                    
                    frame_i = 1
                    
                    if next_move then next_move() end
                    
                else
                    
                    while not act_on_frame(frames[frame_i]) do end
                    
                end
                
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
        
        
        function cat:toggle_floor()
            no_floor = true
        end
        function cat:setup_for_level(t)
            
            if not has_been_initialized then
                
                error("Call cat:Init{} first",2)
                
            end
            
            cat.harmless = false
            
            cat:load_assets(layers.srcs, layers.enemy)
            
            cat.source = imgs.default[1]
            
            obstacle_i = 1
            
            obstacles  = lvl.obstacles or error("an obstacles must be set")
            
            no_floor = false
            
            if # obstacles ~= 0 then
                for i = 1, # obstacles do
                    if obstacles[i].x > cat.x then
                        
                        cat.right_obstacle = i
                        
                        break
                        
                    elseif obstacles[i].x < cat.x and
                        obstacles[i].x + obstacles[i].w > cat.x then
                        
                        cat.under_obstacle = i
                        
                    else
                        
                        cat.left_obstacle = i
                        
                    end
                end
            end
            
            exit_count = 1
            
            locked_pre_exit  = nil
            locked_post_exit = nil
            locked_reentry   = nil
            
            
            stop_point = lvl.enemy_stop or error("an enemy stop must be set")
            
            make_sequences()
            
            frame_i = 1
            
            frames = run_sequence
            
            cat_animation.duration = flip_interval
            
--            Animation_Loop:add_animation(cat_animation)
            
            next_move = next_move_w_floor
            
            cat.x = t.start_x or 300
            cat.y = t.start_y or floor_y
            --cat.y_rotation = {0,0,0}
            cat.scale = {1,1}
            cat.opacity = 255
            
            
            deleting_self = false
            cat.left_obstacle  = nil
            cat.under_obstacle = nil
            cat.right_obstacle = 1
            
            check_obstacles()
            
            if t.launch then cat:launch() end
            
        end
        
        function cat:launch()
            
            Animation_Loop:add_animation(cat_animation,"ACTIVE")
            
        end
    end
    
    
    function cat:hit()
        
        cat.pooped_on = true
        
        mediaplayer:play_sound("audio/cat_2.wav")
        
    end
    
    --[[
    local debug_rect1 = Rectangle{color="00009944"}
    local debug_rect2 = Rectangle{color="99000099",w=10,h=10,anchor_point = {5,5}}
    
    physics_world:add(debug_rect1,debug_rect2)
    --]]
    function cat:update_coll_box()
        
        cat.x1 = cat.x - cat.anchor_point[1] + (cat.scale[1] == -1 and -60 or 40)
        cat.y1 = cat.y - cat.anchor_point[2] + 150
        cat.x2 = cat.x - cat.anchor_point[1] + (cat.scale[1] == 1 and cat.w-40 or 200)
        cat.y2 = cat.y - cat.anchor_point[2] + cat.h
        --[[
        debug_rect1.x = cat.x1
        debug_rect1.y = cat.y1
        debug_rect1.w = cat.x2 - cat.x1
        debug_rect1.h = cat.y2 - cat.y1
        
        debug_rect2.x = cat.x
        debug_rect2.y = cat.y
        --]]
    end
    
    gamestate:add_state_change_function(
        function()
            
            cat:unparent()
            
            srcs:clear()
            srcs:unparent()
            
            is_loaded = false
            
        end,
        "ACTIVE","LVL_TRANSITION"
    )
    
    ----------------------------------------------------------------------------
    -- Object
    ----------------------------------------------------------------------------
    
    return cat
    
end

return make_cat






