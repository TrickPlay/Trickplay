
test_description = "Check that the 'L' Filter accelerometer is sending movement events."
test_steps = "1) Z access - Set the device in front of you on the desk in Portrait orientation. Z value should be less than -0.9.\n\n 2) Rotate the device so the screen is facing 90 degrees left. X_value should be less than -0.9.\n\n3) Set back to original position. Rotate it toward you from the top til it is 90 degrees. Y_value should be less than -0.9."
test_verify = ""
test_group = "acceptance"
test_area = "accelerometer"
test_api = "H filter"


function generate_test_image (controller, factory)

	local z_test = ""
	local x_test = ""
	local y_test = ""
	local all_tests = ""


	local total = 0
  	if controller.has_accelerometer then


        function controller:on_accelerometer(x, y, z)
    		controller:start_accelerometer("L", 1)
			local remaining_time = 6 - math.floor(total)
            test_verify_txt.text = "Accelerometer values:\nx =\t"..tostring(x).."\t"..x_test.."\ny =\t"..tostring(y).."\t"..y_test.."\nz =\t"..tostring(z).."\t"..z_test.."\n\n"..all_tests

			if x_test == "Pass" and y_test == "Pass" and z_test == "Pass" then 
				 test_verify_txt.text = "Accelerometer values:\nx =\t"..tostring(x).."\t"..x_test.."\ny =\t"..tostring(y).."\t"..y_test.."\nz =\t"..tostring(z).."\t"..z_test.."\n\n".."All tests pass. Accelerometer turned off."
				controller:stop_accelerometer()
			end

			if x < -0.9 then 
				x_test = "Pass"
			end
			
			if y < -0.9 then 
				y_test = "Pass"
			end
			
			if z < -0.9 then 
				z_test = "Pass"
			end

	

        end

 	controller:start_accelerometer("L", 1)

	-- Stop the accelerometer after 6 seconds
--[[
    function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 6 then
        idle.on_idle = nil
		controller:stop_accelerometer()
 		test_verify_txt.text = "Accelerometer turned off."
      end
    end
--]]
  else
	test_steps = "Accelerometer is not responding. Either confirm this device does not have one or that it is disabled."
	test_verify = "Accelerometer is not responding. Either confirm this device does not have one or that it is disabled."
  end

end

