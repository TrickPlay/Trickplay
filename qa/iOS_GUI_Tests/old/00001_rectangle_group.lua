
test_description = "Create 2 rectangles in a group that take up the entire viewable area."
test_steps = "View the device"
test_verify = " Verify 2 rectangles appear. A white one that takes up the whole area and a slightly smaller pink one that overlaps it."
test_group = "smoke"
test_area = "rectangle"
test_api = "basic"


function generate_test_image (controller)

	local g = controller:Group{ x = 0, y = 0}

	local r1 = controller:Rectangle{color = "FFFFFFFF", x = 0, y = 0, size = { 320 , 440 }, anchor_point = {0, 0}}

	local r2 = controller:Rectangle{color = "FF00FFFF", x = 10, y = 10, size = { 300 , 420 }, anchor_point = {0, 0}}

	g:add(r1, r2)

	return g
end


	
