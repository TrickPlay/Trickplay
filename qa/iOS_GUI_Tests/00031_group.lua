
test_description = "Find a ui element using find_child and remove it."
test_steps = "View the device"
test_verify = "Verify that there are only a blue and red rectangle."
test_group = "acceptance"
test_area = "group"
test_api = "find_child"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "FF3333", x = 10, y = 10, size = { 100 , 100 }, name = "red"}

	local r2 = factory:Rectangle{color = "00EB75", x = 10, y = 80, size = { 100 , 100 }, name = "green"}

	local r3 = factory:Rectangle{color = "0582FF", x = 10, y = 160, size = { 100 , 100 }, name = "blue"}

	g:add(r1, r2, r3)

	g:remove (g:find_child("green"))

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local r1 = Rectangle{color = "FF3333", x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }, name = "red"}

	local r2 = Rectangle{color = "00EB75", x = 10 * resize_ratio_w, y = 80 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }, name = "green"}

	local r3 = Rectangle{color = "0582FF", x = 10 * resize_ratio_w, y = 160 * resize_ratio_h, size = { 100 * resize_ratio_w , 100 * resize_ratio_h }, name = "blue"}

	g:add(r1, r2, r3)

	g:remove (g:find_child("green"))

	return g
end


	
