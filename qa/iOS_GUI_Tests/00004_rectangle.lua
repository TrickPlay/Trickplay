
test_description = "Create 2 rectangles in a group that take up the entire viewable area."
test_steps = "View the device"
test_verify = " Verify 2 rectangles appear. A white one that takes up the whole area and a slightly smaller pink one that overlaps it."
test_group = "smoke"
test_area = "rectangle"
test_api = "basic"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "FF00FFFF", x = 10, y = 10, size = { 300 , 420 },border_color = "00FF00", border_width = 10}

	g:add(r1)

	return g
end


	
