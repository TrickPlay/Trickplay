
test_description = "Render a circle with a radial pattern"
test_group = "smoke"
test_area = "canvas"
test_api = "set_source_radial_pattern"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:set_source_linear_pattern (0, 100, 0, screen.h)
	test_image:add_source_pattern_color_stop (1, "000000")
	test_image:add_source_pattern_color_stop (0, "FFFFFF")
	test_image:rectangle (0, 100, screen.w, screen.h)
	test_image:fill ()

	test_image:translate (screen.w/2 - 200, screen.h/2 - 200)
	test_image:set_source_radial_pattern (200, 240, 30, 204, 204, 200)
	test_image:add_source_pattern_color_stop (1, "000000")
	test_image:add_source_pattern_color_stop (0, "FFFFFF")
	test_image:arc (256, 256, 128, 0, 360)
	test_image:fill()

	return test_image:Image ()
end















