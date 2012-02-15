
screen.perspective = {
    screen.perspective[1],
    screen.perspective[2],
    screen.perspective[3],
    300 -- need to set this so that objects in really far z show up
}

screen:show()

--upvals for the commonly used screen.w & h
screen_w = screen.w
screen_h = screen.h

--llets the splash screen get uncompressed and added to the screen so
--that the user sees that the app is doing something while waiting for the rest of
--it to load
local splash_screen = Image{src = "assets/splash.jpg"}
screen:add(splash_screen)


--this function is 'done later,' workaround for bugs like the one where you can't
--use UIElement:grab_key_focus() during the first pass through the app
--
--also this lets the splash screen load first
local main = function()
    
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
        splash       = "assets/bg/splash.png",
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
                "assets/ducks/float-6a.png",
                "assets/ducks/float-7.png",
                "assets/ducks/float-8.png",
                "assets/ducks/float-8-a.png",
                "assets/ducks/float-9.png",
            },
        },
        ripple = "assets/bg/ripple.png",
    }
    
    ----------------------------------------------------------------------------
    -- Layers                                                                 --
    ----------------------------------------------------------------------------
    
    -- traverse the 'imgs' table and add them as Images to the hidden clone
    -- source layer
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
    
    local bg_img = Image{src = "assets/bg.jpg",size = screen.size}
    bg_layer:add(bg_img)
    
    local duck_timer    = Timer{--needed as a dependency
        interval = 3000,
        on_timer = function(self)     duck_launcher:launch_duck()   end
    }
    
    duck_timer:stop() -- the ducks will have to wait
    
    ----------------------------------------------------------------------------
    -- link dependecies                                                       --
    ----------------------------------------------------------------------------
    duck_launcher:init{
        parent = duck_layer,
        imgs   = imgs,
        hud    = hud,
    }
    hud:init{
        parent = hud_layer,
        imgs   = imgs,
    }
    options:init{
        imgs         = imgs,
        parent       = menu_layer,
        duck_timer   = duck_timer,
        cursor_class = cursor,
        bg_img       = bg_img,
        bg           = bg,
    }
    cursor:init{
        hud          = hud,
        imgs         = imgs,
        duck_layer   = duck_layer,
        cursor_layer = cursor_layer,
    }
    ext_devices:init{
        cursor = cursor
    }
    bg:init{
        bg_layer = bg_layer,
        fg_layer = fg_layer,
        imgs     = imgs,
    }
    ----------------------------------------------------------------------------
    -- create everything                                                      --
    ----------------------------------------------------------------------------
    
    bg:create()
    hud:create()
    options:create()
    
    ----------------------------------------------------------------------------
    -- start everything                                                       --
    ----------------------------------------------------------------------------
    
    ext_devices:start()
    
    --animates out splash screen after 
    dolater(
        2000,
        function()
            
            splash_screen:animate{
                duration = 1000,
                opacity = 0,
                on_completed = function()
                    splash_screen:unparent()
                    splash_screen = nil
                    duck_timer:start()
                    
                end
            }
            
        end
    )
    
    ---[=[        Debugging code that lets you launch ducks manually
    
    local key_press = {
        [keys["1"]] = function() d = duck_launcher:launch_duck(1) end,
        [keys["2"]] = function() d = duck_launcher:launch_duck(2) end,
        [keys["3"]] = function() d = duck_launcher:launch_duck(3) end,
        [keys["4"]] = function() d = duck_launcher:launch_duck(4) end,
        [keys["s"]] = function() d:stop() end,
    }
    
    
    function screen:on_key_down(k,...)  return key_press[k] and key_press[k]()  end
    --]=]
    
    ----------------------------------------------------------------------------
    -- mouse events for screen                                                --
    ----------------------------------------------------------------------------
    
    screen.reactive = true
    
    function screen:on_button_down() last_cursor:fire(false) end
    function screen:on_motion(...)  return g_dragging and g_dragging(...) end
    function screen:on_button_up()         g_dragging = nil               end
    
    
    
    --raise the splash screen on top of everything 
    splash_screen:raise_to_top()
    
    --collect all of the tables, and locals inside do-ends, for loops, etc that
    --are no longer needed
    collectgarbage("collect")
    
    mediaplayer.volume = 0.5
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

--I need to comment out this line otherwise the screen gets blacked out on the
--hardware devices since the 'glee' video doesn't get packaged with the app

--mediaplayer:load("glee-1.mp4")

dolater(main)