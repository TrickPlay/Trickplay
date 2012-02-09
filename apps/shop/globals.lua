
-------------------------------------------------------------------------------
-- FunctionTimeline
-------------------------------------------------------------------------------

function FunctionTimeline( t )
    
    local functions = t.functions
    assert( type( functions ) == "table" )
    t.functions = nil
    local count = # functions
    
    local mode = t.mode
    if mode then
        t.mode = nil
    end
    
    local timeline = Timeline( t )
    
    if mode then
        -- This timeline will never be collected, because the alpha is holding
        -- on to the timeline and is an upvalue in the timeline's on_new_frame
        
        local alpha = Alpha{ timeline = timeline , mode = mode }
        function timeline.on_new_frame( timeline , elapsed , progress )
            for i = 1 , count do functions[i]( alpha.alpha ) end
        end
    else
        function timeline.on_new_frame( timeline , elapsed , progress )
            for i = 1 , count do functions[i]( progress ) end
        end
    end
    return timeline
end

-------------------------------------------------------------------------------
-- Encapsulate
-------------------------------------------------------------------------------

Encapsulate = dofile( "Encapsulate" )

