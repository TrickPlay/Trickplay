screen:show()

local function main()
    screen_w = screen.w
    screen_h = screen.h
    
    
    
    assets_path_dir = "assets/"
    
    ----------------------------------------------------------------------------
    -- Utility Functions                                                      --
    ----------------------------------------------------------------------------
    
    function make_flash_anim(obj,stop_check)
        return {
            loop     = true,
            duration = .7,
            on_step  = function(s,p)
                obj.opacity = 255*(.5-.5*math.cos(math.pi*2*p))
            end,
            on_loop = function(self)
                if stop_check() then
                    print(obj.opacity)
                    Animation_Loop:delete_animation(self)
                end
            end
        }
    end
    
    function apply_func_to_table(t,f)
    
        for _, v in pairs(t) do
            
            if type(v) == "table" then
                
                apply_func_to_table(v,f)
                
            else
                
                f(v)
                
            end
            
        end
    end
    
    function clamp(v,min,max)
        if v < min then
            v = min
        elseif v > max then
            v = max
        end
        return v
    end
    
    function clamp_mag(v,min,max)
        
        if min < 0 then
            error("Parameter 2 must be a positive value, it is a magnitude",2)
        end
        if max < 0 then
            error("Parameter 3 must be a positive value, it is a magnitude",2)
        end
        
        if v < 0 then
            if v > -min then
                v = -min
            elseif v < -max then
                v = -max
            end
        else
            if v < min then
                v = min
            elseif v > max then
                v = max
            end
        end
        
        return v
    end
    
    local discriminant
    function quadratic(a,b,c)
        
        print(a,b,c, b*b - 4*a*c)
        
        --discriminant = b*b - 4*a*c
    
        return  (-b + math.sqrt(b*b - 4*a*c)) / (2*a),
                (-b - math.sqrt(b*b - 4*a*c)) / (2*a)
    end
    
    ----------------------------------------------------------------------------
    -- non-'Filed' pieces                                                     --
    ----------------------------------------------------------------------------
    
    
    -----------------------------------
    -- Game Layers
    layers = {
        srcs         = Group{  name  =  "Clone Sources layer"      },
        
        distance     = Group{  name  =  "'In the Distance' layer"  },
        wall         = Group{  name  =  "'Tiled Wall' layer"       },
        wall_objs    = Group{  name  =  "Wall Objects layer"       },
        background   = Group{  name  =  "Background Objects layer" },
        items        = Group{  name  =  "Collidables layer"        },
        player       = Group{  name  =  "Player layer"             },
        enemy        = Group{  name  =  "Enemy layer"              },
        foreground   = Group{  name  =  "Foreground layer"         },
        
        menus        = Group{  name  =  "Menus layer"              },
    }
    
    physics_world = Group{name="PHYSICS WORLD"}
    physics_world:add(
        layers.distance,
        layers.wall,
        layers.wall_objs,
        layers.background,
        layers.items,     
        layers.player,    
        layers.enemy,     
        layers.foreground
    )
    screen:add(layers.srcs,physics_world,layers.menus)
    
    layers.srcs:hide()
    
    -----------------------------------
    -- Collisions
    collides_with_max = {}
    collides_with_enemy = {}
    enemies = {}
    local collided = function(object_1,object_2)
    
        --do box collision detection
        
        return not (                     --returns false if
            
            object_1.x1 > object_2.x2 or -- object_1 is   to the right of    object_2
            object_1.x2 < object_2.x1 or -- object_1 is   to the left  of    object_2
            object_1.y1 > object_2.y2 or -- object_1 is   behind             object_2
            object_1.y2 < object_2.y1    -- object_1 is   ahead of           object_2
            
        )
        
    end
    
    r1 = Rectangle{w=100,h=100,color="00009955"}
    r2 = Rectangle{w=100,h=100,color="99000055"}
    layers.foreground:add(r1,r2)
    check_collisions = function()
        
        if Jazz and Max then
            
            Jazz.x1 = Jazz.x-Jazz.anchor_point[1]+40
            Jazz.y1 = Jazz.y-Jazz.anchor_point[2]+150
            Jazz.x2 = Jazz.x-Jazz.anchor_point[1]+Jazz.w-40
            Jazz.y2 = Jazz.y-Jazz.anchor_point[2]+Jazz.h
            
            Max.x1 = Max.x-Max.anchor_point[1]+20
            Max.y1 = Max.y-Max.anchor_point[2]
            Max.x2 = Max.x-Max.anchor_point[1]+Max.w-50
            Max.y2 = Max.y-Max.anchor_point[2]+Max.h-40
            
            r1.x = Max.x1
            r1.w = Max.x2 - Max.x1
            
            r1.y = Max.y1
            r1.h = Max.y2 - Max.y1
            
            r2.x = Jazz.x1
            r2.w = Jazz.x2 - Jazz.x1
            
            r2.y = Jazz.y1
            r2.h = Jazz.y2 - Jazz.y1
            
            
            if not Max.hit and collided(Max,Jazz) then
                
                --[[
                if Jazz.y < Max.y - 20 then
                    print("above")
                else
                    print("below")
                end
                
                if Jazz.x < Max.x then
                    print("left")
                else
                    print("right")
                end
                --]]
                Max:recieve_impact(-1600,-1600)
                --Max:apply_v(Jazz.)
                --print("hit")
                
            end
            
            
            
            for i, item in pairs(collides_with_max) do
                
                item.x1 = item.x-item.anchor_point[1]
                item.y1 = item.y-item.anchor_point[2]
                item.x2 = item.x-item.anchor_point[1]+item.w
                item.y2 = item.y-item.anchor_point[2]+item.h
                
                if collided(Max,item) then
                    item:collision()
                end
                
            end
            
            for i, item in pairs(collides_with_enemy) do
                --for j, e in pairs(enemies) do
                    
                    item.x1 = item.x-item.anchor_point[1]
                    item.y1 = item.y-item.anchor_point[2]
                    item.x2 = item.x-item.anchor_point[1]+item.w
                    item.y2 = item.y-item.anchor_point[2]+item.h
                    
                    if collided(Jazz,item) then
                        item:collision(Jazz)
                    end
                    
                --end
            end
            
        end
    end
    
    
    
    
    ----------------------------------------------------------------------------
    -- Import all Components  (DOFILES)                                       --
    ----------------------------------------------------------------------------
    
    --generic utility files
    Animation_Loop = dofile("Utils/Animation_Loop.lua")
    StateMachine   = dofile("Utils/State_Machine.lua")
    
    gamestate = StateMachine{"OFFLINE","SPLASH","LVL_TRANSITION","ACTIVE","PAUSED"}
    
    --MadCapMax specific
    Item            = dofile("Items.lua")
    Splash_Menu     = dofile("Splash_Menu.lua")
    Transition_Menu = dofile("Transition_Menu.lua")
    LVL_Object      = dofile("Level_Object.lua")
    Max             = dofile("Max.lua")
    Jazz            = dofile("Jazz.lua")
    
    
    ----------------------------------------------------------------------------
    -- Link them up                                                           --
    ----------------------------------------------------------------------------
    
    
    Animation_Loop:init{
        states = gamestate:states()
    }
    
    gamestate:add_state_change_function(
        function(old,new)
            if new ~= "PAUSED" then
                Animation_Loop:clear_state(old)
            end
            Animation_Loop:switch_state_to(new)
        end
    )
    
    Transition_Menu:init{
        player = Max,
    }
    
    LVL_Object:init{
        layers        = layers,
        physics_world = physics_world,
    }
    Jazz:init{
        target = Max,
        parent = layers.enemy,
    }
    Max:init{
        parent = layers.player
    }
    
    ---------------------------------------------------------------------------- 
    -- Init                                                                   --
    ----------------------------------------------------------------------------
    
    launch_lvl = {
        function(loader)
            
            LVL_Object:prep_level{
                level = 1,
                scroll_speed = 100,
                set_progress = loader.set_progress,
                inc_progress = loader.inc_progress,
            }
            
            Jazz:load_assets(layers.srcs, layers.enemy)
            
            Jazz:launch_AI(LVL_Object.obstacles,LVL_Object.enemy_stop)
            
            Max:setup_for_level{--(LVL_Object,200,300)
                lvl = LVL_Object,
                start_x = 200,
                start_y = 300,
                scroll_speed = 100,
            }
            
            
            LVL_Object.animation = Animation_Loop:add_animation{
                on_step = LVL_Object.on_idle,
            }
            
            Max.animation = Animation_Loop:add_animation{
                on_step = Max.on_idle
            }
            
            check_collisions_animation = Animation_Loop:add_animation{on_step = check_collisions}
            
            Max:grab_key_focus()
        end
    }
    
    
    --Splash_Menu:load_assets(layers.menus)
    
    idle.on_idle = Animation_Loop.loop
    
    --dolater(100,Splash_Menu.grab_key_focus,Splash_Menu)
    
    gamestate:change_state_to("SPLASH")
    
end

dolater(main)


