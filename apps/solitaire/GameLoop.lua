GameLoop = Class(nil,
function(gameloop, ...)

    gameloop.sw = Stopwatch()
    gameloop.elements = {}
    local elements = gameloop.elements
    local sw = gameloop.sw
    local props
    
    local function my_idle()
        
        if #elements == 0 then 
            enable_event_listeners() 
            idle.on_idle = nil
            return
        end
        
        disable_event_listeners() 
        
        local progress
        local element
        for i = #elements,1,-1 do
            props = elements[i]
            element = props.element
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
                    if type(interval) == "table" then
                        local temp_table = {}
                        for j,v in ipairs(interval) do
                            temp_table[j] = v:get_value(progress) 
                        end
                        element[var] = temp_table
                    else
                        element[var] = interval:get_value(progress)
                    end
                end
                if progress >= 1 then
                    table.remove(elements, i)
                    if props.on_completed then props.on_completed() end
                end
            end
        end
        
    end

    function gameloop:add(element, duration, wait, intervals, on_completed)
        if not element then error("no element", 2) end
        if not duration then error("no duration", 2) end
        if not intervals or not type(intervals) == "table" then
            error("intervals is nil or not a table", 2)
        end
        if wait and not type(wait) == "number" then
            error("wait needs a number", 2)
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
            on_completed = on_completed,
            vals = vals
        })
        disable_event_listeners()
        idle.on_idle = my_idle
    end
    local t = Timer
    {
        interval = 100,
        on_timer = 
            function()
                if game_timer  and (not game_timer.stop) then
                    if game:get_router():get_active_component() == Components.GAME then
                        if not settings.saved_time then settings.saved_time = 0 end
                        if game:is_new_game() then
                            game_timer.start = math.floor(sw.elapsed_seconds)
                            if game_timer.prev ~= 0 then
                                game_timer.prev = 0
                                game_timer.text.text = "0:00"
                                settings.saved_time = 0
                            end
                        else
                            game_timer.current = math.floor(sw.elapsed_seconds)
                            if game_timer.prev ~=
                            game_timer.current - game_timer.start + settings.saved_time
                            then
                                game_timer.prev =
                                    game_timer.current - game_timer.start + settings.saved_time
                                game_timer:update()
                            end
                        end
                    else
                        game_timer.current = math.floor(sw.elapsed_seconds)
                        game_timer.start = game_timer.current + settings.saved_time - game_timer.prev
                    end
                end
            end
    }

end)
