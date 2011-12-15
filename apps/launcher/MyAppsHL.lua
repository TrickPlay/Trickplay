
local myAppsHL = {}

local has_been_initialized = false

--init()'s params
local img_srcs,font, icon_size,canvas_srcs

--vis sources
local left_triangle,right_triangle, main_bg,sub_menu_bg

function myAppsHL:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    canvas_srcs = p.canvas_srcs or error("must pass 'canvas_srcs'", 2)
    img_srcs    = p.img_srcs    or error("must pass 'img_srcs'",    2)
    main_font   = p.main_font   or error("must pass 'main_font'",   2) -- "FreeSans Medium 24px"
    sub_font    = p.sub_font    or error("must pass 'sub_font'",    2) -- "FreeSans Medium 24px"
    icon_size   = p.icon_size   or error("must pass 'icon_size'",   2) --{116/270*480,116}
    
    left_triangle  = Image{ name = "myAppsHL left",        src = "assets/my_apps_slider/focus-left-corner.png",   }
    right_triangle = Image{ name = "myAppsHL right",       src = "assets/my_apps_slider/focus-right-corner.png",  }
    main_bg        = Image{ name = "myAppsHL main_bg",     src = "assets/my_apps_slider/focus-banner-1.png",      }
    sub_menu_bg    = Image{ name = "myAppsHL sub_menu_bg", src = "assets/my_apps_slider/focus-banner-2flaps.png", }
    
    
    img_srcs:add( left_triangle, right_triangle, main_bg, sub_menu_bg )
    
    has_been_initialized = true
    
end
local y_off = 10
function myAppsHL:create(p)
    
    local instance = Group{name = "Highlight"}
    
    
    ----------------------------------------------------------------------------
    -- Highlight Visual Pieces
    ----------------------------------------------------------------------------
    
    local left_triangle  = Clone{ name = "left",    source = left_triangle,  x = - left_triangle.w,             y = main_bg.h-y_off}
    local right_triangle = Clone{ name = "right",   source = right_triangle, x = main_bg.w - left_triangle.w*2, y = main_bg.h-y_off, }
    local main_bg        = Clone{ name = "main_bg", source = main_bg,        x = - left_triangle.w,             y = -y_off }
    
    local sub_menu    = Group{ name = "sub_menu",   x = main_bg.w - left_triangle.w, y = -30 - y_off, opacity = 0, y_rotation = {120,0,0} }
    
    local prev  = Clone{ y=-y_off, size = icon_size}
    local next  = Clone{ size = icon_size,position = {icon_size[1]/2,icon_size[2]/2-y_off},anchor_point = {icon_size[1]/2,icon_size[2]/2} }
    local frame = Clone{source=canvas_srcs.launcher_icon_frame,y=-y_off,size = icon_size}
    
    local caption = Text{  name = "caption", font = main_font,x = 240,y=35-y_off}
    
    instance:add(
        
        left_triangle,
        right_triangle,
        main_bg,
        
        sub_menu,
        
        prev,
        next,
        
        Clone{
            source = canvas_srcs.launcher_icon_frame,
            y      = -y_off,
            size   = icon_size,
        },
        caption
    )
    
    ----------------------------------------------------------------------------
    -- Sub Menu Visual Pieces
    ----------------------------------------------------------------------------
    
    local arrow = Clone{
        source = canvas_srcs.arrow,
        x=50,
        y =canvas_srcs.arrow.h/2 + 5,
        anchor_point = {0,canvas_srcs.arrow.h/2}
    }
    
    local sub_menu_items = {
        Text{ text = "Play",  font = main_font, x = 100, y = 20 },
        Text{ text = "Share", font = main_font, x = 100, y = 60 },
    }
    
    sub_menu:add( Clone{ name = "sub_menu_bg", source = sub_menu_bg}, arrow )
    sub_menu:add( unpack( sub_menu_items ) )
    
    ----------------------------------------------------------------------------
    -- Sub Menu Animation
    ----------------------------------------------------------------------------
    
    local sub_menu_state = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*", target = "SHOW", duration = 300,
                animator = Animator{
                    duration   = 1000,
                    properties = {
                        {
                            source = right_triangle,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.5, "LINEAR",   0},
                                {1.0, "LINEAR",   0},
                            }
                        },
                        {
                            source = sub_menu,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.5, "LINEAR", 255},
                                {1.0, "LINEAR", 255},
                            }
                        },
                        {
                            source = sub_menu,
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
                            source = right_triangle,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.7, "LINEAR",   0},
                                {1.0, "LINEAR", 255},
                            }
                        },
                        {
                            source = sub_menu,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.7, "LINEAR", 255},
                                {1.0, "LINEAR",   0},
                            }
                        },
                        {
                            source = sub_menu,
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
    
    sub_menu_state.state = "HIDE"
    
    ----------------------------------------------------------------------------
    -- Events
    ----------------------------------------------------------------------------
    
    function instance:show_sub_menu()
        
        self.parent:raise_to_top()
        
        sub_menu_state.state = "SHOW"
        
    end
    function instance:hide_sub_menu()
        
        self.parent:raise_to_top()
        
        sub_menu_state.state = "HIDE"
        
    end
    function instance:focus(text,icon,id)
        print(id)
        self.app_id = id
        
        caption.text = text
        prev.source = next.source
        next.source = icon
        next.scale = {0,0}
        
        next:animate{
            duration = 100,
            scale    = {1,1},
        }
        
    end
    
    
    
    
    ----------------------------------------------------------------------------
    -- Key Events
    ----------------------------------------------------------------------------
    
    local sub_menu_i = 1
    
    local sub_menu_functions = {
        function(self)
            arrow:hide()
            apps:launch(self.app_id) -- set in instance:focus()
        end,
        function(self)
            print("Share")
        end,
    }
    
    local key_events = {
        [keys.Up] = function(self)
            
            if sub_menu_i == 1 then
                
                self:hide_sub_menu()
                
                self.logical_parent:grab_key_focus()
                
                self.logical_parent:on_key_down(keys.Up)
                
            else
                
                sub_menu_i = sub_menu_i - 1
                
                arrow.y = sub_menu_items[sub_menu_i].y+17--5+arrow.h/2+40*(sub_menu_i-1)
                
                return true
                
            end
            
        end,
        [keys.Down] = function(self)
            
            if sub_menu_i == #sub_menu_items then
                
                self:hide_sub_menu()
                
                self.logical_parent:grab_key_focus()
                
                self.logical_parent:on_key_down(keys.Down)
                
            else
                
                sub_menu_i = sub_menu_i + 1
                
                arrow.y = sub_menu_items[sub_menu_i].y+17--5+arrow.h/2+40*(sub_menu_i-1)
                
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
            
            return sub_menu_functions[ sub_menu_i ] and sub_menu_functions[ sub_menu_i ](self)
            
        end,
        
    }
    
    arrow.y = sub_menu_items[sub_menu_i].y+17
    
    function instance:on_key_down(k)
        
        return key_events[k] and key_events[k](self)
        
    end
    
    return instance
    
end

return myAppsHL



