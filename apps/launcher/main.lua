
arrow = Canvas(20,20)
arrow:move_to(0,0)
arrow:line_to(arrow.w,arrow.h/2)
arrow:line_to(0,arrow.h)
arrow:line_to(0,0)

arrow:set_source_color("#000000")
arrow:fill()
arrow = arrow:Image{x=50, y =arrow.h/2 + 5, anchor_point = {0,arrow.h/2}}


function mediaplayer:on_loaded()
    mediaplayer.volume = 0
    mediaplayer:play()
    
end

function mediaplayer:on_end_of_stream()
    
    mediaplayer:seek(0)
    
    mediaplayer:play()
    
end

mediaplayer:load("glee-1.mp4")

--]]

local showcase_imgs = {
    Image{src ="assets/showcase/beauty-product-all-content.jpg" },
    Image{src ="assets/showcase/main-1.jpg" },
    Image{src ="assets/showcase/main screen.png" },
    Image{src ="assets/showcase/mockup.png" },
}
local apps_imgs = {
    Image{src ="assets/apps/start-background-1E.jpg" },
    Image{src ="assets/apps/mockup.png" },
    Image{src ="assets/apps/_reference_main_screen.png" },
}
local src = Group{}
src:add(unpack(apps_imgs))
src:add(unpack(showcase_imgs))
src:hide()
screen:add(src)


screen:show()

do
    
    local l = dofile("localized:strings.lua")
    
    function _L(s) return l[s] or s end
    
end

local launcher_icon_resized_w = 4*48
local launcher_icon_resized_h = 4*27
local video_tile_inner_width  = 547


local canvas_srcs = dofile("CanvasCloneSources")
local vt = dofile("VideoTile.lua")

canvas_srcs:init{
    
    launcher_frame_w               = launcher_icon_resized_w,
    launcher_frame_h               = launcher_icon_resized_h,
    launcher_frame_border          = 2,
    launcher_frame_border_gradient = 7,
    
    video_tile_inner_width   = video_tile_inner_width,
    video_tile_border_width  = 3,
    video_tile_corner_radius = 20,
    video_tile_font          = "FreeSans Medium 32px",
    
    my_apps_hl_w        = 300,
    my_apps_hl_h        = 150,
    my_apps_hl_shadow_h = 20,
    
}

vt:init{
    shrunken_h  = 100,
    expanded_h  = 900,
    inner_w     = video_tile_inner_width,
    canvas_srcs = canvas_srcs,
    max_vis_len = 12,
    font        = "FreeSans Medium 32px",
}
tiles = {}


local vtb = dofile("VideoTileBar.lua")

screen:add(vtb)

kb =  dofile("KenBurns.lua")

kb:init{}

apps_kb = kb:create{
    visible_w = 600,
    visible_h = 950,
    q = apps_imgs,
}
apps_kb:play()

showcase_kb = kb:create{
    visible_w = 600,
    visible_h = 950,
    q = showcase_imgs,
}
showcase_kb:play()


