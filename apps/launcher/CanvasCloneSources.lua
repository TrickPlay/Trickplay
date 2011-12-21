local clonesources = {}

local make_hl = function(p)
    local c = Canvas(p.w,p.h)
    
    --center color
    c:rectangle(0,p.shadow_h,p.w,p.h-2*p.shadow_h)
    
    local h = (p.h-2*p.shadow_h)/2 + p.shadow_h
    c:set_source_radial_pattern(
        p.w-h/2, h,
        5,
        
        p.w-h, h,
        p.w/4
    )
    
    c:add_source_pattern_color_stop(0,"#ffcc00")
    c:add_source_pattern_color_stop(1,"#ffaa00")
    
    c:fill()
    
    
    --top shadow
    c:rectangle(0,0,p.w,p.shadow_h)
    c:set_source_linear_pattern(
        0,0,
        0,p.shadow_h
    )
    c:add_source_pattern_color_stop(0,"#00000000")
    c:add_source_pattern_color_stop(1,"#000000aa")
    
    c:fill()
    
    --bottom shadow
    c:rectangle(0,p.h-p.shadow_h,p.w,p.shadow_h)
    c:set_source_linear_pattern(
        0,p.h-p.shadow_h,
        0,p.h
    )
    c:add_source_pattern_color_stop(0,"#000000aa")
    c:add_source_pattern_color_stop(1,"#00000000")
    
    c:fill()
    
    return c:Image()
end


local make_launcher_frame = function(p)
    
    local c = Canvas(p.w,p.h)
    
    c.line_width = 2
    c.op = "SOURCE"
    for i = 0,p.border do
        
        c:rectangle(i,i,p.w-2*i,p.h-2*i)
        c:set_source_color({255,255,255,255})
        c:stroke()
        
    end
    for i = p.border,p.border+p.gradient do
        
        c:rectangle(i,i,p.w-2*i,p.h-2*i)
        c:set_source_color({255,255,255,255*(1-(i-p.border)/p.gradient)})
        c:stroke()
        
    end
    
    return c:Image{x = 500,y=500}
    
end

local function make_video_tile_frame(p)
    
    
    local c = Canvas(
        p.w+2*p.b+2*p.s_sz,
        p.r+1+3*p.b+p.t_h+2*p.s_sz
    )
    
    c.op = "SOURCE"
    
    --background
    c:round_rectangle(
        p.s_sz,
        p.s_sz,
        c.w-2*p.s_sz,
        c.h-2*p.s_sz,
        p.r
    )
    c:set_source_color("#ffffff")
    c:fill()
    for i = 1, p.s_sz do
        c:set_source_color{0,0,0,(255/p.s_sz*(p.s_sz-i+1))/4}
        
        c:round_rectangle(
            p.s_sz-i,
            p.s_sz-i,
            c.w-2*p.s_sz+2*i,
            c.h-2*p.s_sz+2*i,
            p.r+2*i
        )
        print(
            p.s_sz-i,
            p.s_sz-i,
            c.w-2*p.s_sz+2*i,
            c.h-2*p.s_sz+2*i,
            p.r+2*i
        )
        c:stroke()
    end
    
    --punch a hole
    c:round_rectangle(
        p.b+p.s_sz,
        2*p.b + p.t_h+p.s_sz,
        p.w,
        p.r+1,
        p.r
    )
    c:set_source_color("#00000000")
    c:fill()
    
    local b = c:Bitmap()
    
    
    --get top piece
    c = Canvas(c.w, 2*p.b + p.t_h+10)
    c:set_source_bitmap(b)
    c:paint()
    
    local top = c:Image{name="Video Tile Frame - Top & Caption"}
    
    
    --get middle slice
    c = Canvas(c.w,1)
    c:set_source_bitmap(b,0,-top.h)
    c:paint()
    
    local mid = c:Image{name="Video Tile Frame - Middle Slice"}
    
    
    --get bottom piece
    c = Canvas(c.w, p.b + 10)
    c:set_source_bitmap(b,0,-b.h+c.h)
    c:paint()
    
    local btm = c:Image{name="Video Tile Frame - Bottom"}
    
    top.border = p.b + p.s_sz
    mid.border = p.b + p.s_sz
    btm.border = p.b + p.s_sz
    
    return top,mid,btm
    
end

function HL_arrow(sz)
    local arrow = Canvas(sz/2,sz)
    arrow:move_to(0,0)
    arrow:line_to(arrow.w,arrow.h/2)
    arrow:line_to(0,arrow.h)
    arrow:line_to(0,0)
    
    arrow:set_source_color("#000000")
    arrow:fill()
    arrow = arrow:Image{x=50, y =arrow.h/2 + 5, anchor_point = {0,arrow.h/2}}
    return arrow
end

local has_been_initialized = false

function clonesources:init(p)
    
    assert(not has_been_initialized)
    
    clonesources.launcher_icon_frame =
        make_launcher_frame{
            w        = p.launcher_frame_w,
            h        = p.launcher_frame_h,
            border   = p.launcher_frame_border,
            gradient = p.launcher_frame_border_gradient,
        }
    
    clonesources.video_tile_frame_top,
    clonesources.video_tile_frame_middle_slice,
    clonesources.video_tile_frame_bottom =
        make_video_tile_frame{
            w = p.video_tile_inner_width,
            b = p.video_tile_border_width,
            r = p.video_tile_corner_radius,
            t_h = Text{text=" ",font=p.video_tile_font}.h,
            s_sz = 5,
        }
    
    clonesources.my_apps_hl =
        make_hl{
            w        = p.my_apps_hl_w,
            h        = p.my_apps_hl_h,
            shadow_h = p.my_apps_hl_shadow_h,
        }
    
    clonesources.arrow = HL_arrow(p.arrow_size)
    
    local g = Group{
        name = "Canvas Clone Sources",
        children = {
            clonesources.launcher_icon_frame,
            clonesources.video_tile_frame_top,
            clonesources.video_tile_frame_middle_slice,
            clonesources.video_tile_frame_bottom,
            clonesources.my_apps_hl,
            clonesources.arrow,
        }
    }
    
    g:hide()
    
    screen:add(g)
    
    has_been_initialized = true
    
end

return clonesources