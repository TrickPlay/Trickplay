
local bg = {}
local bg_layer, imgs, fg_layer

local has_been_initialized = false
function bg:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    fg_layer = t.fg_layer or error("fg_layer")
    bg_layer = t.bg_layer or error("bg_layer")
    imgs = t.imgs or error("imgs")
    
end

local function make_water()
    
    local c = Canvas(1,44)
    
    c:set_source_linear_pattern(0,0,0,c.h)
    c:add_source_pattern_color_stop(0.0,"#74a6d8")
    c:add_source_pattern_color_stop(1.0,"#2760ae")
    
    c:paint()
    
    c = c:Image()
    c.w = screen_w
    c.y = screen_h-c.h
    
    return c
    
end

function bg:start(t)
    
    if not has_been_initialized then error("Must initialize",2) end
    
    bg_layer:add(
        Image{
            src = "assets/bg/tree-left.png",
        },
        Image{
            src = "assets/bg/tree-right.png",
            x   = screen_w - 286,
        },
        --Image{
        --    src = "assets/bg/mountain.png",
        --    x   = screen_w - 541,
        --    y   = screen_h - 115,
        --},
        Image{
            src = "assets/bg/sun.png",
            y   = 900,
        },
        make_water()
    )
    
    
    
    local reflections = {
        --Image{
        --    src = "assets/bg/mountain-reflection.png",
        --    anchor_point = {541/2,0},
        --    x   = screen_w - 541/2,
        --    y   = screen_h - 45,
        --},---[[,
        Image{
            src = "assets/bg/water-reflection.png",
            anchor_point = {684/2,0},
            x = 550,
            y   = screen_h - 45,
        },
        Image{
            src = "assets/bg/water-ripples.png",
            anchor_point = {429/2,0},
            x = 1400,
            y   = screen_h - 45,
        },--]]
    }
    
    bg_layer:add(unpack(reflections))
    
    
    
    
    
    --[[
    for i, r in ipairs(reflections) do
        local orig_x = r.x
        Timeline{
            duration = math.random(1000,2000),
            loop = true,
            on_new_frame = function(tl,ms,p)
                
                r.scale = {1+.02*math.sin(math.pi*2*p),1}
                r.x = orig_x+2*math.sin(math.pi*2*p)
                
            end
        }:start()
        
    end
    --]]
    local ripples = Group{x=100}
    local every_other = true
    Timer{
        interval = 2000,
        on_timer = function()
            
            every_other = not every_other
            
            local ripple = Clone{
                source = imgs.ripple,
                x = every_other and imgs.ripple.w/2 or 0,
                y = screen_h - 45,
            }
            ripples:add(ripple)
            local orig_x = ripple.x
            local move_x_by = math.random(180,230)
            Timeline{
                duration = math.random(8000,12000),
                on_new_frame = function(tl,ms,p)
                    ripple.x = orig_x + move_x_by*p
                    ripple.y = screen_h-50*(1-p) 
                    if p < .1 then
                        p=p/.1
                        ripple.opacity = 255*p
                    else
                        ripple.opacity = 255
                    end
                    --ripple.opacity = 255/2 + 255/2*math.sin(math.pi*2*ms/2000)
                    
                    
                end,
                on_completed = function() ripple:unparent() end
            }:start()
            
        end
    }
    reed = Image{
            src = "assets/bg/reeds-left.png",
            y   = screen_h,
            anchor_point = {0,297},
        }
    reed1 = Image{
            src = "assets/bg/reeds-left-1.png",
            y   = screen_h,
            anchor_point = {0,307},
        }
    reed2 = Image{
            src = "assets/bg/reeds-left-2.png",
            y   = screen_h,
            anchor_point = {0,307},
        }
    
    Timeline{
        duration = 4000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            reed.x_rotation  = {-.3 + .3*math.sin(math.pi*2*(p+.3)),0,0}
            
        end
    }:start()
    Timeline{
        duration = 3000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            reed1.x_rotation = {-1 + 1*math.sin(math.pi*2*p),0,0}
            reed2.x_rotation = {-1 + 1*math.sin(math.pi*2*(p+.2)),0,0}
            
        end
    }:start()
    
    
    local cattail = Image{
        src = "assets/bg/cattails.png",
        y   = screen_h,
        x   = screen_w,
        anchor_point = {197,213},
    }
    local cattail2 = Image{
        src = "assets/bg/cattails-2.png",
        y   = screen_h,
        x   = screen_w,
        anchor_point = {197,213},
    }
    local cattail3 = Image{
        src = "assets/bg/cattails-3.png",
        y   = screen_h,
        x   = screen_w,
        anchor_point = {197,213},
    }
    local cattail4 = Image{
        src = "assets/bg/cattails-4.png",
        y   = screen_h,
        x   = screen_w,
        anchor_point = {197,213},
    }
    
    Timeline{
        duration = 4000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            cattail.x_rotation  = {-.3 + .3*math.sin(math.pi*2*(p+.3)),0,0}
            
        end
    }:start()
    Timeline{
        duration = 3000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            cattail2.x_rotation = {-1 + 1*math.sin(math.pi*2*p),0,0}
            cattail3.x_rotation = {-1 + 1*math.sin(math.pi*2*(p+.2)),0,0}
            cattail4.x_rotation = {-1 + 1*math.sin(math.pi*2*(p+.4)),0,0}
            
        end
    }:start()
    bg_layer:add(
        ripples,
        Clone{source = ripples,x=ripples.x+imgs.ripple.w},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*2},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*3},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*4},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*5},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*6},
        Clone{source = ripples,x=ripples.x+imgs.ripple.w*7}
        )
    fg_layer:add(
        reed,
        reed1,
        reed2,
        cattail,
        cattail2,
        cattail3,
        cattail4,
        Image{
            src = "assets/bg/reeds-middle.png",
            x   = screen_w/2 - 100,
            y   = screen_h - 97,
        }
    )
end

return bg