myAppsHlFont = "FreeSans Medium 24px"
myAppsHL = Group{
    children = {
        Image{ name = "left", src = "assets/my_apps_slider/focus-left-corner.png", x = - 22, y = 116},
        Image{ name = "right", src = "assets/my_apps_slider/focus-right-corner.png",x = 597 - 22*2, y = 116, },
        Image{ src = "assets/my_apps_slider/focus-banner-1.png",    x = - 22 },
        
        Group{name = "sub_menu", x = 597-22,opacity = 0,y_rotation = {120,0,0},y=-30,
            children = {
                Image{ name = "sub_menu_bg",src = "assets/my_apps_slider/focus-banner-2flaps.png",},
                arrow,
                Text{text = "Play", font = myAppsHlFont, x = 100, y =  0},
                Text{text = "Info", font = myAppsHlFont, x = 100, y = 40},
                Text{text = "More", font = myAppsHlFont, x = 100, y = 80},
            }
        },
        Clone{ name = "prev", w = 116/270*480,h = 116},
        Clone{ name = "next", w = 116/270*480,h = 116},
        Text{  name = "text", font = "FreeSans Medium 28px",x = 240,y=35}
    },
    on_key_down = function(self,k)
        
        return self.key_events[k] and self.key_events[k](self)
        
    end,
    extra = {
        sub_menu_functions = {
            function(self)
                arrow:hide()
                apps:launch(self.app_id)
            end,
            function(self)
                print("INFO")
            end,
            function(self)
                print("MORE")
            end,
        },
        sub_menu_i = 1,
        key_events = {
            [keys.Up] = function(self)
                
                if self.sub_menu_i == 1 then
                    
                    self:hide_sub_menu()
                    
                    self.logical_parent:grab_key_focus()
                    
                    self.logical_parent:on_key_down(keys.Up)
                    
                else
                    
                    self.sub_menu_i = self.sub_menu_i - 1
                    
                    arrow.y = 5+arrow.h/2+40*(self.sub_menu_i-1)
                    
                    return true
                    
                end
                
            end,
            [keys.Down] = function(self)
                
                if self.sub_menu_i == #self.sub_menu_functions then
                    
                    self:hide_sub_menu()
                    
                    self.logical_parent:grab_key_focus()
                    
                    self.logical_parent:on_key_down(keys.Down)
                    
                else
                    
                    self.sub_menu_i = self.sub_menu_i + 1
                    
                    arrow.y = 5+arrow.h/2+40*(self.sub_menu_i-1)
                    
                    return true
                    
                end
                
            end,
            [keys.Left] = function(self)
                
                self:hide_sub_menu()
                
                self.logical_parent:grab_key_focus()
                
                return true
                
            end,
            [keys.Right] = function(self)
                
                self:hide_sub_menu()
                
            end,
            [keys.OK] = function(self)
                
                self.sub_menu_functions[
                        self.sub_menu_i
                    ](self)
                
                return true
            end,
            
        },
        focus = function(self,text,icon,id)
            print(id)
            self.app_id = id
            
            myAppsHL:find_child("text").text = text
            myAppsHL:find_child("prev").source = myAppsHL:find_child("next").source
            myAppsHL:find_child("next").source = icon
            myAppsHL:find_child("next").opacity = 0
            
            myAppsHL:find_child("next"):animate{
                duration = 100,
                opacity  = 255,
            }
            
        end,
        make_sub_menu_animation = function(self)
            self.sub_menu = AnimationState{
                duration = 300,
                transitions = {
                    {
                        source = "*", target = "SHOW", duration = 300,
                        animator = Animator{
                            duration   = 1000,
                            properties = {
                                {
                                    source = self:find_child("right"),
                                    name = "opacity",
                                    
                                    keys = {
                                        {0.0, "LINEAR", 255},
                                        {0.5, "LINEAR",   0},
                                        {1.0, "LINEAR",   0},
                                    }
                                },
                                {
                                    source = self:find_child("sub_menu"),
                                    name = "opacity",
                                    
                                    keys = {
                                        {0.0, "LINEAR",   0},
                                        {0.5, "LINEAR", 255},
                                        {1.0, "LINEAR", 255},
                                    }
                                },
                                {
                                    source = self:find_child("sub_menu"),
                                    name = "y_rotation",
                                    
                                    keys = {
                                        {0.0, "LINEAR", 120},
                                        {1.0, "LINEAR",   0},
                                    }
                                },
                            }
                        },
                    },
                    {
                        source = "*", target = "HIDE", duration = 300,
                        animator = Animator{
                            duration   = 1000,
                            properties = {
                                {
                                    source = self:find_child("right"),
                                    name = "opacity",
                                    
                                    keys = {
                                        {0.0, "LINEAR",   0},
                                        {0.7, "LINEAR",   0},
                                        {1.0, "LINEAR", 255},
                                    }
                                },
                                {
                                    source = self:find_child("sub_menu"),
                                    name = "opacity",
                                    
                                    keys = {
                                        {0.0, "LINEAR", 255},
                                        {0.7, "LINEAR", 255},
                                        {1.0, "LINEAR",   0},
                                    }
                                },
                                {
                                    source = self:find_child("sub_menu"),
                                    name = "y_rotation",
                                    
                                    keys = {
                                        {0.0, "LINEAR",   0},
                                        {1.0, "LINEAR", 120},
                                    }
                                },
                            }
                        },
                    },
                },
            }
        end,
        show_sub_menu = function(self)
            
            if self.sub_menu == nil then
                
                self:make_sub_menu_animation()
                
            end
            
            self.parent:raise_to_top()
            
            self.sub_menu.state = "SHOW"
            
        end,
        hide_sub_menu = function(self)
            
            if self.sub_menu == nil then
                
                self:make_sub_menu_animation()
                
            end
            
            self.parent:raise_to_top()
            
            self.sub_menu.state = "HIDE"
            
        end,
    }
}

l = dofile("MyAppsList.lua")

l:init{max_vis_len = 10, slider = myAppsHL}

clouds =  dofile("MyAppsBg.lua")

clouds:init{
    visible_w = 600,
    visible_h = 1000,
}


vtb:init{
    video_tile = vt,
    tiles = {
        {text = "My Apps",contents = Group{y=-48,children={clouds,l}, on_key_down = l.on_key_down}, slider = myAppsHL, expanded_h =l.list_h-20 },
        {text = "Showcase",contents = showcase_kb},
        {text = "App Store",contents = apps_kb},
    },
}


screen.z = 100

local screen_keys = {
    [keys["1"]] = function()
        vtb:move_anchor_point(0,0)
        vtb.position = {0,0}
        vtb:animate{
            --mode = "EASE_IN_BACK",
            duration = 400,
            x_rotation = -180,
        }
    end,
    [keys["2"]] = function()
        vtb:move_anchor_point(0,0)
        vtb.position = {0,0}
        vtb:animate{
            --mode = "EASE_OUT_BACK",
            duration = 400,
            x_rotation = 0,
        }
    end,
    [keys["3"]] = function()
        vtb:move_anchor_point(screen.w/2,screen.h/2)
        vtb.position = {screen.w/2,screen.h/2}
        vtb:animate{
            --mode = "EASE_OUT_BACK",
            duration = 400,
            scale = {1.5,1.5},
            opacity = 0,
        }
    end,
    [keys["4"]] = function()
        vtb:move_anchor_point(screen.w/2,screen.h/2)
        vtb.position = {screen.w/2,screen.h/2}
        vtb:animate{
            --mode = "EASE_IN_BACK",
            duration = 400,
            scale = {1,1},
            opacity = 255,
        }
    end,
    [keys["5"]] = function()
        vtb:move_anchor_point(screen.w/2,screen.h/2)
        vtb.position = {screen.w/2,screen.h/2}
        vtb:animate{
            mode = "EASE_OUT_BACK",
            duration = 400,
            z=0,
            --z_rotation = 0,
        }
    end,
    [keys["6"]] = function()
        vtb:move_anchor_point(screen.w/2,screen.h/2)
        vtb.position = {screen.w/2,screen.h/2}
        vtb:animate{
            mode = "EASE_IN_BACK",
            duration = 400,
            z=600,
            --z_rotation = 180,
        }
    end,
}
function screen:on_key_down(k)
    print("yea",k,keys.BACK,screen_keys[k])
    return screen_keys[k] and screen_keys[k]()
end







