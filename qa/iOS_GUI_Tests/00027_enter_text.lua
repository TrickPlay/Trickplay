
test_description = "Check that enter_text allows user to enter text and then saves result in callback."
test_steps = "Enter ABC123 in the enter text field."
test_verify = "Verify that:\n - The field appears with label 'Enter ABC100'\n - User can enter ABC123\n - Enter_text box disappears after hitting the done key.\n - Verify field says Pass.\n"
test_group = "acceptance"
test_area = "enter_text"
test_api = "enter_text"


function generate_device_image (controller, factory)
	local result
	function controller.on_ui_event (controller, text)
		if text == "ABC123" then
			result = "Pass"
		else
			result = "Fail"
		end
		test_verify_txt.text = test_verify.."\nEnter_text status = "..result
	end

-- bug 2024
	--local test_result = controller:enter_text ("Enter ABC123", "123")

-- workaround
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total > 1  then
		      controller:enter_text("Enter ABC123", "ABC")
				idle.on_idle = nil
		  end
	end	


	return nil
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 310 * resize_ratio_w, h = 50 * resize_ratio_h, markup = "Text dialog appears.", color = "FFFFFF", font = "Verdana 30px", use_markup = true}

	return t1
end

