-- Test Set up --
timerCalls = 0
timer=Timer()
timer.interval=400

function timer.on_timer(timer)
  timerCalls = timerCalls + 1
  if timerCalls == 1 then
  	timer:stop()
  end
end
collectgarbage()
timer:start()


-- Tests --


function test_Timer_instantiated_interval ()
	assert_function (Timer, "Timer not instantiated")
	assert_equal (timer.interval, 400, "timer.interval returned: "..timer.interval.." Expected: 400")
	assert_not_equal (timerCalls, 0, "timerCalls returned: "..timerCalls.." Expected it to not equal 0")
end


-- Test Tear down --




