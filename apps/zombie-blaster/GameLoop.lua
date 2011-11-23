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
            gameloop:remove_idle(my_idle)
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
        if not intervals or not type(intervals) == "table" then
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
        gameloop:add_idle(my_idle)
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
                gameloop:add(element, durations[i], nil, intervals[i],
                    function()
                        if cb then cb() end
                        temp()
                    end)
            end
        end

        current()

    end


----------------- on_idle control -------------------


    do
        local min = math.min
        local step = 1/60
        idle.limit = step
        function idle:on_idle(seconds)
            if physics_enabled then
                physics:step(min(step,seconds))
            end
            --physics:draw_debug()
            for func,args in pairs(my_idles) do
                if type(args) == "table" then
                    args[#args] = seconds
                    func(unpack(args))
                else
                    func()
                end
            end
        end
    end

    function gameloop:add_idle(func, args)
        if type(func) ~= "function" then
            error("can only add functions to on_idle", 2)
        end
        if args then
            if type(args) ~= "table" then
                error("arguments must be held in a table", 2)
            end
            my_idles[func] = args
            table.insert(args, 1)     -- arbitrary value replaced by seconds
        else
            my_idles[func] = func
        end
    end

    function gameloop:remove_idle(func)
        my_idles[func] = nil
    end

    function gameloop:idle_added(func)
        if my_idles[func] then return true else return false end
    end

    function gameloop:clear_idle()
        for k,v in pairs(my_idles) do my_idles[k] = nil end
    end

end)
