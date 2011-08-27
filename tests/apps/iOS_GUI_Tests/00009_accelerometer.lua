
test_description = "Check that the accelerometer is sending movement events."
test_steps = "Move the device around to see how the x,y and z accelerometer values change."
test_verify = "Need to fill this in."
test_group = "smoke"
test_area = "accelerometer"
test_api = "basic movement"


function generate_test_image (controller, factory)

	local total = 0
  	if controller.has_accelerometer then

        function controller:on_accelerometer(x, y, z)
    		controller:start_accelerometer("L", 1)
			local remaining_time = 10 - math.floor(total)
            test_verify_txt.text = "Accelerometer at ("..tostring(x)..", "..tostring(y)..", "..tostring(z)..")\n\nAcclerometer off in "..remaining_time.." seconds."
        end

 	controller:start_accelerometer("L", 1)

	-- Stop the accelerometer after 10 seconds

    function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 6 then
        idle.on_idle = nil
		controller:stop_accelerometer()
 		test_verify_txt.text = "Accelerometer turned off."
      end
    end

  else
	test_steps = "Accelerometer is not responding. Either confirm this device does not have one or that it is disabled."
	test_verify = "Accelerometer is not responding. Either confirm this device does not have one or that it is disabled."
  end

end

