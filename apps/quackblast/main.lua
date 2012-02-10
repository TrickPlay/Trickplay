
screen.perspective = {screen.perspective[1],screen.perspective[2],screen.perspective[3],300}
screen:show()

screen_w = screen.w
screen_h = screen.h

local splash = Image{src = "assets/splash.jpg"} -- loads first
--screen:add(splash)

local main = function()
    in_game = true
    ----------------------------------------------------------------------------
    -- Images                                                                 --
    ----------------------------------------------------------------------------
    local imgs = {
        options = {
            corner = "assets/options/menu-bg-corner.png",
            edge   = "assets/options/menu-bg-edge-slice.png",
            arrow  = "assets/options/menu-arrows-up.png",
            track  = "assets/options/slider-bar.png",
            grip   = "assets/options/slider-dot.png",
            logo   = "assets/options/menu-logo.png",
            exit   = "assets/options/exit-btn.png",
            slider_duck  = "assets/options/slider-duck.png",
            crosshair    = "assets/options/slider-crosshair.png",
            full_ducks   = "assets/options/slider-ducks-opaque.png",
            hollow_ducks = "assets/options/slider-dim-ducks.png",
            blur_line    = "assets/options/slider-blur-edge.png",
        },
        crosshair = {
            normal = "assets/crosshair/crosshair-normal.png",
            target = "assets/crosshair/crosshair-target.png",
            burst = {
                "assets/crosshair/burst-1.png",
                "assets/crosshair/burst-2.png",
            },
        },
        feathers = {
            "assets/feathers/feather-1.png",
            "assets/feathers/feather-2.png",
            "assets/feathers/feather-3.png",
            "assets/feathers/feather-4.png",
        },
        duck = {
            angle = {
                "assets/ducks/duck-angle-1.png",
                "assets/ducks/duck-angle-1-a.png",
                "assets/ducks/duck-angle-2.png",
                "assets/ducks/duck-angle-3.png",
                "assets/ducks/duck-angle-4.png",
                "assets/ducks/duck-angle-5.png",
            },
            front = {
                "assets/ducks/duck-front-1.png",
                "assets/ducks/duck-front-2.png",
                "assets/ducks/duck-front-3.png",
                "assets/ducks/duck-front-4.png",
                "assets/ducks/duck-front-5.png",
                "assets/ducks/duck-front-6.png",
            },
            side = {
                "assets/ducks/duck-side-1.png",
                "assets/ducks/duck-side-1a.png",
                "assets/ducks/duck-side-1b.png",
                "assets/ducks/duck-side-2.png",
            },
            float = {
                "assets/ducks/float-1.png",
                "assets/ducks/float-2.png",
                "assets/ducks/float-3.png",
                "assets/ducks/float-4.png",
                "assets/ducks/float-5.png",
                "assets/ducks/float-6.png",
                "assets/ducks/float-7.png",
            },
        },
        ripple = "assets/bg/ripple.png",
        --[[   These one Images would have only been Cloned once
        bg = {
            btm_r   = "assets/bg/cattails.png",
            btm_l   = "assets/bg/reeds-left.png",
            btm_mid = "assets/bg/reeds-middle.png",
            top_l   = "assets/bg/tree-left.png",
            top_r   = "assets/bg/tree-right.png",
        },
        --]]
    }
    
    ----------------------------------------------------------------------------
    -- Layers                                                                 --
    ----------------------------------------------------------------------------
    
    do
        
        local clone_srcs = Group{name = "Clone Sources"}
        
        local add_table_to_clone_srcs
        add_table_to_clone_srcs= function(t)
            
            if type(t) ~= "table" then error("not table",2) end
            
            for k,v in pairs(t) do
                
                if type(v) == "table" then
                    
                    add_table_to_clone_srcs(v)
                    
                else
                    
                    t[k] = Image{name = v,src = v}
                    
                    clone_srcs:add(t[k])
                    
                end
                
            end
        end
        
        add_table_to_clone_srcs(imgs)
        
        screen:add(clone_srcs)
        
        clone_srcs:hide()
        
    end
    
    local   duck_layer = Group{name =    "duck layer"}
    local     bg_layer = Group{name =      "bg layer"}
    local     fg_layer = Group{name =      "fg layer"}
    local cursor_layer = Group{name =  "cursor layer"}
    local    hud_layer = Group{name =     "hud_layer"}
    local   menu_layer = Group{name =    "menu_layer"}
    
    screen:add(
        bg_layer,
        duck_layer,
        fg_layer,
        hud_layer,
        menu_layer,
        cursor_layer
    )
    
    ----------------------------------------------------------------------------
    -- dofiles                                                                --
    ----------------------------------------------------------------------------
    
    local bg            = dofile("GameBG.lua")
    local hud           = dofile("HUD.lua")
    local duck_launcher = dofile("Duck.lua")
    local cursor        = dofile("Cursor.lua")
    local ext_devices   = dofile("Controllers.lua")
    local options       = dofile("OptionsMenu.lua")
    local duck_timer    = Timer{}
    
    ----------------------------------------------------------------------------
    -- link dependecies                                                       --
    ----------------------------------------------------------------------------
    duck_launcher:init{
        parent = duck_layer,
        imgs = imgs,
        hud  = hud,
    }
    hud:init{
        parent = hud_layer,
        imgs = imgs,
    }
    options:init{
        imgs = imgs,
        parent = menu_layer,
        duck_timer = duck_timer,
    }
    cursor:init{
        hud  = hud,
        imgs = imgs,
        duck_layer = duck_layer,
        cursor_layer = cursor_layer,
    }
    ext_devices:init{
        cursor = cursor
    }
    bg:init{
        bg_layer = bg_layer,
        fg_layer = fg_layer,
        imgs = imgs,
    }
    ----------------------------------------------------------------------------
    -- start everything                                                       --
    ----------------------------------------------------------------------------
    
    bg:start()
    hud:start()
    options:start()
    duck_timer.interval = 3000
    duck_timer.on_timer = function(self)
        duck_launcher:launch_duck()
        print("launch",duck_timer.interval)
    end
    dolater(
        2000,
        function()
            
            splash:animate{
                duration = 1000,
                opacity = 0,
                on_completed = function()
                    splash:unparent()
                    splash = nil
                    duck_timer:start()
                    
                end
            }
            
        end
    )
    ext_devices:start()
    
    --]]
    local key_press = {
        [keys["1"]] = function() d = duck_launcher:launch_duck(1) end,
        [keys["2"]] = function() d = duck_launcher:launch_duck(2) end,
        [keys["3"]] = function() d = duck_launcher:launch_duck(3) end,
        [keys["4"]] = function() d = duck_launcher:launch_duck(4) end,
        [keys["s"]] = function() d:stop() end,
    }
    
    
    function screen:on_key_down(k,...)  return key_press[k] and key_press[k]()  end
    
    screen.reactive = true
    
    function screen:on_key_down(...)
        print("screen:on_key_down",...)
    end
    function screen:on_button_down()
        print("screen:on_button_down")
        last_cursor:fire(false)
        
    end
    function screen:on_motion(...)  return g_dragging and g_dragging(...) end
    function screen:on_button_up()         g_dragging = nil               end
    
    screen:add(splash)
    
end

    
--------------------------------------------------------------------------------
-- pretend background TV
--------------------------------------------------------------------------------

function mediaplayer:on_loaded()
    mediaplayer.volume = 0
    mediaplayer:play()
    
end

function mediaplayer:on_end_of_stream()
    
    mediaplayer:seek(0)
    
    mediaplayer:play()
    
end

--mediaplayer:load("glee-1.mp4")

dolater(main)