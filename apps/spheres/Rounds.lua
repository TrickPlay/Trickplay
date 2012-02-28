
formations = {}

--Balls bouncing back and forth in a line
table.insert(
    
    formations,
    
    {
        {x = screen_w/2+75*-5, y = screen_h/2, vx = 0, vy = -10},
        {x = screen_w/2+75*-4, y = screen_h/2, vx = 0, vy =  10},
        {x = screen_w/2+75*-3, y = screen_h/2, vx = 0, vy = -10},
        {x = screen_w/2+75*-2, y = screen_h/2, vx = 0, vy =  10},
        {x = screen_w/2+75*-1, y = screen_h/2, vx = 0, vy = -10},
        {x = screen_w/2,       y = screen_h/2, vx = 0, vy =  10},
        {x = screen_w/2+75* 1, y = screen_h/2, vx = 0, vy = -10},
        {x = screen_w/2+75* 2, y = screen_h/2, vx = 0, vy =  10},
        {x = screen_w/2+75* 3, y = screen_h/2, vx = 0, vy = -10},
        {x = screen_w/2+75* 4, y = screen_h/2, vx = 0, vy =  10},
        {x = screen_w/2+75* 5, y = screen_h/2, vx = 0, vy = -10},
    }
)


--Balls in a ring formation moving inward
do
    
    local f =  {}
    local n =  10
    local r = 450
    local v =  -2
    
    for i = 1,n do
        
        f[i]   = {
            x  = r*math.cos(math.pi*2*i/n) + screen.w/2,
            y  = r*math.sin(math.pi*2*i/n) + screen.h/2,
            vx = v*math.cos(math.pi*2*i/n),
            vy = v*math.sin(math.pi*2*i/n),
        }
        
    end
    
    table.insert(formations,f)
    
end
