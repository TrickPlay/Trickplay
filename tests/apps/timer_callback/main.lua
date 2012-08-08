newTimer = Timer()
newTimer.interval = 1000
function newTimer.on_timer( newTimer )
    print( "timer.ontimer callback (this implementation will be removed)\n" )
end

count = 0
function cb1()
    count = count+1
    print("callback1 (added with timer:add_ontimer_callback)")
    
    if (count > 5) then
        newTimer:remove_ontimer_listener(ref1)
    end
    
end

function cb2()
    count = count+1
    print("additional callback (added with timer:add_ontimer_callback)")
    if (count>3) then
        newTimer:remove_ontimer_listener(ref2)
    end
end

ref1 = newTimer:add_ontimer_listener(cb1)
ref2 = newTimer:add_ontimer_listener(cb2)



newTimer:start()