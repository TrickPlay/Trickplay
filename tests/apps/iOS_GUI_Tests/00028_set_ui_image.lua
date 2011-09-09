test_description = "Display a jpg image."
test_steps = "View the device"
test_verify = "Verify a progressive jpg image of a mechnical panda displays and it is resized to 100, 150."
test_group = "acceptance"
test_area = "set_ui_image - jpg"
test_api = "set_ui_image"


function generate_test_image (controller, factory)
	controller.screen:clear()
	controller:declare_resource("panda", "assets/medium_640x420_MQ_Progressive_panda.jpg")

	
	local r1 = factory:Rectangle{color = "00EB75", x = 15, y = 15, size = { 160 , 110 }}
	controller.screen:add(r1)
	r1:lower_to_bottom()
	controller:set_ui_image ("panda", 20, 20, 150, 100 )
	return nil
end

