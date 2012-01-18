-- TODO: converts this to a class that operates with any sized rotation

SemiCircleInterval = Class(nil,
function(interval, radius, from, to, theta_start, theta_end, is_x, is_y, ...)
    assert(type(from) == "table")
    assert(type(to) == "table")
    assert(is_x and not is_y or not is_x and is_y)

    local cntr = {x = (from.x + to.x)*.5, y = (from.y + to.y)*.5}
    radius = from.x - cntr.x -- for now
    
    function interval:get_value(progress)
        if is_x then return cntr.x + radius*math.cos(math.pi*progress) end
        if is_y then return cntr.y - radius*math.sin(math.pi*progress) end
    end

end)
