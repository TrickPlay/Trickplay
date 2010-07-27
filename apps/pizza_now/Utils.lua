dofile("Class.lua")

Utils = {}

function Utils.mixin(table_a, table_b)
    table_a = table_a or {}
    table_b = table_b or {}
    for k,v in pairs(table_b) do
        table_a[k] = v
    end
    return table_a
end

function Utils.clamp(a, b, c)
    if(b < a) then
        return a
    end
    if(b > c) then
        return c
    end
    return b
end

function Utils.makeCallbackCounter(num_calls, callback)
    local call_count = 0
    return function()
        call_count = call_count + 1
        if call_count == num_calls then
            callback()
        end
    end
end

function Utils.makeMovie(frame_duration_pairs, properties, parent_group, callback)

    local images = {} 
    local duration_count = 0
    local markers = {}
    for i,v in ipairs(frame_duration_pairs) do
        local image_src      = v[1]
        local image_duration = v[2]

        -- keep track of how far you are in the movie
        duration_count = duration_count + image_duration

        local image = Images:load(image_src, properties)
        images[#images+1] = image

        markers[#markers+1] = {tostring(i+1), duration_count}
        image:hide()
        parent_group:add(image)
    end

    local function on_started(timeline)
        images[1]:show()
    end

    local function on_marker_reached(timeline, marker_name, position) 
        local index = tonumber(marker_name)   
        images[index-1]:hide()
        local next_image = images[index]
        if next_image then
            next_image:show()
        else
            --assert(false, "makeMovie getting to invalid marker!")
        end
    end

    local function on_completed(timeline)
        images[#images]:hide()
        for i,v in ipairs(images) do
            v:unparent()
        end
        if callback ~= nil then callback() end
    end

    local timeline = Timeline{
        duration     = duration_count,
        on_marker_reached = on_marker_reached,
        on_started   = on_started,
        on_completed = on_completed
    }
    if callback == nil then timeline.loop = true end

    for i,v in ipairs(markers) do
        timeline:add_marker(v[1], v[2])
    end

    return timeline
end
