test_description = "Display a jpg image."
test_steps = "View the device"
test_verify = "Verify an jpg image of a mechnical panda displays"
test_group = "smoke"
test_area = "image"
test_api = "src"


function generate_device_image (controller, factory)

	controller:declare_resource("panda", "assets/medium_640x420_panda.jpg")
	
	g = factory:Group{ x = 0, y = 0}

	local s = factory:Image{x = 20, y = 20, w = 300, h = 200, src = "panda"}
	
	g:add(s)

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local image1 = Image {src = "assets/medium_640x420_panda.jpg", x = 20 * resize_ratio_w, y = 20 * resize_ratio_w, w = 300 * resize_ratio_h, h = 200 * resize_ratio_h, async = false }
	
	g:add(image1)

	return g
end

