
screen.perspective = {screen.perspective[1],screen.perspective[2],screen.perspective[3],300}
screen:show()

screen_w = screen.w
screen_h = screen.h

local splash = Image{src = "assets/splash.jpg"} -- loads first
--screen:add(splash)

local main = function()
    
	
    
    ----------------------------------------------------------------------------
    -- Images                                                                 --
    ----------------------------------------------------------------------------
    local imgs = {
        crosshair = {
            normal = "assets/crosshair/crosshair-normal.png",
            target = "assets/crosshair/crosshair-target.png",
            burst = {
                "assets/crosshair/burst-1.png",
                "assets/crosshair/burst-2.png",
            },
        },
        duck = {
            angle = {
                "assets/ducks/duck-angle-1.png",
                "assets/ducks/duck-angle-2.png",
                "assets/ducks/duck-angle-3.png",
                "assets/ducks/duck-angle-4.png",
            },
            front = {
                "assets/ducks/duck-front-1.png",
                "assets/ducks/duck-front-2.png",
                "assets/ducks/duck-front-3.png",
                "assets/ducks/duck-front-4.png",
                "assets/ducks/duck-front-5.png",
            },
            side = {
                "assets/ducks/duck-side-1.png",
                "assets/ducks/duck-side-2.png",
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
    local cursor_layer = Group{name =  "cursor layer"}
    
    screen:add( duck_layer, bg_layer, cursor_layer )
    
    ----------------------------------------------------------------------------
    -- dofiles                                                                --
    ----------------------------------------------------------------------------
    
    local bg            = dofile("GameBG.lua")
    local duck_launcher = dofile("Duck.lua")
    local cursor        = dofile("Cursor.lua")
    local ext_devices   = dofile("Controllers.lua")
    
    ----------------------------------------------------------------------------
    -- link dependecies                                                       --
    ----------------------------------------------------------------------------
    duck_launcher:init{
        parent = duck_layer,
        imgs = imgs,
    }
    
    cursor:init{
        imgs = imgs,
        duck_layer = duck_layer,
        cursor_layer = cursor_layer,
    }
    ext_devices:init{
        cursor = cursor
    }
    bg:init{
        bg_layer = bg_layer,
        imgs = imgs,
    }
    ----------------------------------------------------------------------------
    -- start everything                                                       --
    ----------------------------------------------------------------------------
    
    bg:start()
    ext_devices:start()
    
    --[[Timer{
        interval = 3000,
        on_timer = function(self)
            duck_launcher:launch_duck()
        end
    }
    --]]
    local key_press = {
        [keys["1"]] = function() d = duck_launcher:launch_duck(1) end,
        [keys["2"]] = function() d = duck_launcher:launch_duck(2) end,
        [keys["3"]] = function() d = duck_launcher:launch_duck(3) end,
        [keys["s"]] = function() d:stop() end,
    }
    
    
    function screen:on_key_down(k)
        
        return key_press[k] and key_press[k]()
        
    end
    
    screen.reactive = true
    function screen:on_button_down()
        last_cursor:fire()
    end
end



dolater(main)