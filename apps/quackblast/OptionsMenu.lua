
local menu = Group{}

local w = 1470
local h = 490

local align_left = 100

local has_been_initialized = false
local arrow_buff = 10
local imgs, parent, duck_timer

function menu:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    print("duck launcher has been initialized")
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    imgs         = t.imgs
    parent       = t.parent
    duck_timer   = t.duck_timer
    parent:add(self)
    
end

function menu:start(t)
    
    if not has_been_initialized then error("Must initialize",2) end
    
    --make the bg
    local btm_arrow = Clone{
        source = imgs.options.arrow,
        position = {w-imgs.options.arrow.w/2-arrow_buff,h-imgs.options.arrow.h/2-arrow_buff},
        anchor_point = {imgs.options.arrow.w/2,imgs.options.arrow.h/2},
    }
    
    local track = Clone{
        source  = imgs.options.track,
        x       = align_left,
        y       = 340,
        anchor_point = {0,imgs.options.track.h/2},
    }
    
    local grip       =  Clone{
        source       =  imgs.options.grip,
        anchor_point = {imgs.options.grip.w/2,imgs.options.grip.h/2},
        x            =  align_left,
        y            =  340,
    }
    
    grip.reactive = true
    
    local position_grabbed_from, p, dx--upvals
    
    local slider_duck_i = 1
    ---[[
    local slider_ducks = {
        Clone{ source = imgs.options.slider_duck, x = align_left-20,      y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+290,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+480,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+627,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+740,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+820,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+835,  y = 107+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+895,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+910,  y = 107+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+935,  y = 107+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+970,  y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+985,  y = 107+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1010, y = 107+  0},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1050, y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1065, y = 107+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1090, y = 107+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1110, y = 107- 50},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1130, y = 107+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1145, y = 107+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1165, y = 107+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1185, y = 107- 50},
    }--]]
    
    for _,d in ipairs(slider_ducks) do
        
        d:hide()
        
    end
    
    slider_ducks[1]:show()
    
    
    function grip:on_button_down(original_position)
        
        position_grabbed_from = grip.x
        
        g_dragging = function(curr_position)
            
            dx = position_grabbed_from + curr_position - original_position
            
            grip.x =
                dx < align_left           and align_left           or 
                dx > align_left + track.w and align_left + track.w or
                dx
            
            p = (grip.x-align_left)/track.w
            
            --ducks_clip[3] = ducks.w*p
            --ducks.clip = ducks_clip
            duck_timer.interval = 4000+10000*(1-p)
            
            ---[[
            if     slider_duck_i ~=             1 and slider_ducks[slider_duck_i].x > grip.x then
                
                slider_ducks[slider_duck_i]:hide()
                
                slider_duck_i = slider_duck_i - 1
                
            elseif slider_duck_i ~= #slider_ducks and slider_ducks[slider_duck_i+1].x < grip.x then
                
                slider_duck_i = slider_duck_i + 1
                
                slider_ducks[slider_duck_i]:show()
                
            end
            --]]
            
        end
        
    end
    dolater(function()
        grip:on_button_down(grip.x)
        g_dragging(grip.x)
        screen:on_button_up()
    end)
    
    local num_ducks = Text{
        text = "Number of Ducks",
        font = "Chango 24px",
        color = "f6edb0",
        x      = align_left,
        y      = 390,
    }
    
    self:add(
        --corners
        Clone{
            name         = "top_left",
            source       = imgs.options.corner,
            anchor_point = imgs.options.corner.size,
            z_rotation   = {180,0,0},
            opacity      = 255*.85,
        },
        Clone{
            name         = "top_right",
            source       = imgs.options.corner,
            anchor_point = imgs.options.corner.size,
            z_rotation   = {270,0,0},
            x            = w,
            opacity      = 255*.85,
        },
        Clone{
            name         = "btm_left",
            source       = imgs.options.corner,
            anchor_point = imgs.options.corner.size,
            z_rotation   = {90,0,0},
            y            = h,
            opacity      = 255*.85,
        },
        Clone{
            name         = "btm_right",
            source       = imgs.options.corner,
            anchor_point = imgs.options.corner.size,
            x            = w,
            y            = h,
            opacity      = 255*.85,
        },
        --edges
        Clone{
            name         = "right",
            source       =  imgs.options.edge,
            anchor_point = {imgs.options.edge.w,0},
            h            = h - 2*imgs.options.corner.h,
            y            = imgs.options.corner.h,
            x            = w,
            opacity      = 255*.85,
        },
        Clone{
            name         = "bottom",
            source       =  imgs.options.edge,
            anchor_point = {imgs.options.edge.w,0},
            z_rotation   = {90,0,0},
            h            = w - 2*imgs.options.corner.w,
            y            = h,
            x            = w-imgs.options.corner.w,
            opacity      = 255*.85,
        },
        Clone{
            name         = "left",
            source       = imgs.options.edge,
            anchor_point = {imgs.options.edge.w,0},
            z_rotation   = {180,0,0},
            h            = h - 2*imgs.options.corner.h,
            y            = h-imgs.options.corner.h,
            x            = 0,
            opacity      = 255*.85,
        },
        Clone{
            name         = "top",
            source       = imgs.options.edge,
            anchor_point = {imgs.options.edge.w,0},
            z_rotation   = {270,0,0},
            h            = w - 2*imgs.options.corner.w,
            y            = 0,
            x            = imgs.options.corner.w,
            opacity      = 255*.85,
        },
        --middle
        Rectangle{
            color    = "000000",
            size     = {w - 2*imgs.options.corner.w,h - 2*imgs.options.corner.h},
            position = {imgs.options.corner.w,imgs.options.corner.h},
            opacity  = 255*.85,
        },
        Clone{ source = imgs.options.arrow,x=arrow_buff,y=arrow_buff },
        btm_arrow,
        Clone{
            source = imgs.options.hollow_ducks,
            x      =  align_left-20,
            y      =  40,
        },
        --ducks,
        track,
        grip,
        num_ducks,
        unpack(slider_ducks)
    )
    
    
    local on_started = {
        ["OPEN"] = function()
            in_game = false
        end,
        ["CLOSED"] = function()
        end,
    }
    local on_completed = {
        ["OPEN"] = function()
        end,
        ["CLOSED"] = function()
            in_game = true
        end,
    }
    
    
    
    
    local state = AnimationState{
        transitions = {
            {
                source = "*", target = "OPEN",
                keys = {
                    {menu,     "x",               0},
                    {menu,     "y",               0},
                    {btm_arrow,"z_rotation",      0},
                }
            },
            {
                source = "*", target = "CLOSED",
                keys = {
                    {menu,     "x",         -w + imgs.options.arrow.w+arrow_buff},
                    {menu,     "y",         -h + imgs.options.arrow.h+arrow_buff},
                    {btm_arrow,"z_rotation",                180},
                }
            },
        }
    }
    
    state:warp("CLOSED")
    state.timeline.on_started = function()
        on_started[state.state]()
    end
    
    state.timeline.on_completed = function()
        on_completed[state.state]()
    end
    btm_arrow.reactive = true
    
    function btm_arrow:on_button_down()
        state.state = state.state == "CLOSED" and "OPEN" or "CLOSED"
        
    end
    
end

return menu