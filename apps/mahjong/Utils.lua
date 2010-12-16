function grid_check(grid, i, j, k)
    return grid[i][j][k] and (not grid[i-1] or grid[i][j][k] ~= grid[i-1][j][k])
           and (not grid[i][j-1] or grid[i][j][k] ~= grid[i][j-1][k])
end

Utils = {}

function Utils.clamp(min, element, max)
    if not element then error("Utils.clamp: nil element", 2) end
    if not min then error("Utils.clamp: nil min", 2) end
    if not max then error("Utils.clamp: nil max", 2) end

    if(element < min) then return min end
    if(element > max) then return max end
    return element
end

function Utils.deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = Utils.deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end


function Utils.move_element_to_group(element, group,
            position_in_group, duration, to_top, to_back, wait_duration, cb)

    if not group then
        error("needs a group to move the element to", 2)
    end
    if not position_in_group[1] then
        error("position needs an x value", 2)
    end
    if not position_in_group[2] then
        error("position needs a y value", 2)
    end
    if not position_in_group[3] then
        error("position needs a z value", 2)
    end

    local x = position_in_group[1]
    local y = position_in_group[2]
    local z = position_in_group[3]

    if(element.parent) then
        element.x = element.parent.x+element.x
        element.y = element.parent.y+element.y
        element.z = element.parent.z+element.z
        element:unparent()
    end
   
    group:add(element) 
    element.x = element.x-group.x
    element.y = element.y-group.y
    element.z = element.z-group.z

    local on_completed = function()
        assert(not (to_top and to_back),
            "are you sure you want to lower and raise?")
        if to_top then element:raise_to_top()
        elseif to_back then element:lower_to_bottom()
        end
        -- run callback
        if cb then cb() end
    end

    if gameloop and gameloop:is_a(GameLoop) then
        local intervals = {
            ["x"] = Interval(element.x, x),
            ["y"] = Interval(element.y, y),
            ["z"] = Interval(element.z, z),
        }
        gameloop:add(element, duration, wait_duration, intervals, on_completed)
    else
        element:animate{position={x, y, z}, duration=duration,
            on_completed = on_completed
        }
    end

end
