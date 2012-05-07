
test_description = "Create 3 rectangles. Make the top one half the size and the lower one double the size.  "
test_steps = "View the device."
test_verify = "3 boxes connected at the corners.\n* rect1 *\nposition = { 0, 0 }\nsize = { 40, 40 }\n* rect2 *\nposition = { 20, 20 }\nw = 40, h = 40\n* rect3 *\nposition = { 60, 60 }\nsize = { 40, 40 }"
test_group = "smoke"
test_area = "ui_element"
test_api = "scale"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "0070E0", x = 0, y =  0, size = { 40 , 40 }}

	r1.scale = { 0.5, 0.5 }

	local r2 = factory:Rectangle{color = "0070E0", x = 20, y =  20, size = { 40 , 40 }}

	local r3 = factory:Rectangle{color = "0070E0", x = 60, y = 60, size = { 40 , 40 }}

	r3.scale = { 2, 2 }


	g:add(r1, r2, r3)

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local r1 = Rectangle{color = "0070E0", x = 0, y =  0, size = { 40 * resize_ratio_w , 40 * resize_ratio_h }}

	r1.scale = { 0.5, 0.5 }

	local r2 = Rectangle{color = "0070E0", x = 20* resize_ratio_w , y =  20 * resize_ratio_h , size = { 40* resize_ratio_w  , 40 * resize_ratio_h }}

	local r3 = Rectangle{color = "0070E0", x = 60* resize_ratio_w , y = 60 * resize_ratio_h , size = { 40* resize_ratio_w  , 40 * resize_ratio_h  }}

	r3.scale = { 2, 2 }

	g:add(r1, r2, r3)

	return g
end


	
