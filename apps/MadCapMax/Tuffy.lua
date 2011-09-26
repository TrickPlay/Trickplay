

local dog = Clone{}

local is_loaded = false
local srcs = Group{}
local imgs = {}
local has_been_initialized = false
local stop_point, obstacles, flip_interval, floor_y, target, lvl




function dog:init(t)
    
    if has_been_initialized then
        
        error("dog has already been initialized",2)
        
    end
    
    flip_interval = t.flip_interval or .08
    floor_y       = t.floor_y       or 900
    --jump_dur      = t.jump_duration or 400
    target        = t.target        or error("must give dog a target",2)
    lvl           = t.lvl           or error("must give dog the level object",2)
    
    has_been_initialized = true
    
end


--Loads up the assets for dog into memory
--That way the character is only in memory when it needs to be
function dog:load_assets(src_parent, actor_parent)
    
    if not has_been_initialized then
        
        error("Call dog:Init{} first",2)
        
    end
    
    if type(src_parent) ~= "userdata" then
        
        error("parameter must be a group",2)
        
    end
    
    if is_loaded then
        
        if # srcs.children == 0 then
            
            error("meta-data 'dog.is_loaded' is incorrect",2)
            
        else
            
            error("load_assets was called when the assets where already loaded",2)
            
        end
        
    end
    
    imgs.poop = {
        Image{src ="assets/tuffy/tuffy-poop-1.png"},
        Image{src ="assets/tuffy/tuffy-poop-2.png"},
        Image{src ="assets/tuffy/tuffy-poop-3.png"},
        Image{src ="assets/tuffy/tuffy-poop-4.png"},
    }
    imgs.sit = {
        Image{src ="assets/tuffy/tuffy-1.png"},
        Image{src ="assets/tuffy/tuffy-2.png"},
        Image{src ="assets/tuffy/tuffy-3.png"},
        Image{src ="assets/tuffy/tuffy-4.png"},
    }
    imgs.attack = {
        Image{src ="assets/tuffy/tuffy-6.png"},
        Image{src ="assets/tuffy/tuffy-7.png"},
        Image{src ="assets/tuffy/tuffy-8.png"},
        Image{src ="assets/tuffy/tuffy-9.png"},
        Image{src ="assets/tuffy/tuffy-10.png"},
    }
    imgs.eye_lids = Image{src ="assets/tuffy/tuffy-eyelid-full.png"}
    imgs.run = {
        Image{src ="assets/tuffy/tuffy-run1.png"},
        Image{src ="assets/tuffy/tuffy-run2.png"},
        Image{src ="assets/tuffy/tuffy-run3.png"},
        Image{src ="assets/tuffy/tuffy-run4.png"},
        Image{src ="assets/tuffy/tuffy-run5.png"},
        Image{src ="assets/tuffy/tuffy-run6.png"},
        Image{src ="assets/tuffy/tuffy-run7.png"},
        Image{src ="assets/tuffy/tuffy-run8.png"},
    }
    --imgs.arm = Image{src ="assets/jazz_sprite/jazz-swat-arm.png"}
    
    apply_func_to_table(imgs, function(img) srcs:add(img) end)
    
    src_parent:add(srcs)
    
    dog.lids = Clone{source = imgs.eye_lids}
    
    actor_parent:add(dog,dog.lids)
    
    is_loaded = true
    
    dog.anchor_point = {
        imgs.run[3].w/2,
        imgs.run[3].h/2
    }
    
end




