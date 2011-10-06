test_steps = "View the device."
test_description = "Move a mid level square to the top level using lower_to_bottom"
test_verify = "Verify that the red rectangle is at the top."
test_group = "acceptance"
test_area = "ui_element"
test_api = "lower_to_bottom"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "00EB75", x = 110, y = 110, size = { 100 , 100 }}

	local r2 = factory:Rectangle{color = "FF3333", x = 120, y = 120, size = { 100 , 100 }}

	local r3 = factory:Rectangle{color = "0582FF", x = 130, y = 130, size = { 100 , 100 }}

	g:add(r1, r2, r3)
	r3:lower_to_bottom()

	return g
end


	
