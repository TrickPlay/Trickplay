local bg = Rectangle{
    size = screen.size,
    color = "bbbbbb"
}
local card_src = Image{
    src = "assets/card.png"
}
card_src:hide()
w = screen.w-200
h = 700

end_angle = 90

local function make_side(w,h,bg_color)
    local instance = Group{
        anchor_point={w/2,h/2},
    }


    local bg = Rectangle{
        w=w,
        h=h,
        --position={w/2,h/2},
        color=bg_color
    }

    -----------------------------------------------
    local top_left = Rectangle{
        x=26,
        y=32,
        w=530,
        h=400,
        --position={w/2,h/2},
        color="pink"
    }
    local btm_left = Rectangle{
        x=top_left.x,
        y=top_left.y+top_left.h,
        w=top_left.w,
        h=260,
        --position={w/2,h/2},
        color="yellow"
    }
    -----------------------------------------------
    local items1 = {}
    for i=1,3 do
        items1[i] = {}
        for j=1,3 do
            items1[i][j] = "Icon "..i.." "..j
        end
    end
    local grid1 = make_grid(items1,90,140,80,80)
    grid1.x = w*3/6
    grid1.y = top_left.y+20
    -----------------------------------------------
    local items2 = {}
    for i=1,3 do
        items2[i] = {}
        for j=1,3 do
            items2[i][j] = "Icon "..i.." "..j
        end
    end
    local grid2 = make_grid(items2,150,100,30,120)
    grid2.x = w*5/6+5
    grid2.y = top_left.y+40
    -----------------------------------------------
    --grid.y = h/2
    instance:add(
        bg,
        Clone{
            source = card_src,
        },
        Clone{
            source = card_src,
            x      = w*2/6
        },
        Clone{
            source = card_src,
            x      = w*4/6
        },
        top_left,
        btm_left,
        grid1,
        grid2
    )

    return instance
end


r1 = make_side(w,h,'red')
r2 = make_side(w,h,'green')

g = Group{
    position={screen.w/2,h/2+50}
}


local btm_row_backing = Image{
    src="assets/bottom-bar.png"
}
btm_row_backing.y = screen.h-btm_row_backing.h
local btm_row_backing_text = Text{
    text = "More",
    font = "Lato 40px",
    color = "white",
    x  = screen.w/2,
    y  = btm_row_backing.y,
}
btm_row_backing_text.anchor_point = {btm_row_backing_text.w/2,0}
local items = {}
for i=1,1 do
    items[i] = {}
    for j=1,10 do
        items[i][j] = "Icon "..i.." "..j
    end
end
local grid = make_grid(items,100,100,80,80)
grid.x = screen.w/2
grid.y = 900

g:add(r1,r2)
screen:add(card_src,bg,btm_row_backing,btm_row_backing_text,grid,g)


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
