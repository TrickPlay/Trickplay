
test_description = "Check that sound is playing."
test_steps = "Listen to the device."
test_verify = "Bark sound plays for 5 seconds and then is turned off."
test_group = "smoke"
test_area = "sound"
test_api = "play_sound/stop_sound"


function generate_device_image (controller, factory)

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

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 310 * resize_ratio_w, h = 50 * resize_ratio_h, markup = "No comparison image for this test.", color = "FFFFFF", font = "Verdana 30px", use_markup = true}

	return t1
end

