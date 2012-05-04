
test_description = "Add and remove a group element"
test_steps = "View the device"
test_verify = "Verify that there are only 2 blue rectangles."
test_group = "smoke"
test_area = "group"
test_api = "add/remove"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "0070E0", x = 10, y = 10, size = { 100 , 100 }}

	local r2 = factory:Rectangle{color = "0070E0", x = 10, y = 140, size = { 100 , 100 }}

	local r3 = factory:Rectangle{color = "0070E0", x = 10, y = 270, size = { 100 , 100 }}

	g:add(r1, r2, r3)
	g:remove(r2)

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local r1 = Rectangle{color = "0070E0", x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, size = { 100 * resize_ratio_w, 100 * resize_ratio_h }}

	local r2 = Rectangle{color = "0070E0", x = 10 * resize_ratio_w, y = 140 * resize_ratio_h, size = { 100 * resize_ratio_w, 100 * resize_ratio_h }}

	local r3 = Rectangle{color = "0070E0", x = 10 * resize_ratio_w, y = 270 * resize_ratio_h, size = { 100 * resize_ratio_w, 100 * resize_ratio_h }}

	g:add(r1, r2, r3)

	g:remove(r2)

	return g
end

	
