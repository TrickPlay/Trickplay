
test_description = "Check that the basic touch events are being returned."
test_steps = "Press down and release then drag with one finger. Repeat with 2 and 3 fingers."
test_verify = "Need to fill this in."
test_group = "smoke"
test_area = "touch"
test_api = "basic"


function generate_test_image (controller, factory)

	local total = 0
  	if controller.has_sound then
	     local remaining_time
		 controller:declare_resource("sound_file", "assets/barkpant.mp3")

		local success = controller:play_sound("sound_file", 0)

		if success == true then
			test_verify_txt.text = "play_sound = true."
		else
			test_verify_txt.text = "play_sound = false."
		end
	
		function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total >= 5 then
			idle.on_idle = nil
			local success = controller:stop_sound()
			if success == true then
				test_verify_txt.text = "stop_sound returned true."
			else
				test_verify_txt.text = "stop_sound returned false."
			end
	      end
	    end

  	else
		test_steps = "has_sound = false. Either confirm this device does not have one or that it is disabled."
		test_verify = "has_sound = false. Either confirm this device does not have one or that it is disabled."
 	 end

end

