test_description = "Populate the screen with text of various size, color and position"
test_steps = "View the device"
test_verify = " Verify that 2 images display - a small poker chip and a larger picture of a pandaS."
test_group = "smoke"
test_area = "text"
test_api = "basic"


function generate_test_image (controller, factory)

	controller:declare_resource("panda", "assets/medium_640x420_panda.jpg")

	g = factory:Group{ x = 0, y = 0}

	local s = factory:Image{x = 0, y = 110, w = 300, h = 100, src = "panda"}
	
	g:add(s)

	return g
end

