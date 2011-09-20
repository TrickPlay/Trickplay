screen:show()


clone_counter = {}
setmetatable(clone_counter,{__mode = "k"})

local function main()
    screen_w = screen.w
    screen_h = screen.h
    
    
    
    assets_path_dir = "assets/"
    
    ----------------------------------------------------------------------------
    -- Utility Functions                                                      --
    ----------------------------------------------------------------------------
    
    --calculates a pararbola that the 2 points (x1,y1), (x2,y2), (x3,y3) lie on
    function calc_parabola(
            x1, y1,
            x2, y2,
            x3, y3
        )
        
        if type(x1) ~= "number" then error("arg 1 must be a number",2) end
        if type(y1) ~= "number" then error("arg 2 must be a number",2) end
        if type(x2) ~= "number" then error("arg 3 must be a number",2) end
        if type(y2) ~= "number" then error("arg 4 must be a number",2) end
        if type(x3) ~= "number" then error("arg 5 must be a number",2) end
        if type(y3) ~= "number" then error("arg 6 must be a number",2) end
        
        
        local denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
        
        local a = (      x3 * (y2 - y1)      +      x2 * (y1 - y3)      +      x1 * (y3 - y2)      ) / denom
        local b = ( x3 * x3 * (y1 - y2)      + x2 * x2 * (y3 - y1)      + x1 * x1 * (y2 - y3)      ) / denom
        local c = ( x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3 ) / denom
        
        local f = function(x) return a * x * x   +   b * x   +   c end
        
        print("\n",
            x1, y1, f(x1),"\n",
            x2, y2, f(x2),"\n",
            x3, y3, f(x3)
        )
        print("\n\n\nfunc is:",a,b,c)
        
        local v_x = -b/ (2*a)
        local v_y = c - b*b / (4*a)
        
        local dist = math.sqrt( (x1-v_x)*(x1-v_x) + (y1-v_y)*(y1-v_y))+
            math.sqrt( (x3-v_x)*(x3-v_x) + (y3-v_y)*(y3-v_y))
            
        local t = 1+(dist/650-1)/4
        
        print("dist",dist,"t",t)
        
        
        return f, t
        
    end

    
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
        backdrop     = Rectangle{name = "Backdrop", size = screen.size,color="000000" },
        
        distance     = Group{  name  =  "'In the Distance' layer"  },
        wall         = Group{  name  =  "'Tiled Wall' layer"       },
        wall_objs    = Group{  name  =  "Wall Objects layer"       },
        background   = Group{  name  =  "Background Objects layer" },
        items        = Group{  name  =  "Collidables layer"        },
        player       = Group{  name  =  "Player layer"             },
        enemy        = Group{  name  =  "Enemy layer"              },
        foreground   = Group{  name  =  "Foreground layer"         },
        
        hud          = Group{  name  =  "HUD layer"              },
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
    screen:add(layers.srcs,layers.backdrop,physics_world,layers.hud,layers.menus)
    
    layers.srcs:hide()
    
    -----------------------------------
    -- Collisions
    collides_with_max = {}
    collides_with_enemy = {}
    curr_enemies = {}
    collided = function(object_1,object_2)
    
        --do box collision detection
        
        return not (                     --returns false if
            
            object_1.x1 > object_2.x2 or -- object_1 is   to the right of    object_2
            object_1.x2 < object_2.x1 or -- object_1 is   to the left  of    object_2
            object_1.y1 > object_2.y2 or -- object_1 is   behind             object_2
            object_1.y2 < object_2.y1    -- object_1 is   ahead of           object_2
            
        )
        
    end
    
    check_collisions = {
        on_step = function()
            
            if Max and not Max.dead then
                
                Max:update_coll_box()
                
                for e,_ in pairs(curr_enemies) do
                    
                    e:update_coll_box()
                    
                    if not Max.hit and not e.harmless and collided(Max,e) then
                        
                        Max:recieve_impact(-1200,-1200)
                        
                    end
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
                    
                    for e,_ in pairs(curr_enemies) do
                        
                        item.x1 = item.x-item.anchor_point[1]
                        item.y1 = item.y-item.anchor_point[2]
                        item.x2 = item.x-item.anchor_point[1]+item.w
                        item.y2 = item.y-item.anchor_point[2]+item.h
                        
                        if collided(e,item) then
                            
                            item:collision(e)
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
    }
    
    
    
    
    ----------------------------------------------------------------------------
    -- Import all Components  (DOFILES)                                       --
    ----------------------------------------------------------------------------
    
    --generic utility files
    Animation_Loop = dofile("Utils/Animation_Loop.lua")
    StateMachine   = dofile("Utils/State_Machine.lua")
    
    gamestate = StateMachine{
        "OFFLINE",
        "SPLASH",
        "LVL_TRANSITION",
        "HS_MENU",
        "ACTIVE",
        "PAUSED"
    }
    
    --MadCapMax specific
    Max             = dofile("Max.lua")
    Make_Cat        = dofile("Jazz.lua")
    Frog            = dofile("Frog.lua")
    Crawfish        = dofile("Crawfish.lua")
    Tuffy           = dofile("Tuffy.lua")
    
    Item            = dofile("Items.lua")
    Hud             = dofile("Hud.lua")
    LVL_Object      = dofile("Level_Object.lua")
    ScoreKeeper     = dofile("Score_Keeper.lua")
    
    Splash_Menu     = dofile("Splash_Menu.lua")
    Transition_Menu = dofile("Transition_Menu.lua")
    HS_Menu         = dofile("High_Score_Menu.lua")
    
    ----------------------------------------------------------------------------
    -- Link them up - removes circular dependencies                           --
    ----------------------------------------------------------------------------
    
    
    Jazz  = Make_Cat("Jazz")
    Frank = Make_Cat("Frank")
    
    
    
    Animation_Loop:init{   states = gamestate:states()   }
    
    local in_game_animations = {}
    
    gamestate:add_state_change_function(
        function(old,new)
            
            if new ~= "PAUSED" then
                Animation_Loop:clear_state(old)
            end
            Animation_Loop:switch_state_to(new)
            
        end
    )
    
    Transition_Menu:init{
        player  = Max,
        sk      = ScoreKeeper,
        hs_menu = HS_Menu
    }
    
    LVL_Object:init{
        layers        = layers,
        physics_world = physics_world,
    }
    Jazz:init{
        target = Max,
        lvl    = LVL_Object,
    }
    Frank:init{
        target = Max,
        lvl    = LVL_Object,
    }
    Tuffy:init{
        target = Max,
        lvl    = LVL_Object,
    }
    Max:init{
        lvl    = LVL_Object,
        sk     = ScoreKeeper,
        hud    = Hud,
    }
    
    ---------------------------------------------------------------------------- 
    -- Init                                                                   --
    ----------------------------------------------------------------------------
    
    lvl_params = {
        {
            [Max] = {
                launch  = false,
                start_x = 400-30,
                start_y = 380,
                start_wing_src = 5,
                start_z_rot    = -20,
                start_wing_rot = 60,
            },
            [LVL_Object] = {
                intro_actors = {
                    [2] = { --in stage 2
                        2--the first actor is item 2
                    }
                },
                --call_before_intro = {Jazz.attack}
                call_after_intro = {Max.launch}--,Jazz.launch}
            },
            enemies = {
                [Jazz] = { launch = true}
            },
        },
        {
            [Max] = {
                launch  = true,
            },
            [LVL_Object] = {
                outro_actors = {
                    [2] = { --in stage 2
                        "maxina-eyelids"
                    },
                    
                    [4] = { --in stage 4
                        "heart"
                    },
                    
                    [6] = { --in stage 6
                        "heart1"
                    }
                },
                call_before_outro = {
                    
                    [Max.fly_to] = {d = 1,x = 13060-100, y=800}
                    
                }
            },
            enemies = {
                [Frank] = {start_x = 2500, launch = true },
                [Tuffy] = {call_on_start = Frank.exit },
            }
        }
    }
    
    function launch_lvl(lvl_i,loader)
        
        
        --in_game_animations = {}
        
        print("LNCH_LVL")
        
        --setup level
        LVL_Object:setup_for_level{
            
            level        = lvl_i,
            
            set_progress = loader.set_progress,
            
            inc_progress = loader.inc_progress,
            
            intro_actors =  lvl_params[lvl_i][LVL_Object] and
                            lvl_params[lvl_i][LVL_Object].intro_actors or nil,
            
            call_after_intro =  lvl_params[lvl_i][LVL_Object] and
                                lvl_params[lvl_i][LVL_Object].call_after_intro or nil,
            
            outro_actors =  lvl_params[lvl_i][LVL_Object] and
                            lvl_params[lvl_i][LVL_Object].outro_actors or nil,
            
            call_before_outro = lvl_params[lvl_i][LVL_Object] and
                                lvl_params[lvl_i][LVL_Object].call_before_outro or nil,
        }
        
        Hud:setup_lvl()
        
        Animation_Loop:add_animation(check_collisions,"ACTIVE")
        
        --setup enemies
        curr_enemies = lvl_params[lvl_i].enemies
        
        for e,p in pairs(curr_enemies) do
            
            e:setup_for_level(p)
            
        end
        
        --setup Max
        Max:setup_for_level(lvl_params[lvl_i][Max])
        
        Max:grab_key_focus()
        
        --gamestate:change_state_to("ACTIVE")
        
    end
    
    idle.on_idle = Animation_Loop.loop
    
    gamestate:change_state_to("SPLASH")
    
end

dolater( main )


