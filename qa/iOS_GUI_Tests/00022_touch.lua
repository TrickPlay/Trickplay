
test_description = "Check that the down and up finger touches are being counted."
test_steps = "Tap on the screed 3 times.\n\nVerify it says Pass below."
test_verify = ""
test_group = "acceptance"
test_area = "touch"
test_api = "finger count"


function generate_device_image (controller, factory)
	local g = factory:Group{ x = 0, y = 0}

	local down_finger_count = 0
	local up_finger_count = 0
	local test_status = ""

 	if controller.has_touches then

		controller:start_touches()


		function check_result ()
			if down_finger_count == 3 and up_finger_count == 3 then
				test_status = "Pass"
				controller:stop_touches()
	

			end
		end

		function controller:on_touch_down(finger, x, y)


			down_finger_count = finger
			check_result()
		
			test_verify_txt.text = "Down finger count =\t"..down_finger_count.."\nUp finger count =\t\t"..up_finger_count.."\n\nTest status =\t"..test_status

		end

		function controller:on_touch_up(finger, x, y)

			up_finger_count = finger
			check_result()

			test_verify_txt.text = "Down finger count =\t"..down_finger_count.."\nUp finger count =\t\t"..up_finger_count.."\n\nTest status =\t"..test_status

		end

	end

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 310 * resize_ratio_w, h = 50 * resize_ratio_h, markup = "No comparison image for this test.", color = "FFFFFF", font = "Verdana 30px", use_markup = true}

	return t1
end


