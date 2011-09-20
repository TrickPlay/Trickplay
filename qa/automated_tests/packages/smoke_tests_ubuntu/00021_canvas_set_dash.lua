
test_description = "Create a variety of dashed lines"
test_group = "smoke"
test_area = "canvas"
test_api = "set_dash"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)

	test_image:set_source_color({0, 0, 0, 255})
	
	local dashed_1 = { 20.0, 5.0 }
	
	local dashed_2 = { 20.0, 5.0, 20.0 }

	local dashed_3 = { 5.0 }

	local dashed_4 = { 5.0, 0 }  -- should be a regular line

	test_image.line_width = 10

	test_image:set_dash(0, dashed_1)
	test_image:move_to (200, screen.h/6 * 2)
	test_image:line_to (screen.w - 200, screen.h/6 * 2)
	test_image:stroke()

	test_image:set_dash(0, dashed_2)
	test_image:move_to (200, screen.h/6 * 3)
	test_image:line_to (screen.w - 200, screen.h/6 * 3)
	test_image:stroke()

	test_image:set_dash(0, dashed_3)
	test_image:move_to (200, screen.h/6 * 4)
	test_image:line_to (screen.w - 200, screen.h/6 * 4)
	test_image:stroke()

	test_image:set_dash(0, dashed_4)
	test_image:move_to (200, screen.h/6 * 5)
	test_image:line_to (screen.w - 200, screen.h/6 * 5)
	test_image:stroke()


	return test_image:Image ()

end















