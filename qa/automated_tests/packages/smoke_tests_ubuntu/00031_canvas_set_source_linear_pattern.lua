
test_description = "Render a linear pattern rectangle"
test_group = "smoke"
test_area = "canvas"
test_api = "set_source_linear_pattern"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:set_source_linear_pattern (0, 100, 0, screen.h)
	test_image:add_source_pattern_color_stop (1, "000000")
	test_image:add_source_pattern_color_stop (0, "FFFFFF")
	test_image:rectangle (0, 100, screen.w, screen.h)
	test_image:fill ()

	return test_image:Image ()
end















