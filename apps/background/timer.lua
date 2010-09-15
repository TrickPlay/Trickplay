timer=Timer()
timer.interval=10
function timer.on_timer(timer)
    random_circles()
    print("Timer Fired")
end
