CANVAS = true

--draws a rounded rectangle canvas path
round_rectangle = function(c,r)
    
    
    local inset = c.line_width/2
    
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
