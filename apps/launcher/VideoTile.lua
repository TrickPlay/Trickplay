local self = {}


local shrunken_h,expanded_h,canvas_srcs,inner_w

local has_been_initialized = false

local font 
function self:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    shrunken_h  = p.shrunken_h  or error("must pass shrunken_h")
    expanded_h  = p.expanded_h  or error("must pass expanded_h")
    inner_w     = p.inner_w     or error("must pass inner_w")
    canvas_srcs = p.canvas_srcs or error("must pass canvas_srcs")
    font        = p.font        or error("must pass font")
    
    has_been_initialized = true
    
end





--[[
    make_frame(p)
    
    helper function, creates the white polaroid-esque frame for the tile
    
    expects:
        p.w - inner width (total width includes border width)
        p.t - caption text
        p.f - font
        p.b - border width
        p.r - corner radius
--]]
local function make_frame(p)
    
    --text for the title
    local t = Text{text = p.t,font=p.f}
    
    local c = Canvas(p.w+2*p.b,p.r+1+3*p.b+t.h)
    
    c.op = "SOURCE"
    
    --background
    c:round_rectangle(0,0,c.w,c.h,p.r)
    c:set_source_color("#ffffff")
    c:fill()
    
    --Caption
    c:move_to(p.r/2,p.b)
    c:text_element_path(t)
    c:set_source_color("#000000")
    c:fill()
    
    --punch a hole
    c:round_rectangle( p.b, 2*p.b + t.h, p.w, p.r+1, p.r )
    c:set_source_color("#00000000")
    c:fill()
    
    local b = c:Bitmap()
    
    
    --get top piece
    c = Canvas(p.w+2*p.b, 2*p.b + t.h+10)
    c:set_source_bitmap(b)
    c:paint()
    
    local top = c:Image{name="Frame - Top & Caption"}
    
    
    --get middle slice
    c = Canvas(p.w+2*p.b,1)
    --c:rectangle(0,0,c.w,c.h)
    c:set_source_bitmap(b,0,-top.h)
    c:paint()
    
    local mid = c:Image{name="Frame - Middle Slice"}
    
    
    --get bottom piece
    c = Canvas(p.w+2*p.b, p.b + 10)
    c:set_source_bitmap(b,0,-b.h+c.h)
    c:paint()
    
    local btm = c:Image{name="Frame - Bottom"}
    
    return top,mid,btm
    
end

function self:create(p)
    
    assert(has_been_initialized)
    
    local g  = Group{
        name = "Video Tile: '"..p.text.."'",
        x    = p.x or 0,
        y    = p.y or 0,
    }
    
    local l_expanded_h = p.expanded_h and p.expanded_h < expanded_h and  p.expanded_h or expanded_h
    
    --Visual Components
    local text = Text{ text   = p.text, font = font, color = "999999", x = 15, y = 3 }
    local top = Clone{ source = canvas_srcs.video_tile_frame_top }
    local mid = Clone{ source = canvas_srcs.video_tile_frame_middle_slice }
    local btm = Clone{ source = canvas_srcs.video_tile_frame_bottom } --[[make_frame{
        w = inner_w, --inner width
        b = 3,       --border width
        r = 20,      --corner radius
        t = p.t,
        f = "DejaVu Sans Bold 24px",
    }]]
    
    mid.y = top.h
    mid.h = shrunken_h
    btm.y = mid.y + mid.h
    
    local contents = Group{
        name = "Clipped Contents",
        y    = top.h - btm.h,
        clip = {3,0,inner_w,shrunken_h+2*btm.h-3},
    }
    
    --local r = Rectangle{color="009900",size = screen.size}
    
    contents:add(p.contents)
    
    g:add(contents,top,mid,btm,text,p.slider)
    
    
    
    local anim_state = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*",          target = "CONTRACT", duration = 300,
                keys   = {
                    {text,      "color", "999999"},
                    {mid,       "h",     shrunken_h},
                    {btm,       "y",     shrunken_h + mid.y},
                    {contents,  "clip",  {3,0,inner_w,shrunken_h+2*btm.h-2}},
                },
            },
            {
                source = "*",          target = "EXPAND", duration = 300,
                keys   = {
                    {text,      "color", "000000"},
                    {mid,       "h",     l_expanded_h},
                    {btm,       "y",     l_expanded_h + mid.y},
                    {contents,  "clip",  {3,0,inner_w, l_expanded_h+2*btm.h-2}},
                },
            },
        },
    }
    
    anim_state.state = "CONTRACT"
    
    local meta_setters = {
        expanded_h = function(v)
            l_expanded_h     = v
            local save_state = anim_state.state
            anim_state = AnimationState{
                duration = 300,
                transitions = {
                    {
                        source = "*",          target = "CONTRACT", duration = 300,
                        keys   = {
                            {text,      "color", "999999"},
                            {mid,       "h",    shrunken_h},
                            {btm,       "y",    shrunken_h + mid.y},
                            {contents,  "clip", {3,0,inner_w,shrunken_h+2*btm.h-2}},
                        },
                    },
                    {
                        source = "*",          target = "EXPAND", duration = 300,
                        keys   = {
                            {text,      "color", "000000"},
                            {mid,       "h",     l_expanded_h},
                            {btm,       "y",     l_expanded_h + mid.y},
                            {contents,  "clip",  {3,0,inner_w, l_expanded_h+2*btm.h-2}},
                        },
                    },
                },
            }
            
            anim_state.state = save_state
            
        end,
        state      = function(v)
            if v == "EXPAND" then
                if  p.slider then
                    p.slider:animate{duration = 100,opacity = 255}
                end
                
                p.contents:grab_key_focus()
                
                if p.focus then p.focus() end
                
            elseif v == "CONTRACT" and p.slider then
                
                p.slider:animate{duration = 100,opacity = 0}
                
                if p.unfocus then p.unfocus() end
                
            end
            
            anim_state.state = v
            
        end,
        text       = function(v) text.text        = v end,
    }
    local meta_getters = {
        expanded_h = function() return l_expanded_h     end,
        state      = function() return anim_state.state end,
        text       = function() return text.text        end,
        content    = function() return p.contents       end,
    }
    
    --function g:warp(s) return anim_state:warp(s) end
    function g:warp(s) if s == "CONTRACT" and p.slider then p.slider.opacity = 0 end return anim_state:warp(s) end
    
    setmetatable(
        g.extra,
        {
            __newindex = function(t,k,v)
                
                return meta_setters[k] and meta_setters[k](v)
                
            end,
            __index = function(t,k)
                
                return meta_getters[k] and meta_getters[k]()
                
            end
        }
    )
    
    g.anchor_point = {-50,0}
    
    return g
    
end


return self