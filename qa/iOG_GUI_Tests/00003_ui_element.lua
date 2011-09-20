
test_description = "Rotate 3 rectangles in x, y and z planes."
test_steps = "View the device.\nVerify that there are 9 rects rotated as following."
test_verify = "\t\t\t\t\t\tx\ty\tz\n1st Col Rects\tx_rotation\t\t20\t45\t80\n2nd Col Rects\ty_rotation\t\t20\t45\t80\n3rd Col Rects\tz_rotation\t\t20\t45\t80"
test_group = "smoke"
test_area = "ui_element"
test_api = "rotation"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "0070E0", x = 5, y =  10, size = { 60 , 60 }}

	r1.x_rotation = { 20, 30, 0  }

	local r2 = factory:Rectangle{color = "0070E0", x = 5, y =  100, size = {  60 , 60 }}

	r2.x_rotation = { 45, 30, 0  }

	local r3 = factory:Rectangle{color = "0070E0", x = 5, y = 190, size = { 60 , 60 }}

	r3.x_rotation = { 80, 30, 0  }

	local r4 = factory:Rectangle{color = "0070E0", x = 105, y =  10, size = { 60 , 60 }}

	r4.y_rotation = { 20, 30, 0  }

	local r5 = factory:Rectangle{color = "0070E0", x = 105, y =  100, size = {  60 , 60 }}

	r5.y_rotation = { 45, 30, 0  }

	local r6 = factory:Rectangle{color = "0070E0", x = 105, y = 190, size = { 60 , 60 }}

	r6.y_rotation = { 80, 30, 0  }

	local r7 = factory:Rectangle{color = "0070E0", x = 200, y =  10, size = { 60 , 60 }}

	r7.z_rotation = { 20, 30, 0  }

	local r8 = factory:Rectangle{color = "0070E0", x = 200, y =  100, size = {  60 , 60 }}

	r8.z_rotation = { 45, 30, 0  }

	local r9 = factory:Rectangle{color = "0070E0", x = 200, y = 190, size = { 60 , 60 }}

	r9.z_rotation = { 80, 30, 0  }


	g:add(r1, r2, r3, r4, r5, r6, r7, r8, r9)

	return g
end


	
