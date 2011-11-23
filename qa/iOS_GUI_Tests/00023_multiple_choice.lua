
test_description = "The multiple choice dialog appears and responds to touch."
test_steps = "Select New Jersey."
test_verify = "Verify there are 4 items: California, Texas, New York and New Jersey."
test_group = "acceptance"
test_area = "show_multiple_choice"
test_api = "show_multiple_choice"


function generate_test_image (controller, factory)


		function controller.on_ui_event (controller, text)
			test_verify_txt.text = test_verify_txt.text.."\n\nTest passed."
		end 	  

		controller:show_multiple_choice( "Pick a state. Any State? A state of your preference. No simple basic state. Maybe a stateless state?" , "a" , "California" , "b" , "Texas", "c", "New York", "d", "New Jersey")
		controller:hide_virtual_remote()


	return nil
end

