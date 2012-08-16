
local bg = {}
local bg_layer, imgs, fg_layer

local has_been_initialized = false


--------------------------------------------------------------------------------
-- links the dependencies
--------------------------------------------------------------------------------
function bg:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    fg_layer = t.fg_layer or error("must pass fg_layer",2)
    bg_layer = t.bg_layer or error("must pass bg_layer",2)
    imgs     = t.imgs     or error("must pass imgs",2)
    
end

--makes the blue gradient that is the water
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

--------------------------------------------------------------------------------
-- make the object
--------------------------------------------------------------------------------
function bg:create(t)
    
    if not has_been_initialized then error("Must initialize",2) end
    
    ----------------------------------------------------------------------------
    -- background                                                             --
    ----------------------------------------------------------------------------
    
    local sun = Image{
        src = "assets/bg/sun.png",
        y   = 900,
    }
    local water = make_water()
    local reflection = Image{
        src = "assets/bg/water-reflection.png",
        anchor_point = {684/2,0},
        x = 550,
        y   = screen_h - 45,
    }
    
    bg_layer:add(
        Image{
            src = "assets/bg/tree-left.png",
        },
        Image{
            src = "assets/bg/tree-right.png",
            x   = screen_w - 286,
        },
        sun,
        water,
        reflection
    )
    
    ----------------------------------------------------------------------------
    -- Make the ripples in the water                                          --
    ----------------------------------------------------------------------------
    local ripples = Group{name="ripples"}
    
    local ripples_src = Group{name = "source_ripples",x=100}
    local every_other = true
    local count = 0
    Timer{
        interval = 2000,
        on_timer = function(self)
            
            every_other = not every_other
            
            local ripple = Clone{
                source = imgs.ripple,
                x = every_other and imgs.ripple.w/2 or 0,
                y = screen_h - 45,
                opacity = 0,
            }
            ripples_src:add(ripple)
            local a = Animator{
                duration = 12000,
                properties = {
                    {
                        source = ripple, name = "y",
                        keys = {
                            {0.0, ripple.y },
                            {1.0, ripple.y+math.random(50,70)},
                        }
                    },
                    {
                        source = ripple, name = "x",
                        keys = {
                            {0.0, ripple.x     },
                            {1.0, ripple.x+math.random(150,250)},
                        }
                    },
                    {
                        source = ripple, name = "opacity",
                        keys = {
                            {0.0,   0},
                            {0.1, 255},
                        }
                    },
                }
            }
            a.timeline.loop = true
            a:start()
            if count < 5 then
                count = count + 1
            else
                self:stop()
                --print("stop()")
            end
            
        end
    }--:stop()
    ripples:add(
        ripples_src,
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*2},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*3},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*4},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*5},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*6},
        Clone{source = ripples_src,x=ripples_src.x+imgs.ripple.w*7}
    )
    bg_layer:add(ripples)
    
    function bg:fades_out_with_tv()
        
        return ripples,sun,water,reflection
        
    end
    
    -- upval used in the reed and cattail animation, so that multiple tables
    -- aren't create every iteration
    local table = {0,0,0} 
    
    ----------------------------------------------------------------------------
    -- Make the windy reeds                                                   --
    ----------------------------------------------------------------------------
    reed = Image{
        src = "assets/bg/reeds-left.png",
        y   = screen_h,
        anchor_point = {0,297},
    }
    reed1 = Image{
        src = "assets/bg/reeds-left-1.png",
        position     = reed.position,
        anchor_point = reed.anchor_point,
    }
    reed2 = Image{
        src = "assets/bg/reeds-left-2.png",
        position     = reed.position,
        anchor_point = reed.anchor_point,
    }
    
    Timeline{
        duration = 4000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            table[1] = -.3 + .3*math.sin(math.pi*2*(p+.3))
            
            reed.x_rotation  = table
            
        end
    }:start()
    Timeline{
        duration = 3000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            table[1] = -1 + 1*math.sin(math.pi*2*p)
            
            reed1.x_rotation = table
            
            table[1] = -1 + 1*math.sin(math.pi*2*(p+.2))
            
            reed2.x_rotation = table
            
        end
    }:start()
    
    ----------------------------------------------------------------------------
    -- Make the windy cattails                                                --
    ----------------------------------------------------------------------------
    local cattail = Image{
        src = "assets/bg/cattails.png",
        y   = screen_h,
        x   = screen_w,
        anchor_point = {197,213},
    }
    local cattail2 = Image{
        src = "assets/bg/cattails-2.png",
        position     = cattail.position,
        anchor_point = cattail.anchor_point,
    }
    local cattail3 = Image{
        src = "assets/bg/cattails-3.png",
        position     = cattail.position,
        anchor_point = cattail.anchor_point,
    }
    local cattail4 = Image{
        src = "assets/bg/cattails-4.png",
        position     = cattail.position,
        anchor_point = cattail.anchor_point,
    }
    
    Timeline{
        duration = 4000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            table[1] = -.3 + .3*math.sin(math.pi*2*(p+.3))
            
            cattail.x_rotation  = table
            
        end
    }:start()
    Timeline{
        duration = 3000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            
            table[1] = -1 + 1*math.sin(math.pi*2*p)
            
            cattail2.x_rotation = table
            
            table[1] = -1 + 1*math.sin(math.pi*2*(p+.2))
            
            cattail3.x_rotation = table
            
            table[1] = -1 + 1*math.sin(math.pi*2*(p+.4))
            
            cattail4.x_rotation = table
            
        end
    }:start()
    
    ----------------------------------------------------------------------------
    -- foreground                                                             --
    ----------------------------------------------------------------------------
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
