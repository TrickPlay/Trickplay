test_description = "Display a jpg image."
test_steps = "View the device"
test_verify = "Verify an jpg image of a mechnical panda displays"
test_group = "smoke"
test_area = "image"
test_api = "src"


function generate_test_image (controller, factory)

	controller:declare_resource("panda", "assets/medium_640x420_panda.jpg")
	
	g = factory:Group{ x = 0, y = 0}

	local s = factory:Image{x = 20, y = 20, w = 300, h = 200, src = "panda"}
	
	g:add(s)

	return g
end

