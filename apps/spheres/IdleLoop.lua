-------------------------------------------------------------------------------
-- IDLE LOOP
--    the physics engine uses an idle loop, since that means I cannot use
--    Timeline, Timer or any other animation methods, a system for appending
--    animations to this IDLE LOOP is needed
-------------------------------------------------------------------------------

step_functions = {}

function add_step_func( duration , func , on_completed )
    
    local step -- the new step function
    
    if duration then
        
        local e = 0
        local d = duration / 1000
        local p = 0
        local min = math.min
        
        step =
            function( seconds )
                e = e + seconds      -- update total elapsed time
                p = min( e / d , 1 ) -- figure out the progress value
                func( p )            -- call the function with that progress value
                if p == 1 then       -- see if animation is done
                    if on_completed then
                        dolater( on_completed )
                    end
                    step_functions[ step ] = nil
                end
            end
        
    else
        
        step =
            function( seconds )
                if false == func( seconds ) then
                    if on_completed then
                        dolater( on_completed )
                    end
                    step_functions[ step ] = nil
                end
            end
        
    end
    
    step_functions[ step ] = true -- add the new function to the list
    
    return step
    
end

-------------------------------------------------------------------------------
-- the function that updates all the animations

local function run_step_funcs(_, s )
    
    for f , _ in pairs( step_functions ) do     f( s )     end
    
    collectgarbage( "step" )
    
end

-------------------------------------------------------------------------------
-- Hook up the idle loop to the physics engines on_step function

if DEBUG then
    
    function physics:on_step( seconds )
        
        run_step_funcs( nil, seconds )
        
        physics:draw_debug()
        
    end
    
else
    
    physics.on_step = run_step_funcs
    
end






