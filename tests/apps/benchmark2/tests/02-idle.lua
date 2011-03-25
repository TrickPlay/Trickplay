
local t = Timer( 5000 )

idle.limit = 0

local ticks = 0

function idle.on_idle()
    ticks = ticks + 1
end

local total = Stopwatch()

function t.on_timer( t )
    t.on_timer = nil
    idle.on_idle = nil
    finish_test( ticks / total.elapsed_seconds , "Hz" )
end

title( "Idle test" )

total:start()
t:start()
