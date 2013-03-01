
w = screen.w-200
h = 700

end_angle = 90

local function make_side(w,h,bg_color)
    local instance = Group{
        anchor_point={w/2,h/2},
    }


    local r = Rectangle{
        w=w,
        h=h,
        --position={w/2,h/2},
        color=bg_color
    }


    local items = {}
    for i=1,4 do
        items[i] = {}
        for j=1,8 do
            items[i][j] = "Icon "..i.." "..j
        end
    end
    local grid = make_grid(items,100,100,80,80)
    grid.x = w/2
    --grid.y = h/2
    instance:add(r,grid)

    return instance
end


r1 = make_side(w,h,'red')
r2 = make_side(w,h,'green')

g = Group{
    position={screen.w/2,h/2+50}
}


local items = {}
for i=1,1 do
    items[i] = {}
    for j=1,10 do
        items[i][j] = "Icon "..i.." "..j
    end
end
local grid = make_grid(items,100,100,80,80)
grid.x = screen.w/2
grid.y = 850

g:add(r1,r2)
screen:add(grid,g)


local phase_one, phase_two
local animating = false
local curr_r = r2
local next_r = r1
local function rotate(outgoing,incoming,direction)
    if animating then return end
    animating = true
    outgoing.y_rotation={ 0,0,-w/2}
    incoming.y_rotation={(direction == "LEFT" and -end_angle or end_angle),0,-w/2}
    phase_one = Animator{
        duration = 400,
        properties = {
            {
                source = outgoing,
                name   = "y_rotation",
                keys   = {
                    {0.0,"EASE_IN_SINE",  0},
                    {1.0,"EASE_IN_SINE", (direction == "LEFT" and end_angle/2 or -end_angle/2)},
                },
            },
            {
                source = incoming,
                name   = "y_rotation",
                keys   = {
                    {0.0,"EASE_IN_SINE", (direction == "LEFT" and -end_angle   or end_angle)},
                    {1.0,"EASE_IN_SINE", (direction == "LEFT" and -end_angle/2 or end_angle/2)},
                },
            },
            {
                source = g,
                name   = "z",
                keys   = {
                    {0.0,"EASE_IN_OUT_QUAD", 0},
                    {1.0,"EASE_IN_OUT_QUAD", -w/2},
                },
            },
        }
    }
    function phase_one.timeline.on_completed()
        incoming:raise_to_top()
        phase_two = Animator{
            duration = 400,
            properties = {
                {
                    source = outgoing,
                    name   = "y_rotation",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",(direction == "LEFT" and end_angle/2 or -end_angle/2)},
                        {1.0,"EASE_OUT_SINE",(direction == "LEFT" and end_angle   or -end_angle)},
                    },
                },
                {
                    source = incoming,
                    name   = "y_rotation",
                    keys   = {
                        {0.0,"EASE_OUT_SINE", (direction == "LEFT" and -end_angle/2 or end_angle/2)},
                        {1.0,"EASE_OUT_SINE",  0},
                    },
                },
                {
                    source = g,
                    name   = "z",
                    keys   = {
                        {0.0,"EASE_IN_OUT_QUAD", -w/2},
                        {1.0,"EASE_IN_OUT_QUAD",  0},
                    },
                },
            }
        }
        function phase_two.timeline.on_completed()
            animating = false

            curr_r = incoming
            next_r = outgoing
        end
        dolater(phase_two.start,phase_two)
    end
    dolater(phase_one.start,phase_one)
end


local key_events = {
    [keys.Right] = function()
        rotate(curr_r,next_r,"RIGHT")
    end,
    [keys.Left] = function()
        rotate(curr_r,next_r,"LEFT")
    end,
}
function screen:on_key_down(k)
    return key_events[k] and key_events[k]()
end
