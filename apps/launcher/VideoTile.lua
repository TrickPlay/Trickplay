local self = {}


local shrunken_h,expanded_h,canvas_srcs,inner_w,img_srcs, drop_shadow,overlay

local has_been_initialized = false

local font 
function self:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    shrunken_h  = p.shrunken_h  or error("must pass shrunken_h")
    expanded_h  = p.expanded_h  or error("must pass expanded_h")
    inner_w     = p.inner_w     or error("must pass inner_w")
    canvas_srcs = p.canvas_srcs or error("must pass canvas_srcs")
    img_srcs    = p.img_srcs    or error("must pass img_srcs")
    font        = p.font        or error("must pass font")
    
    overlay = Image{src = "assets/gloss-small.png"}
    img_srcs:add(overlay)
    
    
    has_been_initialized = true
    
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
    local text = Text{ text   = p.text, font = font, color = "999999", x = 20, y = 8 }
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
        clip = {8,0,inner_w,shrunken_h+2*btm.h-8},
    }
    
    --local r = Rectangle{color="009900",size = screen.size}
    
    contents:add(p.contents)
    local overlay = Clone{ source = overlay, x = 8, y = top.h - btm.h + 8 }
    
    g:add(contents,overlay,top,mid,btm,text)
    if p.outer  then g:add( p.outer  ) end
    if p.slider then g:add( p.slider ) end
    

    
    local anim_state = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*",          target = "CONTRACT", duration = 300,
                keys   = {
                    {text,      "color", "999999"},
                    {mid,       "h",     shrunken_h},
                    {btm,       "y",     shrunken_h + mid.y},
                    {contents,  "clip",  {8,0,inner_w,shrunken_h+2*btm.h-8}},
                    {overlay,  "opacity",  255},
                    p.outer and {p.outer,  "opacity",  0} or nil,
                },
            },
            {
                source = "*",          target = "EXPAND", duration = 300,
                keys   = {
                    {text,      "color", "000000"},
                    {mid,       "h",     l_expanded_h},
                    {btm,       "y",     l_expanded_h + mid.y},
                    {contents,  "clip",  {8,0,inner_w, l_expanded_h+2*btm.h-8}},
                    {overlay,  "opacity",  0},
                    p.outer and {p.outer,  "opacity",  255} or nil,
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
                            {contents,  "clip", {8,0,inner_w,shrunken_h+2*btm.h-8}},
                            {overlay,  "opacity",  255},
                            p.outer and {p.outer,  "opacity",  0} or nil,
                        },
                    },
                    {
                        source = "*",          target = "EXPAND", duration = 300,
                        keys   = {
                            {text,      "color", "000000"},
                            {mid,       "h",     l_expanded_h},
                            {btm,       "y",     l_expanded_h + mid.y},
                            {contents,  "clip",  {8,0,inner_w, l_expanded_h+2*btm.h-8}},
                            {overlay,  "opacity",  0},
                            p.outer and {p.outer,  "opacity",  255} or nil,
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
    function g:warp(s)
        if s == "CONTRACT" then
            if p.slider  then p.slider.opacity = 0 end
            if p.unfocus then p.unfocus() end
        else
            if p.focus   then p.focus() end
        end
        
        return anim_state:warp(s)
    end
    
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
