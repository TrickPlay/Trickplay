test_steps = "View the device."
test_description = "Check size and position of 3 simple rectangles."
test_verify = "* rect1 *\nposition = { 100, 100 }\nsize = { 200, 200 }\n* rect2 *\nposition = { 100, 400 }\nw = 50, h = 50\n* rect3 *\nposition = { 200, 100 }\nsize = { 50, 50 }\nis_visible = false"
test_group = "smoke"
test_area = "ui_element"
test_api = "size/position"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "0070E0", x = 100, y = 100, size = { 200 , 200 }}

	local r2 = factory:Rectangle{color = "0070E0", x = 100, y = 400, size = { 50 , 50 }}

	local r3 = factory:Rectangle{color = "0070E0", x = 200, y = 400, size = { 50 , 50 }}

	r3.is_visible = true

	g:add(r1, r2, r3)

	return g
end


	
