
local myAppsHL = {}

local has_been_initialized = false

--init()'s params
local img_srcs,font, icon_size,canvas_srcs, imgs

--vis sources
local shadow, left_triangle,right_triangle, main_bg, sub_menu_edge, sub_menu_bg, sub_sub_menu_edge, sub_sub_menu_bg

function myAppsHL:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    canvas_srcs = p.canvas_srcs or error("must pass 'canvas_srcs'", 2)
    img_srcs    = p.img_srcs    or error("must pass 'img_srcs'",    2)
    imgs        = p.imgs        or error("must pass 'imgs'",        2)
    main_font   = p.main_font   or error("must pass 'main_font'",   2) -- "FreeSans Medium 24px"
    sub_font    = p.sub_font    or error("must pass 'sub_font'",    2) -- "FreeSans Medium 24px"
    icon_size   = p.icon_size   or error("must pass 'icon_size'",   2) --{116/270*480,116}
    
    menu_shadow      = Image{ name = "myAppsHL shadow",  src = "assets/my_apps_slider/focus-shadow-closed.png",  }
    sub_shadow      = Image{ name = "myAppsHL shadow",  src = "assets/my_apps_slider/focus-shadow-open-1.png",  }
    sub_sub_shadow      = Image{ name = "myAppsHL shadow",  src = "assets/my_apps_slider/focus-shadow-open-2.png",  }
    left_triangle      = Image{ name = "myAppsHL left triangle",  src = "assets/my_apps_slider/focus-tab-left.png",  }
    right_triangle     = Image{ name = "myAppsHL right triangle", src = "assets/my_apps_slider/focus-tab-right.png", }
    main_bg            = Image{ name = "myAppsHL main_bg",        src = "assets/my_apps_slider/focus-1.png",         }
    sub_menu_edge      = Image{ name = "myAppsHL sub_menu_edge",  src = "assets/my_apps_slider/focus-flap-1.png",    }
    sub_menu_bg        = Image{ name = "myAppsHL sub_menu_bg",    src = "assets/my_apps_slider/focus-flap-2.png",    }
    sub_sub_menu_edge  = Image{ name = "myAppsHL sub_menu_edge",  src = "assets/my_apps_slider/focus-flap-3.png",    }
    sub_sub_menu_bg    = Image{ name = "myAppsHL sub_menu_bg",    src = "assets/my_apps_slider/focus-flap-4.png",    }
    
    img_srcs:add( menu_shadow, sub_shadow, sub_sub_shadow, left_triangle, right_triangle, main_bg,sub_menu_edge, sub_menu_bg, sub_sub_menu_edge, sub_sub_menu_bg )
    
    has_been_initialized = true
    
end

local y_off = 10


