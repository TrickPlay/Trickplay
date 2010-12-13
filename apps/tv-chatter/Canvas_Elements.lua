local border_w = 1
local r        = 20
local bg_color = "0C0C0C"
local upper_outline = "B9B9B9"
local lower_outline = "4D4D4D"

make_bg = function(w,h,x,y)
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
end

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