do
    
    local run_dir = 1
    
    local run_sequence, attack_sequence, wait_sequence, poop_shake_sequence, blink_sequence
    
    local next_move
    
    ----------------------------------------------------------------------------
    --init's all of the sequences
    --can only be called once assets were loaded
    local function make_sequences()
        run_sequence = {
            function() dog.x = dog.x + run_dir*60 end,
            imgs.run[1],
            function() dog.x = dog.x + run_dir*80 end,
            function() if math.random(1,5) == 1 then mediaplayer:play_sound("audio/dog bark"..math.random(1,2)..".mp3") end end,
            imgs.run[2],
            function() dog.x = dog.x + run_dir*60 end,
            imgs.run[3],
            function() dog.x = dog.x + run_dir*40 end,
            imgs.run[4],
            function() dog.x = dog.x + run_dir*40 end,
            imgs.run[5],
            function() dog.x = dog.x + run_dir*40 end,
            imgs.run[6],
            imgs.run[7],
            imgs.run[8],
            next_move,
        }
        attack_sequence = {
            imgs.attack[1],
            function() dog.harmless = false end,
            imgs.attack[2],
            imgs.attack[3],
            imgs.attack[2],
            imgs.attack[3],
            function() if math.random(1,4) == 1 then mediaplayer:play_sound("audio/dog bark"..math.random(1,2)..".mp3") end end,
            imgs.attack[4],
            imgs.attack[5],
            imgs.attack[4],
            function() dog.harmless = true end,
            imgs.attack[1],
            imgs.run[3],
            next_move
        }
        poop_shake_sequence = {
            imgs.poop[1],
            imgs.poop[2],
            imgs.poop[3],
            imgs.poop[4],
            function()  mediaplayer:play_sound("audio/dog whine "..math.random(1,2)..".mp3") end,
            imgs.poop[3],
            imgs.poop[2],
            imgs.poop[3],
            imgs.poop[4],
            imgs.poop[3],
            imgs.poop[2],
            imgs.poop[3],
            imgs.poop[4],
            imgs.poop[3],
            imgs.poop[2],
            imgs.poop[1],
            next_move
        }
        blink_sequence = {
            function()
                if math.random(1,12) == 7 then
                    
                    dog.lids.x = dog.x +  28
                    dog.lids.y = dog.y - 124
                    
                    dog.lids:show()
                    
                    dolater(
                        100,
                        dog.lids.hide,
                        dog.lids
                    )
                end
            end,
            function() if math.random(1,15) == 1 then mediaplayer:play_sound("audio/dog whine "..math.random(1,2)..".mp3") end end,
            100,
            next_move,
        }
        wait_sequence = {
            100,
            next_move,
        }
    end
    
    local start_x, call_on_start, stop_x, die_x
    
    local attack_radius = 300
    
    local function is_in_attack_range()
        
        return (
                    math.sqrt(
                        math.pow(target.x - dog.x, 2) +
                        math.pow(target.y - dog.y, 2)
                    ) < attack_radius
                )
    end
    
    next_move = function()
        
        frame_i = 1
        
        if dog.pooped_on then
                
                dog.pooped_on = false
                
                frames = poop_shake_sequence
                
            --if Max is in lunge range, then lunge with a probabilty of missing
        elseif is_in_attack_range() then
            
            frames = attack_sequence
            
        elseif target.x < dog.x - 200 then
            
            run_dir = -1
            
            frames = run_sequence
            
        elseif target.x > dog.x + 200 then
            
            run_dir = 1
            
            if dog.x < stop_x then
                
                frames = run_sequence
                
            elseif dog.x < -physics_world.x then
                
                Animation_Loop:delete_animation(dog_animation)
                
            else
                dog.source = imgs.poop[1]
                frames = blink_sequence
                
            end
            
        else
            
            frames = wait_sequence
            
        end
        
        dog.y_rotation = { 90 - run_dir*90,0,0}
    end
    
    ----------------------------------------------------------------------------
    --General Animation Stuff
    
    act_on_frame = function(item)
        
        frame_i = frame_i + 1
        
        if type(item) == "userdata" then
            
            dog.source = item
            
            return true
            
        elseif type(item) == "number" then
            
            dog_animation.duration = item/1000--dog_animation.duration = item
            
            return true
            
        elseif type(item) == "function" then
            
            return item() or false
            
        else
            
            error("frame type not expected " .. type(item), 2)
            
        end
    end
    
    dog_animation = {
        duration = flip_interval,
        loop    = true,
        on_step = function() end,
        on_loop = function(self)
            
            self.duration = flip_interval   -- if a delay was set, then this resets
            
            while not act_on_frame(frames[frame_i]) do end
            
        end
    }
    
    
    local wait_to_start
    wait_to_start = {
        on_step = function()
            
            if -physics_world.x + screen_w > start_x then
                
                if Animation_Loop:has_animation(dog_animation) then return end
                dolater(
                    Animation_Loop.delete_animation,
                    Animation_Loop,
                    wait_to_start
                )
                mediaplayer:play_sound("audio/dog bark2.mp3")
                
                Animation_Loop:add_animation(dog_animation)
                if call_on_start then call_on_start() end
            end
            
        end
    }
    
    function dog:setup_for_level(t)
        
        if not has_been_initialized then
            
            error("Call dog:Init{} first",2)
            
        end
        
        
        start_x = t.entry_x or 3600-100
        stop_x = t.stop_x or 5700-100
        die_x = t.die_x   or stop_x+screen_w
        dog.x = start_x+200
        call_on_start = t.call_on_start
        
        dog:load_assets(layers.srcs, layers.enemy)
        --[[
        obstacle_i = 1
        
        obstacles  = lvl.obstacles or error("an obstacles must be set")
        
        
        if # obstacles ~= 0 then
            for i = 1, # obstacles do
                if obstacles[i].x > dog.x then
                    
                    dog.right_obstacle = i
                    
                    break
                    
                elseif obstacles[i].x < dog.x and
                    obstacles[i].x + obstacles[i].w > dog.x then
                    
                    dog.under_obstacle = i
                    
                else
                    
                    dog.left_obstacle = i
                    
                end
            end
        end
        --]]
        
        --stop_point = lvl.enemy_stop or error("an enemy stop must be set")
        dog.harmless = true
        
        make_sequences()
        
        dog.source = imgs.run[8]
        
        frame_i = 1
        
        frames = run_sequence
        
        dog_animation.duration = flip_interval
        
        --Animation_Loop:add_animation(wait_to_start)
        
        --dog.x = 0
        dog.y = floor_y
        dog.y_rotation = {0,0,0}
        
        Animation_Loop:add_animation(wait_to_start,"ACTIVE")
        
    end
    
end


    function dog:hit()
        
        dog.pooped_on = true
        
    end
function dog:update_coll_box()
    
    dog.x1 = dog.x - dog.anchor_point[1] + 40
    dog.y1 = dog.y - dog.anchor_point[2] 
    dog.x2 = dog.x - dog.anchor_point[1] + dog.w - 40
    dog.y2 = dog.y - dog.anchor_point[2] + dog.h
    
end


    gamestate:add_state_change_function(
        function()
            
            dog:unparent()
            
            srcs:clear()
            srcs:unparent()
            
            is_loaded = false
            
        end,
        "ACTIVE","LVL_TRANSITION"
    )

return dog