local border_w = 1
local r        = 20
local bg_color = "0C0C0C"
local upper_outline = "B9B9B9"
local lower_outline = "4D4D4D"

local upper_corner = Canvas{size={r,r},opacity=0}
    upper_corner:begin_painting()
    upper_corner:move_to(0,r+1)
    upper_corner:line_to(0,r)
    upper_corner:curve_to(
        0,0,
        0,0,
        r,0
    )
    upper_corner:line_to(r+1,0)
    upper_corner:line_to(r+1,r+1)
    upper_corner:line_to(0,r+1)
    upper_corner:set_source_color( bg_color )
    upper_corner:fill(true)
    upper_corner:set_source_color( upper_outline )
    upper_corner:set_line_width(   1 )
	upper_corner:stroke( true )
    upper_corner:finish_painting()
local upper_border = Canvas{size={1,r},opacity=0}
    upper_border:begin_painting()
    upper_border:move_to(-1,0)
    upper_border:line_to(2,0)
    upper_border:line_to(2,r+1)
    upper_border:line_to(-1,r+1)
    upper_border:line_to(-1,0)
    upper_border:set_source_color( bg_color )
    upper_border:fill(true)
    upper_border:set_source_color( upper_outline )
    upper_border:set_line_width(   1 )
	upper_border:stroke( true )
    upper_border:finish_painting()
local lower_border = Canvas{size={1,r},opacity=0}
    lower_border:begin_painting()
    lower_border:move_to(-1,r)
    lower_border:line_to(2,r)
    lower_border:line_to(2,-1)
    lower_border:line_to(-1,-1)
    lower_border:line_to(-1,r)
    lower_border:set_source_color( bg_color )
    lower_border:fill(true)
    lower_border:set_source_color( lower_outline )
    lower_border:set_line_width(   1 )
	lower_border:stroke( true )
    lower_border:finish_painting()
local left_border = Canvas{size={r,3*screen_h/4},opacity=0}
    left_border:begin_painting()
    left_border:move_to( 0,   -1)
    left_border:line_to( 0,   left_border.h+1)
    left_border:line_to( r+1, left_border.h+1)
    left_border:line_to( r+1, -1)
    left_border:line_to( 0,   -1)
    left_border:set_source_color( bg_color )
    left_border:fill(true)
    left_border:set_source_linear_pattern(
		left_border.w/2,0,
		left_border.w/2, left_border.h
	)
    left_border:add_source_pattern_color_stop( 0 , upper_outline )
	left_border:add_source_pattern_color_stop( 1 , lower_outline )
    left_border:set_line_width(   1 )
	left_border:stroke( true )
    left_border:finish_painting()
local lower_corner = Canvas{size={r,r},opacity=0}
    lower_corner:begin_painting()
    lower_corner:move_to(0,-1)
    lower_corner:line_to(0, 0)
    lower_corner:curve_to(
        0,r,
        0,r,
        r,r
    )
    lower_corner:line_to(r+1,r)
    lower_corner:line_to(r+1,-1)
    lower_corner:line_to(0,-1)
    lower_corner:set_source_color( bg_color )
    lower_corner:fill(true)
    lower_corner:set_source_color( lower_outline )
    lower_corner:set_line_width(   1 )
	lower_corner:stroke( true )
    lower_corner:finish_painting()

local focus_corner = Image{src="assets/focus_corner.png",opacity=0}
local focus_edge = Image{src="assets/focus_edge_tile.png",opacity=0}

screen:add(upper_corner,upper_border,lower_border,lower_corner,left_border,focus_corner,focus_edge)

make_focus = function(w,h,x,y)
    local focus       = Group{x=x-20,y=y-20,opacity=0}
    local right_line  = w-focus.x+20
    local bottom_line = h+20+20
    
    focus:add(
        Clone{source=focus_corner},
        Clone{source=focus_edge,scale={w-24,1},x=focus_corner.w},
        Clone{source=focus_corner,z_rotation={90,0,0},x=right_line},
        Clone{source=focus_edge,scale={1,h-24},z_rotation={90,0,0},x=right_line,y=focus_corner.h},
        Clone{source=focus_corner,z_rotation={180,0,0},x=right_line,y=bottom_line},
        Clone{source=focus_edge,scale={w-24,1},z_rotation={180,0,0},x=right_line-focus_corner.w,y=bottom_line},
        Clone{source=focus_corner,z_rotation={270,0,0},y=bottom_line},
        Clone{source=focus_edge,scale={1,h-24},z_rotation={270,0,0},x=0,y=bottom_line-focus_corner.w}
    )
    return focus
