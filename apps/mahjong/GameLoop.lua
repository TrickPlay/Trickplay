GameLoop = Class(nil,
function(gameloop, ...)

--------------- main on_idle stuff ------------------

    gameloop.sw = Stopwatch()
    gameloop.elements = {}
    local elements = gameloop.elements
    local sw = gameloop.sw
    local props
    local to_enable_listeners = true
    local my_idles = {}
   
    local my_idle
    function my_idle()
        
        if #elements == 0 then 
            enable_event_listeners()
            idle.on_idle = nil
            return
        end

        to_enable_listeners = true
        
        local progress
        for i = #elements,1,-1 do
            props = elements[i]
            if props.wait then
                if not (type(props.wait) == "number") then
                    error("wait needs a number", 3)
                end

                progress = Utils.clamp(0, (sw.elapsed-props.start)/props.wait, 1)
                if progress >= 1 then
                    props.wait = nil
                    props.start = sw.elapsed
                else
                    return
                end
            else
                progress = Utils.clamp(0, (sw.elapsed-props.start)/props.duration, 1)

                for var,interval in pairs(props.vals) do
                    if type(interval) == "table" and not interval.is_a then
                        local temp_table = {}
                        for j,v in ipairs(interval) do
                            temp_table[j] = v:get_value(progress) 
                        end
                        props.element[var] = temp_table
                    else
                        props.element[var] = interval:get_value(progress)
                    end
                end
                if progress >= 1 then
                    table.remove(elements, i)
                    if props.on_completed then props.on_completed() end
                end
            end

            if not props.enable then to_enable_listeners = false end
        end

        if to_enable_listeners then enable_event_listeners() end
       
    end


------------- adding animations to the gameloop------------


    function gameloop:add(element, duration, wait, intervals, enable_listeners,
    on_completed)
        if not element then error("no element", 2) end
        if not duration then error("no duration", 2) end
        if (not intervals) or type(intervals) ~= "table" then
            error("intervals is nil or not a table", 2)
        end
        if wait and not type(wait) == "number" then
            error("wait needs a number", 2)
        end
        if enable_listeners and not type(enable_listeners) == "boolean" then
            error("enable_listeners needs a boolean", 2)
        end
        if on_completed and not type(on_completed) == "function" then
            error("on_completed needs a function", 2)
        end

        local vals = {}
        for k,v in pairs(intervals) do
            vals[k] = v
        end
        table.insert(elements, {
            element = element,
            start = sw.elapsed,
            duration = duration,
            wait = wait,
            enable = enable_listeners,
            on_completed = on_completed,
            vals = vals
        })
        disable_event_listeners()
        idle.on_idle = my_idle
    end

    function gameloop:add_list(element, durations, intervals, callback)

        if not element then error("no element", 2) end
        if not durations then error("no durations table", 2) end
        if not intervals then error("no intervals table", 2) end
        if not type(durations) == "table" then
            error("durations needs to be a table", 2)
        end
        if not type(intervals) == "table" then
            error("intervals needs to be a table", 2)
        end
        if #intervals ~= #durations then
            error("#intervals ~= #durations, should be a duration per interval", 2)
        end

        local current = callback
        for i = #intervals,1,-1 do
            local temp = current
            local cb = intervals[i].callback
            intervals[i].callback = nil
            current = function()
                gameloop:add(element, durations[i], nil, intervals[i], nil,
                    function()
                        if cb then cb() end
                        temp()
                    end)
            end
        end

        current()

    end

    -- The game timer
    --[[
    local t = Timer
    {
        interval = 1500,
        on_timer = 
            function()
                if game_timer  and (not game_timer.stop) then
                    if game:get_router():get_active_component() == Components.GAME then
                        if game:is_new_game() then
                            game_timer.start = math.floor(sw.elapsed_seconds)
                            if game_timer.prev ~= 0 then
                                game_timer.prev = 0
                                game_timer.text.text = "0:00"
                            end
                        else
                            game_timer.current = math.floor(sw.elapsed_seconds)
                            if game_timer.prev ~= game_timer.current - game_timer.start then
                                game_timer.prev = game_timer.current - game_timer.start
                                game_timer:update()
                            end
                        end
                    else
                        game_timer.current = math.floor(sw.elapsed_seconds)
                        game_timer.start = game_timer.current - game_timer.prev
                    end
                end
            end
    }
    --]]

end)
