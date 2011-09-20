
test_description = "Check that sound plays correct number of times."
test_steps = "Listen to the device."
test_verify = "Bark sound plays 5 times."
test_group = "acceptance"
test_area = "sound"
test_api = "play_sound"


function generate_test_image (controller, factory)

	local total = 0
  	if controller.has_sound then
	     local remaining_time
		 controller:declare_resource("sound_file", "assets/barkpant.mp3")

		local success = controller:play_sound("sound_file", 5)

		if success == true then
			test_verify_txt.text = "play_sound = true."
		else
			test_verify_txt.text = "play_sound = false."
		end
	


  	else
		test_steps = "has_sound = false. Either confirm this device does not have one or that it is disabled."
		test_verify = "has_sound = false. Either confirm this device does not have one or that it is disabled."
 	 end

end

