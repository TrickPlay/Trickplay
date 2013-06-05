MyAnimator = function(initial_properties)
    local instance = {}
    local p = initial_properties or {}
    if type(p) ~= "table" then error("No",2) end

    instance.on_completed = on_c
    function instance:add_properties( t )
        for i,v in ipairs(t) do
            table.insert(p,v)
        end
    end
    function instance:start(t)
        if t.properties then error("No",2) end

        t.properties = p

        local a = Animator(t)

        a.timeline.on_started   = instance.on_started
        a.timeline.on_completed = instance.on_completed
        a:start()
    end
    return instance
end