local function make_sub_menu(p)
    
    local sub_menu = p.group or Group{}
    
    local sub_menu_edge  = Clone{ name = "sub_menu_edge", source = p.edge_src }
    local sub_menu_bg    = Clone{ name = "sub_menu_bg",   source = p.bg_src   }
    local sub_menu_items = p.sub_menu_items
    local logical_parent = p.logical_parent
    local parent_ref     = p.parent_ref
    
    local contents = Group{
        name       = "contents",
        x          = p.edge_src.w,
        children   = { sub_menu_bg },
    }
    contents:add( unpack( sub_menu_items ) )
    
    sub_menu:add( sub_menu_edge, contents )
    
    
    local dur = 200
    --[[
    local sub_menu_state = AnimationState{
        transitions = {
            {
                source = "*", target = "SHOW", duration = dur,
                animator = Animator{
                    duration   = dur,
                    properties = {
                        p.old_shadow and {
                            source = p.old_shadow,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.8, "LINEAR", 255},
                                {1.0, "LINEAR",   0},
                            }
                        } or nil,
                        p.new_shadow and {
                            source = p.new_shadow,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.8, "LINEAR",   0},
                                {1.0, "LINEAR", 255},
                            }
                        } or nil,
                        p.right_triangle and {
                            source = p.right_triangle,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.5, "LINEAR",   0},
                                {1.0, "LINEAR",   0},
                            }
                        } or nil,
                        {
                            source = sub_menu_edge,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.1, "LINEAR", 255},
                                {1.0, "LINEAR", 255},
                            }
                        },
                        {
                            source = sub_menu_edge,
                            name = "y_rotation",
                            
                            keys = {
                                {0.0, "LINEAR", 120},
                                {0.3, "LINEAR",   0},
                                {1.0, "LINEAR",   0},
                            }
                        },
                        {
                            source = contents,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.7, "LINEAR",   0},
                                {0.8, "LINEAR", 255},
                                {1.0, "LINEAR", 255},
                            }
                        },
                        {
                            source = contents,
                            name = "y_rotation",
                            
                            keys = {
                                {0.0, "LINEAR", 120},
                                {0.7, "LINEAR", 120},
                                {1.0, "LINEAR",   0},
                            }
                        },
                    }
                },
            },
            {
                source = "*", target = "HIDE", duration = dur,
                animator = Animator{
                    duration   = dur,
                    properties = {
                        p.old_shadow and {
                            source = p.old_shadow,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.2, "LINEAR", 255},
                                {1.0, "LINEAR", 255},
                            }
                        } or nil,
                        p.new_shadow and {
                            source = p.new_shadow,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.2, "LINEAR",   0},
                                {1.0, "LINEAR",   0},
                            }
                        } or nil,
                        p.right_triangle and {
                            source = p.right_triangle,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.7, "LINEAR",   0},
                                {1.0, "LINEAR", 255},
                            }
                        } or nil,
                        {
                            source = contents,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.2, "LINEAR", 255},
                                {0.3, "LINEAR",   0},
                                {1.0, "LINEAR",   0},
                            }
                        },
                        {
                            source = contents,
                            name = "y_rotation",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.3, "LINEAR", 120},
                                {1.0, "LINEAR", 120},
                            }
                        },
                        {
                            source = sub_menu_edge,
                            name = "opacity",
                            
                            keys = {
                                {0.0, "LINEAR", 255},
                                {0.9, "LINEAR", 255},
                                {1.0, "LINEAR",   0},
                            }
                        },
                        {
                            source = sub_menu_edge,
                            name = "y_rotation",
                            
                            keys = {
                                {0.0, "LINEAR",   0},
                                {0.7, "LINEAR",   0},
                                {1.0, "LINEAR", 120},
                            }
                        },
                    }
                },
            },
        },
    }
    --]]
    local state = "HIDE"
    if p.new_shadow then
        p.new_shadow.opacity = 0
    end
    sub_menu_edge.opacity = 0
    contents.opacity = 0
    local show = Animator{
        duration   = dur,
        properties = {
            p.old_shadow and {
                source = p.old_shadow,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR", 255},
                    {0.8, "LINEAR", 255},
                    {1.0, "LINEAR",   0},
                }
            } or nil,
            p.new_shadow and {
                source = p.new_shadow,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.8, "LINEAR",   0},
                    {1.0, "LINEAR", 255},
                }
            } or nil,
            p.right_triangle and {
                source = p.right_triangle,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR", 255},
                    {0.5, "LINEAR",   0},
                    {1.0, "LINEAR",   0},
                }
            } or nil,
            {
                source = sub_menu_edge,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.1, "LINEAR", 255},
                    {1.0, "LINEAR", 255},
                }
            },
            {
                source = sub_menu_edge,
                name = "y_rotation",
                
                keys = {
                    {0.0, "LINEAR", 120},
                    {0.3, "LINEAR",   0},
                    {1.0, "LINEAR",   0},
                }
            },
            {
                source = contents,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.7, "LINEAR",   0},
                    {0.8, "LINEAR", 255},
                    {1.0, "LINEAR", 255},
                }
            },
            {
                source = contents,
                name = "y_rotation",
                
                keys = {
                    {0.0, "LINEAR", 120},
                    {0.7, "LINEAR", 120},
                    {1.0, "LINEAR",   0},
                }
            },
        }
    }
    local hide = Animator{
        duration   = dur,
        properties = {
            p.old_shadow and {
                source = p.old_shadow,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.2, "LINEAR", 255},
                    {1.0, "LINEAR", 255},
                }
            } or nil,
            p.new_shadow and {
                source = p.new_shadow,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR", 255},
                    {0.2, "LINEAR",   0},
                    {1.0, "LINEAR",   0},
                }
            } or nil,
            p.right_triangle and {
                source = p.right_triangle,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.7, "LINEAR",   0},
                    {1.0, "LINEAR", 255},
                }
            } or nil,
            {
                source = contents,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR", 255},
                    {0.2, "LINEAR", 255},
                    {0.3, "LINEAR",   0},
                    {1.0, "LINEAR",   0},
                }
            },
            {
                source = contents,
                name = "y_rotation",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.3, "LINEAR", 120},
                    {1.0, "LINEAR", 120},
                }
            },
            {
                source = sub_menu_edge,
                name = "opacity",
                
                keys = {
                    {0.0, "LINEAR", 255},
                    {0.9, "LINEAR", 255},
                    {1.0, "LINEAR",   0},
                }
            },
            {
                source = sub_menu_edge,
                name = "y_rotation",
                
                keys = {
                    {0.0, "LINEAR",   0},
                    {0.7, "LINEAR",   0},
                    {1.0, "LINEAR", 120},
                }
            },
        }
    }
    
    --sub_menu_state.state = "HIDE"
    
    local sub_menu_i = 1
    
    for i,v in ipairs(sub_menu_items) do
        
        if i == sub_menu_i then
            v:focus()
        else
            v:unfocus()
        end
        
    end
    
    local key_events = p.direction == "VERTICAL" and {
        [keys.Up] = function(self)
            
            if sub_menu_i == 1 then
                --[[
                self:hide_sub_menu()
                
                logical_parent:grab_key_focus()
                
                logical_parent:on_key_down(keys.Up)
                --]]
                
                p.total_close(sub_menu,keys.Up)
                
            else
                
                sub_menu_items[sub_menu_i]:unfocus()
                
                sub_menu_i = sub_menu_i - 1
                
                sub_menu_items[sub_menu_i]:focus()
                
            end
            
            return true
            
        end,
        [keys.Down] = function(self)
            
            if sub_menu_i == #sub_menu_items then
                --[[
                self:hide_sub_menu()
                
                logical_parent:grab_key_focus()
                
                logical_parent:on_key_down(keys.Down)
                --]]
                
                p.total_close(sub_menu,keys.Down)
                
            else
                
                sub_menu_items[sub_menu_i]:unfocus()
                
                sub_menu_i = sub_menu_i + 1
                
                sub_menu_items[sub_menu_i]:focus()
                
            end
            
            return true
            
        end,
        [keys.Left] = function(self)
            --[[
            self:hide_sub_menu()
            
            logical_parent:grab_key_focus()
            --]]
            p.local_close(sub_menu)
            
            return true
            
        end,
        [keys.Right] = function(self)
            --[[
            self:hide_sub_menu()
            --]]
            p.total_close(sub_menu,keys.Right)
            
            --return true
            
        end,
        [keys.OK] = function(self)
            
            sub_menu_items[sub_menu_i]:unfocus()
            
            return sub_menu_items[sub_menu_i]:press_enter()
            
        end,
        
    } or {
        [keys.Left] = function(self)
            
            if sub_menu_i == 1 then
                --[[
                self:hide_sub_menu()
                
                logical_parent:grab_key_focus()
                --]]
                
                p.local_close(sub_menu)
                
            else
                
                sub_menu_items[sub_menu_i]:unfocus()
                
                sub_menu_i = sub_menu_i - 1
                
                sub_menu_items[sub_menu_i]:focus()
                
            end
            
            return true
            
        end,
        [keys.Right] = function(self)
            
            if sub_menu_i == #sub_menu_items then
                --[[
                self:hide_sub_menu()
                --]]
                p.total_close(sub_menu,keys.Right)
            else
                
                sub_menu_items[sub_menu_i]:unfocus()
                
                sub_menu_i = sub_menu_i + 1
                
                sub_menu_items[sub_menu_i]:focus()
                
                return true
                
            end
            
            
            
        end,
        [keys.Up] = function(self)
            --[[
            self:hide_sub_menu()
            
            logical_parent:grab_key_focus()
            
            logical_parent:on_key_down(keys.Up)
            --]]
            p.total_close(sub_menu,keys.Up)
            
            return true
            
        end,
        [keys.Down] = function(self)
            --[[
            self:hide_sub_menu()
            
            logical_parent:grab_key_focus()
            
            logical_parent:on_key_down(keys.Down)
            --]]
            p.total_close(sub_menu,keys.Down)
            
            return true
            
        end,
        [keys.OK] = function(self)
            
            sub_menu_items[sub_menu_i]:unfocus()
            
            return sub_menu_items[sub_menu_i]:press_enter()
            
        end,
        
    }
    
    function sub_menu:on_key_down(k)
        
        return key_events[k] and key_events[k](self)
        
    end
    
    function sub_menu:show_sub_menu(i)
        
        sub_menu_i = i or 1
        
        for i,item in ipairs(sub_menu_items) do
            
            if i == sub_menu_i then
                
                item:focus()
                
            else
                
                item:unfocus()
                
            end
            
        end
        
        parent_ref.parent:raise_to_top()
        
        --sub_menu_state.state = "SHOW"
        if state == "HIDE" then
        if hide.is_playing then hide:stop() end
        show:start()
        state = "SHOW"
        end
        
        sub_menu:grab_key_focus()
        
    end
    
    function sub_menu:hide_sub_menu()
        
        parent_ref.parent:raise_to_top()
        
        --sub_menu_state.state = "HIDE"
        if state == "SHOW" then
        if show.is_playing then show:stop() end
        hide:start()
        state = "HIDE"
        end
    end
    
    --sub_menu_state:warp("HIDE")
    
    return sub_menu
    
