
local menu = Group{}

local w = 1470
local h = 700

local align_left = 100

local has_been_initialized = false
local arrow_buff = 10
local imgs, parent, duck_timer, cursor_class, bg_img, bg


local spacing = 10

-- helper functions
--------------------------------------------------------------------------------
local function make_text(text,color)
    
    local t = Canvas(text.w+2*spacing,text.h+2*spacing)
    
    t.line_width = 2
    
    t:set_source_color(color)
    
    t:round_rectangle( 1, 1, t.w-2, t.h-2,20 )
    t:stroke()
    
    t:move_to(spacing,spacing)
    t:text_element_path(text)
    t:fill()
    
    return t:Image()
    
end

local function make_buttons(btns,font,parent)
    
    local t = Text()
    t.font = font
    
    for i = 1, #btns do
        for j = 1,#btns[i] do
            
            t.text = btns[i][j].t
            
            btns[i][j].dim = make_text(t,"#424141")
            btns[i][j].hl  = make_text(t,"#b7361c")
            
            btns[i][j].dim.x = btns[i][j].x
            btns[i][j].dim.y = btns[i][j].y
            btns[i][j].hl.x  = btns[i][j].x
            btns[i][j].hl.y  = btns[i][j].y
            
            parent:add(btns[i][j].dim,btns[i][j].hl)
            
            if not btns[i][j].sel then btns[i][j].hl:hide() end
            
        end
    end
    
    for i = 1, #btns do
        for j = 1,#btns[i] do
            
            btns[i][j].dim.reactive = true
            
            btns[i][j].dim.on_button_down = function ()
                
                if not btns[i][j].hl.is_visible then
                    
                    for jj = 1,#btns[i] do
                        
                        if j == jj then
                            
                            btns[i][jj].hl:show()
                            
                        else
                            
                            btns[i][jj].hl:hide()
                            
                        end
                        
                    end
                    
                    btns[i][j].f()
                    
                end
                
            end
        end
    end
    
end


--------------------------------------------------------------------------------
-- links the dependencies
--------------------------------------------------------------------------------
function menu:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    bg           = t.bg
    imgs         = t.imgs
    bg_img       = t.bg_img
    parent       = t.parent
    duck_timer   = t.duck_timer
    cursor_class = t.cursor_class
    parent:add(self)
    
end

