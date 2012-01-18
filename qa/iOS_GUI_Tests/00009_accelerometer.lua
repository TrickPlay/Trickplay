
test_description = "Check that the accelerometer is sending acceleration values only as it has 'L' filter."
test_steps = "Set the device down on the table and verify that all three values are near 0.\nMoving the device should only move the values small amounts. "
test_verify = "Need to fill this in."
test_group = "smoke"
test_area = "accelerometer"
test_api = "basic 'L' movement"


function generate_test_image (controller, factory)

	local total = 0
  	if controller.has_accelerometer then

        function controller:on_accelerometer(x, y, z)
    		controller:start_accelerometer("L", 1)
			local remaining_time = 10 - math.floor(total)
            test_verify_txt.text = "Accelerometer values:\nx =\t"..tostring(x).."\t".."\ny =\t"..tostring(y).."\t".."\nz =\t"..tostring(z)
        end

 	controller:start_accelerometer("L", 1)

	-- Stop the accelerometer after 10 seconds

    function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 10 then
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

