test_steps = "View the device."
test_description = "Move a mid level square to the top level using raise_to_top"
test_verify = "Verify that the green rectangle is at the top."
test_group = "acceptance"
test_area = "ui_element"
test_api = "raise_to_top"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "00EB75", x = 110, y = 110, size = { 100 , 100 }}

	local r2 = factory:Rectangle{color = "FF3333", x = 120, y = 120, size = { 100 , 100 }}

	local r3 = factory:Rectangle{color = "0582FF", x = 130, y = 130, size = { 100 , 100 }}

	g:add(r1, r2, r3)
	r1:raise_to_top()

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local r1 = Rectangle{color = "00EB75", x = 110 * resize_ratio_w, y = 110 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }}

	local r2 = Rectangle{color = "FF3333", x = 120 * resize_ratio_w, y = 120 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }}

	local r3 = Rectangle{color = "0582FF", x = 130 * resize_ratio_w, y = 130 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }}

	g:add(r1, r2, r3)
	r1:raise_to_top()

	return g
end

	
