-- Test Set up --
cb1_Calls = 0
cb2_Calls = 0
timer2=Timer()
timer2.interval=400

function on_timer2_1(timer)
  if (cb1_Calls==0) then cb1_Calls = cb1_Calls + 1 end
  if (cb2_Calls==1) then timer2:stop() end
end

function on_timer2_2(timer)
  if (cb2_Calls==0) then cb2_Calls = cb2_Calls + 1 end
  if (cb1_Calls==1) then timer2:stop() end
end

timer2:add_ontimer_listener(on_timer2_1)
timer2:add_ontimer_listener(on_timer2_2)

timer2:start()


-- Tests --


function test_Timer_callbacks_called ()
	assert_equal (timer2.interval, 400, "timer.interval returned: "..timer2.interval.." Expected: 400")
	assert_equal (cb1_Calls, 1, "cb1_Calls returned: "..cb1_Calls.." Expected 1")
        assert_equal (cb2_Calls, 1, "cb2_Calls returned: "..cb2_Calls.." Expected 1")
end


-- Test Tear down --