end





function myAppsHL:create(p)
    
    local instance = p.group or Group{name = "Highlight",x=5}
    
    p.contents.y = -y_off
    ----------------------------------------------------------------------------
    -- Highlight Visual Pieces
    ----------------------------------------------------------------------------
    
    local left_triangle  = Clone{ name = "left",    source = left_triangle,  x = - left_triangle.w,             y = main_bg.h-y_off}
    local right_triangle = Clone{ name = "right",   source = right_triangle, x = main_bg.w - left_triangle.w*2, y = main_bg.h-y_off, }
    local main_bg        = Clone{ name = "main_bg", source = main_bg,        x = - left_triangle.w,             y = -y_off }
    
    --local sub_menu    = Group{ name = "sub_menu",   x = main_bg.w - left_triangle.w, y = -30 - y_off, --[[opacity = 0, y_rotation = {120,0,0}]] }
    
    local prev  = Clone{ y=-y_off, size = icon_size}
    local next  = Clone{ size = icon_size,position = {icon_size[1]/2,icon_size[2]/2-y_off},anchor_point = {icon_size[1]/2,icon_size[2]/2} }
    local frame = Clone{source=canvas_srcs.launcher_icon_frame,y=-y_off,size = icon_size}
    
    
    local menu_shadow    = Clone{ source = menu_shadow,y = main_bg.y+main_bg.h}
    local sub_shadow     = Clone{ source = sub_shadow,y = -25,opacity = 0}
    local sub_sub_shadow = Clone{ source = sub_sub_shadow,y = -45,opacity = 0}
    local sub_menu = Group{}
    local sub_sub_menu = make_sub_menu{
        direction      = "HORIZONTAL",
        bg_src         = sub_sub_menu_bg,
        parent_ref     = instance,
        edge_src       = sub_sub_menu_edge,
        logical_parent = sub_menu,
        old_shadow     = sub_shadow,
        new_shadow     = sub_sub_shadow,
        local_close    = function(self)
            
            self:hide_sub_menu()
            
            sub_menu:show_sub_menu(2)
            
        end,
        total_close    = function(self,k)
            
            self:hide_sub_menu()
            
            p.logical_parent:grab_key_focus()
            
            p.logical_parent:on_key_down(k)
            
            dolater(200,sub_menu.hide_sub_menu,sub_menu)
            
        end,
        sub_menu_items = {
            Group{
                x = 10,
                y = 10,
                children = {
                    Clone{ name = "unfocus", source = imgs.fb_unfocus },
                    Clone{ name =   "focus", source = imgs.fb_focus   },
                },
                extra = {
                    focus = function(self)
                        self:find_child("focus"):show()
                    end,
                    unfocus = function(self)
                        self:find_child("focus"):hide()
                    end,
                    press_enter = function(self)
                        print("facebook")
                    end,
                },
            },
            Group{
                x = 120,
                y = 10,
                children = {
                    Clone{ name = "unfocus", source = imgs.tw_unfocus },
                    Clone{ name =   "focus", source = imgs.tw_focus   },
                },
                extra = {
                    focus = function(self)
                        self:find_child("focus"):show()
                    end,
                    unfocus = function(self)
                        self:find_child("focus"):hide()
                    end,
                    press_enter = function(self)
                        print("twitter")
                    end,
                },
            }
        },
    }
    
    sub_menu           = make_sub_menu{
        group          = sub_menu,
        direction      = "VERTICAL",
        bg_src         = sub_menu_bg,
        parent_ref     = instance,
        edge_src       = sub_menu_edge,
        logical_parent = p.logical_parent,
        right_triangle = right_triangle,
        old_shadow     = menu_shadow,
        new_shadow     = sub_shadow,
        local_close    = function(self)
            
            self:hide_sub_menu()
            
            p.logical_parent:grab_key_focus()
            
        end,
        total_close    = function(self,k)
            
            self:hide_sub_menu()
            
            p.logical_parent:grab_key_focus()
            
            p.logical_parent:on_key_down(k)
            
            --dolater(200,sub_menu.hide_sub_menu,sub_menu)
            
        end,
        sub_menu_items = {
            Group{
                x = 5,
                y = 37,
                children = {
                    Clone{
                        name = "arrow",
                        source = canvas_srcs.arrow,
                        anchor_point = {0,canvas_srcs.arrow.h/2},
                        x = 4,
                    },
                    Text{ name="text", text = "Play", font = sub_font, x = 25, y=-16},
                },
                extra = {
                    focus = function(self)
                        self:find_child("arrow"):show()
                        self:find_child("text").color = "000000"
                    end,
                    unfocus = function(self)
                        self:find_child("arrow"):hide()
                        self:find_child("text").color = "ffffff"
                    end,
                    press_enter = function(self)
                        self:find_child("arrow"):hide()
                        apps:launch(instance.app_id)
                    end,
                },
            },
            Group{
                x = 5,
                y = 77,
                children = {
                    Clone{
                        name = "arrow",
                        source = canvas_srcs.arrow,
                        anchor_point = {0,canvas_srcs.arrow.h/2},
                        x = 4,
                    },
                    Text{ name="text", text = "Share", font = sub_font, x = 25, y=-16},
                },
                extra = {
                    focus = function(self)
                        self:find_child("arrow"):show()
                        self:find_child("text").color = "000000"
                    end,
                    unfocus = function(self)
                        self:find_child("arrow"):hide()
                        self:find_child("text").color = "ffffff"
                    end,
                    press_enter = function(self)
                        sub_sub_menu:show_sub_menu()
                    end,
                },
            }
        },
    }
    
    sub_sub_menu.x = sub_menu_bg.w + sub_menu_edge.w
    
    sub_menu:add(sub_sub_menu)
    
    sub_menu.x = main_bg.w - left_triangle.w
    sub_menu.y = -40
    sub_sub_menu.y = -30
    instance:add(
        left_triangle,
        right_triangle,
        menu_shadow,
        sub_shadow,
        sub_sub_shadow,
        main_bg,
        sub_menu,
        --[[
        prev,
        next,
        
        Clone{
            source = canvas_srcs.launcher_icon_frame,
            y      = -y_off,
            size   = icon_size,
        },
        caption
        --]]
        p.contents
        
    )
    
    ----------------------------------------------------------------------------
    -- Events
    ----------------------------------------------------------------------------
    
    function instance:show_sub_menu()
        
        sub_menu:show_sub_menu()
        
    end
    function instance:hide_sub_menu()
        
        sub_menu:hide_sub_menu()
        
    end
    
    instance.focus = p.focus
    
    return instance
end

return myAppsHL



