test_description = "Display a jpg image."
test_steps = "View the device"
test_verify = "Verify a progressive jpg image of a mechnical panda displays and it is resized to 100, 150."
test_group = "acceptance"
test_area = "set_ui_image - jpg"
test_api = "set_ui_image"


function generate_device_image (controller, factory)
	controller.screen:clear()
	controller:declare_resource("panda", "assets/medium_640x420_MQ_Progressive_panda.jpg")


	controller:set_ui_image ("panda", 20, 20, 150, 100 )
	return nil
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local image1 = Image {src = "assets/medium_640x420_panda.jpg", x = 20 * resize_ratio_w, y = 20 * resize_ratio_w, w = 150 * resize_ratio_h, h = 100 * resize_ratio_h, async = false }
	
	g:add(image1)

	return g
end