end
make_bg = function(w,h,x,y,rules)
    local side_scale = (h-2*r)/left_border.h
    local bg = Group{x=x,y=y,w=w,h=h}
    
    bg:add(
        Clone{source=upper_corner},
        Clone{source=upper_border,scale={w-2*r,1},x=r},
        Clone{source=upper_corner,z_rotation={90,r/2,r/2},x=w-r},
        
        Clone{source=left_border,scale={1,side_scale},y=r},
        Rectangle{color=bg_color,w=w-2*r,h=h-2*r,x=r,y=r},
        Clone{source=left_border,scale={1,side_scale},y_rotation={180,0,0},y=r,x=w},
        
        Clone{source=lower_corner,y=h-r},
        Clone{source=lower_border,scale={w-2*r,1},x=r,y=h-r},
        Clone{source=lower_corner,z_rotation={-90,r/2,r/2},x=w-r,y=h-r}
    )
    if rules then
        bg:add(
            Rectangle{w=w,h=1,x=0,y=23,color="#505050"},
            Rectangle{w=w,h=1,x=0,y=h-23,color="#505050"}
        )
    end
    
    
    return bg,make_focus(w,h,x,y)
--[[
    local bg = Canvas{size={w,h},x=x,y=y}
    
    
    local top    =        math.ceil(border_w/2)
	local bottom = bg.h - math.ceil(border_w/2)
	local left   =        math.ceil(border_w/2)
	local right  = bg.w - math.ceil(border_w/2)
    bg:begin_painting()
    bg:move_to(left+r,top)
    bg:line_to(right-r,top)
    bg:curve_to(
        right, top,
        right, top,
        right, top+r
    )
    bg:line_to(right,bottom-r)
    bg:curve_to(
        right,   bottom,
        right,   bottom,
        right-r, bottom
    )
    bg:line_to(left+r,bottom)
    bg:curve_to(
        left, bottom,
        left, bottom,
        left, bottom-r
    )
    bg:line_to(left,top+r)
    bg:curve_to(
        left,   top,
        left,   top,
        left+r, top
    )

    
    bg:set_source_color( bg_color )
    bg:fill(true)
    bg:set_source_linear_pattern(
		bg.w/2,0,
		bg.w/2,bg.h
	)
	bg:add_source_pattern_color_stop( 0 , upper_outline )
	bg:add_source_pattern_color_stop( 1 , lower_outline )
    bg:set_line_width(   border_w )
	bg:stroke( true )
    bg:finish_painting()
    return bg
    --]]
    --return Rectangle{color="#000000",w=w,h=h,x=x,y=y}
end

focus_strip = Canvas{size={1,69},opacity=0}
          focus_strip:begin_painting()
          focus_strip:move_to(0,0)
          focus_strip:line_to(focus_strip.w, 0)
          focus_strip:line_to(focus_strip.w, focus_strip.h+1)
          focus_strip:line_to(0,         focus_strip.h+1)
          focus_strip:line_to(0,0)
          focus_strip:set_source_linear_pattern(
            focus_strip.w/2,0,
            focus_strip.w/2,focus_strip.h
          )
          focus_strip:add_source_pattern_color_stop( 0 , "8D8D8D" )
          focus_strip:add_source_pattern_color_stop( 1 , "727272" )
	      focus_strip:fill( true )
          focus_strip:finish_painting()
base_grey_rect = Canvas{size={1,69},opacity=0}
          base_grey_rect:begin_painting()
          base_grey_rect:move_to(-1,0)--border_w,         border_w)
          base_grey_rect:line_to(2, 0)
          base_grey_rect:line_to(2, base_grey_rect.h)
          base_grey_rect:line_to(-1, base_grey_rect.h)
          base_grey_rect:line_to(-1,0)
          base_grey_rect:set_source_color( "181818" )
	      base_grey_rect:fill( true )
          base_grey_rect:set_source_color( "2D2D2D" )
          base_grey_rect:set_line_width(   1 )
	      base_grey_rect:stroke( true )
          base_grey_rect:finish_painting()
screen:add(focus_strip,base_grey_rect)
make_bg_mini = function(w,h,x,y)
    local bg = Canvas{size={w,h},x=x,y=y}
    
    
    local top    = 0    
	local bottom = bg.h
	local left   = 0    
	local right  = bg.w
    bg:begin_painting()
    bg:move_to(left+r,top)
    bg:line_to(right-r,top)
    bg:curve_to(
        right, top,
        right, top,
        right, top+r
    )
    bg:line_to(right,bottom-r)
    bg:curve_to(
        right,   bottom,
        right,   bottom,
        right-r, bottom
    )
    bg:line_to(left+r,bottom)
    bg:curve_to(
        left, bottom,
        left, bottom,
        left, bottom-r
    )
    bg:line_to(left,top+r)
    bg:curve_to(
        left,   top,
        left,   top,
        left+r, top
    )

    
    bg:set_source_color( bg_color.."D0" )
    bg:fill(true)
    
    bg:finish_painting()
    return bg
end