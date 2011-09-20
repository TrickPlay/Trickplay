
test_description = "Render a smile curve from coordinates."
test_group = "smoke"
test_area = "canvas"
test_api = "curve_to"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	local x = 25.6
	local y = 128
	local x1 = 102.4
	local x2 = 153.6
	local x3 = 230.4
	local y1 = 230.4
	local y2 = 25.6
	local y3 = 128

	test_image:translate (screen.w/2 - 300, screen.h/2 - 300)
	test_image:scale (3, 3)
	test_image:move_to (x,y)
	test_image:curve_to (x1, y1, x2, y2, x3, y3)
	test_image.line_width = 10
	test_image:stroke()
	
	test_image:set_source_color ("FF4646AA")
	test_image.line_width = 6
	test_image:move_to (x, y)
	test_image:line_to (x1, y1)
	test_image:move_to (x2, y2)
	test_image:line_to (x3, y3)	
	test_image:stroke()

	return test_image:Image ()
end















