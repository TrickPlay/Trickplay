
local t = Timer( 5000 )

local ticks = 0

local t2 = Timer( 1 )

function t2.on_timer()
    ticks = ticks + 1
end

local total = Stopwatch()

function t.on_timer( t )
    t2:stop()
    t.on_timer = nil
    t2.on_timer = nil
    finish_test( ticks / total.elapsed_seconds , "Hz" )
end

title( "Timer test" )
total:start()
t:start()
t2:start()
