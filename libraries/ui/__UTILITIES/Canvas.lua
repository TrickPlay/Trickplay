
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

make_rounded_corner = function(self,state)
    local r = self.border.corner_radius
    local inset = self.border.width/2

    if r == 0 then
        return Rectangle{w = inset*2,h = inset*2,color = self.border.colors[state]}
    end


    local c = Canvas(r,r)
    c.line_width = inset*2
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    -- wrap back around out of the visible bounds
    c:line_to(r+inset,  inset)
    c:line_to(r+inset,r+inset)
    c:line_to(  inset,r+inset)

    c:set_source_color( self.fill_colors[state] )
    c:fill(true)

    c:set_source_color( self.border.colors[state] )
    c:stroke(true)

    return c:Image{name="rounded_corner - "..state}
end
make_top_sliver = function(self,state)

    local r = self.border.corner_radius
    local inset = self.border.width/2
    if r == 0 then
        return Rectangle{w = 1,h = inset*2,color = self.border.colors[state]}
    end
    local c = Canvas(1,r)
    c.line_width = inset*2
    c:move_to( -inset*2,  inset)
    c:line_to(  inset*2,  inset)
    c:line_to(  inset*2,r+inset*2)
    c:line_to( -inset*2,r+inset*2)
    c:line_to( -inset*2,  inset)

    c:set_source_color( self.fill_colors[state] )
    c:fill(true)

    c:set_source_color( self.border.colors[state] )
    c:stroke(true)

    return c:Image{name="top_sliver - "..state}
end
make_side_sliver = function(self,state)

    local r = self.border.corner_radius
    local inset = self.border.width/2
    if r == 0 then
        return Rectangle{w = inset*2,h = 1,color = self.border.colors[state]}
    end
    local c = Canvas(r,1)
    c.line_width = inset*2
    c:move_to(  inset, -inset*2)
    c:line_to(  inset,  inset*2)
    c:line_to(r+inset*2,  inset*2)
    c:line_to(r+inset*2, -inset*2)
    c:line_to(   inset,-inset*2)

    c:set_source_color( self.fill_colors[state] )
    c:fill(true)

    c:set_source_color( self.border.colors[state] )
    c:stroke(true)

    return c:Image{name="side_sliver - "..state}
end
make_arrow = function(self,state)

	local c = Canvas(self.arrow.size,self.arrow.size)

    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)

    c:set_source_color( self.arrow.colors[state] )

    c:fill(true)

	return c:Image{name="arrow - "..state}

end
make_box = function(self,state)
    --print("ccc")
    local c = Canvas(self.toggle_icon_w,self.toggle_icon_h)

    c.op = "SOURCE"

    c.line_width = self.border.width

    c:set_source_color( self.border.colors[state] )

    c:stroke()

    --the box
    c:rectangle(
        c.h/2-10,
        c.h/2-10,
        20,
        20
    )

    c:stroke(true)

    return c:Image{name="box - "..state}
end
make_x_box = function(self,state)
    --print("ccc")
    local c = Canvas(self.toggle_icon_w,self.toggle_icon_h)

    c.op = "SOURCE"

    c.line_width = self.border.width

    c:set_source_color( self.border.colors[state] )

    c:stroke()

    --the X box
    c:rectangle(
        c.h/2-10,
        c.h/2-10,
        20,
        20
    )
    --the X
    c:move_to(c.h/2-10,c.h/2-10)
    c:line_to(c.h/2+10,c.h/2+10)

    c:move_to(c.h/2-10,c.h/2+10)
    c:line_to(c.h/2+10,c.h/2-10)

    c:stroke(true)

    return c:Image{name="x_box - "..state}
end
make_empty_radio_icon = function(self,state)
    --print("ccc")
    local c = Canvas(2*self.radio_icon_r,2*self.radio_icon_r)

    c.op = "SOURCE"

    c.line_width = self.border.width

    c:set_source_color( self.border.colors[state] )

    c:stroke()

    --the circle
    c:arc(
        c.w/2,--x
        c.w/2,--y
        c.w/2 - c.line_width,--r
        0,    --start angle
        360   --end angle
    )

    c:stroke(true)

    return c:Image{name="empty_radio_icon - "..state}
end
make_filled_radio_icon = function(self,state)
    --print("ccc")
    local c = Canvas(2*self.radio_icon_r,2*self.radio_icon_r)

    c.op = "SOURCE"

    c.line_width = self.border.width

    c:set_source_color( self.border.colors[state] )

    c:stroke()

    --the circle
    c:arc(
        c.w/2,--x
        c.w/2,--y
        c.w/2-c.line_width,--r
        0,    --start angle
        360   --end angle
    )

    c:stroke()

    --the middle
    c:arc(
        c.w/2,--x
        c.w/2,--y
        c.w/2-c.line_width - 5,--r
        0,    --start angle
        360   --end angle
    )

    c:fill()


    return c:Image{name="filled_radio_icon - "..state}
end
--draws a rounded rectangle canvas path
round_rectangle = function(c,r)

    local inset = c.line_width/2
    if r == 0 then
        --using canvas arc with a radius of 0,
        --results in a weird effect in the top-left corner

        c:rectangle(inset,inset,c.w-inset*2,c.h-inset*2)

        return
    end

    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w - (inset+r), inset)
    --top-right corner
    c:arc( c.w - (inset+r), inset+r, r,270,360)
    c:line_to(c.w - inset, c.h - (inset+r))
    --bottom-right corner
    c:arc( c.w - (inset+r), c.h - (inset+r), r,0,90)
    c:line_to( inset+r, c.h - inset)
    --bottom-left corner
    c:arc( inset+r, c.h - (inset+r), r,90,180)
    c:line_to( inset, inset+r)

end
