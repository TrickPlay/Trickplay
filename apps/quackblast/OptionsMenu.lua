
local menu = Group{}

function menu:init(t)
end

function menu:start(t)
    
    local state = AnimationState{
        transitions = {
            {
                source = "*", target = "OPEN",
                keys = {
                    {menu, "x", 0},
                    {menu, "y", 0},
                }
            },
            {
                source = "*", target = "CLOSED",
                keys = {
                    {menu, "x", -1800},
                    {menu, "y",  -900},
                }
            },
        }
    }
    
end