
r1 = Rectangle{
    w=1000,
    h=600,
    anchor_point={500,300},
    color='red'
}
r2 = Rectangle{
    w=1000,
    h=600,
    anchor_point={500,300},
    color='green'
}

g = Group{position={screen.w/2,screen.h/2}}
g:add(r1,r2)
screen:add(g)

local phase_one, phase_two
local animating = false
local curr_r = r2
local next_r = r1
local function rotate(outgoing,incoming,direction)
    if animating then return end
    animating = true
    outgoing.y_rotation={ 0,0,-500}
    incoming.y_rotation={(direction == "LEFT" and -90 or 90),0,-500}
    phase_one = Animator{
        duration = 400,
        properties = {
            {
                source = outgoing,
                name   = "y_rotation",
                keys   = {
                    {0.0,"LINEAR",  0},
                    {1.0,"LINEAR", (direction == "LEFT" and 45 or -45)},
                },
            },
            {
                source = incoming,
                name   = "y_rotation",
                keys   = {
                    {0.0,"LINEAR", (direction == "LEFT" and -90 or 90)},
                    {1.0,"LINEAR", (direction == "LEFT" and -45 or 45)},
                },
            },
            {
                source = g,
                name   = "scale",
                keys   = {
                    {0.0,"EASE_OUT_SINE", {1,1}},
                    {1.0,"EASE_OUT_SINE", {.5,.5}},
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
                        {0.0,"LINEAR",(direction == "LEFT" and 45 or -45)},
                        {1.0,"LINEAR",(direction == "LEFT" and 90 or -90)},
                    },
                },
                {
                    source = incoming,
                    name   = "y_rotation",
                    keys   = {
                        {0.0,"LINEAR", (direction == "LEFT" and -45 or 45)},
                        {1.0,"LINEAR",  0},
                    },
                },
                {
                    source = g,
                    name   = "scale",
                    keys   = {
                        {0.0,"EASE_IN_SINE", {.5,.5}},
                        {1.0,"EASE_IN_SINE",  {1,1}},
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