--------------------------------------------------------------------------------
-- make the object
--------------------------------------------------------------------------------
function menu:create(t)
    
    if not has_been_initialized then error("Must initialize",2) end
    
    ----------------------------------------------------------------------------
    -- The Background                                                         --
    ----------------------------------------------------------------------------
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
        }
    )
    
    ----------------------------------------------------------------------------
    -- The Slider for the number of ducks                                     --
    ----------------------------------------------------------------------------
    local track = Clone{
        source  = imgs.options.track,
        x       = align_left,
        y       = 540,
        anchor_point = {0,imgs.options.track.h/2},
        reactive = true,
    }
    
    local grip       =  Clone{
        source       =  imgs.options.grip,
        anchor_point = {imgs.options.grip.w/2,imgs.options.grip.h/2},
        x            =  align_left,
        y            =  540,
        reactive     = true,
    }
    
    
    
    
    --the individual lit up ducks for the slider, in order of X
    local slider_ducks = {
        Clone{ source = imgs.options.slider_duck, x = align_left-20,      y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+290,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+480,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+627,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+740,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+820,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+835,  y = 307+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+895,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+910,  y = 307+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+935,  y = 307+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+970,  y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+985,  y = 307+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1010, y = 307+  0},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1050, y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1065, y = 307+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1090, y = 307+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1110, y = 307- 50},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1130, y = 307+120},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1145, y = 307+ 60},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1165, y = 307+  5},
        Clone{ source = imgs.options.slider_duck, x = align_left-20+1185, y = 307- 50},
    }
    
    for _,d in ipairs(slider_ducks) do  d:hide() end
    
    local num_ducks = Text{
        text  = "",
        font  = "Chango 24px",
        color = "f6edb0",
        x     = align_left,
        y     = 590,
    }
    slider_ducks[1]:show()
    
    local checking_slider, timing, position_grabbed_from, p, dx--upvals
    local slider_duck_i = 1
    
    --called when the user clicks on the slider knob
    function grip:on_button_down(original_position)
        
        position_grabbed_from = grip.x
        
        --this function is called by screen_on_motion
        g_dragging = function(curr_position)
            
            dx = position_grabbed_from + curr_position - original_position
            
            
            p = (dx-align_left)/track.w
            
            p = p > 1 and 1 or p > 0 and p or 0
            
            grip.x = p*track.w + align_left
            
            --update the interval of the timer that launches the ducks
            timing = 4000+300000*(1-p)
            duck_timer.interval = timing
            
            --Update Caption saying how often ducks are launch
            num_ducks.text = "One duck every ".. (
                timing > 120000 and (math.floor(timing / 60000)      .. " minutes") or
                timing >  60000 and                                     " minute"   or
                timing >  10000 and (math.floor(timing / 10000) * 10 .. " seconds") or
                timing >   1000 and (math.ceil( timing /  1000)      .. " seconds") or
                "second")
            
            
            --update the number of ducks that need to be highlighted, need to use a loop
            --in case the user's mouse moved by more that one duck this iteration
            checking_slider = true
            
            while checking_slider do
                
                if slider_duck_i ~= 1 and slider_ducks[slider_duck_i].x > grip.x then
                    
                    slider_ducks[slider_duck_i]:hide()
                    
                    slider_duck_i = slider_duck_i - 1
                    
                elseif slider_duck_i ~= #slider_ducks and slider_ducks[slider_duck_i+1].x < grip.x then
                    
                    slider_duck_i = slider_duck_i + 1
                    
                    slider_ducks[slider_duck_i]:show()
                    
                else
                    
                    checking_slider = false
                    
                end
                
            end
            
        end
        
    end
    dolater(function()
        grip:on_button_down(grip.x)
        g_dragging(grip.x)
        screen:on_button_up()
    end)
    
    function track:on_button_down(new_position)
        
        grip:on_button_down(
            
            grip.transformed_position[1]*--the transformed position of the grip
            screen_w/screen.transformed_size[1]+--transformed position value has to be converted to the 1920x1080 scale
            grip.w/2 -- transformed position doesn't take anchor point into account
            
        )
        
        g_dragging(new_position)
        
    end
    
    
    
    self:add(
        Clone{
            source = imgs.options.hollow_ducks,
            x      =  align_left-20,
            y      =  240,
        },
        
        track,
        num_ducks,
        unpack(slider_ducks)
    )
    self:add(grip)
    
    ----------------------------------------------------------------------------
    -- The Animation that fades the background in and out                     --
    ----------------------------------------------------------------------------
    
    --the base transitions 
    local bg_img_state = {
        {
            source = "*", target = "HIDDEN",
            keys = {
                {bg_img, "opacity", 0},
            }
        },
        {
            source = "*", target = "VISIBLE",
            keys = {
                {bg_img, "opacity", 255},
            }
        },
    }
    
    --the objects from the background layer that need to fade out when the background fades in
    for i,obj in ipairs{bg:fades_out_with_tv()} do
        
        table.insert(
            bg_img_state[1].keys,
            {obj,"opacity",255}
        )
        
        table.insert(
            bg_img_state[2].keys,
            {obj,"opacity",0}
        )
    end
    
    bg_img_state = AnimationState{
        duration = 300,
        transitions = bg_img_state
    }
    bg_img_state:warp("HIDDEN")
    
    
    
    ----------------------------------------------------------------------------
    -- Make the buttons for changing volume and background                    --
    ----------------------------------------------------------------------------
    
    make_buttons(
        {
            {
                {t = "Show TV",               x = 400,y = 90, f = function() bg_img_state.state="HIDDEN"  end, sel = true},
                {t = "Show Quack Background", x = 600,y = 90, f = function() bg_img_state.state="VISIBLE" end},
            },
            {
                {t = "Mute",  x = 400,y = 190, f = function() mediaplayer.volume = 0    end},
                {t = "Quiet", x = 550,y = 190, f = function() mediaplayer.volume = 0.5 end},
                {t = "Loud",  x = 700,y = 190, f = function() mediaplayer.volume = 1  end, sel = true},
            },
        },
        "Chango 24px", -- use this font
        self           -- add the buttons to this parent
    )
    
    --labels
    self:add(
        Text{
            text  = "Background:",
            font  = "Chango 24px",
            color = "f6edb0",
            x     = align_left+40,
            y     = 100,
        },
        Text{
            text  = "Volume:",
            font  = "Chango 24px",
            color = "f6edb0",
            x     = align_left+110,
            y     = 200,
        }
    )
    
    ----------------------------------------------------------------------------
    -- Mouse Events that trigger OPEN/CLOSE of the menu                       --
    ----------------------------------------------------------------------------
    
    local state
    
    --the arrows with the mouse events
    local btm_arrow = Clone{
        source = imgs.options.arrow,
        x    = w-imgs.options.arrow.w/2-arrow_buff,
        y    = h-imgs.options.arrow.h/2-arrow_buff,
        anchor_point = {
            imgs.options.arrow.w/2,
            imgs.options.arrow.h/2
        },
        reactive = true,
        on_button_down = function()
            
            state.state = state.state == "CLOSED" and "OPEN" or "CLOSED"
            
        end
    }
    
    local top_arrow = Clone{
        source = imgs.options.arrow,
        x      = imgs.options.arrow.w/2 + arrow_buff,
        y      = imgs.options.arrow.h/2 + arrow_buff,
        anchor_point = {
            imgs.options.arrow.w/2,
            imgs.options.arrow.h/2
        },
        reactive = true,
        on_button_down = function()
            
            state.state = "CLOSED"
            
        end
    }
    
    --The Animation State that opens and closes the menu
    state = AnimationState{
        transitions = {
            {
                source = "*", target = "OPEN",
                keys = {
                    {menu,     "x",          0},
                    {menu,     "y",          0},
                    {btm_arrow,"z_rotation", 0},
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
    
    --Stops the cursors from firing when a menu is open
    local on_started = {
        ["OPEN"] = function()
            cursor_class:in_a_menu()
        end,
        ["CLOSED"] = function()
        end,
    }
    local on_completed = {
        ["OPEN"] = function()
        end,
        ["CLOSED"] = function()
            cursor_class:not_in_a_menu()
        end,
    }
    
    state.timeline.on_started = function()   on_started[state.state]()   end
    
    state.timeline.on_completed = function() on_completed[state.state]() end
    
    
    self:add(top_arrow,btm_arrow)
    
    
end

return menu