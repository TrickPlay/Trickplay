
test_description = "Check that the basic touch events are being returned."
test_steps = "Press down and release then drag with one finger. Repeat with 2 and 3 fingers."
test_verify = "Need to fill this in."
test_group = "smoke"
test_area = "touch"
test_api = "basic"


function generate_test_image (controller, factory)

	local total = 0
  	if controller.has_touches then
		controller:start_touches()
       	local remaining_time
		function controller:on_touch_down(finger, x, y)
			 remaining_time = 10 - math.floor(total)
            test_verify_txt.text = "Touch down at "..tostring(x)..", "..tostring(y).." with finger "..tostring(finger).."\nTouch events off in "..remaining_time.." seconds."
        end

 		function controller:on_touch_up(finger, x, y)
		   remaining_time = 10 - math.floor(total)
           test_verify_txt.text = "Touch up at "..tostring(x)..", "..tostring(y).." with finger "..tostring(finger).."\nTouch events off in "..remaining_time.." seconds."
        end

        function controller:on_touch_move(finger, x, y)
		   remaining_time = 10 - math.floor(total)
           test_verify_txt.text = "Touch move at "..tostring(x)..", "..tostring(y).." with finger "..tostring(finger).."\nTouch events off in "..remaining_time.." seconds."
        end
 
		function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total >= 6 then
			idle.on_idle = nil
			controller:stop_touches()
	 		test_verify_txt.text = "Touch events turned off."
	      end
	    end

  	else
		test_steps = "Touch events are not responding. Either confirm this device does not have one or that it is disabled."
		test_verify = "Touch events are not responding. Either confirm this device does not have one or that it is disabled."
 	 end

end


